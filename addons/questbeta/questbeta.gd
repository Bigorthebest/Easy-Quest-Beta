@tool
extends EditorPlugin

var dock
var fenetre

func _enter_tree() -> void:
	dock = preload("res://addons/questbeta/Interface.tscn").instantiate() #Pour avoir un menu
	add_control_to_dock(DOCK_SLOT_LEFT_UL,dock)
	#fenetre = preload("res://addons/questbeta/Test-fenetre.tscn").instantiate()
	#add_control_to_container(fenetre)
	

func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.free()
	#fenetre.free()
