@tool
extends BuildRow

var changed:bool = false
var default:int
var value:int


@onready var name_label: Label = $HBoxContainer/Name
@onready var reset: Button = $HBoxContainer/End/Reset
@onready var option: OptionButton = $HBoxContainer/Option


func _ready() -> void:
	name_label.text = String(name)
	value = default
	option.select(value)


func _on_Reset_pressed() -> void:
	value = default
	option.select(value)
	reset.visible = false
	changed = false
	emit_signal("_changed", String(name) , changed)


func _on_Option_item_selected(index: int) -> void:
	value = index
	if index != default:
		reset.visible = true
		changed = true
	else:
		reset.visible = false
		changed = false
	emit_signal("_changed", String(name) , changed)


func get_parameter() -> String:
	return String(name) + "=" + option.get_item_text(option.selected)
