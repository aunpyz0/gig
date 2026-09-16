extends Control

@onready var compass: Control = %CompassControl
@onready var balance_text: RichTextLabel = %Balance
var _owner: Node3D
var _target: Node3D
var _bank_account: BankAccount

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	balance_text.clear()
	balance_text.push_bold()
	balance_text.add_text("Balance: ")
	balance_text.pop()
	balance_text.add_text("NaN")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (_bank_account != null):
		_uppdate_balance()
	
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

func track(target: Marker) -> void:
	_target = target

func track_balance(bank_account: BankAccount) -> void:
	_bank_account = bank_account

func _uppdate_balance() -> void:
	balance_text.clear()
	balance_text.push_bold()
	balance_text.add_text("Balance: ")
	balance_text.pop()
	balance_text.add_text(str(_bank_account.balance))
