@tool
extends Area2D

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
