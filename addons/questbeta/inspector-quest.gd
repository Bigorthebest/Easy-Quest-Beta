extends EditorInspectorPlugin

var RandomIntEditor = preload("res://addons/questbeta/FonctionEditor.gd")


func _can_handle(object):
	return object is Area2D

func _parse_end(object): #Permet de placer le bouton a la fin 
	add_custom_control(RandomIntEditor.new())
