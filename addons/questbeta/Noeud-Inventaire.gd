extends Node

#Statistique utile 
var OR = 0 
var XP = 0 
var objets : Array

signal recompence

var tableau_items = ["Cube","Pomme","Scarabée"]
var tableau_lien = ["res://RPG-test/items/Cube.tres","res://RPG-test/items/Pomme.tres","res://RPG-test/items/Bug.tres"]

# Référence à l'inventaire
@onready var inventory_ui = preload("res://RPG-test/InventoryUI.tscn")
var inventory_instance = null

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
	var i = 0 
	for items in nouveau_items :
		for tab in tableau_items : 
			if items == tab : 
				add_tres_inventaire(tableau_lien[i])
			i+= 1
	#Maj de l'or 
	add_tres_inventaire("res://RPG-test/items/Lambda-coin.tres",int(drop[0]))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		# Créer l'instance d'inventaire
	inventory_instance = inventory_ui.instantiate()
	# Utiliser call_deferred au lieu de add_child direct
	get_tree().root.call_deferred("add_child", inventory_instance)
	
	call_deferred("add_test_items") #Donne 3 pommes

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	# Ajouter un objet .tres à l'inventaire
func add_tres_inventaire(item_path: String, quantity: int = 1) -> bool:
	# Charger la ressource .tres
	var item_resource = load(item_path) as Item
	if item_resource == null:
		print("Erreur : Impossible de charger l'objet : ", item_path)
		return false

	# Vérifier que l'inventaire existe
	if inventory_instance == null:
		print("Erreur : Instance d'inventaire non trouvée")
		return false

	# Attendre que l'inventaire soit prêt
	if not inventory_instance.is_inside_tree():
		await get_tree().process_frame

	# Ajouter l'objet à l'inventaire
	var success = inventory_instance.add_item(item_resource, quantity)
	if success:
		print("Ajouté : ", item_resource.item_name, " x", quantity, " à l'inventaire")
	else:
		print("Échec : Inventaire plein ou erreur lors de l'ajout")

	return success

# Ajouter plusieurs objets .tres (pas encore essayé"
func add_multiple_tres_items(items_data: Array):
	for item_data in items_data:
		var path = item_data.get("path", "")
		var quantity = item_data.get("quantity", 1)
		if path != "":
			add_tres_inventaire(path, quantity)

func add_test_items():
	# Attendre que l'inventaire soit prêt
	if not inventory_instance or not inventory_instance.is_inside_tree():
		await get_tree().process_frame

	# Utiliser les objets .tres (chemin de la ressource + quantité)
	add_tres_inventaire("res://RPG-test/items/Pomme.tres", 3)
