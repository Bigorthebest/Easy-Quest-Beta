@tool
extends Area2D

@export var bind : String
var fichier = "user://bdd.json"
@export var dico_quete : Dictionary
var dialogue_already_played = false  # NOUVEAU : Variable pour tracker si le dialogue a déjà été joué

func _enter_tree():
	pass

func _ready() -> void:
	if not Engine.is_editor_hint():
		if not body_entered.is_connected(_on_body_entered):
			body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	pass

func _transmettre_quest(valeur):
	print("Donnée reçue chez le quete trigger :", valeur)
	bind = valeur
	
	if FileAccess.file_exists(fichier):
		var file = FileAccess.open(fichier, FileAccess.ModeFlags.READ)
		var contenu = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse_string(contenu)
		if typeof(parse_result) == TYPE_DICTIONARY:
			print("Le bind est :", bind)
			for quete in parse_result:
				if parse_result[quete]["Titre"] == bind:
					dico_quete = parse_result[quete]
					break
		else:
			push_warning("Le fichier existe mais ne contient pas un dictionnaire valide.")
		
		print("Prêt à être utilisé : ", dico_quete)
	else:
		push_warning("Fichier JSON inexistant !")

func _on_body_entered(body: Node2D) -> void:
	if Engine.is_editor_hint():
		return
	
	if bind == "" or bind == "null":
		print("Aucune quête n'est liée")
	else:
		# Vérifier si le dialogue a déjà été joué
		if dialogue_already_played:
			print("Dialogue déjà joué pour cette quête")
			return
		
		print("Personnage dans la boîte", dico_quete)
		
		# déclencher le dialogue si une timeline est définie
		var timeline = dico_quete.get("Timeline", "")
		if timeline != "" and Dialogic:
			print("Déclenchement du dialogue : ", timeline)
			dialogue_already_played = true  # Marquer le dialogue comme joué
			Dialogic.start(timeline)
		else:
			print("Pas de timeline associée à cette quête")

# réinitialiser le dialogue (si besoin)
func reset_dialogue():
	dialogue_already_played = false
	print("Dialogue réinitialisé pour cette quête")
