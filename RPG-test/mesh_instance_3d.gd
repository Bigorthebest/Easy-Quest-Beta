extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	rotate_y(1.0 * delta)
	rotate_x(0.5 * delta)
