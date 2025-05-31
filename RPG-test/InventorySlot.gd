extends Resource
class_name InventorySlot

@export var item: Item
@export var quantity: int = 0

func _init(p_item: Item = null, p_quantity: int = 0):
	item = p_item
	quantity = p_quantity

func is_empty() -> bool:
	return item == null or quantity <= 0

func clear():
	item = null
	quantity = 0
