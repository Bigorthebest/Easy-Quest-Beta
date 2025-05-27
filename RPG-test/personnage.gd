extends Node2D

var vitesse = 50 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("Haut") :
		position.y -= vitesse * delta 
		$CharacterBody2D/AnimatedSprite2D.play("marche")
	if Input.is_action_pressed("Bas") :
		position.y += vitesse * delta 
		$CharacterBody2D/AnimatedSprite2D.play("marche")
	if Input.is_action_pressed("Gauche") :
		position.x -= vitesse * delta 
		$".".scale.x = 1 
		$CharacterBody2D/AnimatedSprite2D.play("marche")
	if Input.is_action_pressed("Droite") :
		position.x += vitesse * delta 
		$".".scale.x = -1 
		$CharacterBody2D/AnimatedSprite2D.play("marche")
	if not Input.is_anything_pressed() :
		$CharacterBody2D/AnimatedSprite2D.play("idle")
