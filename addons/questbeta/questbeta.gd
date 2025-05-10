@tool
extends EditorPlugin

var dock

func _enter_tree() -> void:
	dock = preload("res://addons/questbeta/Interface.tscn").instantiate() #Pour avoir un menu
	add_control_to_dock(DOCK_SLOT_LEFT_UL,dock)
	add_custom_type("Quete Trigger","Area2D",preload("res://addons/questbeta/Noeud-Quete.gd"),preload("res://addons/questbeta/icon/icon_quest.png"))
	

func _exit_tree() -> void:
	remove_control_from_docks(dock)
	remove_custom_type("Quete Trigger")
	dock.free()
