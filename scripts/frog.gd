extends AnimatedSprite2D

var jumpHeight := 50
var jumpDistance := 100
var jumpDuration := 0.5		# 0.1 * num frames in "jump" animation
var jumping := false
var baseEyePos := Vector2(0, 2.5)
var eyePos := baseEyePos

@onready var eyesNode := $Eyes
@onready var pupilsNode := $Eyes/Pupils
@onready var blinkTimer := $BlinkTimer

func _ready() -> void:
	eyesNode.animation = "open"
	animation = "idle"

func _on_frame_changed() -> void:
	setEyePos()

func _process(_delta: float) -> void:
	eyesFollowMouse()

func setEyePos():
	if frame >= 1 and frame <= 5:
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
	
	var window = get_window()
	var usableRect := DisplayServer.screen_get_usable_rect()
	
	if right and not window.position.x + window.size.x + jumpDistance <= usableRect.end.x:
		right = false
	elif not right and not window.position.x - jumpDistance >= usableRect.position.x:
		right = true
	
	var direction = 1 if right else -1
	if !right:
		flip_h = true
	
	eyesNode.visible = false
	play("jump")
	
	jumping = true
	
	var startPos = window.position
	var timePassed = 0.0
	
	while timePassed < jumpDuration:
		await get_tree().process_frame
		timePassed += get_process_delta_time()
		
		var t = timePassed / jumpDuration
		var x = lerp(0.0, float(jumpDistance * direction), t)
		var y = -sin(t * PI) * jumpHeight
		
		window.position = Vector2i(Vector2(startPos) + Vector2(x, y))
	
	window.position = Vector2i(startPos) + Vector2i(jumpDistance * direction, 0)
	
	jumping = false
	eyesNode.visible = true
	play("idle")
	flip_h = false

func _on_timer_timeout() -> void:
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
