@tool
extends Control

var fichier = "user://bdd.json"
var quete_en_modification = null # pour tracker la quête en cours de modification
var toutes_les_quetes = {}  # pour stocker toutes les quêtes

func in_list(item_list: ItemList, valeur: String) -> bool:
	for i in item_list.get_item_count():
		if item_list.get_item_text(i) == valeur:
			return true
	return false

func reloadQuete(fichier):
	$ItemList.clear() # Vider la liste avant de la recharger
	
	if FileAccess.file_exists(fichier):
		var file = FileAccess.open(fichier, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			toutes_les_quetes = parse_result  # sauvegarder toutes les quêtes
			afficher_quetes(parse_result)
		else:
			push_warning("Le fichier existe mais ne contient pas un dictionnaire valide.")

# afficher les quêtes (avec ou sans filtre)
func afficher_quetes(quetes_a_afficher: Dictionary):
	$ItemList.clear()
	
	for quete in quetes_a_afficher:
		var quete_data = quetes_a_afficher[quete]
		var titre = quete_data["Titre"]
		var active = quete_data.get("Active", true)
		var statut = " [ACTIVE]" if active else " [INACTIVE]"
		
		$ItemList.add_item(titre)
		
		# changer la couleur selon le statut
		var item_index = $ItemList.get_item_count() - 1
		if not active:
			$ItemList.set_item_custom_fg_color(item_index, Color.GRAY)

# Nouvelle fonction pour filtrer les quêtes selon la recherche
func filtrer_quetes(texte_recherche: String) -> Dictionary:
	if texte_recherche == "":
		return toutes_les_quetes
	
	var quetes_filtrees = {}
	texte_recherche = texte_recherche.to_lower()
	
	for quete_id in toutes_les_quetes:
		var quete_data = toutes_les_quetes[quete_id]
		var titre = quete_data["Titre"].to_lower()
		
		# Vérifier si le texte de recherche est présent dans le titre
		if texte_recherche in titre:
			quetes_filtrees[quete_id] = quete_data
		else:
			# Vérifier chaque mot du titre
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
	
	# Désactiver le bouton modifier si aucune quête n'est sélectionnée après filtrage
	if $ItemList.get_item_count() == 0:
		$ButtonModifier.disabled = true
	
	print("Recherche : '", new_text, "' - ", quetes_filtrees.size(), " quête(s) trouvée(s)")

# afficher les détails d'une quête (sous la liste)je pense qu'il faudrait en faire une autre fenêtre mais bon
func _on_item_list_item_selected(index: int) -> void:
	var nom_quete = $ItemList.get_item_text(index).split(" [")[0] # Enlever le statut
	afficher_details_quete(nom_quete)
	
	# activer le bouton modifier quand une quête est sélectionnée
	$ButtonModifier.disabled = false

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
					$Window/LineEditRecompense.text = quete_data.get("Recompense", "")
					$Window/LineEditQueteSuivante.text = quete_data.get("QueteSuivante", "")
					
					$Window/Label.text = "Menu de modification de quête :"
					$Window/ButtonValider.text = "Modifier"
					
					$Window.show()
					break

func _ready() -> void:
	reloadQuete(fichier)
	# connecter le signal de sélection d'item
	if not $ItemList.item_selected.is_connected(_on_item_list_item_selected):
		$ItemList.item_selected.connect(_on_item_list_item_selected)
	
	# connecter le signal de recherche
	if has_node("LineEditRecherche") and not $LineEditRecherche.text_changed.is_connected(_on_line_edit_recherche_text_changed):
		$LineEditRecherche.text_changed.connect(_on_line_edit_recherche_text_changed)
	
	# désactiver le bouton modifier au démarrage
	$ButtonModifier.disabled = true

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
	$Window/LabelErreur.text = ""
	
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
	var selected_index = $ItemList.get_selected_items()
	if selected_index.size() > 0:
		var nom_quete = $ItemList.get_item_text(selected_index[0]).split(" [")[0]
		charger_quete_pour_modification(nom_quete)
	else:
		print("Aucune quête sélectionnée")

func _on_button_supr_all_pressed() -> void:
	#Reset de la liste
	print("Bouton reset cliquer")
	$ItemList.clear()
	
	# Vider la barre de recherche
	if has_node("LineEditRecherche"):
		$LineEditRecherche.text = ""
	
	# effacer les détails affichés
	if has_node("LabelDescription"):
		$LabelDescription.text = "Description: "
	if has_node("LabelRecompense"):
		$LabelRecompense.text = "Récompense: "
	if has_node("LabelActive"):
		$LabelActive.text = "Statut: "
	if has_node("LabelQueteSuivante"):
		$LabelQueteSuivante.text = "Quête suivante: "
	
	# Désactiver le bouton modifier
	$ButtonModifier.disabled = true
	
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
