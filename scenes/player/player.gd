class_name Player extends CharacterBody2D

signal lost
signal battery_picked_up

@onready var AudioPlayer: AudioStreamPlayer = %AudioPlayer
@onready var MyCamera: Camera2D = %MyCamera
@onready var FlashlightTimer: Timer = %FlashlightTimer
@onready var PlayerSprite: Sprite2D = %PlayerSprite
@onready var CenterLight: PointLight2D = %CenterLight
@onready var FlashlightTurner: Node2D = %FlashlightTurner
@onready var Flashlight: PointLight2D = %Flashlight

@export_range(10.0, 120.0, 10.0) var flashlight_expire_time: float = 1.0
@export_range(10.0, 1000.0, 10.0) var speed: float = 20.0
@export var max_light_energy: float = 1.0
@export var walk_change_frame_time: float = 0.25
@export var win_zoomout_time: float = 2.0
@export var camera_final_zoom: float = 0.2

@export var idle_frame: Texture2D
@export var walk_frames: Array[Texture2D]
@export var walk_stream: AudioStream

var disable_everything: bool
var is_walking: bool

const SCREEN_CENTER := Vector2(576, 324)
func _ready() -> void:
	onRefillFlashlight()

func _physics_process(_delta: float) -> void:
	if disable_everything: return
	var direction: Vector2 = Input.get_vector("Left", "Right", "Forward", "Backward")
	
	velocity = direction * speed
	move_and_slide()

	var old_is_walking: bool = is_walking
	is_walking = direction != Vector2.ZERO
	
	if old_is_walking and !is_walking:
		onEndWalking()
	elif !old_is_walking and is_walking:
		onStartWalking()
	
	if !is_walking: return
	PlayerSprite.rotation = direction.angle()

func _process(_delta: float) -> void:
	var energy: float = max_light_energy * (FlashlightTimer.time_left / flashlight_expire_time)
	Flashlight.energy = energy
	CenterLight.energy = energy
	var flashlight_angle: float = SCREEN_CENTER.direction_to(get_viewport().get_mouse_position()).angle() - (PI / 2)
	FlashlightTurner.rotation = flashlight_angle
	
func onBatteryDetectorAreaEntered(area: Area2D) -> void:
	disable_everything = true
	onEndWalking()
	var battery: Battery = area.get_parent()
	battery.onPickedUp()
	battery_picked_up.emit()

func getFlashlightAngle() -> float: return FlashlightTurner.rotation
func onChangeLightLevel(p: float) -> void:
	Flashlight.energy = max_light_energy * p
	CenterLight.energy = max_light_energy * p

var LightLevelTween: Tween
func onUpdateLightLevelTween() -> void:
	if LightLevelTween: LightLevelTween.kill()
	onChangeLightLevel(1.0)
	LightLevelTween = create_tween()
	LightLevelTween.tween_method(onChangeLightLevel, 1.0, 0.0, flashlight_expire_time)

func onBatteryCollected() -> void:
	onRefillFlashlight()
	disable_everything = false
	
func onRefillFlashlight() -> void:
	FlashlightTimer.start(flashlight_expire_time)

func onLoseLight(lose_light_ratio: float) -> void:
	var remaining_time: float = FlashlightTimer.time_left
	remaining_time *= (1.0 - lose_light_ratio)
	FlashlightTimer.start(remaining_time)

var WaitTween: Tween
func onStartWalking() -> void:
	AudioPlayer.play()
	var index: int = walk_frames.find(PlayerSprite.texture)
	if index == -1: index = 0
	index += 1
	
	if index == walk_frames.size(): index = 0
	PlayerSprite.texture = walk_frames[index]
	if WaitTween: WaitTween.kill()
	WaitTween = create_tween()
	WaitTween.tween_interval(walk_change_frame_time)
	WaitTween.finished.connect(onStartWalkingChangeFrame)

func onStartWalkingChangeFrame() -> void:
	onStartWalking()

func onEndWalking() -> void:
	AudioPlayer.stop()
	PlayerSprite.texture = idle_frame
	if WaitTween: WaitTween.kill()

func onWon() -> void:
	disable_everything = true
	onEndWalking()
	FlashlightTimer.stop()
	
	var tween := create_tween()
	tween.tween_property(MyCamera, "zoom", Vector2(camera_final_zoom, camera_final_zoom), win_zoomout_time)

func onLost() -> void:
	disable_everything = true
	onEndWalking()

func onFlashlightTimerTimeout() -> void:
	lost.emit()
