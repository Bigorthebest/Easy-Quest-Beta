extends CanvasLayer

@onready var title_label = $Control/Background/VBoxContainer/TitleLabel
@onready var quest_name_label = $Control/Background/VBoxContainer/QuestNameLabel
@onready var timer = $Timer

# NOUVEAU : Sons différents pour chaque type de notification
var new_quest_sound = preload("res://RPG-test/sounds/ping.ogg")
var completed_quest_sound = preload("res://RPG-test/sounds/ping2.ogg")  # NOUVEAU son

var audio_player: AudioStreamPlayer

# NOUVEAU : Système de queue pour les notifications
var notification_queue: Array = []
var is_displaying: bool = false

# NOUVEAU : Types de notifications
enum NotificationType {
	NEW_QUEST,
	COMPLETED_QUEST
}

func _ready():
	visible = false
	audio_player = AudioStreamPlayer.new()
	audio_player.volume_db = -5.0
	add_child(audio_player)

# NOUVELLE FONCTION : Ajouter une notification à la queue
func add_notification_to_queue(quest_name: String, type: NotificationType):
	var notification_data = {
		"quest_name": quest_name,
		"type": type
	}
	notification_queue.append(notification_data)
	
	# Si aucune notification n'est en cours, démarrer l'affichage
	if not is_displaying:
		process_next_notification()

# NOUVELLE FONCTION : Traiter la prochaine notification dans la queue
func process_next_notification():
	if notification_queue.is_empty():
		is_displaying = false
		return
	
	is_displaying = true
	var next_notification = notification_queue.pop_front()
	display_notification(next_notification.quest_name, next_notification.type)

# FONCTION MODIFIÉE : Afficher une notification avec type
func display_notification(quest_name: String, type: NotificationType):
	quest_name_label.text = quest_name
	
	# NOUVEAU : Configurer selon le type de notification
	match type:
		NotificationType.NEW_QUEST:
			title_label.text = "Nouvelle Quête:"
			title_label.modulate = Color(1, 0.843137, 0, 1)  # Jaune
			audio_player.stream = new_quest_sound
			timer.wait_time = 3.0
		
		NotificationType.COMPLETED_QUEST:
			title_label.text = "Quête Terminée:"
			title_label.modulate = Color(0, 1, 0, 1)  # Vert
			audio_player.stream = completed_quest_sound
			timer.wait_time = 4.0  # Plus long pour les quêtes terminées
	
	visible = true
	
	if audio_player and audio_player.stream:
		audio_player.play()
	
	# Animer l'apparition
	var tween = create_tween()
	tween.tween_property($Control, "modulate:a", 1.0, 0.3).from(0.0)
	
	timer.start()

# ANCIENNE FONCTION : Maintenir la compatibilité
func show_notification(quest_name: String):
	add_notification_to_queue(quest_name, NotificationType.NEW_QUEST)

# NOUVELLE FONCTION : Afficher notification de quête terminée
func show_quest_completed(quest_name: String):
	add_notification_to_queue(quest_name, NotificationType.COMPLETED_QUEST)

func _on_timer_timeout():
	# Animer la disparition
	var tween = create_tween()
	tween.tween_property($Control, "modulate:a", 0.0, 0.3).finished.connect(_on_fade_out_complete)

# NOUVELLE FONCTION : Appelée quand l'animation de disparition est terminée
func _on_fade_out_complete():
	hide()
	# Traiter la prochaine notification dans la queue
	process_next_notification()
