extends AudioStreamPlayer

#  gérer la musique globale
var base_volume: float = -5.0
var menu_volume: float = -10.0
var is_in_menu: bool = false

var main_music = preload("res://RPG-test/music/Woodland Fantasy.mp3")

func _ready():
	# Configuration initiale
	stream = main_music
	volume_db = base_volume
	# autoplay = true
	process_mode = Node.PROCESS_MODE_ALWAYS


func play_main_music():
	if not playing:
		stream = main_music
		play()
		print("Musique du monde démarrée")

func stop_music():
	stop()
	print("Musique arrêtée")

func set_menu_mode(enabled: bool):
	is_in_menu = enabled
	if enabled:
		# Baisser le volume pour les menus
		var tween = create_tween()
		tween.tween_property(self, "volume_db", menu_volume, 0.3)
	else:
		# Remettre le volume normal
		var tween = create_tween()
		tween.tween_property(self, "volume_db", base_volume, 0.3)

func set_volume(db: float):
	volume_db = db
