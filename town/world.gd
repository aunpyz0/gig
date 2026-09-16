extends Node3D

@onready var _phone: Phone = %Myphone

var _houses: Array[Node]
var _shops: Array[Node]
var _job: Job
var _pickup_tracked := false
var _dropoff_tracked := false
var _marker: Resource

class Job:
	enum {CREATED, PICKEDUP, DROPPEDOFF}
	
	var _rng := RandomNumberGenerator.new()
	var _pickup_cost: int
	var _pickup: Node3D
	var _dropoff: Node3D
	
	func _init(pickup: Node3D, dropoff: Node3D) -> void:
		_pickup = pickup
		_dropoff = dropoff
	
	func just_received() -> bool:
		return _pickup != null && _dropoff != null
	
	func has_picked_up() -> bool:
		return _pickup == null && _dropoff != null
	
	func has_dropped_off() -> bool:
		return _pickup == null && _dropoff == null
	
	func mark_pickup(phone: Phone, marker: Marker) -> void:
		var balance := phone.balance
		_pickup_cost = _rng.randi_range(int(balance * 0.3), balance)
		_pickup.add_child(marker)
		marker.track.connect(phone.track)
		var picked_up: Callable = func (m: Marker, c: Car) -> void:
			if (c.bank_account.withdraw(_pickup_cost)):
				phone.notify("Balance -%d" % _pickup_cost)
				_pickup = null
				m.queue_free()
		marker.reached.connect(picked_up)
		marker.start_track()
	
	func mark_dropoff(phone: Phone, marker: Marker) -> void:
		_dropoff.add_child(marker)
		marker.track.connect(phone.track)
		var dropped_off: Callable = func (m: Marker, c: Car) -> void:
			var payment := _pickup_cost + 20
			c.bank_account.deposit(payment)
			phone.notify("Delivered!! Balance +%d" % payment)
			_dropoff = null
			m.queue_free()
		marker.reached.connect(dropped_off)
		marker.start_track()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_houses = get_tree().get_nodes_in_group(&"drop-off")
	_shops = get_tree().get_nodes_in_group(&"pick-up")
	_marker = preload("res://marker/marker.tscn")
	var refuels := get_tree().get_nodes_in_group(&"refuel")
	for rf in refuels:
		var marker: Marker = _marker.instantiate()
		rf.add_child(marker)
		var refuel: Callable = func (_m: Marker, c: Car) -> void:
			if c.bank_account.withdraw(42):
				_phone.notify("Balance -42")
				c.refuel()
		marker.reached.connect(refuel)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (_job == null):
		var pickup := _random_shop()
		var dropoff := _random_house()
		_job = Job.new(pickup, dropoff)

	if (_job.just_received() && !_pickup_tracked):
		var marker: Marker = _marker.instantiate()
		_job.mark_pickup(_phone, marker)
		_pickup_tracked = true
	elif (_job.has_picked_up() && !_dropoff_tracked):
		var marker: Marker = _marker.instantiate()
		_job.mark_dropoff(_phone, marker)
		_dropoff_tracked = true
	elif (_job.has_dropped_off()):
		_job = null
		_pickup_tracked = false
		_dropoff_tracked = false

func _random_shop() -> Node3D:
	return _shops.pick_random()

func _random_house() -> Node3D:
	#TODO: Maybe re-random if what is random turns into the same Node again
	return _houses.pick_random()
