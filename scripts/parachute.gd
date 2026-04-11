extends Node2D

@onready var parachuteNode := $Parachute

signal parachuteClosed()

func _ready() -> void:
	visible = false

func open():
	visible = true
	parachuteNode.play("opening")

func close():
	parachuteNode.play("closing")

func _on_parachute_animation_finished() -> void:
	if parachuteNode.animation == "opening":
		parachuteNode.play("open")
	elif parachuteNode.animation == "closing":
		parachuteClosed.emit()
		visible = false
