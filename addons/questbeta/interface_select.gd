@tool
extends Control

var fichier = "user://bdd.json"
var toutes_les_quetes = {}  # pour stocker toutes les quêtes

signal bind_quest(valeur)

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

func reloadQuete(fichier):
	$ItemList.clear() # Vider la liste avant de la recharger
	print("Reload interface fenetre appeler")
	
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
		$ButtonSelection.disabled = true
	
	print("Recherche : '", new_text, "' - ", quetes_filtrees.size(), " quête(s) trouvée(s)")

# afficher les détails d'une quête (sous la liste)je pense qu'il faudrait en faire une autre fenêtre mais bon
func _on_item_list_item_selected(index: int) -> void:
	var nom_quete = $ItemList.get_item_text(index).split(" [")[0] # Enlever le statut
	afficher_details_quete(nom_quete)
	
	# activer le bouton modifier quand une quête est sélectionnée
	$ButtonSelection.disabled = false

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
						$LabelRecompense.text = "Récompense: " + quete_data.get("Recompense", "Aucune")[2]
					if has_node("LabelTitre"):
						$LabelTitre.text = "Titre: " + quete_data.get("Titre", "Aucune")
					if has_node("LabelQueteSuivante"):
						$LabelQueteSuivante.text = "Quête suivante: " + quete_data.get("QueteSuivante", "Aucune")
					
					print("=== DÉTAILS DE LA QUÊTE ===")
					print("Titre: ", quete_data["Titre"])
					print("Description: ", quete_data.get("Description", "Aucune"))
					print("Récompense: ", quete_data.get("Recompense", "Aucune"))
					print("Active: ", quete_data.get("Active", true))
					print("Quête suivante: ", quete_data.get("QueteSuivante", "Aucune"))
					print("Timeline: ", quete_data.get("Timeline", "Aucune"))
					print("========================")
					break

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree():
			print("Fenetre afficher")
			reloadQuete(fichier)
			
			# connecter le signal de sélection d'item
			if not $ItemList.item_selected.is_connected(_on_item_list_item_selected):
				$ItemList.item_selected.connect(_on_item_list_item_selected)
			
			# connecter le signal de recherche
			if has_node("LineEditRecherche") and not $LineEditRecherche.text_changed.is_connected(_on_line_edit_recherche_text_changed):
				$LineEditRecherche.text_changed.connect(_on_line_edit_recherche_text_changed)
			
			$ButtonSelection.disabled = true
		else:
			print("Fenetre cacher")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_selection_pressed() -> void:
	var selected_index = $ItemList.get_selected_items()
	if selected_index.size() > 0:
		var nom_quete = $ItemList.get_item_text(selected_index[0]).split(" [")[0]
		emit_signal("bind_quest", nom_quete)
		print("signal envoyée et fenètre fermé")
		get_parent().hide()
	else:
		print("Aucune quête sélectionnée")
