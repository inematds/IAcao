extends Node2D
class_name AreaBase
## AreaBase - Classe base para todas as áreas do jogo
##
## Responsável por:
## - Gerenciar transições de área
## - Configurar spawn points
## - Gerenciar entidades da área

# Area info
@export var area_id: String = ""
@export var area_name: String = ""
@export var region: String = "vila_esperanca"

# Spawn points
@export var spawn_points: Dictionary = {}  # spawn_id -> Vector2
@export var default_spawn: String = "default"

# References
@onready var tilemap: TileMap = $TileMap if has_node("TileMap") else null
@onready var entities: Node2D = $Entities if has_node("Entities") else null
@onready var triggers: Node2D = $Triggers if has_node("Triggers") else null

# Signals
signal area_entered(area_id: String)
signal area_exited(area_id: String)
signal transition_requested(target_area: String, target_spawn: String)

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	add_to_group("areas")
	_setup_spawn_points()
	_on_area_ready()
	print("[Area] %s ready" % area_name)


func _on_area_ready() -> void:
	# Override in subclasses for area-specific setup
	pass


# ===========================================
# Spawn Points
# ===========================================

func _setup_spawn_points() -> void:
	# Auto-discover spawn points from child nodes
	for child in get_children():
		if child.name.begins_with("SpawnPoint_"):
			var spawn_id := child.name.replace("SpawnPoint_", "")
			spawn_points[spawn_id] = child.position
			print("[Area] Registered spawn point: %s at %s" % [spawn_id, child.position])


func get_spawn_position(spawn_id: String = "") -> Vector2:
	if spawn_id == "" or spawn_id == "default":
		spawn_id = default_spawn

	if spawn_points.has(spawn_id):
		return spawn_points[spawn_id]

	# Fallback to first spawn point or center
	if spawn_points.size() > 0:
		return spawn_points.values()[0]

	return Vector2(640, 360)  # Center of 1280x720


# ===========================================
# Player Management
# ===========================================

func spawn_player(spawn_id: String = "") -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.position = get_spawn_position(spawn_id)
		print("[Area] Player spawned at %s" % player.position)


# ===========================================
# Transitions
# ===========================================

func request_transition(target_area: String, target_spawn: String = "default") -> void:
	transition_requested.emit(target_area, target_spawn)


# ===========================================
# Area Events
# ===========================================

func on_player_enter() -> void:
	GameManager.current_area = area_id
	area_entered.emit(area_id)
	print("[Area] Player entered: %s" % area_name)


func on_player_exit() -> void:
	area_exited.emit(area_id)
	print("[Area] Player exited: %s" % area_name)
