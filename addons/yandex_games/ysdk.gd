@tool 
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("JS", "res://addons/yandex_games/JS.gd")
#	add_custom_type("AdTimer", "Timer", load("res://addons/yandex_games/adv_timer.gd"), null)
	add_custom_type("FocusTimerADV", "Timer", load("res://addons/yandex_games/focus_timer_adv.gd"), null)



func _exit_tree():
	remove_autoload_singleton("JS")
	remove_custom_type("FocusTimerADV")
