extends Node


func _init() -> void:
	JS.adv.connect(adv_status)
	JS.rewarded_ad.connect(rew_adv_status)
	JS.response_get_data.connect(data_returned)

func _ready() -> void:
	JS.set_data({"test": 120123})
	await get_tree().create_timer(10).timeout
	JS.get_data(["test"])
	JS.show_adv()

func adv_status(status:String)->void:
	print("adv: ", status)

func rew_adv_status(status:String)->void:
	print("rew: ", status)

func _on_button_pressed() -> void:
	JS.show_rewarded()

func data_returned(result:String, data:Dictionary)->void:
	print(result, " ", data)
