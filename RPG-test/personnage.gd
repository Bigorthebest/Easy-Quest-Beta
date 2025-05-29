extends CharacterBody2D

var vitesse = 80
var direction = 0 #0 face, 1 droite, 2 gauche, 3 dos
var dialogue_deja_lance = false

func _ready() -> void:
	# Connecter le signal de fin de dialogue si Dialogic est disponible
	if Dialogic:
		Dialogic.timeline_ended.connect(_on_dialogue_ended)

func _physics_process(_delta: float) -> void:
	# vérifier si un dialogue est en cours
	if Dialogic and Dialogic.current_timeline != null:
		# idle pendant dialogue
		match direction:
			0: $AnimatedSprite2D.play("face")
			1: $AnimatedSprite2D.play("droite")
			2: $AnimatedSprite2D.play("gauche")
			3: $AnimatedSprite2D.play("dos")
		return  # ne pas bouger pendant le dialogue
	
	# test dialogue avec la touche f
	if Input.is_action_just_pressed("dialogue"):
		start_dialogue()
	
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
				$AnimatedSprite2D.play("marche_droite")
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

func start_dialogue():
	print("Démarrage du dialogue...")
	dialogue_deja_lance = true
	
	# Lancer le dialogue Dialogic
	if Dialogic:
		Dialogic.start("timeline")

func _on_dialogue_ended():
	print("Dialogue terminé")
	dialogue_deja_lance = false
	# Le personnage peut bouger à nouveau
