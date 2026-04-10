extends Node2D

var usableRect: Rect2
var frogSize := Vector2.ZERO
var parachuteSize := Vector2.ZERO
var parachuteOffset := Vector2(0, 4)

@onready var mainWindow = get_window()
@onready var frogNode := $Frog
@onready var parachuteNode := $Parachute
@onready var frogIdleArea := $IdleArea
@onready var frogJumpingArea := $JumpingArea

func _ready() -> void:
	frogNode.jumpEnd.connect(frogNodeJumpEnd)
	
	frogSize = frogNode.bodyNode.sprite_frames.get_frame_texture("idle", 0).get_size()
	parachuteSize = parachuteNode.parachuteNode.sprite_frames.get_frame_texture("open", 0).get_size()
	
	initWindow()
	initScale()
	initWindowPosition()
	initSpritePositions()
	setMousePassthroughArea(frogIdleArea)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		frogNode.jump(frogNode.to_local(event.position).x < 0)
		setMousePassthroughArea(frogJumpingArea)

func initWindow():
	mainWindow.transparent_bg = true
	mainWindow.transparent = true 
	mainWindow.borderless = true
	mainWindow.always_on_top = true
	mainWindow.unresizable = true

func initScale():
	frogNode.scale = Vector2(Globals.data.scale, Globals.data.scale)
	parachuteNode.scale = Vector2(Globals.data.scale, Globals.data.scale)

func initWindowPosition():
	usableRect = DisplayServer.screen_get_usable_rect()
	
	mainWindow.position = usableRect.position
	mainWindow.size = usableRect.size

func initSpritePositions():
	usableRect = DisplayServer.screen_get_usable_rect()

	frogNode.position = Vector2((frogSize.x * Globals.data.scale) / 2, usableRect.size.y - (frogSize.y * Globals.data.scale) / 2)
	parachuteNode.position = frogNode.position + parachuteOffset * Globals.data.scale

func setMousePassthroughArea(polygon: Polygon2D):
	var area = PackedVector2Array()
	
	for p in polygon.polygon:
		area.append(p * Globals.data.scale + frogNode.position)
	
	DisplayServer.window_set_mouse_passthrough(area)

func frogNodeJumpEnd():
	setMousePassthroughArea(frogIdleArea)
