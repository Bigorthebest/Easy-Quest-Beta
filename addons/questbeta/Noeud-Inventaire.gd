extends Node

#Statistique utile 
var OR = 0 
var XP = 0 
var objets : Array
var all_quete 

signal recompence

func afficher_inv() :
	print("======INVENTAIRE ACTUEL=======")
	print("OR : ",OR,"\nXP : ",XP)
	print("Inventaire du Joueurs :",objets)
	print("==============================")

func check_quete_items () :
	var compt = 0  
	for quete in all_quete : 
		if all_quete[quete]["ItemsDemandes"][0] != "" :
			for obj in objets : 
				if obj == all_quete[quete]["ItemsDemandes"][0] : 
					compt += 1 
					print("Il y a ", compt, all_quete[quete]["ItemsDemandes"][0] )
					if compt == int(all_quete[quete]["ItemsDemandes"][1]) :
						print("Quete d'objet ",all_quete[quete]["Titre"]," terminer !")
						get_parent()._update_quete_manager(all_quete[quete])
#Appelé quand le joueurs reçoit une récompence par le Quete Manager
func _get_reward(drop) :
	OR += int(drop[0])
	XP += int(drop[1])
	var nouveau_items = drop[2].split(",")
	objets.append_array(nouveau_items)
	afficher_inv()
	check_quete_items()
	
func _update_quete(quete) : 
	all_quete = quete
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
