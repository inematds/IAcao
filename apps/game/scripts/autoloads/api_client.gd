extends Node
## APIClient - Cliente HTTP para comunicação com o backend
##
## Responsável por:
## - Requisições HTTP ao servidor
## - Autenticação OAuth e gerenciamento de tokens
## - Auto-refresh de tokens
## - Cache de respostas

# Signals
signal request_completed(response: Dictionary)
signal request_failed(error: String)
signal logged_in(user: Dictionary)
signal logged_out()
signal auth_error(message: String)

# Constants
const API_URL := "http://localhost:3000/api/v1"
const GAME_URL := "http://localhost:8080"
const TIMEOUT := 10.0
const TOKEN_REFRESH_MARGIN := 60  # Refresh token 60s before expiry

# State
var access_token := ""
var refresh_token := ""
var token_expires_at := 0
var is_authenticated := false
var current_user: Dictionary = {}

# HTTP client
var http_request: HTTPRequest
var refresh_timer: Timer

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	http_request = HTTPRequest.new()
	http_request.timeout = TIMEOUT
	add_child(http_request)

	refresh_timer = Timer.new()
	refresh_timer.one_shot = true
	refresh_timer.timeout.connect(_on_refresh_timer)
	add_child(refresh_timer)

	# Try to load saved tokens
	_load_saved_tokens()

	print("[APIClient] Initialized - API URL: ", API_URL)


# ===========================================
# Authentication - OAuth Flow
# ===========================================

func get_google_auth_url() -> String:
	return API_URL + "/auth/google"


func get_microsoft_auth_url() -> String:
	return API_URL + "/auth/microsoft"


func handle_auth_callback(url: String) -> bool:
	## Parse callback URL from OAuth flow
	## Returns true if authentication was successful

	if not url.begins_with(GAME_URL + "/auth/callback"):
		return false

	# Parse query parameters
	var query_start := url.find("?")
	if query_start == -1:
		auth_error.emit("URL de callback inválida")
		return false

	var query_string := url.substr(query_start + 1)
	var params := _parse_query_string(query_string)

	if params.has("accessToken") and params.has("refreshToken"):
		var expires_in := int(params.get("expiresIn", "900"))
		set_tokens(
			params["accessToken"],
			params["refreshToken"],
			expires_in
		)

		var is_new_user := params.get("isNewUser", "false") == "true"
		print("[APIClient] OAuth successful, new user: ", is_new_user)

		# Fetch user info
		await _fetch_current_user()
		return true
	else:
		var error_message := params.get("message", "Erro desconhecido na autenticação")
		auth_error.emit(error_message)
		return false


func _parse_query_string(query: String) -> Dictionary:
	var result := {}
	var pairs := query.split("&")
	for pair in pairs:
		var kv := pair.split("=")
		if kv.size() == 2:
			result[kv[0]] = kv[1].uri_decode()
	return result


# ===========================================
# Token Management
# ===========================================

func set_tokens(access: String, refresh: String, expires_in: int = 900) -> void:
	access_token = access
	refresh_token = refresh
	token_expires_at = int(Time.get_unix_time_from_system()) + expires_in
	is_authenticated = true

	# Save tokens
	_save_tokens()

	# Schedule refresh
	_schedule_token_refresh(expires_in)

	print("[APIClient] Tokens set, expires in %ds" % expires_in)


func clear_tokens() -> void:
	access_token = ""
	refresh_token = ""
	token_expires_at = 0
	is_authenticated = false
	current_user = {}

	refresh_timer.stop()

	# Clear saved tokens
	_clear_saved_tokens()

	logged_out.emit()
	print("[APIClient] Tokens cleared, user logged out")


func _schedule_token_refresh(expires_in: int) -> void:
	var refresh_in := max(expires_in - TOKEN_REFRESH_MARGIN, 10)
	refresh_timer.start(refresh_in)
	print("[APIClient] Token refresh scheduled in %ds" % refresh_in)


func _on_refresh_timer() -> void:
	print("[APIClient] Refreshing access token...")
	await refresh_access_token()


func get_auth_headers() -> PackedStringArray:
	var headers := PackedStringArray([
		"Content-Type: application/json"
	])
	if access_token != "":
		headers.append("Authorization: Bearer " + access_token)
	return headers


# ===========================================
# Token Persistence
# ===========================================

func _save_tokens() -> void:
	var data := {
		"access_token": access_token,
		"refresh_token": refresh_token,
		"expires_at": token_expires_at
	}
	SaveManager.save_secure_data("auth_tokens", data)


func _load_saved_tokens() -> void:
	var data := SaveManager.load_secure_data("auth_tokens")
	if data.is_empty():
		return

	var saved_access: String = data.get("access_token", "")
	var saved_refresh: String = data.get("refresh_token", "")
	var saved_expires: int = data.get("expires_at", 0)

	if saved_refresh == "":
		return

	var now := int(Time.get_unix_time_from_system())

	if saved_expires > now + TOKEN_REFRESH_MARGIN:
		# Token still valid
		access_token = saved_access
		refresh_token = saved_refresh
		token_expires_at = saved_expires
		is_authenticated = true
		_schedule_token_refresh(saved_expires - now)
		print("[APIClient] Loaded saved tokens, valid for %ds" % (saved_expires - now))

		# Fetch user info in background
		_fetch_current_user()
	elif saved_refresh != "":
		# Token expired but we have refresh token
		refresh_token = saved_refresh
		print("[APIClient] Saved token expired, refreshing...")
		refresh_access_token()


func _clear_saved_tokens() -> void:
	SaveManager.delete_secure_data("auth_tokens")


# ===========================================
# Generic HTTP Methods
# ===========================================

func _make_request(method: HTTPClient.Method, endpoint: String, body: Dictionary = {}, retry_on_401: bool = true) -> Dictionary:
	var url := API_URL + endpoint
	var headers := get_auth_headers()
	var body_str := JSON.stringify(body) if body.size() > 0 else ""

	print("[APIClient] %s %s" % [HTTPClient.Method.keys()[method], endpoint])

	var error := http_request.request(url, headers, method, body_str)
	if error != OK:
		push_error("[APIClient] Request failed to start: ", error)
		return {"success": false, "error": {"code": "REQUEST_FAILED", "message": "Failed to start request"}}

	var result = await http_request.request_completed

	var response_code: int = result[1]
	var response_body: PackedByteArray = result[3]
	var response_str := response_body.get_string_from_utf8()

	var json := JSON.new()
	var parse_error := json.parse(response_str)

	if parse_error != OK:
		push_error("[APIClient] Failed to parse JSON response")
		return {"success": false, "error": {"code": "PARSE_ERROR", "message": "Failed to parse response"}}

	var response: Dictionary = json.data

	# Handle 401 Unauthorized - try to refresh token
	if response_code == 401 and retry_on_401 and refresh_token != "":
		print("[APIClient] Got 401, attempting token refresh...")
		var refresh_result := await refresh_access_token()
		if refresh_result.get("success", false):
			# Retry the original request
			return await _make_request(method, endpoint, body, false)
		else:
			# Refresh failed, logout
			clear_tokens()
			auth_error.emit("Sessão expirada. Faça login novamente.")

	if response_code >= 400:
		print("[APIClient] Request failed with status: ", response_code)
		request_failed.emit(response.get("error", {}).get("message", "Unknown error"))
	else:
		request_completed.emit(response)

	return response


func get(endpoint: String) -> Dictionary:
	return await _make_request(HTTPClient.METHOD_GET, endpoint)


func post(endpoint: String, body: Dictionary = {}) -> Dictionary:
	return await _make_request(HTTPClient.METHOD_POST, endpoint, body)


func patch(endpoint: String, body: Dictionary = {}) -> Dictionary:
	return await _make_request(HTTPClient.METHOD_PATCH, endpoint, body)


func delete(endpoint: String) -> Dictionary:
	return await _make_request(HTTPClient.METHOD_DELETE, endpoint)


# ===========================================
# API Endpoints
# ===========================================

# Health check
func health_check() -> Dictionary:
	var url := API_URL.replace("/api/v1", "") + "/health"
	var http := HTTPRequest.new()
	add_child(http)
	http.timeout = 5.0

	var error := http.request(url)
	if error != OK:
		http.queue_free()
		return {"success": false}

	var result = await http.request_completed
	http.queue_free()

	var response_code: int = result[1]
	return {"success": response_code == 200}


# Auth
func refresh_access_token() -> Dictionary:
	var response := await post("/auth/refresh", {"refreshToken": refresh_token})

	if response.get("success", false):
		var data: Dictionary = response.get("data", {})
		set_tokens(
			data.get("accessToken", ""),
			data.get("refreshToken", refresh_token),
			data.get("expiresIn", 900)
		)

	return response


func logout() -> Dictionary:
	var response := await post("/auth/logout")
	clear_tokens()
	return response


func _fetch_current_user() -> void:
	var response := await get("/auth/me")
	if response.get("success", false):
		current_user = response.get("data", {})
		logged_in.emit(current_user)
		print("[APIClient] User info loaded: ", current_user.get("email", "unknown"))


func get_current_user() -> Dictionary:
	return current_user


# Game
func load_game() -> Dictionary:
	return await get("/game/load")


func save_game(game_state: Dictionary) -> Dictionary:
	return await post("/game/save", game_state)


func record_choice(choice_data: Dictionary) -> Dictionary:
	return await post("/game/choice", choice_data)


func complete_mission(mission_id: String, data: Dictionary) -> Dictionary:
	return await post("/game/mission/complete", {"missionId": mission_id, "data": data})


# AI (ARIA)
func query_aria(action: String, context: String = "", player_context: Dictionary = {}) -> Dictionary:
	var body := {
		"action": action,
		"additionalContext": context
	}
	if not player_context.is_empty():
		body["playerContext"] = player_context
	return await post("/ai/query", body)
