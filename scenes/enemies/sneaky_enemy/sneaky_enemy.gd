extends Enemy

@export var player: Player
@export var angle_reset_timer: float = 5.0
@export var cancel_attack_min_time: float = 2.0
@export var cancel_attack_max_time: float = 3.5
@export var epsilon_flashlight: float = 0.1
@export_range(10.0, 1000.0, 10.0) var speed: float = 200.0
@export var start_distance: float = 600.0

var is_attack_active: bool
var is_attack_cancelled: bool
var is_cancel_attack_window: bool
var attack_angle: float
func _ready() -> void:
	onChooseAttackAngle()
	
func _process(_delta: float) -> void:
	look_at(player.global_position)
	if is_cancel_attack_window and !is_attack_cancelled and abs(attack_angle - player.getFlashlightAngle()) <= epsilon_flashlight:
		is_attack_cancelled = true

	if is_attack_active:
		var direction: Vector2 = global_position.direction_to(player.global_position)
		velocity = direction * speed
		
		if abs(attack_angle - player.getFlashlightAngle()) <= epsilon_flashlight:
			onChooseAttackAngle()

func onChooseAttackAngle() -> void:
	is_attack_active = false
	visible = false
	await get_tree().create_timer(angle_reset_timer).timeout
	attack_angle = randf_range(0, PI * 2)
	is_cancel_attack_window = true
	var cancel_attack_time: float = randf_range(cancel_attack_min_time, cancel_attack_max_time)
	await get_tree().create_timer(cancel_attack_time).timeout
	
	is_cancel_attack_window = false
	if is_attack_cancelled: onChooseAttackAngle(); return
	is_attack_active = true
	visible = true
	global_position = player.global_position + (global_position.direction_to(player.global_position) * start_distance)
