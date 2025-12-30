@tool

extends BuildRow

var changed:bool = false
var default:String
var value:String = "":
	set(_value):
		value = _value
		value_line.text = value
		value_line.text = value
		changed = value != default
		reset.visible = value != default
		emit_signal("_changed", String(name) , changed)

@onready var name_label: Label = $HBoxContainer/Name
@onready var reset: Button = $HBoxContainer/End/Reset
@onready var value_line: LineEdit = $HBoxContainer/Value
@onready var button: Button = $HBoxContainer/Button


func _ready() -> void:
	value_line.text = value
	name_label.text = String(name)
	value = default


func _on_Reset_pressed() -> void:
	value_line.text = default
	value = default
	reset.visible = false
	changed = false
	emit_signal("_changed", String(name) , changed)


func set_value(_value:String)->void:
	value = _value
	value_line.text = value
	value_line.text = value
	changed = _value != default
	reset.visible = value != default
	emit_signal("_changed", String(name) , changed)


func get_parameter() -> String:
	return String(name) + value
