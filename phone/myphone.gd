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
	#var dir_3d := _target.global_position
	
	
	#compass.rotation = Vector2(dir_3d.x, dir_3d.z).angle() / -2
	#compass.global_rotation = lerp_angle(compass.rotation, Vector2(dir_3d.x, dir_3d.z).angle(), delta * 1.0)
	var dir_3d := _target.global_position - _owner.global_position
	var dir_2d := Vector2(dir_3d.x, -dir_3d.z)
	var target_angle := dir_2d.angle() - _owner.global_rotation.y
	compass.rotation = lerp_angle(compass.rotation, dir_2d.angle(), delta * 1.0)
	print("owner pos: ", _owner.global_position, " owner rot: ", _owner.global_rotation)

func poweron(owner: Node3D) -> void:
	_owner = owner

func new_job(target: Node3D) -> void:
	_target = target
