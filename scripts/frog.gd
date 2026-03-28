extends AnimatedSprite2D

var baseEyePos := Vector2(0, 1)

@onready var eyesNode := $Eyes

func _on_frame_changed() -> void:
	if frame % 2 == 1:
		baseEyePos.y = 0
	elif frame == 0:
		baseEyePos.y = 1
	elif frame == 2:
		baseEyePos.y = -1
	
	eyesNode.position = baseEyePos

func _process(_delta: float) -> void:
	followMouse()

func followMouse():
	var mousePos = get_global_mouse_position()
	var eyePos = baseEyePos + mousePos
	eyePos.y += 15
	
	eyePos.x = clamp(eyePos.x, -3, 0)
	eyePos.y = clamp(eyePos.y, 0 + baseEyePos.y, 3 + baseEyePos.y)
	
	eyesNode.position = eyePos

	
