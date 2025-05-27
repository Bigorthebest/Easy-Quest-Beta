@tool
extends Window

var jsonfile = "user://bdd.json"#"res://addons/questbeta/data/bdd.json"

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
		'Recompense': $LineEditRecompense.text,
		'QueteSuivante': $LineEditQueteSuivante.text
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
	file.store_string(JSON.stringify(data, "\t")) # "\t" pour indenter joliment
	file.close()

# pour modifier une quête existante
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
					parse_result[quete_id]["Recompense"] = $LineEditRecompense.text
					parse_result[quete_id]["QueteSuivante"] = $LineEditQueteSuivante.text
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#On essaye de charger les données d'une configurations existante
	move_to_center()
	print("ready")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _enter_tree() -> void:
	print("Enter tree...")
	# Convertir le dictionnaire en chaîne JSON
	#var json = JSON.new()
	#var json_string = json.stringify(premiere_save)
	var tab = loadBDD(jsonfile)
	print(tab)
	# Écrire la chaîne JSON dans un fichier
	#var file = FileAccess.open("jsonfile", FileAccess.WRITE)
	#if file.file_exists(jsonfile) :
	# file.store_string(json_string)
	# file.close()
	#else :
	# print("Impossible d'ouvrir le fichier :" + jsonfile)

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
		
		if interface_node.quete_en_modification == null: # mode création seulement
			if verifier_quete_existe($LineEditTitre.text):
				$LabelErreur.text = "Erreur : Une quête avec ce nom existe déjà !"
				return
		else: # mode modification
			# permettre de garder le même nom lors de la modification
			if verifier_quete_existe($LineEditTitre.text) and $LineEditTitre.text != interface_node.quete_en_modification:
				$LabelErreur.text = "Erreur : Une quête avec ce nom existe déjà !"
				return
		
		# validation optionnelle pour la quête suivante
		if $LineEditQueteSuivante.text != "":
			if not verifier_quete_existe($LineEditQueteSuivante.text):
				$LabelErreur.text = "Attention : La quête suivante n'existe pas encore"
				# la suite c'est si on veut empêcher de créer si y'a pas de quête suivante (au cas ou)
				# return # bon c'est un peu bête, ça sera jamais utile
		
		print("Création de quête : " + $LineEditTitre.text)
		$LabelErreur.text = "" #pour "cacher" la potentiel erreur
		
		# vérifier si on est en mode modification ou création
		if interface_node.quete_en_modification != null:
			# mode modification
			modifier_quete_dans_json(jsonfile, interface_node.quete_en_modification)
			print("Quête modifiée : " + $LineEditTitre.text)
		else:
			# mode création
			ajouter_dictionnaire_au_json(jsonfile)
			print("Store in json")
		
		#$ItemList.add_item($Window/LineEditTitre.text)
		#$ItemList.size.y += $Window/LineEditTitre.size.y
		#Bdd.set_value($LineEditTitre.text, $LineEditDescription.text, "Vide")
		#Bdd.save("res://bdd_quete.cfg")
		#print("Donner sauvegarder dans la bdd")
		#close_requested.emit()
		#Etape de récupération
		#var file = FileAccess.get_file_as_string(jsonfile)
		#var tab = loadBDD(jsonfile)
		#print(tab.size())
		#Etape de stockage
		#var file = FileAccess.open(jsonfile, FileAccess.ModeFlags.WRITE)
		#var text_to_json = JSON.stringify(tab.merge(nouvelle_entrer))
		#file.store_string(text_to_json)
		#file.close()
		close_requested.emit()
