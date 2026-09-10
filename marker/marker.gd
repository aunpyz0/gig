extends Node3D

signal new_job(Node3D)
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

func created() -> void:
	new_job.emit(get_node("."))
