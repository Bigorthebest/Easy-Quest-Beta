extends Control

func _ready():
	pass

func _on_retour_pressed():
	print("Retour au menu principal...")
	get_tree().change_scene_to_file("res://RPG-test/TitleScreen.tscn")

func _unhandled_input(event):
	# Permettre de revenir avec Échap
	if event.is_action_pressed("ui_cancel"):
		_on_retour_pressed()
