extends Control

var fichier = "user://bdd.json"
var all_quete
var quete_active : Array

signal update_quete
signal recompence

# Précharger la scène de notification
var notification_scene = preload("res://RPG-test/QuestNotification.tscn")
var notification_instance = null

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
				pass # La gestion des quêtes actives se fera via les triggers
		else:
			push_warning("Le fichier existe mais ne contient pas un dictionnaire valide.")

func _give_stuff (arrayStuff) :
	print("Du stuff a été give :" , arrayStuff)
	emit_signal("recompence",arrayStuff)

#Appelez quand une quete et terminer par un quest trigger
func _update_quete_manager (dico_quete) :
	#Update des propriété
	dico_quete["Active"] = false
	if dico_quete["Finie"] == true :
		print("Anti recursion")
		return
	dico_quete["Finie"] = true # Marquer comme finie
	
	print("🎉 Quête terminée : ", dico_quete["Titre"])
	
	# NOUVEAU : Afficher la notification de quête terminée
	if notification_instance:
		notification_instance.show_quest_completed(dico_quete["Titre"])
	
	# Logique pour trouver la quête dans all_quete et la mettre à jour
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
						# MODIFIÉ : Afficher la notification pour la nouvelle quête activée
						if notification_instance:
							notification_instance.show_notification(quete_suivante_titre)
						break
			break
	
	# Sauvegarder les changements dans la base de données
	save_all_quetes()
	
	emit_signal("recompence",dico_quete["Recompense"])
	#Transmision a tous
	emit_signal("update_quete",all_quete)

# FONCTION MODIFIÉE : Utiliser l'instance unique de notification
func show_quest_notification(quest_name: String):
	if notification_instance:
		notification_instance.show_notification(quest_name)

# Fonction pour sauvegarder toutes les quêtes
func save_all_quetes():
	if FileAccess.file_exists(fichier):
		var file_write = FileAccess.open(fichier, FileAccess.ModeFlags.WRITE)
		file_write.store_string(JSON.stringify(all_quete, "\t"))
		file_write.close()
		print("Base de données des quêtes sauvegardée.")

func _ready() -> void:
	# NOUVEAU : Créer une instance unique de notification
	notification_instance = notification_scene.instantiate()
	get_tree().root.add_child(notification_instance)
	
	loadQuete(fichier)
	for enfant in get_children():
		# Vérifier si le signal n'est pas déjà connecté avant de le connecter
		if enfant.has_method("_update_quete"):
			if not update_quete.is_connected(Callable(enfant, "_update_quete")):
				connect("update_quete", Callable(enfant, "_update_quete"))
		
		if enfant.has_method("_get_reward"):
			if not recompence.is_connected(Callable(enfant, "_get_reward")):
				connect("recompence", Callable(enfant,"_get_reward"))
	
	emit_signal("update_quete",all_quete)

func _process(delta: float) -> void:
	pass
