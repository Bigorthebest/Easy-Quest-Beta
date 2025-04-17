@tool
extends Control

var Bdd = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#On essaye de charger les données d'une configurations existante 
	var err = Bdd.load("res://bdd_quete.cfg")
	if (err != OK):
		return
	else : 
		for data in Bdd.get_sections() :
			$ItemList.add_item(data.get_basename())
			$ItemList.size.y += $LineEditTitre.size.y
			$ButtonSuprAll.position.y += $LineEditTitre.size.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	if ($LineEditTitre.text == "Nom de quete :"):
		$LabelErreur.show()
		$LabelErreur.text = "Aucun titre entrée !"
	else :
		print($LineEditTitre.text)
		$LabelErreur.hide()
		$ItemList.add_item($LineEditTitre.text)
		$ItemList.size.y += $LineEditTitre.size.y
		Bdd.set_value($LineEditTitre.text,"Description","Vide")
		Bdd.save("res://bdd_quete.cfg")


func _on_button_supr_all_pressed() -> void:
	$ItemList.clear() 
	$ItemList.size.y = 0 
	for data in Bdd.get_sections() :
		Bdd.erase_section(data)
	$ButtonSuprAll.position.y = 180 
