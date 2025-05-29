extends Control

var fichier = "user://bdd.json"
var all_quete
var quete_active : Array
signal update_quete
signal recompence

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
				if parse_result[quete]["Active"] == true:
					quete_active.append(parse_result[quete])
		else:
			push_warning("Le fichier existe mais ne contient pas un dictionnaire valide.")

#Appelez quand une quete et terminer par un quest trigger
func _update_quete_manager (dico_quete) :
	print("Quete terminier surle quest manager : ",dico_quete)
	#Update des propriété 
	dico_quete["Active"] = false 
	emit_signal("recompence",dico_quete["Recompense"])
	for quete in all_quete : 
		if all_quete[quete]["Titre"] == dico_quete["QueteSuivante"] :
			all_quete[quete]["Active"] = true
		if all_quete[quete]["Titre"] == dico_quete["Titre"] :
			all_quete[quete]["Active"] = false
	#Transmision a tous
	emit_signal("update_quete",all_quete)

func _ready() -> void:
	loadQuete(fichier)
	for enfant in get_children() :
		enfant.connect("update_quete", Callable(enfant, "_update_quete"))

func _process(delta: float) -> void:
	pass
