@tool
extends Area2D

@export var bind : String
@export var dico_quete : Dictionary
var fichier = "user://bdd.json"
var dialogue_already_played = false #tracker si le dialogue a déjà été joué
var quest_to_activate = false # tracker si on doit activer la quête après le dialogue

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
		# vérifier si la quête est déjà terminée
		if dico_quete.get("Finie", false) == true:
			print("Quête déjà terminée : ", dico_quete["Titre"])
			return
		
		# Vérifier si le dialogue a déjà été joué pour cette quête
		if dialogue_already_played:
			print("Dialogue déjà joué pour cette quête")
			return
		
		# vérifier d'abord s'il y a un dialogue
		var timeline = dico_quete.get("Timeline", "")
		if timeline != "" and Dialogic:
			# Si dialogue ET quête inactive, marquer pour activation après dialogue
			if dico_quete["Active"] == false:
				quest_to_activate = true
			
			print("Déclenchement du dialogue : ", timeline)
			dialogue_already_played = true
			
			# connecter le signal de fin de dialogue
			if not Dialogic.timeline_ended.is_connected(_on_dialogue_ended):
				Dialogic.timeline_ended.connect(_on_dialogue_ended)
			
			Dialogic.start(timeline)
		else:
			# pas de dialogue, activer immédiatement
			if dico_quete["Active"] == false:
				activate_quest()
			
			emit_signal("quete_terminer", dico_quete)

# appelée quand le dialogue se termine
func _on_dialogue_ended():
	print("Dialogue terminé pour la quête : ", dico_quete["Titre"])
	
	# Déconnecter le signal pour éviter les répétitions
	if Dialogic.timeline_ended.is_connected(_on_dialogue_ended):
		Dialogic.timeline_ended.disconnect(_on_dialogue_ended)
	
	# Activer la quête maintenant que le dialogue est fini
	if quest_to_activate:
		activate_quest()
	
	# émettre le signal de fin de quête si nécessaire
	emit_signal("quete_terminer", dico_quete)

# activer la quête et afficher la notification
func activate_quest():
	if dico_quete["Active"] == false:
		print("Activation de la quête : ", dico_quete["Titre"])
		dico_quete["Active"] = true
		quest_to_activate = false
		
		# Mettre à jour dans la base de données
		update_quest_in_database()
		
		# Afficher la notification
		var manager = get_parent()
		if manager and manager.has_method("show_quest_notification"):
			manager.show_quest_notification(dico_quete["Titre"])

# mettre à jour la quête dans la base de données
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
	quest_to_activate = false
	print("Dialogue réinitialisé pour cette quête")
	
func _ready() -> void:
	# s'assurer que le parent est bien le Quete Manager
	if get_parent() and get_parent().name == "Quete Manager":
		connect("quete_terminer",Callable(get_parent(),"_update_quete_manager"))
	else:
		push_warning("Noeud-Quete n'a pas Quete Manager comme parent direct. Signal 'quete_terminer' non connecté.")
		
	if not Engine.is_editor_hint():
		if not body_entered.is_connected(_on_body_entered):
			body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	pass
