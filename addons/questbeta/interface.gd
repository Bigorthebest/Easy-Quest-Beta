@tool
extends Control

var Bdd = ConfigFile.new()
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
					$ItemList.size.y += $LineEditTitre.size.y
					$ButtonSuprAll.position.y += $LineEditTitre.size.y
		else:
			push_warning("Le fichier existe mais ne contient pas un dictionnaire valide. Écrasement.")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#On essaye de charger les données d'une configurations existante 
	var err = Bdd.load("res://bdd_quete.cfg")
	if (err != OK):
		return
	else : 
		for data in Bdd.get_sections() :
			$ItemList.add_item(data)
			$ItemList.size.y += $LineEditTitre.size.y
			$ButtonSuprAll.position.y += $LineEditTitre.size.y
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
	print("Bouton reset cliquer")
	$ItemList.clear() 
	$ItemList.size.y = 0 
	for data in Bdd.get_sections() :
		Bdd.erase_section(data)
		print("section : ",data," supprimer")
	$ButtonSuprAll.position.y = 155
	Bdd.save("res://bdd_quete.cfg")
	print("Fin de suppression ?")


func _on_window_close_requested() -> void:
	$Window.hide()
	#for data in Bdd.get_sections() :
	#	$ItemList.add_item(data)
	#	$ItemList.size.y += $LineEditTitre.size.y
	#	$ButtonSuprAll.position.y += $LineEditTitre.size.y
	reloadQuete(fichier)
	
func _on_button_valider_pressed() -> void:
	if ($Window/LineEditTitre.text == ""):
		$Window/LabelErreur.show()
		$Window/LabelErreur.text = "Aucun titre entrée !"
	else :
		print($WIndow/LineEditTitre.text)
		$Window/LabelErreur.hide()
		$ItemList.add_item($Window/LineEditTitre.text)
		$ItemList.size.y += $Window/LineEditTitre.size.y
		Bdd.set_value($Window/LineEditTitre.text,$Window/LineEditDescription.text,"Vide")
		Bdd.save("res://bdd_quete.cfg")
		$Window.hide()
