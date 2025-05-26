extends EditorInspectorPlugin

var BoutonQuestBind = preload("res://addons/questbeta/FonctionEditor.gd")
var node_courant 

func _can_handle(object):
	return object is Area2D

func _parse_end(object): #Permet de placer le bouton a la fin 
	var editeur = BoutonQuestBind.new()
	editeur.set_noeud_courant(object)
	add_custom_control(editeur)
