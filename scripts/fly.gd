extends Node2D

# General
var usableRect: Rect2
var flySize := Vector2.ZERO

# Flying constants
var flyingSpeed := 250
var sineTime := 1.5
var sineHeight := 50
var startPos := Vector2.ZERO
var timePassed := 0.0
var direction := -1
var borderSafeArea := 5

# Nodes (onready)
@onready var bodyNode := $Body
@onready var eyeNode := $Body/Eye

# Timer (onready)
@onready var blinkTimer := $BlinkTimer

func _on_blink_timer_timeout() -> void:
	eyeNode.play("blink")

func _on_eye_animation_finished() -> void:
	if eyeNode.animation == "blink":
		eyeNode.animation = "open"
		blinkTimer.start()

func _ready():
	flySize = bodyNode.sprite_frames.get_frame_texture("fly", 0).get_size()
	startPos = position
	timePassed = 0.0
	direction = -1

func _process(delta: float) -> void:
	usableRect = DisplayServer.screen_get_usable_rect()
	
	if startPos == Vector2.ZERO:
		startPos = position
	
	elif position.x <= borderSafeArea or position.x >= usableRect.size.x - flySize.x * Globals.data.scale + borderSafeArea:
		direction *= -1
		timePassed = 0.0
		startPos = position
		
		if direction == 1:
			bodyNode.flip_h = true
			eyeNode.flip_h = true
			eyeNode.position.x = 19.5
		else:
			bodyNode.flip_h = false
			eyeNode.flip_h = false
			eyeNode.position.x = 12.5
	
	timePassed += delta
	
	var t = timePassed
	var x = t * flyingSpeed * direction
	var y = -sin(t * PI) * sineHeight
	
	position = startPos + Vector2(x, y)
