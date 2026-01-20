class_name RunnerEnemy extends Enemy

@onready var RunnerSprite: Sprite2D = %RunnerSprite

@export var walk_change_frame_time: float = 0.25
@export_range(10.0, 1000.0, 10.0) var speed: float = 20.0
@export var idle_frame: Texture2D
@export var walk_frames: Array[Texture2D]
@export var stream: AudioStream
@export var end_stream: AudioStream

var disable_everything: bool
var is_walking: bool
var player: Player
func _physics_process(_delta: float) -> void:
	if disable_everything: return
	var old_is_walking: bool = is_walking
	is_walking = player != null
	
	if old_is_walking and !is_walking:
		onEndWalking()
	elif !old_is_walking and is_walking:
		onStartWalking()
		
	if !is_walking: return
	var direction: Vector2 = global_position.direction_to(player.global_position)
	
	velocity = direction * speed
	move_and_slide()
	rotation = direction.angle()

func onPlayerEntered(area: Area2D) -> void:
	player = area.get_parent()
	Audio.onPlay(stream, -6)

func onPlayerExited(_area: Area2D) -> void:
	player = null

var WaitTween: Tween
func onStartWalking() -> void:
	var index: int = walk_frames.find(RunnerSprite.texture)
	if index == -1: index = 0
	index += 1
	
	if index == walk_frames.size(): index = 0
	RunnerSprite.texture = walk_frames[index]
	if WaitTween: WaitTween.kill()
	WaitTween = create_tween()
	WaitTween.tween_interval(walk_change_frame_time)
	WaitTween.finished.connect(onStartWalkingChangeFrame)

func onStartWalkingChangeFrame() -> void:
	onStartWalking()

func onEndWalking() -> void:
	RunnerSprite.texture = idle_frame
	if WaitTween: WaitTween.kill()

func onLost(area: Area2D) -> void:
	area.get_parent().onLoseLight(0.99)
	Audio.onPlay(end_stream)

func onFreeze() -> void:
	disable_everything = true
	onEndWalking()
