@tool

extends BuildRow

var changed:bool = false
var default:String
var value:String = "":
	set(_value):
		value = _value
		value_line.text = value
		changed = value != default
		reset.visible = value != default
		emit_signal("_changed", String(name) , value if changed else null)

@onready var name_label: Label = $HBoxContainer/Name
@onready var reset: Button = $HBoxContainer/End/Reset
@onready var value_line: LineEdit = $HBoxContainer/Value
@onready var button: Button = $HBoxContainer/Button


func _ready() -> void:
	value_line.text = value
	name_label.text = String(name)
	value = default


func row_reset() -> void:
	value_line.text = default
	value = default
	reset.visible = false
	changed = false
	emit_signal("_changed", String(name) , null)


func set_value(_value:String)->void:
	value = _value
	value_line.text = value
	changed = _value != default
	await get_tree().process_frame
	reset.visible = changed
	#emit_signal("_changed", String(name) , value if changed else null)


func get_parameter() -> String:
	return String(name) + value
