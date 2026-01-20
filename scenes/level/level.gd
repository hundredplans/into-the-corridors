class_name Level extends Node2D

signal won
signal lost

@onready var Enemies: Node2D = %Enemies
@onready var WinTimer: Timer = %WinTimer
@onready var player: Player = %Player
@export var win_time: float = 10.0

signal player_picked_up_battery
func _ready() -> void:
	WinTimer.start(win_time)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func onPlayerPickedUpBattery() -> void:
	player_picked_up_battery.emit()

func onBatteryCollected() -> void:
	player.onBatteryCollected()

func onWinTimerTimeout() -> void:
	won.emit()
	player.onWon()
	for enemy: Enemy in Enemies.get_children():
		enemy.onFreeze()

func onLost() -> void:
	lost.emit()
	player.onLost()
	WinTimer.stop()
	for enemy: Enemy in Enemies.get_children():
		enemy.onFreeze()
