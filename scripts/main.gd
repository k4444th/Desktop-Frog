extends Node2D

@onready var mainWindow = get_window()
@onready var frogNode := $Frog
@onready var frogIdleArea := $IdleArea
@onready var frogJumpingArea := $JumpingArea

func _ready() -> void:
	frogNode.jumpEnd.connect(frogNodeJumpEnd)
	
	initWindow()
	initScale()
	initWindowPosition()
	setMousePassthroughArea(frogIdleArea)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		frogNode.jump(event.position.x < mainWindow.size.x / 2.0)
		setMousePassthroughArea(frogJumpingArea)

func initWindow():
	get_viewport().transparent_bg = true
	mainWindow.transparent = true 
	mainWindow.borderless = true
	mainWindow.always_on_top = true
	mainWindow.unresizable = true

func initScale():
	frogNode.scale = Vector2(Globals.data.scale, Globals.data.scale)
	mainWindow.size = frogNode.sprite_frames.get_frame_texture("jump", 0).get_size() * Globals.data.scale

func initWindowPosition():
	var usableRect := DisplayServer.screen_get_usable_rect()
	var yPos = usableRect.end.y - mainWindow.size.y
	
	mainWindow.position = Vector2i(0, yPos)

func setMousePassthroughArea(polygon: Polygon2D):
	var area = PackedVector2Array()
	
	for p in polygon.polygon:
		area.append(p * Globals.data.scale + mainWindow.size / 2.0)
	
	DisplayServer.window_set_mouse_passthrough(area)

func frogNodeJumpEnd():
	setMousePassthroughArea(frogIdleArea)
