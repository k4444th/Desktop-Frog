extends AnimatedSprite2D

var baseEyePos := Vector2(0, 1)

@onready var blinkTimer := $Timer
@onready var eyesNode := $Eyes
@onready var pupilsNode := $Eyes/Pupils

func _ready() -> void:
	eyesNode.animation = "open"

func _on_frame_changed() -> void:
	setEyeBasePos()

func _process(_delta: float) -> void:
	followMouse()

func setEyeBasePos():
	if frame % 2 == 1:
		baseEyePos.y = 0
	elif frame == 0:
		baseEyePos.y = 1
	elif frame == 2:
		baseEyePos.y = -1
	
	eyesNode.position = baseEyePos

func followMouse():
	var mousePos = get_global_mouse_position()
	var pupilsPos = mousePos
	pupilsPos.y += 15
	
	pupilsPos.x = clamp(pupilsPos.x, -3, 0)
	pupilsPos.y = clamp(pupilsPos.y, 0 , 3)
	
	pupilsNode.position = pupilsPos

func _on_timer_timeout() -> void:
	pupilsNode.visible = false
	eyesNode.play("blink")

func _on_eyes_animation_finished() -> void:
	if eyesNode.animation == "blink":
		eyesNode.animation = "open"
		pupilsNode.visible = true
		blinkTimer.start()
