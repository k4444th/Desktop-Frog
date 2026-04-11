extends Node2D

# Enums
enum State { FLYING, JITTERING }

# General
var usableRect: Rect2
var flySize := Vector2.ZERO

# Flying constants
var flyingSpeed := 500
var jitterDistance := 25
var targetPosition := Vector2.ZERO
var moveDuration := 1
var moveTime := 0.0
var startPosition := Vector2.ZERO
var state = State.FLYING

# Nodes (onready)
@onready var bodyNode := $Body
@onready var eyeNode := $Body/Eye

# Timer (onready)
@onready var blinkTimer := $BlinkTimer

# Signals
signal flyPositionChanged()

func _ready():
	flySize = bodyNode.sprite_frames.get_frame_texture("fly", 0).get_size()
	pickNewTarget()

func _process(delta: float) -> void:
	match state:
		State.FLYING:
			moveTime += delta
			var t = clamp(moveTime / moveDuration, 0.0, 1.0)
			var eased_t = -cos(t * PI) * 0.5 + 0.5
			position = startPosition.lerp(targetPosition, eased_t)
			
			if t >= 1.0:
				state = State.JITTERING
		
		State.JITTERING:
			position = position.lerp(targetPosition, delta * 5.0)
			
			if position.distance_to(targetPosition) < 2.0:
				pickNewJitterTarget()
	
	flyPositionChanged.emit()

func pickNewTarget():
	usableRect = DisplayServer.screen_get_usable_rect()

	startPosition = position

	targetPosition = Vector2(
		randf_range(usableRect.position.x + jitterDistance, usableRect.end.x - flySize.x * Globals.data.scale - jitterDistance),
		randf_range(usableRect.position.y + jitterDistance, usableRect.end.y - flySize.y * Globals.data.scale - jitterDistance),
	)

	moveTime = 0.0
	state = State.FLYING

func pickNewJitterTarget():
	var randomOffset = Vector2(
		randf_range(-jitterDistance, jitterDistance),
		randf_range(-jitterDistance, jitterDistance)
	)
	
	targetPosition = position + randomOffset

func _on_blink_timer_timeout() -> void:
	eyeNode.play("blink")

func _on_eye_animation_finished() -> void:
	if eyeNode.animation == "blink":
		eyeNode.animation = "open"
		blinkTimer.start()

func _on_new_position_timer_timeout() -> void:
	pickNewTarget()
