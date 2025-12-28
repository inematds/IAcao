extends Interactable
class_name Door
## Door - Porta interativa que leva a outra área
##
## Combina interação com transição de área

@export var target_area: String = ""
@export var target_spawn: String = "default"
@export var locked: bool = false
@export var key_required: String = ""
@export var locked_message: String = "A porta está trancada."

func _ready() -> void:
	super._ready()
	interaction_text = "Entrar" if not locked else "Trancada"


func _on_interact(player: Node2D) -> void:
	if locked:
		if key_required != "" and _player_has_key(player):
			_unlock()
		else:
			_show_locked_message()
			end_interaction()
			return

	if target_area != "":
		print("[Door] Transitioning to: %s" % target_area)
		SceneManager.change_area(target_area, target_spawn)
	else:
		end_interaction()


func _player_has_key(player: Node2D) -> bool:
	# Check if player has required key in inventory
	# TODO: Implement inventory check
	return false


func _unlock() -> void:
	locked = false
	interaction_text = "Entrar"
	print("[Door] Door unlocked!")


func _show_locked_message() -> void:
	# TODO: Show message in UI
	print("[Door] %s" % locked_message)


func set_locked(value: bool, message: String = "") -> void:
	locked = value
	if message != "":
		locked_message = message
	interaction_text = "Trancada" if locked else "Entrar"
