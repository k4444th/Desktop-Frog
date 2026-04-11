extends Node2D

# General
var usableRect: Rect2

# Sprite related
var frogSize := Vector2.ZERO
var parachuteSize := Vector2.ZERO
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
@onready var frogIdleArea := $IdleArea
@onready var frogJumpingArea := $JumpingArea
@onready var frogCameraNode := $Camera

# Parachute (onready)
@onready var parachuteWindow = $ParachuteWindow
@onready var parachuteNode := $Parachute
@onready var parachuteCameraNode := $ParachuteWindow/Camera


func _ready() -> void:
	frogNode.jumpEnd.connect(frogNodeJumpEnd)
	parachuteNode.parachuteClosed.connect(parachuteClosed)
	parachuteWindow.close_requested.connect(queue_free)
	
	initWindows()
	initWindowWorlds()
	initSpriteSizes()
	initSpriteScales()
	initWindowSizes()
	initSpritePositions()
	initSubwindowsVisibility()
	
	setWindowPositions()
	setCameraPositions()
	setMousePassthroughArea(frogIdleArea)

func _physics_process(_delta: float) -> void:
	setWindowPositions()
	setCameraPositions()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouseDown = true
			clickCancelled = false
			deadzoneTimer.start()
			dragOffset = frogNode.get_local_mouse_position()
		else:
			mouseDown = false
			
			flyDown()
			
			if not clickCancelled:
				frogNode.jump(event.position.x < mainWindow.size.x / 2.0)
				setMousePassthroughArea(frogJumpingArea)
	
	if event is InputEventMouseMotion:
		if mouseDown:
			frogNode.position = get_global_mouse_position() - dragOffset * Globals.data.scale
			
			var minPos = usableRect.position + Vector2(0, (parachuteSize.y + parachuteOffset.y) * Globals.data.scale)
			var maxPos = Vector2(usableRect.size.x - frogSize.x * Globals.data.scale, usableRect.position.y + usableRect.size.y - frogSize.y * Globals.data.scale)
			frogNode.position = frogNode.position.clamp(minPos, maxPos)
			
			setMousePassthroughArea(frogIdleArea)

func initWindows():
	mainWindow.transparent_bg = true
	mainWindow.transparent = true 
	mainWindow.borderless = true
	mainWindow.always_on_top = true
	mainWindow.unresizable = true
	
	
	parachuteWindow.transparent_bg = true
	parachuteWindow.transparent = true 
	parachuteWindow.borderless = true
	parachuteWindow.always_on_top = true
	parachuteWindow.unresizable = true
	
	mainWindow.grab_focus() 

func initWindowWorlds():
	parachuteWindow.world_2d = mainWindow.world_2d

func initSpriteSizes():
	frogSize = frogNode.bodyNode.sprite_frames.get_frame_texture("idle", 0).get_size()
	parachuteSize = parachuteNode.parachuteNode.sprite_frames.get_frame_texture("open", 0).get_size()

func initSpriteScales():
	frogNode.scale = Vector2(Globals.data.scale, Globals.data.scale)
	parachuteNode.scale = Vector2(Globals.data.scale, Globals.data.scale)

func initWindowSizes():
	mainWindow.size = frogSize * Globals.data.scale
	parachuteWindow.size = parachuteSize * Globals.data.scale

func initSpritePositions():
	usableRect = DisplayServer.screen_get_usable_rect()
	
	frogNode.position = usableRect.position + Vector2(0, usableRect.size.y - frogSize.y * Globals.data.scale)
	parachuteNode.position = frogNode.position + Vector2(parachuteOffset.x, 0) * Globals.data.scale

func initSubwindowsVisibility():
	parachuteWindow.visible = false

func setWindowPositions():
	if isFlying:
		return
	
	usableRect = DisplayServer.screen_get_usable_rect()
	
	mainWindow.position = frogNode.position
	parachuteWindow.position = parachuteNode.position + Vector2(0, parachuteOffset.y) * Globals.data.scale

func setCameraPositions():
	if isFlying:
		return
		
	frogCameraNode.position = frogNode.position
	parachuteCameraNode.position = parachuteNode.position + Vector2(0, parachuteOffset.y) * Globals.data.scale

func setMousePassthroughArea(polygon: Polygon2D):
	var area = PackedVector2Array()
	
	for p in polygon.polygon:
		area.append(p * Globals.data.scale + mainWindow.size / 2.0)
	
	DisplayServer.window_set_mouse_passthrough(area)

func frogNodeJumpEnd():
	setMousePassthroughArea(frogIdleArea)

func flyDown():
	usableRect = DisplayServer.screen_get_usable_rect()
	DisplayServer.window_set_mouse_passthrough([])
	
	var yPos = usableRect.position.y + usableRect.size.y - (frogSize.y * Globals.data.scale)
	var xPos = clamp(frogNode.position.x, 0, usableRect.size.x - (frogSize.x * Globals.data.scale))
	#var oldXPos = frogNode.position.x
	
	var flyTime = pow(abs(frogNode.position.y - yPos), 0.6) * 0.0175
	var parachuteAnimationDuration = (1 / parachuteNode.parachuteNode.sprite_frames.get_animation_speed("opening")) * parachuteNode.parachuteNode.sprite_frames.get_frame_count("opening")
	
	mainWindow.position = frogNode.position
	
	
	if flyTime > parachuteAnimationDuration:
		parachuteNode.position = frogNode.position + Vector2(parachuteOffset.x, 0) * Globals.data.scale
		#parachuteNode.rotation_degrees = (oldXPos - xPos) / 10
		parachuteWindow.position = parachuteNode.position + Vector2(0, parachuteOffset.y) * Globals.data.scale
		parachuteCameraNode.position = parachuteNode.position + Vector2(0, parachuteOffset.y) * Globals.data.scale
		parachuteWindow.visible = true
		parachuteNode.open()
	
	isFlying = true
	
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
	
	#if parachuteNode.rotation_degrees != 0:
		#var parachuetRotationTween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		#parachuetRotationTween.tween_property(parachuteNode, "rotation", 0, flyTime)
	
	await frogPositionTween.finished
	
	isFlying = false
	
	if flyTime > parachuteAnimationDuration:
		parachuteNode.close()
	
	setMousePassthroughArea(frogIdleArea)

func parachuteClosed():
	parachuteWindow.visible = false

func _on_deadzone_timer_timeout() -> void:
	clickCancelled = true
