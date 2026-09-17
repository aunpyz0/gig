class_name Phone
extends Control

@onready var _compass: Control = %CompassControl
@onready var _balance_text: RichTextLabel = %Balance
@onready var _notification: Notification = %Noti
@onready var _distance: Label = %Distance
@onready var _money: Label = %Money
@onready var _job_status: Label = %Job
var _owner: Node3D
var _target: Node3D
var _bank_account: BankAccount

var balance: int:
	get:
		return _bank_account.balance

var current_pickup_fee: int = 0
var current_profit: int = 0
var current_status: String = "Pick Up"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_balance_text.clear()
	_balance_text.push_bold()
	_balance_text.add_text("Balance: ")
	_balance_text.pop()
	_balance_text.add_text("NaN")
	_update_money_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (_bank_account != null):
		_uppdate_balance()
	
	if (_owner == null):
		return

	if (_target != null):
		_update_compass(delta)
		_update_distance()

func _update_compass(delta: float) -> void:
	var target_dir := _target.global_position - _owner.global_position
	var owner_forward := _owner.global_transform.basis.z
	_compass.rotation = lerp_angle(_compass.rotation, Vector2(owner_forward.x, owner_forward.z).angle_to(Vector2(target_dir.x, target_dir.z)), delta * 1.0)

func poweron(owner: Node3D) -> void:
	_owner = owner

func track(target: Marker) -> void:
	_target = target

func track_balance(bank_account: BankAccount) -> void:
	_bank_account = bank_account

func notify(message: String) -> void:
	_notification.pop(message)

func _uppdate_balance() -> void:
	_balance_text.clear()
	_balance_text.push_bold()
	_balance_text.add_text("Balance: ")
	_balance_text.pop()
	_balance_text.add_text(str(_bank_account.balance))
	_update_money_ui()

func _update_distance() -> void:
	var dist_m := _owner.global_position.distance_to(_target.global_position)
	if dist_m >= 1000.0:
		_distance.text = "%.2f km" % (dist_m / 1000.0)
	else:
		_distance.text = "%.0f m" % dist_m

func update_job_money(fee: int, profit: int, status: String) -> void:
	current_pickup_fee = fee
	current_profit = profit
	current_status = status
	_update_money_ui()

func _update_money_ui() -> void:
	_money.text = "Fee: $%d | Profit: +$%d" % [current_pickup_fee, current_profit]
	_job_status.text = current_status
