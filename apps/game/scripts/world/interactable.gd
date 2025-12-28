extends Area2D
class_name Interactable
## Interactable - Base class for interactive objects
##
## Provides:
## - Player detection
## - Interaction handling
## - Visual feedback

# Signals
signal interacted(player: Node2D)
signal player_entered()
signal player_exited()

# Configuration
@export var interaction_text: String = "Interagir"
@export var requires_facing: bool = true
@export var one_time_use: bool = false
@export var enabled: bool = true

# Visual feedback
@export var highlight_color: Color = Color(1, 1, 0.8, 0.3)
@export var show_indicator: bool = true

# State
var player_nearby: bool = false
var has_been_used: bool = false
var player_ref: Node2D = null

# Nodes
var highlight: ColorRect
var indicator: Label

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	add_to_group("interactables")

	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Setup visual feedback
	_setup_highlight()
	_setup_indicator()


func _setup_highlight() -> void:
	# Create highlight overlay for when player is near
	highlight = ColorRect.new()
	highlight.name = "Highlight"
	highlight.color = highlight_color
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	highlight.visible = false

	# Match parent size if possible
	if get_parent() is Control:
		highlight.set_anchors_preset(Control.PRESET_FULL_RECT)
	else:
		# Use collision shape bounds
		var collision := _get_collision_shape()
		if collision and collision.shape:
			var shape_size := _get_shape_size(collision.shape)
			highlight.size = shape_size
			highlight.position = -shape_size / 2

	add_child(highlight)
	move_child(highlight, 0)  # Put behind other children


func _setup_indicator() -> void:
	if not show_indicator:
		return

	indicator = Label.new()
	indicator.name = "InteractionIndicator"
	indicator.text = "[E] " + interaction_text
	indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	indicator.add_theme_color_override("font_color", Color(1, 1, 0.9, 1))
	indicator.add_theme_font_size_override("font_size", 12)
	indicator.visible = false

	# Position above the object
	indicator.position = Vector2(-50, -40)
	indicator.size = Vector2(100, 20)

	add_child(indicator)


func _get_collision_shape() -> CollisionShape2D:
	for child in get_children():
		if child is CollisionShape2D:
			return child
	return null


func _get_shape_size(shape: Shape2D) -> Vector2:
	if shape is RectangleShape2D:
		return shape.size
	elif shape is CircleShape2D:
		return Vector2(shape.radius * 2, shape.radius * 2)
	return Vector2(32, 32)


# ===========================================
# Player Detection
# ===========================================

func _on_body_entered(body: Node2D) -> void:
	if not enabled:
		return

	if body.is_in_group("player"):
		player_nearby = true
		player_ref = body
		_show_feedback()

		# Register with player
		if body.has_method("register_interactable"):
			body.register_interactable(self)

		player_entered.emit()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		player_ref = null
		_hide_feedback()

		# Unregister from player
		if body.has_method("unregister_interactable"):
			body.unregister_interactable(self)

		player_exited.emit()


# ===========================================
# Interaction
# ===========================================

func interact(player: Node2D) -> void:
	if not enabled:
		return

	if one_time_use and has_been_used:
		return

	print("[Interactable] %s interacted by player" % name)
	has_been_used = true
	interacted.emit(player)

	# Override _on_interact in subclasses for custom behavior
	_on_interact(player)


func _on_interact(player: Node2D) -> void:
	# Override in subclasses
	pass


func end_interaction() -> void:
	if player_ref and player_ref.has_method("end_interaction"):
		player_ref.end_interaction()


# ===========================================
# Visual Feedback
# ===========================================

func _show_feedback() -> void:
	if highlight:
		highlight.visible = true

	if indicator and show_indicator:
		indicator.visible = true


func _hide_feedback() -> void:
	if highlight:
		highlight.visible = false

	if indicator:
		indicator.visible = false


# ===========================================
# State Management
# ===========================================

func set_enabled(value: bool) -> void:
	enabled = value
	if not enabled and player_nearby:
		_hide_feedback()


func reset() -> void:
	has_been_used = false


func is_available() -> bool:
	if not enabled:
		return false
	if one_time_use and has_been_used:
		return false
	return true
