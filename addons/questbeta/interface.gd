@tool
extends Control

var fichier = "user://bdd.json"
var quete_en_modification = null # pour tracker la quête en cours de modification
var toutes_les_quetes = {} # pour stocker toutes les quêtes

#Pour expoter les quetes 
@onready var file_export := $FileExport
@onready var file_import := $FileImport

func in_list(item_list: ItemList, valeur: String) -> bool:
	for i in item_list.get_item_count():
		if item_list.get_item_text(i) == valeur:
			return true
	return false

func reloadQuete(fichier):
	get_itemlist().clear() # Vider la liste avant de la recharger
	
	if FileAccess.file_exists(fichier):
		var file = FileAccess.open(fichier, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			toutes_les_quetes = parse_result # sauvegarder toutes les quêtes
			afficher_quetes(parse_result)
		else:
			push_warning("Le fichier existe mais ne contient pas un dictionnaire valide.")

# Helper function pour obtenir l'ItemList
func get_itemlist() -> ItemList:
	return $MainContainer/QuestListContainer/ItemList

# Helper function pour obtenir la barre de recherche
func get_search_bar() -> LineEdit:
	return $MainContainer/QuestListContainer/ListHeaderContainer/LineEditRecherche

# Helper function pour obtenir le bouton modifier
func get_modifier_button() -> Button:
	return $MainContainer/QuestListContainer/ListButtonsContainer/ButtonModifier

# Helper function pour obtenir le bouton supprimer
func get_supprimer_button() -> Button:
	return $MainContainer/TopButtonsContainer/ButtonSupprimer

# afficher les quêtes (avec ou sans filtre)
func afficher_quetes(quetes_a_afficher: Dictionary):
	get_itemlist().clear()
	
	for quete in quetes_a_afficher:
		var quete_data = quetes_a_afficher[quete]
		var titre = quete_data["Titre"]
		var active = quete_data.get("Active", true)
		var statut = " [ACTIVE]" if active else " [INACTIVE]"
		
		get_itemlist().add_item(titre)
		
		# changer la couleur selon le statut
		var item_index = get_itemlist().get_item_count() - 1
		if not active:
			get_itemlist().set_item_custom_fg_color(item_index, Color.GRAY)

# filtrer les quêtes selon la recherche
func filtrer_quetes(texte_recherche: String) -> Dictionary:
	if texte_recherche == "":
		return toutes_les_quetes
	
	var quetes_filtrees = {}
	texte_recherche = texte_recherche.to_lower()
	
	for quete_id in toutes_les_quetes:
		var quete_data = toutes_les_quetes[quete_id]
		var titre = quete_data["Titre"].to_lower()
		
		# vérifier si le texte de recherche est présent dans le titre
		if texte_recherche in titre:
			quetes_filtrees[quete_id] = quete_data
		else:
			# vérifier chaque mot du titre
			var mots_titre = titre.split(" ")
			for mot in mots_titre:
				if texte_recherche in mot:
					quetes_filtrees[quete_id] = quete_data
					break
	
	return quetes_filtrees

# Nouvelle fonction appelée quand le texte de recherche change
func _on_line_edit_recherche_text_changed(new_text: String) -> void:
	var quetes_filtrees = filtrer_quetes(new_text)
	afficher_quetes(quetes_filtrees)
	
	# désactiver les boutons si aucune quête n'est sélectionnée après filtrage
	if get_itemlist().get_item_count() == 0:
		get_modifier_button().disabled = true
		get_supprimer_button().disabled = true
	
	print("Recherche : '", new_text, "' - ", quetes_filtrees.size(), " quête(s) trouvée(s)")

# afficher les détails d'une quête (sous la liste)je pense qu'il faudrait en faire une autre fenêtre mais bon
func _on_item_list_item_selected(index: int) -> void:
	var nom_quete = get_itemlist().get_item_text(index).split(" [")[0] # Enlever le statut
	afficher_details_quete(nom_quete)
	
	# activer les boutons modifier et supprimer quand une quête est sélectionnée
	get_modifier_button().disabled = false
	get_supprimer_button().disabled = false

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
					
					if has_node("MainContainer/QuestDetailsContainer/LabelDescription"):
						$MainContainer/QuestDetailsContainer/LabelDescription.text = "Description: " + quete_data.get("Description", "Aucune")
					if has_node("MainContainer/QuestDetailsContainer/LabelRecompense"):
						var recompense = quete_data.get("Recompense", "Aucune")
						if typeof(recompense) == TYPE_ARRAY and recompense.size() > 2:
							$MainContainer/QuestDetailsContainer/LabelRecompense.text = "Récompense: " + str(recompense[2])
						else:
							$MainContainer/QuestDetailsContainer/LabelRecompense.text = "Récompense: " + str(recompense)
					if has_node("MainContainer/QuestDetailsContainer/LabelActive"):
						var active = quete_data.get("Active", true)
						$MainContainer/QuestDetailsContainer/LabelActive.text = "Statut: " + ("Active" if active else "Inactive")
					if has_node("MainContainer/QuestDetailsContainer/LabelQueteSuivante"):
						$MainContainer/QuestDetailsContainer/LabelQueteSuivante.text = "Quête suivante: " + quete_data.get("QueteSuivante", "Aucune")
					if has_node("MainContainer/QuestDetailsContainer/LabelTimeline"):
						$MainContainer/QuestDetailsContainer/LabelTimeline.text = "Timeline: " + quete_data.get("Timeline", "Aucune")
					if has_node("MainContainer/QuestDetailsContainer/LabelOr") :
						var recompense = quete_data.get("Recompense", "Aucune")
						if typeof(recompense) == TYPE_ARRAY and recompense.size() > 0:
							$MainContainer/QuestDetailsContainer/LabelOr.text = "Or : " + str(recompense[0])
						else:
							$MainContainer/QuestDetailsContainer/LabelOr.text = "Or : 0"
					if has_node("MainContainer/QuestDetailsContainer/LabelXp") :
						var recompense = quete_data.get("Recompense", "Aucune")
						if typeof(recompense) == TYPE_ARRAY and recompense.size() > 1:
							$MainContainer/QuestDetailsContainer/LabelXp.text = "Xp : " + str(recompense[1])
						else:
							$MainContainer/QuestDetailsContainer/LabelXp.text = "Xp : 0"
					
					print("=== DÉTAILS DE LA QUÊTE ===")
					print("Titre: ", quete_data["Titre"])
					print("Description: ", quete_data.get("Description", "Aucune"))
					print("Récompense: ", quete_data.get("Recompense", "Aucune"))
					print("Active: ", quete_data.get("Active", true))
					print("Quête suivante: ", quete_data.get("QueteSuivante", "Aucune"))
					print("Timeline: ", quete_data.get("Timeline", "Aucune"))
					print("Items Demandés: ", quete_data.get("ItemsDemandes","Aucune"))
					print("========================")
					break

# charger une quête dans la fenêtre de modification
func charger_quete_pour_modification(nom_quete: String):
	if FileAccess.file_exists(fichier):
		var file = FileAccess.open(fichier, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			for quete in parse_result:
				if parse_result[quete]["Titre"] == nom_quete:
					var quete_data = parse_result[quete]
					
					quete_en_modification = nom_quete
					
					# remplir la fenêtre avec les données existantes
					$Window/LineEditTitre.text = quete_data["Titre"]
					$Window/LineEditDescription.text = quete_data["Description"]
					$Window/CheckBoxActive.button_pressed = quete_data.get("Active", true)
					
					var recompense = quete_data.get("Recompense", "")
					if typeof(recompense) == TYPE_ARRAY and recompense.size() > 2:
						$Window/LineEditRecompense.text = str(recompense[2])
					else:
						$Window/LineEditRecompense.text = str(recompense)
					
					$Window/LineEditQueteSuivante.text = quete_data.get("QueteSuivante", "")
					$Window/LineEditTimeline.text = quete_data.get("Timeline", "") # NOUVEAU CHAMP
					
					if typeof(recompense) == TYPE_ARRAY and recompense.size() > 1:
						$Window/SpinBoxOr.value = recompense[0] if recompense.size() > 0 else 0
						$Window/SpinBoxXp.value = recompense[1] if recompense.size() > 1 else 0
					else:
						$Window/SpinBoxOr.value = 0
						$Window/SpinBoxXp.value = 0
					
					$Window/Label.text = "Menu de modification de quête :"
					$Window/ButtonValider.text = "Modifier"
					
					var itemWanted =  quete_data.get("ItemsDemandes","")
					if itemWanted[0] != "" :
						$Window/CheckBoxItemsWanted.button_pressed = true 
						$Window/LineEditItemsWanted.text = itemWanted[0]
						$Window/SpinBoxNbrItem.value = itemWanted[1]
					
					$Window.show()
					break

# supprimer une quête
func supprimer_quete(nom_quete: String):
	if FileAccess.file_exists(fichier):
		var file = FileAccess.open(fichier, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			# Trouver et supprimer la quête
			for quete_id in parse_result:
				if parse_result[quete_id]["Titre"] == nom_quete:
					parse_result.erase(quete_id)
					print("Quête supprimée : ", nom_quete)
					break
			
			# Réécrire le fichier JSON
			var file_write = FileAccess.open(fichier, FileAccess.ModeFlags.WRITE)
			file_write.store_string(JSON.stringify(parse_result, "\t"))
			file_write.close()
			
			reloadQuete(fichier)
			
			# effacer les détails affichés
			if has_node("MainContainer/QuestDetailsContainer/LabelDescription"):
				$MainContainer/QuestDetailsContainer/LabelDescription.text = "Description: "
			if has_node("MainContainer/QuestDetailsContainer/LabelRecompense"):
				$MainContainer/QuestDetailsContainer/LabelRecompense.text = "Récompense: "
			if has_node("MainContainer/QuestDetailsContainer/LabelActive"):
				$MainContainer/QuestDetailsContainer/LabelActive.text = "Statut: "
			if has_node("MainContainer/QuestDetailsContainer/LabelQueteSuivante"):
				$MainContainer/QuestDetailsContainer/LabelQueteSuivante.text = "Quête suivante: "
			if has_node("MainContainer/QuestDetailsContainer/LabelTimeline"):
				$MainContainer/QuestDetailsContainer/LabelTimeline.text = "Timeline: "
			if has_node("MainContainer/QuestDetailsContainer/LabelOr") :
				$MainContainer/QuestDetailsContainer/LabelOr.text = "Or :"
			if has_node("MainContainer/QuestDetailsContainer/LabelXp") :
				$MainContainer/QuestDetailsContainer/LabelXp.text = "Xp :"
			
			# désactiver les boutons
			get_modifier_button().disabled = true
			get_supprimer_button().disabled = true

func _ready() -> void:
	reloadQuete(fichier)
	# connecter le signal de sélection d'item
	if not get_itemlist().item_selected.is_connected(_on_item_list_item_selected):
		get_itemlist().item_selected.connect(_on_item_list_item_selected)
	
	# connecter le signal de recherche
	if not get_search_bar().text_changed.is_connected(_on_line_edit_recherche_text_changed):
		get_search_bar().text_changed.connect(_on_line_edit_recherche_text_changed)
	
	# désactiver les boutons au démarrage
	get_modifier_button().disabled = true
	get_supprimer_button().disabled = true
	
	#Config pour export 
	file_export.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_export.access = FileDialog.ACCESS_FILESYSTEM
	file_export.set_filters(["*.txt", "*.json"]) 
	file_export.title = "Exporter vos quêtes sous forme de fichier"
	file_export.ok_button_text = "Enregistrer"
	file_export.file_selected.connect(_on_file_selected_to_save)
	#Config pour import 
	file_import.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_import.access = FileDialog.ACCESS_FILESYSTEM
	file_import.set_filters(["*.txt", "*.json"])
	file_import.title = "Importer un fichier de quêtes"
	file_import.ok_button_text = "Importer"
	file_import.file_selected.connect(_on_file_selected_to_open)

func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	# Réinitialiser la fenêtre pour création
	quete_en_modification = null
	$Window/Label.text = "Menu de création de quêtes :"
	$Window/ButtonValider.text = "Valider"
	
	# Vider les champs
	$Window/LineEditTitre.text = ""
	$Window/LineEditDescription.text = ""
	$Window/CheckBoxActive.button_pressed = true
	$Window/LineEditRecompense.text = ""
	$Window/LineEditQueteSuivante.text = ""
	$Window/LineEditTimeline.text = "" # NOUVEAU CHAMP
	$Window/LabelErreur.text = ""
	$Window/LineEditItemsWanted.text = ""
	$Window/SpinBoxNbrItem.value = 0 
	$Window/SpinBoxOr.value = 0 
	$Window/SpinBoxXp.value = 0 
	
	#if ($LineEditTitre.text == ""):
	# $LabelErreur.show()
	# $LabelErreur.text = "Aucun titre entrée !"
	#else :
	# print($LineEditTitre.text)
	# $LabelErreur.hide()
	# $ItemList.add_item($LineEditTitre.text)
	# $ItemList.size.y += $LineEditTitre.size.y
	# Bdd.set_value($LineEditTitre.text,"Description","Vide")
	# Bdd.save("res://bdd_quete.cfg")
	
	$Window.show()

# fonction pour le bouton modifier
func _on_button_modifier_pressed() -> void:
	var selected_index = get_itemlist().get_selected_items()
	if selected_index.size() > 0:
		var nom_quete = get_itemlist().get_item_text(selected_index[0]).split(" [")[0]
		charger_quete_pour_modification(nom_quete)
	else:
		print("Aucune quête sélectionnée")

#  pour le bouton supprimer
func _on_button_supprimer_pressed() -> void:
	var selected_index = get_itemlist().get_selected_items()
	if selected_index.size() > 0:
		var nom_quete = get_itemlist().get_item_text(selected_index[0]).split(" [")[0]
		print("Suppression de la quête : ", nom_quete)
		supprimer_quete(nom_quete)
	else:
		print("Aucune quête sélectionnée")

func _on_button_supr_all_pressed() -> void:
	#Reset de la liste
	print("Bouton reset cliquer")
	get_itemlist().clear()
	
	# vider la barre de recherche
	get_search_bar().text = ""
	
	# effacer les détails affichés
	if has_node("MainContainer/QuestDetailsContainer/LabelDescription"):
		$MainContainer/QuestDetailsContainer/LabelDescription.text = "Description: "
	if has_node("MainContainer/QuestDetailsContainer/LabelRecompense"):
		$MainContainer/QuestDetailsContainer/LabelRecompense.text = "Récompense: "
	if has_node("MainContainer/QuestDetailsContainer/LabelActive"):
		$MainContainer/QuestDetailsContainer/LabelActive.text = "Statut: "
	if has_node("MainContainer/QuestDetailsContainer/LabelQueteSuivante"):
		$MainContainer/QuestDetailsContainer/LabelQueteSuivante.text = "Quête suivante: "
	if has_node("MainContainer/QuestDetailsContainer/LabelTimeline"):
		$MainContainer/QuestDetailsContainer/LabelTimeline.text = "Timeline: "
	if has_node("MainContainer/QuestDetailsContainer/LabelOr") :
		$MainContainer/QuestDetailsContainer/LabelOr.text = "Or : "
	if has_node("MainContainer/QuestDetailsContainer/LabelXp") :
		$MainContainer/QuestDetailsContainer/LabelXp.text = "Xp :"
	
	# Désactiver les boutons
	get_modifier_button().disabled = true
	get_supprimer_button().disabled = true
	
	# Vider le cache des quêtes
	toutes_les_quetes = {}
	
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
	# $ItemList.add_item(data)
	# $ItemList.size.y += $LineEditTitre.size.y
	# $ButtonSuprAll.position.y += $LineEditTitre.size.y
	
	reloadQuete(fichier)

#Quand le bouton export et cliquez
func _on_button_export_pressed() -> void:
	open_export_dialog()
	
func _on_file_selected_to_save(path: String) -> void:
	var contenu = "Si vous voyez cette chaine, c'est que le fichier c'est mal enregistrer :) "
	if FileAccess.file_exists(fichier):
		var file = FileAccess.open(fichier, FileAccess.ModeFlags.READ)
		contenu = file.get_as_text()
		file.close()
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Erreur : impossible d’ouvrir le fichier à l’écriture.")
		return
	file.store_string(contenu)
	file.close()
	print("Fichier enregistré à : ", path)

func _on_button_import_pressed() -> void:
	open_import_dialog()
	
func _on_file_selected_to_open(path: String) -> void:
	var contenu := "Si vous voyez cette chaine, c'est que le fichier c'est mal importé :("
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		contenu = file.get_as_text()
		file.close()

	var parse_result := JSON.parse_string(contenu)

	var file = FileAccess.open(fichier, FileAccess.WRITE)
	file.store_string(JSON.stringify(parse_result, "\t"))
	file.close()

	reloadQuete(fichier)
	
func open_export_dialog():
	file_export.popup_centered()
	
func open_import_dialog():
	file_import.popup_centered()
