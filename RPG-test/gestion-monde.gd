extends Node2D

func _ready():
	var follower = $ElCube
	var hero = $Personnage
	follower.target = hero
