extends Node2D

# General
var usableRect: Rect2

# Sprite sizes
var frogSize := Vector2.ZERO
var parachuteSize := Vector2.ZERO
var flySize := Vector2.ZERO

# Offset constans
var frogFlyingOffset := Vector2(0, 13)
var parachuteOffset := Vector2(3, -32)

# Click logic
var clickCancelled := false

# Drag logic
var mouseDown := false
var isDragging := false
var dragOffset := Vector2.ZERO

# Flying logic
var isFlying := false

# General (onready)
@onready var mainWindow = get_window()
@onready var deadzoneTimer := $DeadzoneTimer

# Frog (onready)
@onready var frogNode := $Frog
@onready var frogCameraNode := $Camera
@onready var frogIdleArea := $FrogIdleArea
@onready var frogWholeArea := $FrogWholeArea

# Parachute (onready)
@onready var parachuteNode := $Parachute
@onready var parachuteWindow := $ParachuteWindow
@onready var parachuteCameraNode := $ParachuteWindow/Camera

# Fly (onready)
@onready var flyNode := $Fly
@onready var flyWindow := $FlyWindow
@onready var flyCameraNode := $FlyWindow/Camera
@onready var flyArea := $FlyArea

func _ready() -> void:
	frogNode.jumpEnd.connect(frogNodeJumpEnd)
	parachuteNode.parachuteClosed.connect(parachuteClosed)
	parachuteWindow.close_requested.connect(queue_free)
	flyNode.flyPositionChanged.connect(flyPositionChanged)
	
	initWindows()
	initWindowWorlds()
	initSpriteSizes()
	initSpriteScales()
	initWindowSizes()
	initSpritePositions()
	setMousePassthroughAreas()
	initSubwindowsVisibility()
	setWindowPositions()
	setCameraPositions()

func _physics_process(_delta: float) -> void:
	setWindowPositions()
	setCameraPositions()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		print(event)
		if event.pressed:
			mouseDown = true
			clickCancelled = false
			deadzoneTimer.start()
			dragOffset = frogNode.get_local_mouse_position()
		else:
			mouseDown = false
			
			if not clickCancelled:
				frogNode.jump(event.position.x < mainWindow.size.x / 2.0)
				setMousePassthroughArea(frogWholeArea, mainWindow)
			
			if isDragging:
				isDragging = false
				flyDown()
	
	if event is InputEventMouseMotion:
		if mouseDown and event.relative.length() > 2:
			isDragging = true
			frogNode.position = get_global_mouse_position() - dragOffset * Globals.data.scale
			
			var minPos = usableRect.position + Vector2(0, (parachuteSize.y + parachuteOffset.y) * Globals.data.scale)
			var maxPos = Vector2(usableRect.size.x - frogSize.x * Globals.data.scale, usableRect.position.y + usableRect.size.y - frogSize.y * Globals.data.scale)
			frogNode.position = frogNode.position.clamp(minPos, maxPos)
			
			setMousePassthroughArea(frogIdleArea, mainWindow)

func initWindows():
	initWindow(mainWindow)
	initWindow(parachuteWindow)
	initWindow(flyWindow)
	
	mainWindow.grab_focus() 

func initWindow(window: Window):
	window.transparent_bg = true
	window.transparent = true 
	window.borderless = true
	window.always_on_top = true
	window.unresizable = true

func initWindowWorlds():
	parachuteWindow.world_2d = mainWindow.world_2d
	flyWindow.world_2d = mainWindow.world_2d

func initSpriteSizes():
	frogSize = frogNode.bodyNode.sprite_frames.get_frame_texture("idle", 0).get_size()
	parachuteSize = parachuteNode.parachuteNode.sprite_frames.get_frame_texture("open", 0).get_size()
	flySize = flyNode.bodyNode.sprite_frames.get_frame_texture("fly", 0).get_size()

func initSpriteScales():
	frogNode.scale = Vector2(Globals.data.scale, Globals.data.scale)
	parachuteNode.scale = Vector2(Globals.data.scale, Globals.data.scale)
	flyNode.scale = Vector2(Globals.data.scale, Globals.data.scale)

func initWindowSizes():
	mainWindow.size = frogSize * Globals.data.scale
	parachuteWindow.size = parachuteSize * Globals.data.scale
	flyWindow.size = flySize * Globals.data.scale

func initSpritePositions():
	usableRect = DisplayServer.screen_get_usable_rect()
	
	frogNode.position = usableRect.position + Vector2(0, usableRect.size.y - frogSize.y * Globals.data.scale)
	parachuteNode.position = frogNode.position + Vector2(parachuteOffset.x, 0) * Globals.data.scale
	flyNode.position = usableRect.position + Vector2(usableRect.size.x - flySize.x * Globals.data.scale, 50)

func initSubwindowsVisibility():
	parachuteWindow.visible = false
	flyWindow.visible = true

func setWindowPositions():
	flyWindow.position = flyNode.position
	
	if isFlying:
		return
	
	usableRect = DisplayServer.screen_get_usable_rect()
	
	mainWindow.position = frogNode.position
	parachuteWindow.position = parachuteNode.position + Vector2(0, parachuteOffset.y) * Globals.data.scale

func setCameraPositions():
	flyCameraNode.position = flyNode.position
	
	if isFlying:
		return
		
	frogCameraNode.position = frogNode.position
	parachuteCameraNode.position = parachuteNode.position + Vector2(0, parachuteOffset.y) * Globals.data.scale

func setMousePassthroughAreas():
	setMousePassthroughArea(frogIdleArea, mainWindow)
	setMousePassthroughArea(Polygon2D.new(), parachuteWindow)
	setMousePassthroughArea(flyArea, flyWindow)

func setMousePassthroughArea(polygon: Polygon2D, window: Window):
	var area = PackedVector2Array()
	
	for p in polygon.polygon:
		area.append(p * Globals.data.scale)
	
	DisplayServer.window_set_mouse_passthrough(area, window.get_window_id())

func frogNodeJumpEnd():
	setMousePassthroughArea(frogIdleArea, mainWindow)

func flyDown():
	usableRect = DisplayServer.screen_get_usable_rect()
	setMousePassthroughArea(frogWholeArea, mainWindow)
	
	var yPos = usableRect.position.y + usableRect.size.y - (frogSize.y * Globals.data.scale)
	var xPos = clamp(frogNode.position.x, 0, usableRect.size.x - (frogSize.x * Globals.data.scale))
	
	frogNode.position += frogFlyingOffset * Globals.data.scale
	parachuteNode.position = frogNode.position + Vector2(parachuteOffset.x, 0) * Globals.data.scale
	
	setCameraPositions()
	setWindowPositions()
	
	var flyTime = pow(abs(frogNode.position.y - yPos), 0.6) * 0.0175
	var parachuteAnimationDuration = (1 / parachuteNode.parachuteNode.sprite_frames.get_animation_speed("opening")) * parachuteNode.parachuteNode.sprite_frames.get_frame_count("opening")
	
	if flyTime > parachuteAnimationDuration:
		parachuteNode.position = frogNode.position + Vector2(parachuteOffset.x, 0) * Globals.data.scale
		parachuteWindow.position = parachuteNode.position + Vector2(0, parachuteOffset.y) * Globals.data.scale
		parachuteCameraNode.position = parachuteNode.position + Vector2(0, parachuteOffset.y) * Globals.data.scale
		parachuteWindow.visible = true
		parachuteNode.open()
	
	isFlying = true
	
	frogNode.bodyNode.play("flying")
	frogNode.eyesNode.visible = false
	
	var frogPositionTween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	frogPositionTween.tween_property(frogNode, "position", Vector2(xPos, yPos), flyTime)
	
	var mainWindowPositionTween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	mainWindowPositionTween.tween_property(mainWindow, "position", Vector2i(xPos, yPos), flyTime)
	
	var frogCameraPositionTween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	frogCameraPositionTween.tween_property(frogCameraNode, "position", Vector2(xPos, yPos), flyTime)
	
	var parachutePositionTween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	parachutePositionTween.tween_property(parachuteNode, "position", Vector2(xPos + parachuteOffset.x * Globals.data.scale, yPos), flyTime)
	
	var parachuteWindowPositionTween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	parachuteWindowPositionTween.tween_property(parachuteWindow, "position", Vector2i(xPos, yPos) + Vector2i(parachuteOffset) * Globals.data.scale, flyTime)
	
	var parachuteCameraPositionTween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	parachuteCameraPositionTween.tween_property(parachuteCameraNode, "position", Vector2(Vector2i(xPos, yPos) + Vector2i(parachuteOffset * Globals.data.scale)), flyTime)
	
	await frogPositionTween.finished
	
	frogNode.bodyNode.play("idle")
	frogNode.eyesNode.visible = true
	
	isFlying = false
	
	if flyTime > parachuteAnimationDuration:
		parachuteNode.close()
	
	setMousePassthroughArea(frogIdleArea, mainWindow)

func parachuteClosed():
	parachuteWindow.visible = false

func flyPositionChanged():
	setMousePassthroughArea(flyArea, flyWindow)

func _on_deadzone_timer_timeout() -> void:
	clickCancelled = true

func _on_fly_window_window_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print(event)
