extends Control

@onready var needle: Sprite2D = %GaugesGas
var _car: Car

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (_car != null):
		var gas_left := _car.gas_left
		needle.rotation = lerp_angle(needle.rotation, (-0.5 + gas_left) * PI, delta)

func watch(car: Car) -> void:
	_car = car
