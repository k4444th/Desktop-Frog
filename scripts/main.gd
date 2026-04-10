extends Node2D

var usableRect: Rect2
var frogSize := Vector2.ZERO
var parachuteSize := Vector2.ZERO
var parachuteOffset := Vector2(0, 4)
var clickCancelled := false
var mouseDown := false
var dragOffset := Vector2.ZERO
var screenArea := Polygon2D.new()

@onready var window = get_window()
@onready var frogNode := $Frog
@onready var parachuteNode := $Parachute
@onready var frogIdleArea := $IdleArea
@onready var frogJumpingArea := $JumpingArea
@onready var deadzoneTimer := $DeadzoneTimer

func _ready() -> void:
	frogNode.jumpEnd.connect(frogNodeJumpEnd)
	
	frogSize = frogNode.bodyNode.sprite_frames.get_frame_texture("idle", 0).get_size()
	parachuteSize = parachuteNode.parachuteNode.sprite_frames.get_frame_texture("open", 0).get_size()
	
	parachuteNode.visible = false
	
	initWindow()
	initScale()
	initWindowPosition()
	initSpritePositions()
	setMousePassthroughArea(frogIdleArea)
	
	calculateScreenArea()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouseDown = true
			clickCancelled = false
			deadzoneTimer.start()
			dragOffset = frogNode.get_local_mouse_position()
			calculateScreenArea()
		else:
			mouseDown = false
			
			flyDown()
			
			if not clickCancelled:
				frogNode.jump(frogNode.to_local(event.position).x < 0)
				setMousePassthroughArea(frogJumpingArea)
	
	if event is InputEventMouseMotion:
		if mouseDown:
			
			setMousePassthroughArea(frogIdleArea)
			frogNode.position = get_global_mouse_position() - dragOffset * Globals.data.scale
			parachuteNode.position = get_global_mouse_position() - dragOffset * Globals.data.scale

func initWindow():
	window.transparent_bg = true
	window.transparent = true 
	window.borderless = true
	window.always_on_top = true
	window.unresizable = true

func initScale():
	frogNode.scale = Vector2(Globals.data.scale, Globals.data.scale)
	parachuteNode.scale = Vector2(Globals.data.scale, Globals.data.scale)

func initWindowPosition():
	calculateScreenArea()
	
	window.position = usableRect.position
	window.size = usableRect.size

func initSpritePositions():
	calculateScreenArea()

	frogNode.position = Vector2((frogSize.x * Globals.data.scale) / 2, usableRect.size.y - (frogSize.y * Globals.data.scale) / 2)
	parachuteNode.position = frogNode.position + parachuteOffset * Globals.data.scale

func calculateScreenArea():
	usableRect = DisplayServer.screen_get_usable_rect()
	DisplayServer.window_set_mouse_passthrough([])

func setMousePassthroughArea(polygon: Polygon2D):
	var area = PackedVector2Array()
	
	for p in polygon.polygon:
		area.append(p * Globals.data.scale + frogNode.position)
	
	DisplayServer.window_set_mouse_passthrough(area)

func frogNodeJumpEnd():
	setMousePassthroughArea(frogIdleArea)

func flyDown():
	usableRect = DisplayServer.screen_get_usable_rect()
	DisplayServer.window_set_mouse_passthrough([])
	
	var yPos = usableRect.size.y - (frogSize.y * Globals.data.scale) / 2
	var xPos = clamp(frogNode.position.x, (frogSize.x * Globals.data.scale) / 2, usableRect.size.x - (frogSize.x * Globals.data.scale) / 2)
	var oldXPos = frogNode.position.x
	
	var flyTime = pow(abs(frogNode.position.y - yPos), 0.6) * 0.0175
	var parachuteAnimationDuration = (1 / parachuteNode.parachuteNode.sprite_frames.get_animation_speed("opening")) * parachuteNode.parachuteNode.sprite_frames.get_frame_count("opening")
	
	if flyTime > parachuteAnimationDuration:
		parachuteNode.open()
	
	parachuteNode.rotation_degrees = (oldXPos - xPos) / 10
	
	var frogPositionTween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	frogPositionTween.tween_property(frogNode, "position", Vector2(xPos, yPos), flyTime)
	
	var parachutePositionTween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	parachutePositionTween.tween_property(parachuteNode, "position", Vector2(xPos, yPos), flyTime)
	
	if parachuteNode.rotation_degrees != 0:
		var parachuetRotationTween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		parachuetRotationTween.tween_property(parachuteNode, "rotation", 0, flyTime)
	
	await frogPositionTween.finished
	
	if flyTime > parachuteAnimationDuration:
		parachuteNode.close()
	
	setMousePassthroughArea(frogIdleArea)

func _on_deadzone_timer_timeout() -> void:
	clickCancelled = true
