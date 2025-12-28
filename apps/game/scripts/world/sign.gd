extends Interactable
class_name Sign
## Sign - Placa com texto para ler
##
## Mostra mensagem quando interagido

@export_multiline var sign_text: String = "Uma placa."
@export var sign_title: String = ""

func _ready() -> void:
	super._ready()
	interaction_text = "Ler"


func _on_interact(player: Node2D) -> void:
	print("[Sign] Showing text: %s" % sign_text)

	# TODO: Show dialogue/message UI with sign_text
	# For now, just print and end interaction
	_display_sign_text()

	# Auto-end after a delay (placeholder)
	await get_tree().create_timer(2.0).timeout
	end_interaction()


func _display_sign_text() -> void:
	# TODO: Integrate with dialogue system
	# This would show a simple message box with the sign text
	pass


func set_text(text: String, title: String = "") -> void:
	sign_text = text
	sign_title = title
