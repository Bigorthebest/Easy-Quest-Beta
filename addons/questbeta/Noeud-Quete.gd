@tool
extends Area2D

@export var bind : String
@export var dico_quete : Dictionary
var fichier = "user://bdd.json"
var dialogue_already_played = false
var quest_to_activate = false
var quest_to_end = false

signal quete_terminer
signal update_quete
signal quete_commencer

func _transmettre_quest(valeur):
	bind = valeur
	# Réinitialiser complètement l'état
	dialogue_already_played = false
	quest_to_activate = false
	quest_to_end = false
	dico_quete = {} # Vider le cache

	if FileAccess.file_exists(fichier):
		var file = FileAccess.open(fichier, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()

		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			for quete in parse_result:
				if parse_result[quete]["Titre"] == bind:
					dico_quete = parse_result[quete]
					print("Nouvelle quête liée : ", dico_quete)
					break
		else:
			push_warning("Le fichier existe mais ne contient pas un dictionnaire valide.")
	else:
		push_warning("Fichier JSON inexistant !")

# NOUVELLE FONCTION : Recharger l'état de la quête depuis le fichier
func reload_quest_data():
	if bind == "" or bind == "null":
		return false
	
	if FileAccess.file_exists(fichier):
		var file = FileAccess.open(fichier, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()

		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			for quete in parse_result:
				if parse_result[quete]["Titre"] == bind:
					dico_quete = parse_result[quete]
					print("État de la quête rechargé : ", dico_quete["Titre"], " - Active: ", dico_quete["Active"], " - Finie: ", dico_quete["Finie"])
					return true
	return false

func _on_body_entered(body: Node2D) -> void:
	if Engine.is_editor_hint():
		return

	if bind == "" or bind == "null":
		print("Aucune quête n'est liée")
		return
	
	# vérifier si la quête est déjà terminée
	if dico_quete.get("Finie", false) == true:
		print("Quête déjà terminée : ", dico_quete["Titre"])
		return

	# vérifier si le dialogue a déjà été joué pour cette quête
	if dialogue_already_played:
		print("Dialogue déjà joué pour cette quête")
		return

	# LOGIQUE CORRIGÉE : Déterminer l'action selon l'état actuel de la quête
	var timeline = dico_quete.get("Timeline", "")
	if timeline != "" and Dialogic:
		# Déterminer l'action selon l'état de la quête
		if dico_quete["Active"] == false:
			quest_to_activate = true
			print("Quête inactive détectée, sera activée après dialogue : ", dico_quete["Titre"])
		elif dico_quete["Active"] == true:
			quest_to_end = true
			print("Quête active détectée, sera terminée après dialogue : ", dico_quete["Titre"])

		print("Déclenchement du dialogue : ", timeline)
		dialogue_already_played = true

		# Connecter le signal de fin de dialogue
		if not Dialogic.timeline_ended.is_connected(_on_dialogue_ended):
			Dialogic.timeline_ended.connect(_on_dialogue_ended)

		Dialogic.start(timeline)
	else:
		# Pas de dialogue, action immédiate
		if dico_quete["Active"] == false:
			activate_quest()
		elif dico_quete["Active"] == true:
			complete_quest()

func _on_dialogue_ended():
	print("Dialogue terminé pour la quête : ", dico_quete["Titre"])

	# Déconnecter le signal pour éviter les répétitions
	if Dialogic.timeline_ended.is_connected(_on_dialogue_ended):
		Dialogic.timeline_ended.disconnect(_on_dialogue_ended)

	# Activer ou terminer la quête selon l'état déterminé
	if quest_to_activate:
		activate_quest()
	elif quest_to_end:
		complete_quest()

func activate_quest():
	if dico_quete["Active"] == false:
		print("Activation de la quête : ", dico_quete["Titre"])
		dico_quete["Active"] = true
		dico_quete["Finie"] = false  # IMPORTANT : S'assurer que la quête n'est pas finie
		quest_to_activate = false

		# Mettre à jour dans la base de données
		#update_quest_in_database() NON : désactiver pour ne pas que ça créer des problèmes quand on relance le jeu
		emit_signal("quete_commencer", dico_quete)
		# Afficher la notification de nouvelle quête
		#var manager = get_parent()
		#if manager and manager.has_method("show_quest_notification"):
			#manager.show_quest_notification(dico_quete["Titre"])

func complete_quest():
	print("🏁 Complétion de la quête : ", dico_quete["Titre"])
	quest_to_end = false
	# NE PAS modifier ici dico_quete["Active"] et dico_quete["Finie"]
	# Le Manager s'en occupera
	emit_signal("quete_terminer", dico_quete)
	var manager = get_parent()


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
					parse_result[quete_id]["Finie"] = dico_quete.get("Finie", false)
					break

			# Réécrire le fichier JSON
			var file_write = FileAccess.open(fichier, FileAccess.ModeFlags.WRITE)
			file_write.store_string(JSON.stringify(parse_result, "\t"))
			file_write.close()
			print("Quête mise à jour dans la base de données")

func reset_dialogue():
	dialogue_already_played = false
	quest_to_activate = false
	quest_to_end = false
	print("Dialogue réinitialisé pour cette quête")

func _update_quete(quete) : 
	print("HEELOOOOOOOOOOOOOOOO")
	for quete_id in quete : 
		if quete[quete_id]["Titre"] == dico_quete["Titre"] : 
			dico_quete = quete[quete_id]
			print(dico_quete)
	

func _ready() -> void:
	connect("quete_terminer", Callable(get_parent(), "_update_quete_manager"))
	connect("quete_commencer", Callable(get_parent(), "_update_begin_quete_manager"))
	if not Engine.is_editor_hint():
		if not body_entered.is_connected(_on_body_entered):
			body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	pass
