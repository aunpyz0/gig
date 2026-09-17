class_name Marker
extends Node3D

signal track(marker: Marker)
signal reached(marker: Marker, car: Car)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


const ANIMATION_SPEED = 3
const ANIMATION_HEIGHT_INTENSITY = 0.25
var _elapsed: float = 0

func _process(delta: float) -> void:
	_elapsed = fmod((_elapsed + delta), 3600)
	$BillboardControl.position.y = cos(_elapsed * ANIMATION_SPEED) * ANIMATION_HEIGHT_INTENSITY

func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	reached.emit(get_node("."), body)

func start_track() -> void:
	track.emit(get_node("."))

func set_color(color: Vector3) -> void:
	$CSGCylinder3D.set_instance_shader_parameter("color", Vector4(color.x, color.y, color.z, 1))
