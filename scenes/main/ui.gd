class_name UI extends Control

@onready var StartScreen: Control = %StartScreen
@onready var SurviveLabel: Label = %SurviveLabel
@onready var RefillFlashlightUI: Control = %RefillFlashlightUI
@export var start_duration: float = 3.0

func _ready() -> void:
	RefillFlashlightUI.visible = false
	onStart()

func onPlayerPickedUpBattery() -> void:
	RefillFlashlightUI.visible = true

func onBatteryCollected() -> void:
	RefillFlashlightUI.visible = false

func onStart() -> void:
	StartScreen.visible = true
	SurviveLabel.modulate.a = 0.0
	SurviveLabel.position = Vector2.ZERO
	
	var tween := create_tween()
	tween.tween_interval(start_duration / 4.0)
	tween.tween_property(SurviveLabel, "modulate:a", 1.0, start_duration / 4.0)
	tween.tween_interval(start_duration / 4.0)
	tween.tween_property(SurviveLabel, "position:y", 1000, start_duration / 4.0)
	tween.tween_callback(StartScreen.set_visible.bind(false))

func onEnd() -> void:
	RefillFlashlightUI.visible = false

func onCreateLevel() -> void:
	onStart()
