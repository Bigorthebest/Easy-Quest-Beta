@tool
extends Window

var Bdd = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#On essaye de charger les données d'une configurations existante 
	var err = Bdd.load("res://bdd_quete.cfg")
	if (err != OK):
		return
	move_to_center()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_valider_pressed() -> void:
	print("Bouton valider presser")
	if ($LineEditTitre.text == ""):
		print("Bouton valider presser et sans Titre")
		$LabelErreur.text = "Erreur : Pas de titre !"
	elif ($LineEditDescription.text == ""):
		print("Bouton valider presser et sans Description")
		$LabelErreur.text = "Erreur : Pas de Description "
	else :
		print($LineEditTitre.text)
		$LabelErreur.text = "" #pour "cacher" la potentiel erreur 
		#$ItemList.add_item($Window/LineEditTitre.text)
		#$ItemList.size.y += $Window/LineEditTitre.size.y
		Bdd.set_value($LineEditTitre.text,$LineEditDescription.text,"Vide")
		Bdd.save("res://bdd_quete.cfg")
		print("Donner sauvegarder dans la bdd")
		close_requested.emit()
