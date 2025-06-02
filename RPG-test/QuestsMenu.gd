extends CanvasLayer

signal quest_menu_closed

@onready var quests_list = $Control/CenterContainer/Panel/VBoxContainer/ScrollContainer/QuestsList
@onready var no_quests_label = $Control/CenterContainer/Panel/VBoxContainer/ScrollContainer/QuestsList/NoQuestsLabel

var quest_file = "user://bdd.json"

func _ready():
	# NOUVEAU : Activer le mode menu pour la musique
	MusicManager.set_menu_mode(true)
	load_active_quests()

func load_active_quests():
		# Vider la liste existante (sauf le label "Aucune quête")
	#for child in quests_list.get_children():
		#if child != no_quests_label:
			#child.queue_free()
	#
	#if not FileAccess.file_exists(quest_file):
		#no_quests_label.visible = true
		#return
	#
	#var file = FileAccess.open(quest_file, FileAccess.ModeFlags.READ)
	#var content = file.get_as_text()
	#file.close()
	#
	#var quests_data = JSON.parse_string(content)
	#if typeof(quests_data) != TYPE_DICTIONARY:
		#no_quests_label.visible = true
		#return
	for child in quests_list.get_children():
		child.queue_free()
	
	var quests_data = DataBridge.all_quetes
	var active_quests = []
	
	for quest_id in quests_data:
		if quests_data[quest_id]["Active"] == true:
			active_quests.append(quests_data[quest_id])
	
	if active_quests.size() == 0:
		no_quests_label.visible = true
		return
	
	no_quests_label.visible = false
	print("Active quest ", active_quests) # Créer les éléments de quête
	
	for quest in active_quests:
		create_quest_item(quest)

func calculate_font_size_for_length(text: String, base_size: int, max_characters: int) -> int:
	var text_length = text.length()
	if text_length <= max_characters:
		return base_size
	else:
		var reduction_factor = float(max_characters) / float(text_length)
		var new_size = int(base_size * reduction_factor)
		return max(new_size, 12)

func create_quest_item(quest_data: Dictionary):
	var quest_container = VBoxContainer.new()
	quest_container.add_theme_constant_override("separation", 15)
	
	var quest_panel = Panel.new()
	quest_panel.custom_minimum_size = Vector2(0, 120)
	
	var quest_content = VBoxContainer.new()
	quest_content.anchors_preset = Control.PRESET_FULL_RECT
	quest_content.offset_left = 15
	quest_content.offset_top = 15
	quest_content.offset_right = -15
	quest_content.offset_bottom = -15
	# Titre de la quête 
	var title_label = Label.new()
	var title_text = quest_data.get("Titre", "Titre inconnu")
	title_label.text = title_text
	var title_font_size = calculate_font_size_for_length(title_text, 24, 30)
	title_label.add_theme_font_size_override("font_size", title_font_size)
	title_label.add_theme_color_override("font_color", Color.YELLOW)
	# Description de la quête 
	var desc_label = Label.new()
	var desc_text = quest_data.get("Description", "Pas de description")
	desc_label.text = desc_text
	var desc_font_size = calculate_font_size_for_length(desc_text, 20, 50)
	desc_label.add_theme_font_size_override("font_size", desc_font_size)
	desc_label.add_theme_color_override("font_color", Color.WHITE)
	
	var reward = quest_data.get("Recompense", "")
	var reward_text = ""
	# Créer le label de récompense seulement s'il y a du contenu
	if typeof(reward) == TYPE_ARRAY and reward.size() > 0:
		var or_amount = reward[0] if reward.size() > 0 else 0
		var xp_amount = reward[1] if reward.size() > 1 else 0
		var items = reward[2] if reward.size() > 2 else ""
		
		reward_text = "Récompense: " + str(or_amount) + " Or, " + str(xp_amount) + " XP"
		if items != "":
			reward_text += ", " + str(items)
	elif typeof(reward) == TYPE_STRING and reward != "":
		reward_text = "Récompense: " + reward
	
	if reward_text != "":
		var reward_label = Label.new()
		reward_label.text = reward_text
		var reward_font_size = calculate_font_size_for_length(reward_text, 16, 40)
		reward_label.add_theme_font_size_override("font_size", reward_font_size)
		reward_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
		quest_content.add_child(reward_label)
	
	quest_content.add_child(title_label)
	quest_content.add_child(desc_label)
	
	quest_panel.add_child(quest_content)
	quest_container.add_child(quest_panel)
	
	var separator = HSeparator.new()
	quest_container.add_child(separator)
	
	quests_list.add_child(quest_container)

func _on_retour_pressed():
	print("Retour au menu pause")
	#  Remettre le mode menu normal
	quest_menu_closed.emit()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_retour_pressed()
