@tool
extends Area2D

@export var bind : String
@export var dico_quete : Dictionary
var fichier = "user://bdd.json"
var dialogue_already_played = false  #Variable pour tracker si le dialogue a déjà été joué

signal quete_terminer
signal update_quete

#Appelé par le Quest manager pour mettre a jour la quete 
func _update_quete(nouvelle_entree) :
	for quete in nouvelle_entree : 
		if nouvelle_entree[quete]["Titre"] == dico_quete["Titre"] :
			dico_quete = nouvelle_entree[quete]
			print("Update ",dico_quete)

#Appelé par le fonctionEditorProprety pour connaitre sont nom de quete auquel ce 
#noeud a été bind. Ainsi que récupérer tout les infos de cette quete dans la BDD
func _transmettre_quest(valeur):
	bind = valeur
	if FileAccess.file_exists(fichier):
		var file = FileAccess.open(fichier, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			for quete in parse_result:
				if parse_result[quete]["Titre"] == bind:
					dico_quete = parse_result[quete]
					break
		else:
			push_warning("Le fichier existe mais ne contient pas un dictionnaire valide.")
	else:
		push_warning("Fichier JSON inexistant !")

#Appelé quand un joueurs rentre dans la collision shape
func _on_body_entered(body: Node2D) -> void:
	if Engine.is_editor_hint():
		return
	
	if bind == "" or bind == "null":
		print("Aucune quête n'est liée")
	else:
		# Vérifier si la quête est déjà terminée (nouveau système)
		if dico_quete.get("Finie", false) == true:
			print("Quête déjà terminée : ", dico_quete["Titre"])
			return
		
		# Si la quête est inactive, l'activer
		if dico_quete["Active"] == false:
			print("Activation de la quête : ", dico_quete["Titre"])
			dico_quete["Active"] = true
			# Mettre à jour dans la base de données
			update_quest_in_database()
		
		# Vérifier si le dialogue a déjà été joué pour cette quête
		if dialogue_already_played:
			print("Dialogue déjà joué pour cette quête")
			return
		
		emit_signal("quete_terminer", dico_quete)
		
		# déclencher le dialogue si une timeline est définie
		var timeline = dico_quete.get("Timeline", "")
		if timeline != "" and Dialogic:
			print("Déclenchement du dialogue : ", timeline)
			dialogue_already_played = true  # Marquer le dialogue comme joué
			Dialogic.start(timeline)
		else:
			print("Pas de timeline associée à cette quête")

# Nouvelle fonction pour mettre à jour la quête dans la base de données
func update_quest_in_database():
	if FileAccess.file_exists(fichier):
		var file = FileAccess.open(fichier, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			# Trouver et mettre à jour la quête
			for quete_id in parse_result:
				if parse_result[quete_id]["Titre"] == dico_quete["Titre"]:
					parse_result[quete_id]["Active"] = dico_quete["Active"]
					break
			
			# Réécrire le fichier JSON
			var file_write = FileAccess.open(fichier, FileAccess.ModeFlags.WRITE)
			file_write.store_string(JSON.stringify(parse_result, "\t"))
			file_write.close()
			print("Quête mise à jour dans la base de données")

# réinitialiser le dialogue (si besoin)
func reset_dialogue():
	dialogue_already_played = false
	print("Dialogue réinitialisé pour cette quête")
	
func _ready() -> void:
	connect("quete_terminer",Callable(get_parent(),"_update_quete_manager"))
	if not Engine.is_editor_hint():
		if not body_entered.is_connected(_on_body_entered):
			body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	pass
