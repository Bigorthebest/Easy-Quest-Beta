@tool
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
