extends Control

func _ready():
	$AudioStreamPlayer.stop()
	await get_tree().create_timer(0.1).timeout
	$AudioStreamPlayer.seek(DataBridge.audio_timing)
	print(DataBridge.audio_timing)
	$AudioStreamPlayer.play()

func _on_retour_pressed():
	print("Retour au menu principal...")
	get_tree().change_scene_to_file("res://RPG-test/TitleScreen.tscn")

func _unhandled_input(event):
	# Permettre de revenir avec Échap
	if event.is_action_pressed("ui_cancel"):
		_on_retour_pressed()
