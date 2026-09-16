class_name Notification
extends Label

@onready var style_box: StyleBoxFlat = get_theme_stylebox("normal")
var _timeout: float = 0;

func _ready() -> void:
	_clear_text()

func _process(delta: float) -> void:
	if (_timeout > 0):
		_timeout -= delta
	
	if (_timeout <= 0):
		_clear_text()

func _clear_text() -> void:
	text = ""
	style_box.draw_center = false

func pop(message: String) -> void:
	self.text = message
	style_box.draw_center = true
	_timeout = 3
