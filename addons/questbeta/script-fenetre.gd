extends Window

var Bdd = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#On essaye de charger les données d'une configurations existante 
	var err = Bdd.load("res://bdd_quete.cfg")
	if (err != OK):
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_valider_pressed() -> void:
	print("Bouton valider presser")
	if ($Window/LineEditTitre.text == ""):
		print("Bouton valider presser et sans texte")
		$Window/LabelErreur.show()
		$Window/LabelErreur.text = "Aucun titre entrée !"
	#else :
		#print($WIndow/LineEditTitre.text)
		#$Window/LabelErreur.hide()
		#$ItemList.add_item($Window/LineEditTitre.text)
		#$ItemList.size.y += $Window/LineEditTitre.size.y
		#Bdd.set_value($Window/LineEditTitre.text,$Window/LineEditDescription.text,"Vide")
		#Bdd.save("res://bdd_quete.cfg")
		#$Window.hide()
