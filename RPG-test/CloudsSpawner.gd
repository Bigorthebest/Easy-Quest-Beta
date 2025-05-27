extends Node2D

@export var cloud_texture: Texture2D = preload("res://RPG-test/sprites/Clouds.png")
@export var cloud_vitesse: float = 10.0
@export var spawn_intervalle: float = 8.0
@export var cloud_scale_min: float = 0.8
@export var cloud_scale_max: float = 1.2
@export var y_variation: float = 100.0

# zone de couverture des nuages
@export var zone_largeur: float = 2000.0  # Largeur de la zone de nuages
@export var zone_hauteur: float = 1200.0  # Hauteur de la zone de nuages
@export var densite_nuages: int = 50  # Nombre de nuages initiaux dans la zone
@export var marge_spawn: float = 300.0  # Distance de spawn en dehors de l'écran

var clouds_array: Array = []
var spawn_timer: float = 0.0
var screen_width: float
var screen_height: float
var camera: Camera2D
var zone_min_x: float
var zone_max_x: float
var zone_min_y: float
var zone_max_y: float

func _ready():
	# obtenir la caméra du joueur
	camera = get_viewport().get_camera_2d()
	
	# obtenir la taille de l'écran
	screen_width = get_viewport().get_visible_rect().size.x
	screen_height = get_viewport().get_visible_rect().size.y
	
	# définir les limites de la zone de nuages
	update_zone_limits()
	
	# remplir la zone initiale avec des nuages
	populate_initial_clouds()

func _process(delta):
	spawn_timer += delta
	
	# mettre à jour les limites de la zone selon la position de la caméra
	update_zone_limits()
	
	# spawner de nouveaux nuages périodiquement
	if spawn_timer >= spawn_intervalle:
		spawn_new_clouds()
		spawn_timer = 0.0
	
	# déplacer tous les nuages
	move_clouds(delta)
	
	# supprimer les nuages hors de la zone étendue
	cleanup_clouds()

func update_zone_limits():
	if camera:
		var camera_pos = camera.global_position
		zone_min_x = camera_pos.x - zone_largeur/2
		zone_max_x = camera_pos.x + zone_largeur/2
		zone_min_y = camera_pos.y - zone_hauteur/2
		zone_max_y = camera_pos.y + zone_hauteur/2
	else:
		zone_min_x = -zone_largeur/2
		zone_max_x = zone_largeur/2
		zone_min_y = -zone_hauteur/2
		zone_max_y = zone_hauteur/2

func populate_initial_clouds():
	# remplir toute la zone avec des nuages initiaux
	for i in range(densite_nuages):
		var random_x = randf_range(zone_min_x, zone_max_x)
		var random_y = randf_range(zone_min_y, zone_max_y)
		spawn_cloud_at_position(random_x, random_y)

func spawn_new_clouds():
	# spawner des nuages sur le bord droit de la zone étendue
	var spawn_x = zone_max_x + marge_spawn
	var nombre_nouveaux_nuages = randi_range(2, 5)
	
	for i in range(nombre_nouveaux_nuages):
		var random_y = randf_range(zone_min_y, zone_max_y)
		spawn_cloud_at_position(spawn_x, random_y)

func spawn_cloud_at_position(x_position: float, y_position: float):
	var cloud = Sprite2D.new()
	cloud.texture = cloud_texture
	cloud.position.x = x_position
	cloud.position.y = y_position + randf_range(-y_variation, y_variation)
	
	# variation de l'échelle
	var random_scale = randf_range(cloud_scale_min, cloud_scale_max)
	cloud.scale = Vector2(random_scale, random_scale)
	
	# variation d'opacité 
	cloud.modulate.a = randf_range(0.3, 0.8)
	
	# variation de couleur légère
	var color_variation = randf_range(0.9, 1.1)
	cloud.modulate = Color(color_variation, color_variation, color_variation, cloud.modulate.a)
	
	add_child(cloud)
	clouds_array.append(cloud)

func move_clouds(delta: float):
	for cloud in clouds_array:
		if cloud and is_instance_valid(cloud):
			cloud.position.x -= cloud_vitesse * delta

func cleanup_clouds():
	# supprimer les nuages qui sont sortis de la zone étendue
	for i in range(clouds_array.size() - 1, -1, -1):
		var cloud = clouds_array[i]
		if cloud and is_instance_valid(cloud):
			# supprimer si le nuage est trop loin à gauche de la zone
			if cloud.position.x < zone_min_x - marge_spawn:
				cloud.queue_free()
				clouds_array.remove_at(i)
			# supprimer aussi si trop loin verticalement
			elif cloud.position.y < zone_min_y - marge_spawn or cloud.position.y > zone_max_y + marge_spawn:
				cloud.queue_free()
				clouds_array.remove_at(i)

# ajuster la densité en temps réel
func adjust_cloud_density(new_density: int):
	densite_nuages = new_density
	# supprimer tous les nuages existants
	for cloud in clouds_array:
		if cloud and is_instance_valid(cloud):
			cloud.queue_free()
	clouds_array.clear()
	# repeupler avec la nouvelle densité
	populate_initial_clouds()
