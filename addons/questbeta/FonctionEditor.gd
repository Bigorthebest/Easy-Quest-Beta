extends EditorProperty

var property_control = Button.new()
var icon = load("res://addons/questbeta/icon/icon_quest.png")
var fenetre = null 

func _init():
	add_child(property_control)
	add_focusable(property_control)
	
	property_control.text = "Lier une Quete"
	property_control.icon = icon
	property_control.pressed.connect(_on_button_pressed)
	

func _on_button_pressed():
	print("Liée une quete cliquer")
	if fenetre == null : 
		print("fenetre ouverte")
		fenetre = Window.new()
		fenetre.title = "Menu de Selection de quete"
		fenetre.size = Vector2(300, 200)
		fenetre.resizable = false
