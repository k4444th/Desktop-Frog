extends Node2D

var moveSpeed := 1
var direction := Vector2.RIGHT

@onready var frogNode := $Frog

func _ready() -> void:
	var window = get_window()
	
	get_viewport().transparent_bg = true
	window.transparent = true 
	window.borderless = true
	window.always_on_top = true
	window.unresizable = false
	
	var usableRect := DisplayServer.screen_get_usable_rect()
	var yPos = usableRect.end.y - window.size.y
	
	window.position = Vector2i(0, yPos)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		frogNode.jump(event.position.x < get_window().size.x / 2.0)
