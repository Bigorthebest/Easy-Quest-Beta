extends AnimatedSprite2D

var nom = "Chevalier" 
var pv = 100 
var pm = 50 

func _ready():
	pass

func is_alive():
	if pv > 0 : 
		return true 
	else :
		return false 

func is_player():
	return true

func degat(dg):
	pv -= dg 
	print("Pv du chevalier : ",pv)
