extends Control

var fichier = "user://bdd.json"
var all_quete
var quete_active : Array

signal update_quete
signal recompence

# NOUVEAU : Précharger la scène de notification
var notification_scene = preload("res://RPG-test/QuestNotification.tscn")

#Fonction de chargement de la BDD des quetes
func loadQuete(fichier):
	if FileAccess.file_exists(fichier):
		var file = FileAccess.open(fichier, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			all_quete = parse_result
			for quete in parse_result:
				# MODIFIÉ : Ne pas ajouter automatiquement aux quêtes actives ici
				# if parse_result[quete]["Active"] == true:
				# 	quete_active.append(parse_result[quete])
				pass # La gestion des quêtes actives se fera via les triggers
		else:
			push_warning("Le fichier existe mais ne contient pas un dictionnaire valide.")

#Appelez quand une quete et terminer par un quest trigger
func _update_quete_manager (dico_quete) :
	#Update des propriété
	dico_quete["Active"] = false
	dico_quete["Finie"] = true # Marquer comme finie
	
	# NOUVEAU : Logique pour trouver la quête dans all_quete et la mettre à jour
	for quete_id in all_quete:
		if all_quete[quete_id]["Titre"] == dico_quete["Titre"]:
			all_quete[quete_id]["Active"] = false
			all_quete[quete_id]["Finie"] = true
			
			# Activer la quête suivante
			var quete_suivante_titre = dico_quete.get("QueteSuivante", "")
			if quete_suivante_titre != "":
				for next_quete_id in all_quete:
					if all_quete[next_quete_id]["Titre"] == quete_suivante_titre:
						all_quete[next_quete_id]["Active"] = true
						# Afficher la notification pour la nouvelle quête activée
						show_quest_notification(quete_suivante_titre)
						break
			break
	
	# Sauvegarder les changements dans la base de données
	save_all_quetes()
	
	emit_signal("recompence",dico_quete["Recompense"])
	#Transmision a tous
	emit_signal("update_quete",all_quete)

# NOUVEAU : Fonction pour afficher la notification
func show_quest_notification(quest_name: String):
	var notification_instance = notification_scene.instantiate()
	get_tree().root.add_child(notification_instance)
	notification_instance.show_notification(quest_name)

# NOUVEAU : Fonction pour sauvegarder toutes les quêtes
func save_all_quetes():
	if FileAccess.file_exists(fichier):
		var file_write = FileAccess.open(fichier, FileAccess.ModeFlags.WRITE)
		file_write.store_string(JSON.stringify(all_quete, "\t"))
		file_write.close()
		print("Base de données des quêtes sauvegardée.")

func _ready() -> void:
	loadQuete(fichier)
	for enfant in get_children():
		if enfant.has_method("_update_quete"):
			connect("update_quete", Callable(enfant, "_update_quete"))
		if enfant.has_method("_get_reward") :
			connect("recompence", Callable(enfant,"_get_reward"))

func _process(delta: float) -> void:
	pass
