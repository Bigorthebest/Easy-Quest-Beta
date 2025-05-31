extends Resource
class_name Item

@export var item_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var is_stackable: bool = false
@export var max_stack: int = 1
@export var item_id: String = ""

func _init(p_name: String = "", p_description: String = "", p_icon: Texture2D = null, p_stackable: bool = false, p_max_stack: int = 1, p_id: String = ""):
	item_name = p_name
	description = p_description
	icon = p_icon
	is_stackable = p_stackable
	max_stack = p_max_stack
	item_id = p_id
