extends EditorProperty

var property_control = Button.new()
var icon = load("res://addons/questbeta/icon/icon_quest.png")
var fenetre = null 
var scene_fen = preload("res://addons/questbeta/interface-select.tscn")
var fen = scene_fen.instantiate()
var noeud_courant 

func set_noeud_courant(noeud):
	noeud_courant = noeud 

func _init():
	var hbox = HBoxContainer.new()
	var label = Label.new()
	label.text = "Option de quete :"

	property_control.text = "Lier une Quete"
	property_control.icon = icon
	property_control.pressed.connect(_on_button_pressed)
	
	hbox.add_child(label)	
	hbox.add_child(property_control)

	add_child(hbox)
	add_focusable(hbox)

func _on_button_pressed():
	print("Liée une quete cliquer")
	if fenetre == null : 
		print("fenetre ouverte")
		fenetre = Window.new()
		fenetre.title = "Menu de Selection de quete"
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
	if noeud_courant :
		noeud_courant._transmettre_quest(valeur)
