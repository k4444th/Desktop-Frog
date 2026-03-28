extends AnimatedSprite2D

@onready var eyesNode := $Eyes

func _on_frame_changed() -> void:
	if frame % 2 == 1:
		eyesNode.position.y = 0
	elif frame == 0:
		eyesNode.position.y = 1
	elif frame == 2:
		eyesNode.position.y = -1
