extends CharacterBody2D

var vitesse = 80

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
	if Input.is_action_pressed("Haut") :
		velocity.y -= vitesse 
		$AnimatedSprite2D.play("marche")
	if Input.is_action_pressed("Bas") :
		velocity.y += vitesse  
		$AnimatedSprite2D.play("marche")
	if Input.is_action_pressed("Gauche") :
		velocity.x -= vitesse 
		$AnimatedSprite2D.scale.x = 1 
		$AnimatedSprite2D.play("marche")
	if Input.is_action_pressed("Droite") :
		velocity.x += vitesse 
		$AnimatedSprite2D.scale.x = -1 
		$AnimatedSprite2D.play("marche")
	if not Input.is_anything_pressed() :
		$AnimatedSprite2D.play("idle")
		
	move_and_slide()
