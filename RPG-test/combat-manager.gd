extends CanvasLayer

@export var player_party : Array[CombatCharacter] 
@export var enemy_party : Array[CombatCharacter] 

var current_turn = 0
var all_combatants = []

func _ready():
	all_combatants = player_party + enemy_party
	start_turn()

func start_turn():
	if all_combatants.all(func(c): return !c.is_alive()):
		print("Combat terminé.")
		return

	var current = all_combatants[current_turn % all_combatants.size()]
	if !current.is_alive():
		next_turn()
		return

	if current.is_player:
		show_player_choices(current)
	else:
		enemy_act(current)

func show_player_choices(character):
	print("C’est à", character.name, "de jouer.")
	#Affiche les boutons d'action (Attaquer, Soin, etc.) dans l’UI
	$ButtonAttaque.show()
	$ButtonBouclier.show()

func player_attack(target: CombatCharacter):
	var attacker = all_combatants[current_turn % all_combatants.size()]
	target.take_damage(attacker.attack_power)
	next_turn()

func enemy_act(character):
	#L'ennemi attaque un joueur au hasard
	var target = player_party.filter(func(p): return p.is_alive()).pick_random()
	if target:
		target.take_damage(character.attack_power)
	await get_tree().create_timer(1.0).timeout
	next_turn()

func next_turn():
	current_turn += 1
	start_turn()


func _on_button_bouclier_pressed() -> void:
	pass # Replace with function body.


func _on_button_attaque_pressed() -> void:
	pass # Replace with function body.
