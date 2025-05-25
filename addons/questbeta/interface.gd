@tool
extends Control

var fichier = "user://bdd.json"

func in_list(item_list: ItemList, valeur: String) -> bool:
	for i in item_list.get_item_count():
		if item_list.get_item_text(i) == valeur:
			return true
	return false

func reloadQuete(fichier):
	$ItemList.clear()  # Vider la liste avant de la recharger
	
	if FileAccess.file_exists(fichier):
		var file = FileAccess.open(fichier, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			for quete in parse_result:
				var quete_data = parse_result[quete]
				var titre = quete_data["Titre"]
				var active = quete_data.get("Active", true)
				var statut = " [ACTIVE]" if active else " [INACTIVE]"
				
				$ItemList.add_item(titre + statut)
				
				var item_index = $ItemList.get_item_count() - 1
				if not active:
					$ItemList.set_item_custom_fg_color(item_index, Color.GRAY)
		else:
			push_warning("Le fichier existe mais ne contient pas un dictionnaire valide.")

# afficher les détails d'une quête  (sous la liste)je pense qu'il faudrait en faire une autre fenêtre mais bon
func _on_item_list_item_selected(index: int) -> void:
	var nom_quete = $ItemList.get_item_text(index).split(" [")[0]  # Enlever le statut
	afficher_details_quete(nom_quete)

func afficher_details_quete(nom_quete: String):
	if FileAccess.file_exists(fichier):
		var file = FileAccess.open(fichier, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			for quete in parse_result:
				if parse_result[quete]["Titre"] == nom_quete:
					var quete_data = parse_result[quete]
			
					if has_node("LabelDescription"):
						$LabelDescription.text = "Description: " + quete_data.get("Description", "Aucune")
					if has_node("LabelRecompense"):
						$LabelRecompense.text = "Récompense: " + quete_data.get("Recompense", "Aucune")
					if has_node("LabelActive"):
						var active = quete_data.get("Active", true)
						$LabelActive.text = "Statut: " + ("Active" if active else "Inactive")
					if has_node("LabelQueteSuivante"):
						$LabelQueteSuivante.text = "Quête suivante: " + quete_data.get("QueteSuivante", "Aucune")
					
					print("=== DÉTAILS DE LA QUÊTE ===")
					print("Titre: ", quete_data["Titre"])
					print("Description: ", quete_data.get("Description", "Aucune"))
					print("Récompense: ", quete_data.get("Recompense", "Aucune"))
					print("Active: ", quete_data.get("Active", true))
					print("Quête suivante: ", quete_data.get("QueteSuivante", "Aucune"))
					print("========================")
					break

func _ready() -> void:
	reloadQuete(fichier)
	# connecter le signal de sélection d'item
	if not $ItemList.item_selected.is_connected(_on_item_list_item_selected):
		$ItemList.item_selected.connect(_on_item_list_item_selected)

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
	
	# effacer les détails affichés
	if has_node("LabelDescription"):
		$LabelDescription.text = "Description: "
	if has_node("LabelRecompense"):
		$LabelRecompense.text = "Récompense: "
	if has_node("LabelActive"):
		$LabelActive.text = "Statut: "
	if has_node("LabelQueteSuivante"):
		$LabelQueteSuivante.text = "Quête suivante: "
	
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
