extends Node2D

@onready var parachuteNode := $Parachute

func open():
	visible = true
	parachuteNode.play("opening")

func close():
	parachuteNode.play("closing")

func _on_parachute_animation_finished() -> void:
	if parachuteNode.animation == "opening":
		parachuteNode.play("open")
	elif parachuteNode.animation == "closing":
		visible = false
