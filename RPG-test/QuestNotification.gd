extends CanvasLayer

@onready var title_label = $Control/Background/VBoxContainer/TitleLabel
@onready var quest_name_label = $Control/Background/VBoxContainer/QuestNameLabel
@onready var timer = $Timer

func _ready():
	visible = false  

func show_notification(quest_name: String):
	quest_name_label.text = quest_name
	visible = true
	
	# Animer l'apparition 
	var tween = create_tween()
	tween.tween_property($Control, "modulate:a", 1.0, 0.3).from(0.0)
	
	timer.start()

func _on_timer_timeout():
	# Animer la disparition
	var tween = create_tween()
	tween.tween_property($Control, "modulate:a", 0.0, 0.3).finished.connect(hide)
	# ou hide()
