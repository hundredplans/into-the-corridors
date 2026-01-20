extends Node

@onready var LevelCanvasModulate: CanvasModulate = %LevelCanvasModulate
@onready var WinScreen: Control = %WinScreen
@onready var LostScreen: Control = %LostScreen
@onready var FlashlightMinigame: Node2D = %FlashlightMinigame
@onready var UIManager: UI = %UIManager

@export var win_color: Color
@export var dusk_time: float = 2.0
@export var LevelPacked: PackedScene

@export var stream_one: AudioStream
@export var stream_two: AudioStream
@export var win_stream: AudioStream

var level: Level

func _ready() -> void:
	WinScreen.visible = false
	LostScreen.visible = false
	onCreateLevel()

func onPlayerPickedUpBattery() -> void:
	UIManager.onPlayerPickedUpBattery()
	FlashlightMinigame.onPlayerPickedUpBattery()

func onBatteryCollected() -> void:
	level.onBatteryCollected()
	UIManager.onBatteryCollected()

var DuskTween: Tween
func onLost() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	LostScreen.visible = true
	FlashlightMinigame.onEnd()
	UIManager.onEnd()
	
func onWon() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	WinScreen.visible = true
	if DuskTween: DuskTween.kill()
	DuskTween = create_tween()
	DuskTween.tween_property(LevelCanvasModulate, "color", win_color, dusk_time)
	UIManager.onEnd()
	FlashlightMinigame.onEnd()
	Audio.onPlay(win_stream)
	
func onRestartButtonPressed() -> void:
	onCreateLevel()

func onCreateLevel() -> void:
	if level != null: level.queue_free()
	if DuskTween: DuskTween.kill()
	
	Audio.onPlay(stream_one, -6)
	Audio.onPlay(stream_two, -12)
	
	level = LevelPacked.instantiate()
	LevelCanvasModulate.add_child(level)
	level.lost.connect(onLost)
	level.won.connect(onWon)
	level.player_picked_up_battery.connect(onPlayerPickedUpBattery)
	LevelCanvasModulate.color = Color.BLACK
	UIManager.onCreateLevel()
	WinScreen.visible = false
	LostScreen.visible = false
	
