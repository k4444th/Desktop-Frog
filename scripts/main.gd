extends Node2D

var moveSpeed := 1
var direction := Vector2.RIGHT
var clickPending := false
var clickPosition := Vector2.ZERO

@onready var frogNode := $Frog
@onready var clickTimer := $ClickTimer

func _ready() -> void:
	var window = get_window()
	
	get_viewport().transparent_bg = true
	window.transparent = true 
	window.borderless = true
	window.always_on_top = true
	window.unresizable = true
	
	var usableRect := DisplayServer.screen_get_usable_rect()
	var yPos = usableRect.end.y - window.size.y
	
	window.position = Vector2i(0, yPos)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if clickTimer.time_left > 0:
			clickTimer.stop()
			clickPending = false
			
			var is_left_side = event.position.x < get_window().size.x / 2.0
			frogNode.jump(is_left_side, true)
		
		else:
			clickPending = true
			clickPosition = event.position
			clickTimer.start()

func _on_click_timer_timeout() -> void:
	if clickPending:
		clickPending = false
	
	frogNode.jump(clickPosition.x < get_window().size.x / 2.0, false)
