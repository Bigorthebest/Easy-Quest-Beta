@tool
extends Window

var jsonfile = "user://bdd.json"

var premiere_save = {
	"nom": "Quete Principale",
	"description": "Une super quete incroyable"
}

func ajouter_dictionnaire_au_json(fichier_path: String) -> void:
	var data = {}
	var cle = 0
	
	var nouvelle_entrer = {
		'Titre': $LineEditTitre.text,
		'Description': $LineEditDescription.text,
		'Active': $CheckBoxActive.button_pressed,
		'Recompense': [$SpinBoxOr.value, $SpinBoxXp.value, $LineEditRecompense.text],
		'QueteSuivante': $LineEditQueteSuivante.text,
		'Timeline': $LineEditTimeline.text,  
		'Finie': false,
		'ItemsDemandes' : [$LineEditItemsWanted.text,$SpinBoxNbrItem.value]
	}
	
	# Lire le fichier s'il existe
	if FileAccess.file_exists(fichier_path):
		var file = FileAccess.open(fichier_path, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()
		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			data = parse_result
			cle = parse_result.size()
		else:
			push_warning("Le fichier existe mais ne contient pas un dictionnaire valide. Écrasement.")
	
	# Ajouter le nouveau dictionnaire
	data[cle] = nouvelle_entrer
	
	# Réécrire le fichier JSON
	var file = FileAccess.open(fichier_path, FileAccess.ModeFlags.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func modifier_quete_dans_json(fichier_path: String, ancien_nom: String) -> void:
	if FileAccess.file_exists(fichier_path):
		var file = FileAccess.open(fichier_path, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			# Trouver et modifier la quête
			for quete_id in parse_result:
				if parse_result[quete_id]["Titre"] == ancien_nom:
					# Mettre à jour les données
					parse_result[quete_id]["Titre"] = $LineEditTitre.text
					parse_result[quete_id]["Description"] = $LineEditDescription.text
					parse_result[quete_id]["Active"] = $CheckBoxActive.button_pressed
					parse_result[quete_id]["Recompense"] = [$SpinBoxOr.value, $SpinBoxXp.value, $LineEditRecompense.text]
					parse_result[quete_id]["QueteSuivante"] = $LineEditQueteSuivante.text
					parse_result[quete_id]["Timeline"] = $LineEditTimeline.text  # NOUVEAU CHAMP
					parse_result[quete_id]["Finie"] = false 
					parse_result[quete_id]["ItemsDemandes"] = [$LineEditItemsWanted.text,$SpinBoxNbrItem.value]
					break
			
			# Réécrire le fichier JSON
			var file_write = FileAccess.open(fichier_path, FileAccess.ModeFlags.WRITE)
			file_write.store_string(JSON.stringify(parse_result, "\t"))
			file_write.close()

func loadBDD(file):
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	print(typeof(json_as_dict))
	print("renvois :" + str(json_as_dict))
	return json_as_dict

func _ready() -> void:
	move_to_center()
	print("ready")

func _process(delta: float) -> void:
	pass

func _enter_tree() -> void:
	print("Enter tree...")
	var tab = loadBDD(jsonfile)
	print(tab)

func _init() -> void:
	print("init")

func verifier_quete_existe(nom_quete: String) -> bool:
	if FileAccess.file_exists(jsonfile):
		var file = FileAccess.open(jsonfile, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			for quete in parse_result:
				if parse_result[quete]["Titre"] == nom_quete:
					return true
	return false

func _on_button_valider_pressed() -> void:
	print("Bouton valider presser")
	
	if ($LineEditTitre.text == ""):
		print("Bouton valider presser et sans Titre")
		$LabelErreur.text = "Erreur : Pas de titre !"
	elif ($LineEditDescription.text == ""):
		print("Bouton valider presser et sans Description")
		$LabelErreur.text = "Erreur : Pas de Description "
	else:
		# pour empêcher les doublons de noms
		var interface_node = get_parent()
		
		if interface_node.quete_en_modification == null:
			if verifier_quete_existe($LineEditTitre.text):
				$LabelErreur.text = "Erreur : Une quête avec ce nom existe déjà !"
				return
		else:
			if verifier_quete_existe($LineEditTitre.text) and $LineEditTitre.text != interface_node.quete_en_modification:
				$LabelErreur.text = "Erreur : Une quête avec ce nom existe déjà !"
				return
		
		# validation optionnelle pour la quête suivante
		if $LineEditQueteSuivante.text != "":
			if not verifier_quete_existe($LineEditQueteSuivante.text):
				$LabelErreur.text = "Attention : La quête suivante n'existe pas encore"
		
		print("Création de quête : " + $LineEditTitre.text)
		$LabelErreur.text = ""
		
		# vérifier si on est en mode modification ou création
		if interface_node.quete_en_modification != null:
			modifier_quete_dans_json(jsonfile, interface_node.quete_en_modification)
			print("Quête modifiée : " + $LineEditTitre.text)
		else:
			ajouter_dictionnaire_au_json(jsonfile)
			print("Store in json")
		
		close_requested.emit()

#Si c'est une quete d'inventaire
func _on_check_box_items_wanted_toggled(toggled_on: bool) -> void:
	if toggled_on :
		$LineEditItemsWanted.show()
		$Nbr.show()
		$SpinBoxNbrItem.show()
	else : 
		$LineEditItemsWanted.hide()
		$Nbr.hide()
		$SpinBoxNbrItem.hide()
		
