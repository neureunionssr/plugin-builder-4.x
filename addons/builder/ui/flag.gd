@tool
extends BuildRow

var changed:bool = false
var default:String
var value:String

@onready var name_label: Label = $HBoxContainer/Name
@onready var reset: Button = $HBoxContainer/End/Reset
@onready var check_box: CheckBox = $HBoxContainer/CheckBox


func _ready() -> void:
	value = default
	check_box.button_pressed = default == "yes"
	name_label.text = String(name)


func _on_Reset_pressed() -> void:
#	value_line.text = default
	value = default
	changed = false
	check_box.button_pressed = default == "yes"
	reset.visible = false
	emit_signal("_changed", String(name) , null)


func _on_CheckBox_toggled(button_pressed: bool) -> void:
	value = "yes" if button_pressed else "no"
	changed = default != value
	reset.visible = changed
	emit_signal("_changed", String(name) , value if changed else null)


func get_parameter() -> String:
	return String(name) + "=" + value
