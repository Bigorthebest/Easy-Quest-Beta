extends Area2D

signal bois_ramasse

var is_collision = false 

func _ready() -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Personnage":
		is_collision = true 
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Personnage":
		print("Le personnage tourche du bois")
		is_collision = false 
		
func _process(_delta: float) -> void:
	if is_collision and Input.is_action_just_pressed("Intéragir"):
		print("Bois ramassé !")
		emit_signal("bois_ramasse")
		queue_free()
