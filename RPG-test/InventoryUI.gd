extends CanvasLayer

@onready var grid_container = $Control/CenterContainer/MainPanel/HBoxContainer/LeftPanel/GridContainer
@onready var item_icon = $Control/CenterContainer/MainPanel/HBoxContainer/RightPanel/ItemInfoPanel/ItemInfoContainer/ItemIcon
@onready var item_name = $Control/CenterContainer/MainPanel/HBoxContainer/RightPanel/ItemInfoPanel/ItemInfoContainer/ItemName
@onready var item_description = $Control/CenterContainer/MainPanel/HBoxContainer/RightPanel/ItemInfoPanel/ItemInfoContainer/ItemDescription
@onready var close_button = $Control/CenterContainer/MainPanel/HBoxContainer/RightPanel/CloseButton

var inventory_data: Array = []
var slot_scene = preload("res://RPG-test/InventorySlotUI.tscn")
var slots: Array = []

var is_open = false

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	close_button.pressed.connect(_on_close_button_pressed)
	
	# Initialiser l'inventaire avec 20 slots
	initialize_inventory(20)
	clear_item_info()




func _unhandled_input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func initialize_inventory(slot_count: int):
	# Créer les données d'inventaire
	inventory_data.resize(slot_count)
	for i in range(slot_count):
		inventory_data[i] = {}
	
	# Créer les slots UI
	for i in range(slot_count):
		var slot_ui = slot_scene.instantiate()
		grid_container.add_child(slot_ui)
		slot_ui.slot_clicked.connect(_on_slot_clicked)
		slots.append(slot_ui)
		slot_ui.set_slot_data(inventory_data[i])

func toggle_inventory():
	is_open = !is_open
	visible = is_open
	get_tree().paused = is_open
	
	if is_open:
		refresh_inventory()
		clear_item_info()

func refresh_inventory():
	for i in range(slots.size()):
		if i < inventory_data.size():
			slots[i].set_slot_data(inventory_data[i])

func _on_slot_clicked(slot_ui):
	var slot_index = slots.find(slot_ui)
	if slot_index != -1:
		display_item_info(slot_index)

func display_item_info(slot_index: int):
	if slot_index >= inventory_data.size():
		clear_item_info()
		return
	
	var slot_data = inventory_data[slot_index]
	if slot_data.has("item") and slot_data["item"] != null:
		var item = slot_data["item"]
		item_icon.texture = item.icon
		item_name.text = item.item_name
		item_description.text = item.description
	else:
		clear_item_info()

func clear_item_info():
	item_icon.texture = null
	item_name.text = "Sélectionnez un objet"
	item_description.text = "Cliquez sur un objet dans l'inventaire pour voir ses détails."

func add_item(item: Item, quantity: int = 1) -> bool:
	# vérifier si l'objet peut être stacké avec un existant
	if item.is_stackable:
		for i in range(inventory_data.size()):
			var slot_data = inventory_data[i]
			if slot_data.has("item") and slot_data["item"] != null:
				if slot_data["item"].item_id == item.item_id:
					var current_quantity = slot_data.get("quantity", 1)
					var new_quantity = current_quantity + quantity
					if new_quantity <= item.max_stack:
						slot_data["quantity"] = new_quantity
						refresh_inventory()
						return true
	
	# trouver un slot vide
	for i in range(inventory_data.size()):
		if inventory_data[i].is_empty() or not inventory_data[i].has("item"):
			inventory_data[i] = {
				"item": item,
				"quantity": quantity
			}
			refresh_inventory()
			return true
	
	print("Inventaire plein !")
	return false

func remove_item(slot_index: int, quantity: int = 1) -> bool:
	if slot_index >= inventory_data.size():
		return false
	
	var slot_data = inventory_data[slot_index]
	if not slot_data.has("item") or slot_data["item"] == null:
		return false
	
	var current_quantity = slot_data.get("quantity", 1)
	if quantity >= current_quantity:
		inventory_data[slot_index] = {}
	else:
		slot_data["quantity"] = current_quantity - quantity
	
	refresh_inventory()
	clear_item_info()
	return true

func _on_close_button_pressed():
	toggle_inventory()
