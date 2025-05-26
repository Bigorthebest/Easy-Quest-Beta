@tool
extends Area2D

var bind : String
var fichier = "user://bdd.json"
var dico_quete 

func _enter_tree():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _transmettre_quest(valeur):
	print("Donnée reçue chez le quete trigger :", valeur)
	bind = valeur 

func _on_body_entered(body: Node2D) -> void:
	if bind == "null" :
		print("Acune quete n'est lier")
	else : 
		print("Personnage dans la boite")
		if FileAccess.file_exists(fichier):
			var file = FileAccess.open(fichier, FileAccess.ModeFlags.READ)
			var contenu = file.get_as_text()
			file.close()
			var parse_result = JSON.parse_string(contenu)
			if typeof(parse_result) == TYPE_DICTIONARY:
				print(parse_result)
				print("Le bind est :", bind)
				for quete in parse_result:
					if parse_result[quete]["Titre"] == bind:
						print(parse_result[quete]["Titre"])
						print(parse_result[quete])
						print(parse_result[quete]["Description"])
						dico_quete = parse_result[quete]
			else:
				push_warning("Le fichier existe mais ne contient pas un dictionnaire valide.")
			
			print(dico_quete)
		else :
			push_warning("Fichier JSON innexistant !")
		
