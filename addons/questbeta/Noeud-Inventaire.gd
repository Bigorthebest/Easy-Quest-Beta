extends Node

#Statistique utile 
var OR = 0 
var XP = 0 
var objets : Array

signal recompence

func afficher_inv() :
	print("======INVENTAIRE ACTUEL=======")
	print("OR : ",OR,"\nXP : ",XP)
	print("Inventaire du Joueurs :",objets)
	print("==============================")

#Appelé quand le joueurs reçoit une récompence par le Quete Manager
func _get_reward(drop) :
	OR += int(drop[0])
	XP += int(drop[1])
	objets.append(drop[2].split(","))
	afficher_inv()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
