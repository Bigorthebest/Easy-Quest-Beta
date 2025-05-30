extends CharacterBody2D

var vitesse = 80
var espacement = 20
var direction = 0 #0 face, 1 droite, 2 gauche, 3 dos
var dialogue_deja_lance = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position.x -= espacement

func _physics_process(delta: float) -> void:
		
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("Droite"):
		input_vector.x += 1
	if Input.is_action_pressed("Gauche"):
		input_vector.x -= 1
	if Input.is_action_pressed("Bas"):
		input_vector.y += 1
	if Input.is_action_pressed("Haut"):
		input_vector.y -= 1

	velocity = input_vector * vitesse

	# Animation selon la direction dominante (axe Y prioritaire si mouvement en diagonale)
	if input_vector != Vector2.ZERO:
		if abs(input_vector.y) > abs(input_vector.x):
			if input_vector.y < 0:
				direction = 3
				$AnimatedSprite2D.play("marche_haut")
			else:
				direction = 0
				$AnimatedSprite2D.play("marche_bas")
		else:
			if input_vector.x < 0:
				direction = 2
				$AnimatedSprite2D.play("marche_gauche")
			else:
				direction = 1
				$AnimatedSprite2D.play("marche droite")
	else:
		match direction:
			0:
				$AnimatedSprite2D.play("face")
			1:
				$AnimatedSprite2D.play("droite")
			2:
				$AnimatedSprite2D.play("gauche")
			3:
				$AnimatedSprite2D.play("dos")

	move_and_slide()
