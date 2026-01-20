extends Node2D

signal battery_collected
@onready var BatterySprite: Sprite2D = %BatterySprite

@export var min_x: float = 200.0
@export var max_x: float = 1052.0
@export var min_y: float = 100.0
@export var max_y: float = 548.0
@export var reject_distance: float = 100.0

var inside_release_area: bool
var is_mouse_in_battery: bool
var battery_held: bool

func _ready() -> void: visible = false
func onEnd() -> void:
	visible = false
	battery_held = false
	
func onPlayerPickedUpBattery() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = true
	
	var spawn_position := Vector2.ZERO
	while true:
		spawn_position = Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))
		if spawn_position.distance_to(BatterySprite.position) > reject_distance:
			break
	BatterySprite.position = spawn_position

func onMouseEnteredBattery() -> void:
	is_mouse_in_battery = true

func onMouseExitedBattery() -> void:
	is_mouse_in_battery = false

func _process(_delta: float) -> void:
	if is_mouse_in_battery and Input.is_action_just_pressed("MainInput"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		battery_held = true
		
	if inside_release_area and battery_held and Input.is_action_just_pressed("MainInput"):
		battery_collected.emit()
		battery_held = false
		visible = false
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and battery_held:
		BatterySprite.position += event.relative

func onEnteredFlashlightArea(area: Area2D) -> void:
	inside_release_area = true

func onExitedFlashlightArea(area: Area2D) -> void:
	inside_release_area = false
