extends CanvasLayer

@onready var quests_menu = preload("res://RPG-test/QuestsMenu.tscn")
var quests_menu_instance = null

var is_paused = false : set = set_paused

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):  # Échap
		# Si le menu quêtes est ouvert, ne pas gérer l'input ici
		if quests_menu_instance:
			return
		set_paused(!is_paused)

func set_paused(value: bool):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused
	
	if is_paused:
		print("Jeu en pause")
	else:
		print("Jeu repris")
		# Fermer le menu quêtes si ouvert
		if quests_menu_instance:
			quests_menu_instance.queue_free()
			quests_menu_instance = null

func _on_continuer_pressed():
	print("Bouton Continuer pressé")
	set_paused(false)

func _on_quetes_pressed():
	print("Bouton Quêtes pressé")
	if not quests_menu_instance:
		# NOUVEAU : Cacher le menu pause quand on ouvre le menu quêtes
		visible = false
		
		quests_menu_instance = quests_menu.instantiate()
		get_tree().root.add_child(quests_menu_instance)
		quests_menu_instance.quest_menu_closed.connect(_on_quest_menu_closed)

func _on_quitter_pressed():
	print("Bouton Quitter pressé")
	get_tree().quit()

func _on_quest_menu_closed():
	if quests_menu_instance:
		quests_menu_instance.queue_free()
		quests_menu_instance = null
		
		# NOUVEAU : Réafficher le menu pause quand le menu quêtes se ferme
		if is_paused:
			visible = true
