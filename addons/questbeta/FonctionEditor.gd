extends EditorProperty

var icon = load("res://addons/questbeta/icon/icon_quest.png")
var fenetre = null 
var scene_fen = preload("res://addons/questbeta/interface-select.tscn")
var fen = scene_fen.instantiate()
var noeud_courant 
@export var quete_courante : String
#Ajout dans l'inspecteur
var property_control = Button.new()
var vbox = VBoxContainer.new()
var hbox  = HBoxContainer.new()
var nom = Label.new()
var information = Label.new()

func set_noeud_courant(noeud):
	noeud_courant = noeud 

func _init():
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	nom.text = "Option de quete :"
	nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	property_control.text = "Lier une Quete"
	property_control.icon = icon
	property_control.pressed.connect(_on_button_pressed)

	hbox.add_child(nom)
	hbox.add_child(property_control)
	
	information.text = ("Information :" + "placeholder :)")
	information.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	vbox.add_child(hbox)
	vbox.add_child(information)
	
	add_child(vbox)
	add_focusable(vbox)
	
func _update_property() -> void:
	information.text = ("Information :" + quete_courante)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		#hbox.size_flags_horizontal = Vector2(size.x, 0)
		#hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _on_button_pressed():
	print("Lier une quete cliquée")
	if fenetre == null : 
		print("Fenêtre ouverte")
		fenetre = Window.new()
		fenetre.title = "Menu de séléction de quête"
		fenetre.size = Vector2(600, 200)
		
		#var scene_instance = scene_fen.instantiate()
		#scene_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		#scene_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL
		fen.bind_quest.connect(_on_signal_quest)
		fenetre.add_child(fen)
		fenetre.close_requested.connect(fenetre.hide)
		
		get_tree().root.add_child(fenetre)

	fenetre.popup_centered()
	
func _on_signal_quest(valeur):
	print("Signal reçu :",valeur)
	quete_courante = valeur 
	information.text = ("Information : " + quete_courante)
	if noeud_courant :
		noeud_courant._transmettre_quest(valeur)
