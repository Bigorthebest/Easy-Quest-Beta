extends AnimatableBody2D

signal scaranbee_ramasse

var is_collision = false 

func _ready() -> void:
	$AnimatedSprite2D.play("marche")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Personnage":
		print("Rencontre avec un scarabée")
		is_collision = true 
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Personnage":
		print("Aurevoir petit scarabée")
		is_collision = false 
		
func _process(_delta: float) -> void:
	if is_collision and Input.is_action_just_pressed("Intéragir"):
		print("Le scarabée est ramassé !")
		emit_signal("scaranbee_ramasse")
		queue_free()
