extends Control

@onready var compass: Sprite2D = %Compass
var _owner: Node3D
var _target: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (_owner == null):
		return

	if (_target != null):
		_update_compass(delta)

func _update_compass(delta: float) -> void:
	var target_dir := _target.global_position - _owner.global_position
	var owner_forward := _owner.global_transform.basis.z
	compass.rotation = lerp_angle(compass.rotation, Vector2(owner_forward.x, owner_forward.z).angle_to(Vector2(target_dir.x, target_dir.z)), delta * 1.0)

func poweron(owner: Node3D) -> void:
	_owner = owner

func new_job(target: Node3D) -> void:
	_target = target
