extends Control

func _ready():
	# Arrêter la musique du monde si elle joue
	if MusicManager:
		MusicManager.stop_music()

func _on_jouer_pressed():
	print("Démarrage du jeu...")
	# Démarrer la musique du monde avant de changer de scène
	if MusicManager:
		MusicManager.play_main_music()
	get_tree().change_scene_to_file("res://RPG-test/Monde.tscn")

func _on_credits_pressed():
	print("Ouverture des crédits...")
	get_tree().change_scene_to_file("res://RPG-test/CreditsScreen.tscn")

func _on_quitter_pressed():
	print("Fermeture du jeu...")
	get_tree().quit()
