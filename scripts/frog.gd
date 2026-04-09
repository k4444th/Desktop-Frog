extends AnimatedSprite2D

var jumpHeight := 50
var defaultJumpDistance := 100
var jumpDuration := 0.5		# 0.1 * num frames in "jump" animation
var jumping := false
var baseEyePos := Vector2(0, -11)
var eyePos := baseEyePos

@onready var blinkTimer := $BlinkTimer
@onready var eyesNode := $Eyes
@onready var pupilsNode := $Eyes/Pupils

func _ready() -> void:
	eyesNode.animation = "open"
	animation = "idle"

func _on_frame_changed() -> void:
	setEyePos()

func _process(_delta: float) -> void:
	followMouse()

func setEyePos():
	if frame >= 1 and frame <= 5:
		eyePos.y = baseEyePos.y - 1
	else:
		eyePos.y = baseEyePos.y
		
	eyesNode.position = eyePos

func followMouse():
	var pupilsPos = eyesNode.get_local_mouse_position()
	
	pupilsPos.x = clamp(pupilsPos.x, -3, 0)
	pupilsPos.y = clamp(pupilsPos.y, -1 , 3)
	
	pupilsNode.position = pupilsPos

func jump(right: bool, doubleClick: bool):
	if !jumping:
		eyesNode.visible = false
		play("jump")
		
		var window = get_window()
		var usableRect := DisplayServer.screen_get_usable_rect()
		var jumpDistance = defaultJumpDistance * 2 if doubleClick else defaultJumpDistance

		var startPos = window.position
		var timePassed = 0.0

		var smallJump = defaultJumpDistance
		var bigJump = defaultJumpDistance * 2

		var canJumpRightSmall = window.position.x + window.size.x + smallJump <= usableRect.end.x
		var canJumpRightBig = window.position.x + window.size.x + bigJump <= usableRect.end.x

		var canJumpLeftSmall = window.position.x - smallJump >= usableRect.position.x
		var canJumpLeftBig = window.position.x - bigJump >= usableRect.position.x

		if right:
			if doubleClick:
				if canJumpRightBig:
					jumpDistance = bigJump
				elif canJumpRightSmall:
					jumpDistance = smallJump
				else:
					right = false
					jumpDistance = smallJump
			else:
				if canJumpRightSmall:
					jumpDistance = smallJump
				else:
					right = false
					jumpDistance = smallJump
		else:
			if doubleClick:
				if canJumpLeftBig:
					jumpDistance = bigJump
				elif canJumpLeftSmall:
					jumpDistance = smallJump
				else:
					right = true
					jumpDistance = smallJump
			else:
				if canJumpLeftSmall:
					jumpDistance = smallJump
				else:
					right = true
					jumpDistance = smallJump
		
		var direction = 1 if right else -1
		if !right:
			flip_h = true
		
		jumping = true
		
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
