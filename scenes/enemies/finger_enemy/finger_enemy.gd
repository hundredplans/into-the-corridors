extends Enemy

@onready var FingerSprite: Sprite2D = %FingerSprite
@onready var FlashlightEnteredTimer: Timer = %FlashlightEnteredTimer
@export var reactivate_min_time: float = 5.0
@export var reactivate_max_time: float = 8.0
@export var lose_light_ratio: float = 0.33
@export var stream: AudioStream

var disable_everything: bool
var is_active: bool = true
var is_flashlight_inside: bool

func onFlashlightEntered(_area: Area2D = null) -> void:
	if disable_everything: return
	is_flashlight_inside = true
	if !is_active: return
	FlashlightEnteredTimer.start()

func onFlashlightExited(area: Area2D) -> void:
	if disable_everything: return
	is_flashlight_inside = false
	if !is_active: return
	FlashlightEnteredTimer.stop()

func onFlashlightEnteredTimerTimeout() -> void:
	is_active = false
	visible = false
	
	var reactivate_time: float = randf_range(reactivate_min_time, reactivate_max_time)
	await get_tree().create_timer(reactivate_time).timeout
	visible = true
	is_active = true
	if is_flashlight_inside: onFlashlightEntered()

func onPlayerEntered(area: Area2D) -> void:
	if !is_active or disable_everything: return
	Audio.onPlay(stream, -12)
	area.get_parent().onLoseLight(lose_light_ratio)
	onFlashlightEnteredTimerTimeout()

func onFreeze() -> void:
	disable_everything = true
