extends Node2D

var moveSpeed := 1
var direction := Vector2.RIGHT

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

#func _process(_delta: float) -> void:
	#var window = get_window()
	#var moveVector := Vector2i(direction * moveSpeed)
	#var usableRect := DisplayServer.screen_get_usable_rect()
	#window.position += moveVector
	#
	#if window.position.x + window.size.x > usableRect.end.x:
		#direction = Vector2.LEFT
	#elif window.position.x < usableRect.position.x:
		#direction = Vector2.RIGHT
