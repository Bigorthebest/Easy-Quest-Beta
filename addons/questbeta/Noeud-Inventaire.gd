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
	var nouveau_items = drop[2].split(",")
	objets.append_array(nouveau_items)
	afficher_inv()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
