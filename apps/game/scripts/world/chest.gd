extends Interactable
class_name Chest
## Chest - Baú que pode conter itens
##
## Pode ser aberto uma vez para obter itens

signal item_obtained(item_id: String, quantity: int)

@export var item_id: String = ""
@export var item_quantity: int = 1
@export var is_open: bool = false

# Visual nodes (set in scene)
@export var closed_sprite: Node2D
@export var open_sprite: Node2D

func _ready() -> void:
	super._ready()
	one_time_use = true
	interaction_text = "Abrir"
	_update_visual()


func _on_interact(player: Node2D) -> void:
	if is_open:
		end_interaction()
		return

	is_open = true
	_update_visual()

	print("[Chest] Opened! Contains: %s x%d" % [item_id, item_quantity])

	if item_id != "":
		# TODO: Add item to player inventory
		item_obtained.emit(item_id, item_quantity)
		_show_item_obtained()

	# Brief delay before ending
	await get_tree().create_timer(1.0).timeout
	end_interaction()


func _update_visual() -> void:
	if closed_sprite:
		closed_sprite.visible = not is_open
	if open_sprite:
		open_sprite.visible = is_open

	# Update indicator
	if is_open:
		interaction_text = "Vazio"
		enabled = false


func _show_item_obtained() -> void:
	# TODO: Show item obtained UI
	pass


func reset() -> void:
	super.reset()
	is_open = false
	enabled = true
	interaction_text = "Abrir"
	_update_visual()
