@tool
extends BuildRow

var changed:bool = false
var default:String
var value:String = ""#:
	#set(_value):
		#value = _value
		#print("setter: ", value)
		#changed = default != value
		#reset.visible = changed
		#emit_signal("_changed", String(name) , value if changed else null)


@onready var name_label: Label = $HBoxContainer/Name
@onready var reset: Button = $HBoxContainer/End/Reset
@onready var check_box: CheckBox = $HBoxContainer/CheckBox



func _ready() -> void:
	value = default
	check_box.button_pressed = default == "yes"
	name_label.text = String(name)


func row_reset() -> void:
#	value_line.text = default
	value = default
	changed = false
	check_box.button_pressed = default == "yes"
	reset.visible = false
	emit_signal("_changed", String(name) , null)


func _on_CheckBox_toggled(button_pressed: bool) -> void:
	print("check_box: ", value)
	value = "yes" if button_pressed else "no"
	changed = default != value
	reset.visible = changed
	emit_signal("_changed", String(name) , value if changed else null)


func get_parameter() -> String:
	return String(name) + "=" + value


func set_value(_value:String)->void:
	print("flag set value: ", _value, " default: ", default)
	value = _value
	changed = value != default
	await get_tree().process_frame
	reset.visible = changed
	#emit_signal("_changed", String(name) , value if changed else null)
