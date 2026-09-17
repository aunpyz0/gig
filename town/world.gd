extends Node3D

@onready var _phone: Phone = %Myphone

const FULL_GAS_PRICE: int = 42
const REFUEL_COOLDOWN_TIME: float = 10
var _houses: Array[Node]
var _shops: Array[Node]
var _job: Job
var _pickup_tracked := false
var _dropoff_tracked := false
var _refuel_marker: Resource
var _pickup_marker: Resource
var _dropoff_marker: Resource
var _refuels: Array[Marker]
var _cooldown_time: float = 0

class Job:
	enum {CREATED, PICKEDUP, DROPPEDOFF}
	
	var _rng := RandomNumberGenerator.new()
	var _pickup_cost: int
	var _pickup: Node3D
	var _dropoff: Node3D
	var _total_distance_m: float
	var _profit: int
	
	func _init(pickup: Node3D, dropoff: Node3D) -> void:
		_pickup = pickup
		_dropoff = dropoff
		_total_distance_m = _pickup.global_position.distance_to(_dropoff.global_position)
		var base_profit := 10
		var rate_per_meter := 0.20
		_profit = base_profit + int(_total_distance_m * rate_per_meter)
	
	func just_received() -> bool:
		return _pickup != null && _dropoff != null
	
	func has_picked_up() -> bool:
		return _pickup == null && _dropoff != null
	
	func has_dropped_off() -> bool:
		return _pickup == null && _dropoff == null
	
	func mark_pickup(phone: Phone, marker: Marker) -> void:
		var balance := phone.balance
		_pickup_cost = _rng.randi_range(int(balance * 0.3), int(balance * 0.7))
		marker.set_color(Vector3(0, 1, 1))
		_pickup.add_child(marker)
		marker.track.connect(phone.track)
		phone.update_job_money(_pickup_cost, _profit, "Pick Up")
		var picked_up: Callable = func (m: Marker, c: Car) -> void:
			c.bank_account.prepaid(_pickup_cost)
			phone.notify("Balance -%d" % _pickup_cost)
			_pickup = null
			m.queue_free()
		marker.reached.connect(picked_up)
		marker.start_track()
	
	func mark_dropoff(phone: Phone, marker: Marker) -> void:
		_dropoff.add_child(marker)
		marker.set_color(Vector3(1, 1, 0))
		marker.track.connect(phone.track)
		phone.update_job_money(_pickup_cost, _profit, "Deliver")
		var dropped_off: Callable = func (m: Marker, c: Car) -> void:
			var payment := _pickup_cost + _profit
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
	_refuel_marker = preload("res://marker/refuel_marker.tscn")
	_pickup_marker = preload("res://marker/pickup_marker.tscn")
	_dropoff_marker = preload("res://marker/dropoff_marker.tscn")
	var refuels := get_tree().get_nodes_in_group(&"refuel")
	for rf in refuels:
		var marker: Marker = _refuel_marker.instantiate()
		_refuels.push_back(marker)
		rf.add_child(marker)
		var refuel: Callable = func (_m: Marker, c: Car) -> void:
			if _cooldown_time <= 0:
				var gas_price := _get_gas_price(c)
				var balance_left := c.bank_account.balance
				if c.bank_account.withdraw(gas_price):
					_phone.notify("Balance -%d" % gas_price)
					c.refuel()
					_cooldown_time = 10
				elif balance_left > 0:
					var refuelable: float = float(Car.FULL_TANK_SECONDS) * balance_left / FULL_GAS_PRICE
					c.bank_account.withdraw(balance_left)
					_phone.notify("Balance -%d" % balance_left)
					c.refuel_by_amount(refuelable)
					_cooldown_time = 10
		marker.reached.connect(refuel)

func _get_gas_price(c: Car) -> int:
	var gas_left := c.gas_left
	if gas_left <= 0.25:
		return FULL_GAS_PRICE
	elif gas_left <= 0.75:
			return FULL_GAS_PRICE / 2
	else:
		return 10 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_cooldown_time -= delta
	
	var refuel_color := Vector3(1, 0, 0) if _cooldown_time > 0 else Vector3(0, 1, 0)
	for rf in _refuels:
		rf.set_color(refuel_color)
	
	if (_job == null):
		var pickup := _random_shop()
		var dropoff := _random_house()
		_job = Job.new(pickup, dropoff)

	if (_job.just_received() && !_pickup_tracked):
		var marker: Marker = _pickup_marker.instantiate()
		_job.mark_pickup(_phone, marker)
		_pickup_tracked = true
	elif (_job.has_picked_up() && !_dropoff_tracked):
		var marker: Marker = _dropoff_marker.instantiate()
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
