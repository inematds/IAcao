extends Node
## APIClient - Cliente HTTP para comunicação com o backend
##
## Responsável por:
## - Requisições HTTP ao servidor
## - Autenticação e tokens
## - Cache de respostas

# Signals
signal request_completed(response: Dictionary)
signal request_failed(error: String)
signal logged_in()
signal logged_out()

# Constants
const API_URL := "http://localhost:3000/api/v1"
const TIMEOUT := 10.0

# State
var access_token := ""
var refresh_token := ""
var is_authenticated := false

# HTTP client
var http_request: HTTPRequest

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	http_request = HTTPRequest.new()
	http_request.timeout = TIMEOUT
	add_child(http_request)
	print("[APIClient] Initialized - API URL: ", API_URL)


# ===========================================
# Authentication
# ===========================================

func set_tokens(access: String, refresh: String) -> void:
	access_token = access
	refresh_token = refresh
	is_authenticated = true
	logged_in.emit()
	print("[APIClient] Tokens set, user authenticated")


func clear_tokens() -> void:
	access_token = ""
	refresh_token = ""
	is_authenticated = false
	logged_out.emit()
	print("[APIClient] Tokens cleared, user logged out")


func get_auth_headers() -> PackedStringArray:
	var headers := PackedStringArray([
		"Content-Type: application/json"
	])
	if access_token != "":
		headers.append("Authorization: Bearer " + access_token)
	return headers


# ===========================================
# Generic HTTP Methods
# ===========================================

func _make_request(method: HTTPClient.Method, endpoint: String, body: Dictionary = {}) -> Dictionary:
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
	return await get("/health")


# Auth
func refresh_access_token() -> Dictionary:
	return await post("/auth/refresh", {"refreshToken": refresh_token})


func logout() -> Dictionary:
	var response := await post("/auth/logout")
	clear_tokens()
	return response


# User
func get_current_user() -> Dictionary:
	return await get("/users/me")


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
func query_aria(action: String, context: String = "") -> Dictionary:
	return await post("/ai/query", {"action": action, "additionalContext": context})
