extends Resource
class_name Inventory

signal inventory_changed

@export var items: Array[InventorySlot] = []
@export var size: int = 20

func _init(p_size: int = 20):
	size = p_size
	items.resize(size)
	for i in range(size):
		items[i] = InventorySlot.new()

func add_item(item: Item, quantity: int = 1) -> bool:
	# Essayer d'empiler avec des objets existants si stackable
	if item.is_stackable:
		for slot in items:
			if slot.item && slot.item.item_id == item.item_id:
				var can_add = min(quantity, item.max_stack - slot.quantity)
				slot.quantity += can_add
				quantity -= can_add
				if quantity <= 0:
					inventory_changed.emit()
					return true
	
	# Trouver un slot vide
	for slot in items:
		if slot.item == null:
			slot.item = item
			slot.quantity = quantity
			inventory_changed.emit()
			return true
	
	return false # Inventaire plein

func remove_item(index: int, quantity: int = 1) -> bool:
	if index < 0 or index >= items.size():
		return false
	
	var slot = items[index]
	if slot.item == null:
		return false
	
	slot.quantity -= quantity
	if slot.quantity <= 0:
		slot.item = null
		slot.quantity = 0
	
	inventory_changed.emit()
	return true

func get_item(index: int) -> InventorySlot:
	if index < 0 or index >= items.size():
		return null
	return items[index]
