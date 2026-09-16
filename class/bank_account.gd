class_name BankAccount

var _balance: int

var balance: int:
	get:
		return _balance

func _init(initial_balance: int) -> void:
	_balance = initial_balance

func deposit(amount: int) -> void:
	assert(amount >= 0, "Amount must not be negative!")
	_balance += amount

func prepaid(amount: int) -> void:
	_balance -= amount

func withdraw(amount: int) -> bool:
	assert(amount >= 0, "Amount must not be negative!")
	if (_balance >= amount):
		_balance -= amount
		return true
	else:
		return false
