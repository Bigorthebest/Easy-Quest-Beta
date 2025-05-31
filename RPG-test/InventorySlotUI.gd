extends Control

@onready var item_icon = $ItemIcon
@onready var quantity_label = $QuantityLabel
@onready var button = $Button

var slot_data: Dictionary = {}

signal slot_clicked(slot_ui)

func _ready():
	button.pressed.connect(_on_button_pressed)
	clear_slot()

func set_slot_data(data: Dictionary):
	slot_data = data
	update_display()

func update_display():
	if slot_data.is_empty() or not slot_data.has("item"):
		clear_slot()
		return
	
	var item = slot_data["item"]
	if item:
		item_icon.texture = item.icon
		var quantity = slot_data.get("quantity", 1)
		if quantity > 1:
			quantity_label.text = str(quantity)
			quantity_label.visible = true
		else:
			quantity_label.visible = false
	else:
		clear_slot()

func clear_slot():
	item_icon.texture = null
	quantity_label.visible = false
	slot_data = {}

func _on_button_pressed():
	slot_clicked.emit(self)

func get_item() -> Item:
	if slot_data.has("item"):
		return slot_data["item"]
	return null

func has_item() -> bool:
	return slot_data.has("item") and slot_data["item"] != null
