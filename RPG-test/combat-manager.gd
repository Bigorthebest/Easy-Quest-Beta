extends CanvasLayer

var current_turn = 0
var pj = preload("res://RPG-test/chevalier.gd")
var all_combatants = [pj.new()]

func _ready():
	start_turn()

func start_turn():
	if all_combatants.all(func(c): return !c.is_alive()):
		print("Combat terminé.")
		return

	if current_turn % 2 == 0 :
		show_player_choices(all_combatants[0])
	else:
		enemy_act(all_combatants[0])

func show_player_choices(character):
	print("C’est à", character.name, "de jouer.")
	#Affiche les boutons d'action (Attaquer, Soin, etc.) dans l’UI
	$ButtonAttaque.show()
	$ButtonBouclier.show()

func player_attack():
	next_turn()

func enemy_act(character):
	#L'ennemi attaque un joueur au hasard
	await(1)
	all_combatants[0].degat(10)
	next_turn()

func next_turn():
	current_turn += 1
	start_turn()
	
func resolve_player_turn():
	$ButtonAttaque.hide()
	$ButtonBouclier.hide()
	next_turn()

func _on_button_bouclier_pressed() -> void:
	print("Coup de bouclier")
	resolve_player_turn()


func _on_button_attaque_pressed() -> void:
	print("Coup de sabre")
	resolve_player_turn()
