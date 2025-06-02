extends Control

func _ready():
	pass

func _on_jouer_pressed():
	print("Démarrage du jeu...")
	get_tree().change_scene_to_file("res://RPG-test/Monde.tscn")
	
func _on_credits_pressed():
	print("Ouverture des crédits...")
	DataBridge.audio_timing = $AudioStreamPlayer.get_playback_position()
	get_tree().change_scene_to_file("res://RPG-test/CreditsScreen.tscn")

func _on_quitter_pressed():
	print("Fermeture du jeu...")
	get_tree().quit()
