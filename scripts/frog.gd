extends Node2D

# General
var usableRect: Rect2
var frogSize := Vector2.ZERO

# Jumping
var jumpHeight := 10
var jumpDistance := 100
var jumpDuration := 0.5		# 0.1 * num frames in "jump" animation
var jumping := false

# Eyes
var baseEyePos := Vector2(32, 34.5)
var eyePos := baseEyePos

@onready var bodyNode := $Body
@onready var eyesNode := $Eyes
@onready var pupilsNode := $Eyes/Pupils
@onready var blinkTimer := $BlinkTimer

signal jumpEnd()

func _ready() -> void:
	eyesNode.animation = "open"
	bodyNode.animation = "idle"
	frogSize = bodyNode.sprite_frames.get_frame_texture("idle", 0).get_size()

func _on_body_frame_changed() -> void:
	setEyePos()

func _process(_delta: float) -> void:
	eyesFollowMouse()

func setEyePos():
	if bodyNode.frame >= 1 and bodyNode.frame <= 5:
		eyePos.y = baseEyePos.y - 1
	else:
		eyePos.y = baseEyePos.y
		
	eyesNode.position = eyePos

func eyesFollowMouse():
	var pupilsPos = eyesNode.get_local_mouse_position()
	
	pupilsPos.x = clamp(pupilsPos.x, -3, 0)
	pupilsPos.y = clamp(pupilsPos.y, -1 , 3)
	
	pupilsNode.position = pupilsPos

func jump(right: bool):
	if jumping:
		return
	
	usableRect = DisplayServer.screen_get_usable_rect()
	
	if right and not position.x + jumpDistance <= usableRect.end.x:
		right = false
	elif not right and not position.x - jumpDistance  >= 0:
		right = true
	
	var direction = 1 if right else -1
	if !right:
		bodyNode.flip_h = true
	
	eyesNode.visible = false
	bodyNode.play("jump")
	
	jumping = true
	
	var startPos = position
	var timePassed = 0.0
	
	while timePassed < jumpDuration:
		await get_tree().process_frame
		timePassed += get_process_delta_time()
		
		var t = timePassed / jumpDuration
		var x = lerp(0.0, float(jumpDistance * direction), t)
		var y = -sin(t * PI) * jumpHeight * Globals.data.scale
		
		position = Vector2i(startPos + Vector2(x, y))
	
	position = Vector2i(startPos) + Vector2i(jumpDistance * direction, 0)
	
	jumping = false
	eyesNode.visible = true
	bodyNode.play("idle")
	bodyNode.flip_h = false
	jumpEnd.emit()

func _on_blink_timer_timeout() -> void:
	eyesNode.play("blink")

func _on_eyes_animation_finished() -> void:
	if eyesNode.animation == "blink":
		eyesNode.animation = "open"
		blinkTimer.start()

func _on_eyes_frame_changed() -> void:
	if eyesNode.animation == "blink" and eyesNode.frame == 4:
		pupilsNode.visible = false
	if eyesNode.animation == "blink" and eyesNode.frame == 5:
		pupilsNode.visible = true
