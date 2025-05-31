extends CharacterBody2D

var vitesse = 80
var direction = 0 #0 face, 1 droite, 2 gauche, 3 dos
var dialogue_deja_lance = false

# Référence à l'inventaire
@onready var inventory_ui = preload("res://RPG-test/InventoryUI.tscn")
var inventory_instance = null

func _ready() -> void:
	# Connecter le signal de fin de dialogue si Dialogic est disponible
	if Dialogic:
		Dialogic.timeline_ended.connect(_on_dialogue_ended)
	
	# Créer l'instance d'inventaire
	inventory_instance = inventory_ui.instantiate()
	# Utiliser call_deferred au lieu de add_child direct
	get_tree().root.call_deferred("add_child", inventory_instance)
	
	call_deferred("add_test_items")
	
func _physics_process(_delta: float) -> void:
	# vérifier si un dialogue est en cours
	if Dialogic and Dialogic.current_timeline != null:
		# idle pendant dialogue
		match direction:
			0: $AnimatedSprite2D.play("face")
			1: $AnimatedSprite2D.play("droite")
			2: $AnimatedSprite2D.play("gauche")
			3: $AnimatedSprite2D.play("dos")
		return # ne pas bouger pendant le dialogue
	
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

# Ajouter un objet .tres à l'inventaire
func add_tres_inventaire(item_path: String, quantity: int = 1) -> bool:
	# Charger la ressource .tres
	var item_resource = load(item_path) as Item
	if item_resource == null:
		print("Erreur : Impossible de charger l'objet : ", item_path)
		return false

	# Vérifier que l'inventaire existe
	if inventory_instance == null:
		print("Erreur : Instance d'inventaire non trouvée")
		return false

	# Attendre que l'inventaire soit prêt
	if not inventory_instance.is_inside_tree():
		await get_tree().process_frame

	# Ajouter l'objet à l'inventaire
	var success = inventory_instance.add_item(item_resource, quantity)
	if success:
		print("Ajouté : ", item_resource.item_name, " x", quantity, " à l'inventaire")
	else:
		print("Échec : Inventaire plein ou erreur lors de l'ajout")

	return success

# Ajouter plusieurs objets .tres (pas encore essayé"
func add_multiple_tres_items(items_data: Array):
	for item_data in items_data:
		var path = item_data.get("path", "")
		var quantity = item_data.get("quantity", 1)
		if path != "":
			add_tres_inventaire(path, quantity)

func add_test_items():
	# Attendre que l'inventaire soit prêt
	if not inventory_instance or not inventory_instance.is_inside_tree():
		await get_tree().process_frame

	# Utiliser les objets .tres (chemin de la ressource + quantité)
	add_tres_inventaire("res://RPG-test/items/Pomme.tres", 3)



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
