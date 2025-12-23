class_name FocusTimer
extends Timer
var _adv_watching: bool = false
var focus_out: bool = false

func _ready():
	JS.connect("focus", _on_focus)
	JS.connect("adv", _on_adv)
	connect("timeout", _timeout)

func _on_focus(state):
	if not JS.adv_showing:
		if not state:
			start()
			focus_out = true
		else:
			focus_out = false
			stop()


func _timeout():
	if not _adv_watching:
		JS.show_ad()


func _on_adv(state):
	if focus_out:
		match state:
			"wait":
				start()
			"close":
				focus_out = false
				stop()
