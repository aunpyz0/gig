extends Node3D

var _houses: Array[Node]
var _delivering_house: Node
var _marker: Resource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_houses = get_tree().get_nodes_in_group(&"drop-off")
	_marker = preload("res://marker/marker.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (_delivering_house == null):
		_delivering_house = _random_house()
		var marker: Node3D = _marker.instantiate()
		_delivering_house.add_child(marker)
		marker.delivered.connect(_on_delivered)
		marker.new_job.connect(%Myphone.new_job)
		marker.created()

func _random_house() -> Node3D:
	#TODO: Maybe re-random if what is random turns into the same Node again
	return _houses.pick_random()

func _on_delivered() -> void:
	_delivering_house = null
