extends Node
## Main - Entry point do jogo
##
## Carrega a tela de título ao iniciar

func _ready() -> void:
	print("===========================================")
	print("   IAção - RPG Educacional com IA")
	print("   Versão 0.1.0")
	print("===========================================")

	# Go to title screen
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
