class_name Marker
extends Node3D

signal track(Marker)
signal delivered

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	delivered.emit()
	queue_free()

func start_track() -> void:
	track.emit(get_node("."))
