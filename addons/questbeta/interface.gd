@tool
extends Control

var fichier = "user://bdd.json"

func in_list(item_list: ItemList, valeur: String) -> bool:
	for i in item_list.get_item_count():
		if item_list.get_item_text(i) == valeur:
			return true
	return false

func reloadQuete(fichier) :
	if FileAccess.file_exists(fichier):
		var file = FileAccess.open(fichier, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			for quete in parse_result :
				if not in_list($ItemList,parse_result[quete]["Titre"]) :
					#print(parse_result[quete]["Titre"])
					$ItemList.add_item(parse_result[quete]["Titre"])
					$ItemList.size.y += $ButtonAddQuest.size.y
					$ButtonSuprAll.position.y += $ButtonAddQuest.size.y
		else:
			push_warning("Le fichier existe mais ne contient pas un dictionnaire valide. Écrasement.")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reloadQuete(fichier)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	#if ($LineEditTitre.text == ""):
	#	$LabelErreur.show()
	#	$LabelErreur.text = "Aucun titre entrée !"
	#else :
	#	print($LineEditTitre.text)
	#	$LabelErreur.hide()
	#	$ItemList.add_item($LineEditTitre.text)
	#	$ItemList.size.y += $LineEditTitre.size.y
	#	Bdd.set_value($LineEditTitre.text,"Description","Vide")
	#	Bdd.save("res://bdd_quete.cfg")
		$Window.show()


func _on_button_supr_all_pressed() -> void:
	#Reset de la liste
	
	print("Bouton reset cliquer")
	$ItemList.clear()
	
	#Reset de la BDD 
	var quetes_vides = {}
	var json_string = JSON.stringify(quetes_vides)
	var file = FileAccess.open(fichier, FileAccess.ModeFlags.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("La base de données a été réinitialisée.")
	else:
		push_error("Impossible d'écrire dans le fichier : " + fichier)

func _on_window_close_requested() -> void:
	$Window.hide()
	#for data in Bdd.get_sections() :
	#	$ItemList.add_item(data)
	#	$ItemList.size.y += $LineEditTitre.size.y
	#	$ButtonSuprAll.position.y += $LineEditTitre.size.y
	reloadQuete(fichier)
