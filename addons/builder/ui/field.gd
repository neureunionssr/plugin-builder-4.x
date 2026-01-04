@tool

extends BuildRow

var changed:bool = false
var default:String
var value:String

@onready var name_label: Label = $HBoxContainer/Name
@onready var reset: Button = $HBoxContainer/End/Reset
@onready var value_line: LineEdit = $HBoxContainer/Value


func _ready() -> void:
	value_line.connect("text_changed", set_value)
	value = default
	value_line.text = value
	name_label.text = String(name)


#func _on_Value_text_changed(new_text: String) -> void:
##	value_line.text = new_text
	#value = new_text
	#changed = new_text != default
	#reset.visible = changed
	#emit_signal("_changed", name , changed)


func row_reset() -> void:
	value_line.text = default
	value = default
	changed = false
	reset.visible = changed
	emit_signal("_changed", String(name) , null)


func get_parameter() -> String:
	return String(name) + "=" + value


func set_value(new_text: String) -> void:
	value = new_text
	changed = new_text != default
	reset.visible = changed
	emit_signal("_changed", String(name) , value if changed else null)
