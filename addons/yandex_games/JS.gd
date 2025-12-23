extends Node

@onready var window: JavaScriptObject
@onready var console: JavaScriptObject
@onready var array: JavaScriptObject
@onready var document: JavaScriptObject
@onready var canvas: JavaScriptObject
@onready var LeaderBoard: JavaScriptObject


@onready var _js_adv_open_callback: JavaScriptObject
@onready var _js_adv_close_callback: JavaScriptObject
@onready var _js_adv_error_callback: JavaScriptObject
@onready var _js_adv_offline_callback: JavaScriptObject
@onready var _js_banner_then: JavaScriptObject
@onready var _js_rew_open_callback: JavaScriptObject
@onready var _js_rew_close_callback: JavaScriptObject
@onready var _js_rew_rewarded_callback: JavaScriptObject
@onready var _js_rew_error_callback: JavaScriptObject
@onready var _js_pointer_lock_callback: JavaScriptObject
@onready var _js_ysdk_started: JavaScriptObject
@onready var _js_ysdk_errored: JavaScriptObject
@onready var _js_focus_callback: JavaScriptObject
@onready var _js_blur_callback: JavaScriptObject
@onready var _js_fullscreen_callback: JavaScriptObject
@onready var _js_resize_callback: JavaScriptObject
@onready var _js_set_data_then: JavaScriptObject
@onready var _js_set_data_catch: JavaScriptObject
@onready var _js_get_data_then: JavaScriptObject
@onready var _js_get_data_catch: JavaScriptObject
@onready var _js_set_stats_then: JavaScriptObject
@onready var _js_set_stats_catch: JavaScriptObject
@onready var _js_get_stats_then: JavaScriptObject
@onready var _js_get_stats_catch: JavaScriptObject
@onready var _js_inc_stats_then: JavaScriptObject
@onready var _js_inc_stats_catch: JavaScriptObject
@onready var _js_callback_get_stats: JavaScriptObject
@onready var _js_callback_inc_stats: JavaScriptObject
@onready var _js_canvas_click_callback: JavaScriptObject
@onready var _js_get_player_then: JavaScriptObject
@onready var _js_get_player_in_start_then: JavaScriptObject
@onready var _js_api_pause: JavaScriptObject
@onready var _js_api_resume: JavaScriptObject

var callback_ysdk: Callable
var callback_player: Callable
var callback_pointer: Callable
var callback_fullscreen: Callable
var callback_focus: Callable
var callback_lb: Callable

var crypto = Crypto.new()
var crypto_key_private = CryptoKey.new()


var device: String = ""
var fullcsreen: bool = false
var player: JavaScriptObject
var ysdk: JavaScriptObject
var object: JavaScriptObject
var environment: JavaScriptObject
var active: bool = false
var adv_showing: bool = false
var adv_timer: Timer
var adv_timeout_duration: float = 9
var listening_pointer_lock: bool = false
var listening_fullscreen: bool = false
var listening_focus: bool = false
var listening_resize: bool = false
var listening_canvas_click: bool = false
var pointer_locked: bool = false
var player_authorised: bool = false
var is_ysdk_started: bool = false
var adv_can_showing: bool = false
var locale: String = "ru"
var DPI: float

signal adv(state)
signal rewarded_ad(state)
signal focus(state)
signal pointer(state)
signal fullscreen(state)
signal response_set_data
signal response_get_data
signal response_set_stats
signal response_get_stats
signal response_inc_stats
signal banner(state)
signal resize(state)
signal ysdk_started(state)
signal api_pause_resume

func _init():
	window = JavaScriptBridge.get_interface("window")
	adv_timer = Timer.new()
	adv_timer.wait_time = adv_timeout_duration
	if window == null:
		return
	console = JavaScriptBridge.get_interface("console")
	object = JavaScriptBridge.get_interface("Object")
	array = JavaScriptBridge.get_interface("Array")
	document = JavaScriptBridge.get_interface("document")
	canvas = JavaScriptBridge.get_interface("canvas")
	active = true
	DPI = window.devicePixelRatio
	crypto_key_private.load("res://addons/yandex_games/key.key", false)
	#_js_ysdk_started = JavaScriptBridge.create_callback(on_js_ysdk_started)
	#_js_ysdk_errored = JavaScriptBridge.create_callback(on_js_ysdk_errored)
	_js_get_player_then = JavaScriptBridge.create_callback(_on_js_get_player_then)
	#_js_get_player_in_start_then = JavaScriptBridge.create_callback(_on_js_get_player_in_start_then)
	_js_adv_open_callback = JavaScriptBridge.create_callback(_on_js_adv_open_callback)
	_js_adv_close_callback = JavaScriptBridge.create_callback(_on_js_adv_close_callback)
	_js_adv_error_callback = JavaScriptBridge.create_callback(_on_js_adv_error_callback)
	_js_adv_offline_callback = JavaScriptBridge.create_callback(_on_js_adv_offline_callback)
	_js_banner_then = JavaScriptBridge.create_callback(_on_js_banner_then)
	_js_rew_open_callback = JavaScriptBridge.create_callback(_on_js_rew_open_callback)
	_js_rew_close_callback = JavaScriptBridge.create_callback(_on_js_rew_close_callback)
	_js_rew_rewarded_callback = JavaScriptBridge.create_callback(_on_js_rew_rewarded_callback)
	_js_rew_error_callback = JavaScriptBridge.create_callback(_on_js_rew_error_callback)
	_js_pointer_lock_callback = JavaScriptBridge.create_callback(_on_js_pointer_lock_callback)
	_js_focus_callback = JavaScriptBridge.create_callback(_on_js_focus_callback)
	_js_blur_callback = JavaScriptBridge.create_callback(_on_js_blur_callback)
	_js_fullscreen_callback = JavaScriptBridge.create_callback(_on_js_fullscreen_callback)
	_js_resize_callback = JavaScriptBridge.create_callback(_on_js_resize_callback)
	_js_set_data_then = JavaScriptBridge.create_callback(_on_js_set_data_then)
	_js_set_data_catch = JavaScriptBridge.create_callback(_on_js_set_data_catch)
	_js_get_data_then = JavaScriptBridge.create_callback(_on_js_get_data_then)
	_js_get_data_catch = JavaScriptBridge.create_callback(_on_js_get_data_catch)
	_js_set_stats_then = JavaScriptBridge.create_callback(_on_js_set_stats_then)
	_js_set_stats_catch = JavaScriptBridge.create_callback(_on_js_set_stats_catch)
	_js_get_stats_then = JavaScriptBridge.create_callback(_on_js_get_stats_then)
	_js_get_stats_catch = JavaScriptBridge.create_callback(_on_js_get_stats_catch)
	_js_inc_stats_then = JavaScriptBridge.create_callback(_on_js_inc_stats_then)
	_js_inc_stats_catch = JavaScriptBridge.create_callback(_on_js_inc_stats_catch)
	_js_canvas_click_callback = JavaScriptBridge.create_callback(_on_js_canvas_click_callback)
	_js_api_pause = JavaScriptBridge.create_callback(_on_js_api_pause)
	_js_api_resume = JavaScriptBridge.create_callback(_on_js_api_resume)
	if window.ysdk:
		ysdk = window.ysdk
		is_ysdk_started = true
		environment = ysdk.environment
		locale = environment.i18n.lang
		device = ysdk.deviceInfo.type
		is_ysdk_started = true
		player = window.player
		player_authorised = player.isAuthorized()
		ready_game()

var callb_auth
@onready var _js_auth_get_pl_for_auth_then = JavaScriptBridge.create_callback(_on_js_auth_get_pl_for_auth_then)
@onready var _js_auth_update_pl_then = JavaScriptBridge.create_callback(_on_js_auth_update_pl_then)
@onready var _js_open_auth_dialog_then = JavaScriptBridge.create_callback(_on_js_open_auth_dialog_then)
@onready var _js_open_auth_dialog_catch = JavaScriptBridge.create_callback(_on_js_open_auth_dialog_catch)


func _ready() -> void :
	add_child(adv_timer)
	adv_timer.connect("timeout", adv_timer_left)
	adv_timer.one_shot = true
	adv_can_showing = true


func open_auth_dialog(callback = null):
	callb_auth = callback
	if not active:
		callb_auth.call_func("already")
		return
	ysdk.getPlayer().then(_js_auth_get_pl_for_auth_then)


func _on_js_auth_get_pl_for_auth_then(args):
	player = args[0]
	player_authorised = player.isAuthorized()
	if not player_authorised:
			ysdk.auth.openAuthDialog().then(_js_open_auth_dialog_then).catch(_js_open_auth_dialog_catch)
	else:
		if callb_auth != null:
			callb_auth.call_func("already")
			callb_auth = null


func _on_js_open_auth_dialog_then(args):
	ysdk.getPlayer().then(_js_auth_update_pl_then)


func _on_js_open_auth_dialog_catch(args):
	if callb_auth != null:
			callb_auth.call_func("canceled")
			callb_auth = null


func _on_js_auth_update_pl_then(args):
	player = args[0]
	if callb_auth != null:
			callb_auth.call_func("authorised")
			callb_auth = null


func is_player_auth() -> bool:
	if not active or not is_ysdk_started: return false
	return player.isAuthorized()



func get_player(scopes: bool = true, callb: Callable = Callable()) -> void :
	if not is_ysdk_started:
		if callb.is_valid(): callb.call("error")
		return
	var parameters: JavaScriptObject = JavaScriptBridge.create_object("Object")
	parameters.scopes = scopes
	callback_player = callb if callb.is_valid() else Callable()
	ysdk.getPlayer(parameters).then(_js_get_player_then)


func _on_js_get_player_then(args) -> void :
	player = args[0]
	player_authorised = player.isAuthorized()
	if callback_player:
		callback_player.call("ok")
		callback_player = Callable()


func listen_api_pause_resume() -> void :
	if not is_ysdk_started: return
	ysdk.on("game_api_pause", _js_api_pause)
	ysdk.on("game_api_resume", _js_api_resume)


func _on_js_api_pause() -> void :
	if not active or not is_ysdk_started: return
	emit_signal("api_pause_resume", "pause")


func _on_js_api_resume() -> void :
	if not active or not is_ysdk_started: return
	emit_signal("api_pause_resume", "resume")


func ready_game() -> void :
	if not is_ysdk_started: return
	ysdk.features.LoadingAPI.ready()


func gameplay_start() -> void :
	if not is_ysdk_started: return
	ysdk.features.GameplayAPI.start()


func gameplay_stop() -> void :
	if not is_ysdk_started: return
	ysdk.features.GameplayAPI.stop()


func set_stats(stats: Dictionary = {}, timeout: float = 10.0) -> void :
	if not is_ysdk_started:
		emit_signal("response_set_stats", "error")
		return
	player.setStats(dict_to_js_obj(stats)).then(_js_set_stats_then).catch(_js_set_stats_catch)


func _on_js_set_stats_then(args) -> void :
	emit_signal("response_set_stats", "ok")


func _on_js_set_stats_catch(args) -> void :
	emit_signal("response_set_stats", "error")


func inc_stats(stats: Dictionary) -> void :
	if not is_ysdk_started: return
	player.incrementStats(dict_to_js_obj(stats)).then(_js_inc_stats_then).catch(_js_inc_stats_catch)


func _on_js_inc_stats_then(args) -> void :
	emit_signal("response_inc_stats", "ok", args[0])


func _on_js_inc_stats_catch(args) -> void :
	emit_signal("response_inc_stats", "error")


func get_stats(keys: Array = []) -> void :
	if not is_ysdk_started:
		emit_signal("response_get_stats", "error")
		return
	if keys.size() > 0:
		player.getStats(arr_to_js_arr(keys)).then(_js_get_stats_then).catch(_js_get_stats_catch)
	else:
		player.getStats().then(_js_get_stats_then).catch(_js_get_stats_catch)

func _on_js_get_stats_then(args):
	emit_signal("response_get_stats", "ok", js_obj_to_dict(args[0]))

func _on_js_get_stats_catch(args):
	emit_signal("response_get_stats", "error")


func set_data(data: Dictionary = {}) -> void :
	if not is_ysdk_started:
		emit_signal("response_set_data", "error")
		return
	player.setData(dict_to_js_obj(data)).then(_js_set_data_then).catch(_js_set_data_catch)
	
func _on_js_set_data_then(args) -> void :
	emit_signal("response_set_data", "ok")

func _on_js_set_data_catch(args) -> void :
	emit_signal("response_set_data", "error")


func get_data(keys = null) -> void :
	if not is_ysdk_started: emit_signal("response_get_data", "error", {})
	if keys != null:
		player.getData(arr_to_js_arr(keys)).then(_js_get_data_then).catch(_js_get_data_catch)
	else:
		player.getData().then(_js_get_data_then).catch(_js_get_data_catch)

func _on_js_get_data_then(args):
	console.log(args[0])
	emit_signal("response_get_data", "ok", js_obj_to_dict(args[0]))

func _on_js_get_data_catch(args):
	emit_signal("response_get_data", "error", {})


func localstorage_length() -> int:
	if not active: return - 1
	return window.localStorage.length


func localstorage_set_item(key, data, crypt: bool = true) -> void :
	if not active or data == null: return
	if crypt:
		data = _encrypt_data(data)
	window.localStorage.setItem(key, data)


func localstorage_set_dict(dict: Dictionary) -> void :
	if not active: return
	if dict.size() > 0:
		for item in dict:
			window.localStorage.setItem(item, dict[item])


func localstorage_get_item(key, crypted: bool = true):
	if not active: return ""
	var result = window.localStorage.getItem(key)
	if result != null:
		if crypted:
			result = _decrypt_data(result)
	return result


func localstorage_key(index: int):
	if not active: return null
	window.localStorage.key(index)


func localstorage_remove_item(key) -> void :
	if not active: return
	window.localStorage.removeItem(key)


func localstorage_clear() -> void :
	if not active: return
	window.localStorage.clear()


func localstorage_is_empty() -> bool:
	if not active: return true
	return window.localStorage.length == 0


func listener_fullcsreen(turn: bool, callback = null):
	if not active:
		return
	if turn:
		if not listening_fullscreen:
			callback_fullscreen = callback
			document.addEventListener("fullscreenchange", _js_fullscreen_callback)
			listening_fullscreen = true
	else:
		if listening_fullscreen:
			document.removeEventListener("fullscreenchange", _js_fullscreen_callback)
			listening_fullscreen = false


func _on_js_fullscreen_callback(args):
	fullcsreen = ysdk.screen.fullscreen.status != "on"
	emit_signal("fullscreen", fullcsreen)
	if callback_fullscreen != null:
		callback_fullscreen.call(fullcsreen)
		callback_fullscreen = Callable()


func fullscreen_switch():
	if not is_ysdk_started:
		return
	if not listening_fullscreen:
		listener_fullcsreen(true)
	if not fullcsreen:
		ysdk.screen.fullscreen.request()
	else:
		ysdk.screen.fullscreen.exit()


func show_banner():
	if not is_ysdk_started: return
	ysdk.adv.showBannerAdv().then(_js_banner_then)


func _on_js_banner_then(args):
	emit_signal("banner", args[0].stickyAdvIsShowing)


func hide_banner():
	if not is_ysdk_started: return
	ysdk.adv.hideBannerAdv()


@onready var ad_callb = JavaScriptBridge.create_object("Object")

func adv_timer_left() -> void :
	print("adv_timer_left")
	adv_can_showing = true


func show_adv(_adv_timeout: float = adv_timeout_duration) -> void :
	adv_showing = true
	if not is_ysdk_started:
		await get_tree().process_frame
		adv_showing = false
		emit_signal("adv", "error")
		return
	if not adv_can_showing:
		await get_tree().process_frame
		adv_showing = false
		emit_signal("adv", "wait")
		return
	if _adv_timeout != adv_timeout_duration:
		adv_timeout_duration = _adv_timeout
	var callbacks = JavaScriptBridge.create_object("Object")
	callbacks.onOpen = _js_adv_open_callback
	callbacks.onClose = _js_adv_close_callback
	callbacks.onError = _js_adv_error_callback
	#callbacks.onOffline = _js_adv_offline_callback
	ad_callb.callbacks = callbacks
	console.log(ysdk)
	console.log(callbacks)
	console.log(ysdk.adv)
	
	ysdk.adv.showFullscreenAdv(ad_callb)

func _on_js_adv_open_callback(args):
	adv_can_showing = false
	emit_signal("adv", "open")

func _on_js_adv_close_callback(args):
	adv_timer.start(adv_timeout_duration)
	adv_showing = false
	emit_signal("adv", "close")

func _on_js_adv_error_callback(args):
	emit_signal("adv", "error")

func _on_js_adv_offline_callback(args):
	emit_signal("adv", "offline")


@onready var rew_callb: JavaScriptObject = JavaScriptBridge.create_object("Object")


func show_rewarded() -> void :
	if not is_ysdk_started: return
	if not adv_showing:
		var callbacks = JavaScriptBridge.create_object("Object")
		callbacks.onOpen = _js_rew_open_callback
		callbacks.onClose = _js_rew_close_callback
		callbacks.onError = _js_rew_error_callback
		callbacks.onRewarded = _js_rew_rewarded_callback
		rew_callb.callbacks = callbacks
		ysdk.adv.showRewardedVideo(rew_callb)

func _on_js_rew_open_callback(args):
	adv_showing = true
	emit_signal("rewarded_ad", "open")

func _on_js_rew_close_callback(args):
	adv_showing = false
	emit_signal("rewarded_ad", "close")

func _on_js_rew_error_callback(args):
	emit_signal("rewarded_ad", "error")

func _on_js_rew_rewarded_callback(args):
	adv_showing = true
	emit_signal("rewarded_ad", "rewarded")


func listener_pointer_lock(turn: bool, callback = null):
	if not active: return
	if turn:
		if not listening_pointer_lock:
			callback_pointer = callback
			document.addEventListener("pointerlockchange", _js_pointer_lock_callback, false)
			document.addEventListener("mozpointerlockchange", _js_pointer_lock_callback, false)
			document.addEventListener("webkitpointerlockchange", _js_pointer_lock_callback, false)
			listening_pointer_lock = true
	else:
		if listening_pointer_lock:
			callback_pointer = Callable()
			document.removeEventListener("pointerlockchange", _js_pointer_lock_callback, false)
			document.removeEventListener("mozpointerlockchange", _js_pointer_lock_callback, false)
			document.removeEventListener("webkitpointerlockchange", _js_pointer_lock_callback, false)
			listening_pointer_lock = false

func _on_js_pointer_lock_callback(args):
	pointer_locked = document.pointerLockElement.id == "canvas" or document.mozPointerLockElement.id == "canvas" or document.webkitPointerLockElement.id == "canvas"
	if callback_pointer:
		callback_pointer.call(pointer_locked)
	emit_signal("pointer", pointer_locked)


func pointer_lock(variant: bool):
	print("pointer_lock start")
	if not active: return
	if not listening_pointer_lock:
		listener_pointer_lock(true)
	if variant:
		if canvas.requestPointerLock != null:
			canvas.requestPointerLock().catch(JavaScriptBridge.create_callback(_on_js_pl_request_catch))
			return
		if canvas.mozRequestPointerLock != null:
			canvas.mozRequestPointerLock().catch(JavaScriptBridge.create_callback(_on_js_pl_request_catch))
			return
		if canvas.webkitRequestPointerLock != null:
			canvas.webkitRequestPointerLock().catch(JavaScriptBridge.create_callback(_on_js_pl_request_catch))
			return
	else:
		if canvas.requestPointerLock != null:
			document.exitPointerLock()
			return
		if canvas.mozRequestPointerLock != null:
			document.mozExitPointerLock()
			return
		if canvas.webkitRequestPointerLock != null:
			document.webkitExitPointerLock()
	print("pointer_lock finish")


func _on_js_pl_request_catch(args)->void:
	print(args[0])


func listener_canvas_click(turn: bool):
	if not active: return
	if turn:
		if not listening_canvas_click:
			canvas.addEventListener("click", _js_canvas_click_callback)
			listening_canvas_click = true
	else:
		if listening_canvas_click:
			document.removeEventListener("click", _js_canvas_click_callback)
			listening_canvas_click = false


func _on_js_canvas_click_callback(args):
	print("canvas_click")


func listen_page_focus(is_enable: bool = true, _callback_focus: Callable = Callable()) -> void :
	if not active: return
	if is_enable and not listening_focus:
		if _callback_focus: callback_focus = _callback_focus
		window.addEventListener("blur", _js_blur_callback)
		window.addEventListener("focus", _js_focus_callback)
		listening_focus = true
		return
	if not is_enable and listening_focus:
		callback_focus = Callable()
		window.removeEventListener("blur", _js_blur_callback)
		window.removeEventListener("focus", _js_focus_callback)
		listening_focus = false


func _on_js_focus_callback(_args):
	if callback_focus.is_valid(): callback_focus.call(true)
	emit_signal("focus", true)


func focus_on_canvas() -> void :
	if not active: return
	canvas.focus()


func _on_js_blur_callback(args):
	if callback_focus.is_valid(): callback_focus.call(false)
	emit_signal("focus", false)


func listener_resize(turn: bool):
	if not active: return
	if turn:
		if not listening_resize:
			window.addEventListener("resize", _js_resize_callback)
			listening_resize = true
	else:
		if listening_resize:
			window.removeEventListener("resize", _js_resize_callback)
			listening_resize = false


func _on_js_resize_callback(args):
	emit_signal("resize", args[0])


func get_server_time() -> float:
	if not is_ysdk_started: return - 1.0
	return ysdk.serverTime()


var lbs_for_description: JavaScriptObject
var lbs_for_set_score: JavaScriptObject
var lb_set_name: String
var lb_entry_name: String
var lb_entry_size_avatar: String
var lb_entries_name: String
var lb_entries_size_avatar: String
var lb_description_name: String
var lb_include_user: bool
var lb_quantity_around: int
var lb_quantity_top: int
var lb_set_data: String
var lb_set_score: int

@onready var _js_get_lb_description_then = JavaScriptBridge.create_callback(_on_js_get_lb_description_then)
@onready var _js_get_lbs_for_description_then = JavaScriptBridge.create_callback(_on_js_get_lbs_for_description_then)
@onready var _js_get_lbs_for_set_score_then = JavaScriptBridge.create_callback(_on_js_get_lbs_for_set_score_then)
@onready var _js_lb_set_score_is_available_then = JavaScriptBridge.create_callback(_on_js_lb_set_score_is_available_then)
#@onready var _js_get_lb_set_score_then = JavaScriptBridge.create_callback(_on_js_get_lb_set_score_then)
@onready var _js_lb_get_entry_is_available_then = JavaScriptBridge.create_callback(_on_js_lb_get_entry_is_available_then)
@onready var _js_get_lbs_for_player_entry_then = JavaScriptBridge.create_callback(_on_js_get_lbs_for_player_entry_then)
@onready var _js_lb_player_entry_then = JavaScriptBridge.create_callback(_on_js_lb_player_entry_then)
@onready var _js_lb_player_entry_catch = JavaScriptBridge.create_callback(_on_js_lb_player_entry_catch)

@onready var _js_get_lbs_for_entries_then = JavaScriptBridge.create_callback(_on_js_get_lbs_for_entries_then)
@onready var _js_lb_entries_then = JavaScriptBridge.create_callback(_on_js_lb_entries_then)
@onready var _js_lb_entries_catch = JavaScriptBridge.create_callback(_on_js_lb_entries_catch)

var callback_lb_description: Callable
var callback_lb_set_score: Callable
var callback_lb_player_entry: Callable
var callback_lb_entries: Callable


signal response_lb_get_player_entry
signal response_lb_get_entries
signal response_lb_get_description
signal response_lb_set_score


func leaderboard_get_entries(lb_name: String, avatar_size: String = "medium", include_user: bool = true, quantity_around: int = 2, quantity_top: int = 10, callback: Callable = Callable()):
	if not is_ysdk_started:
		emit_signal("response_lb_get_entries", "error")
		if callback.is_valid(): callback.call("error")
		return
	callback_lb_entries = callback
	lb_include_user = include_user
	lb_quantity_around = quantity_around
	lb_quantity_top = quantity_top
	lb_entries_name = lb_name
	lb_entries_size_avatar = avatar_size
	ysdk.getLeaderboards().then(_js_get_lbs_for_entries_then)


func _on_js_get_lbs_for_entries_then(args):
	var param: JavaScriptObject = JavaScriptBridge.create_object("Object")
	param.includeUser = lb_include_user
	param.quantityAround = lb_quantity_around
	param.quantityTop = lb_quantity_top
	args[0].getLeaderboardEntries(lb_entries_name, param).then(_js_lb_entries_then).catch(_js_lb_entries_catch)


func _on_js_lb_entries_then(args):
	var result = {}
	result.ranges = []
	for i in range(args[0].ranges.length):
		result.ranges = js_obj_to_dict(args[0].ranges)
	result.user_rank = args[0].userRank
	result.entries = []
	for i in range(args[0].entries.length):
		var e = _lb_entry(args[0].entries[i], lb_entries_size_avatar)
		result.entries.append(e)
	emit_signal("response_lb_get_entries", "ok", result)
	if callback_lb_entries != null:
		callback_lb_entries.call("ok", result)
	callback_lb_entries = Callable()


func _on_js_lb_entries_catch(args):
	if callback_lb_entries.is_valid():
		callback_lb_entries.call("error")
	emit_signal("response_lb_get_entries", "error")
	callback_lb_entries = Callable()


func leaderboard_get_player_entry(lb_name: String, _lb_entry_size_avatar: String = "medium", callback: Callable = Callable()) -> void :
	if not is_ysdk_started:
		if callback.is_valid(): callback.call("error", {})
		emit_signal("response_lb_get_player_entry", "error", {})
		return
	callback_lb_player_entry = callback
	lb_entry_name = lb_name
	lb_entry_size_avatar = _lb_entry_size_avatar
	ysdk.isAvailableMethod("leaderboards.getLeaderboardPlayerEntry").then(_js_lb_get_entry_is_available_then)


func _on_js_lb_get_entry_is_available_then(args):
	if args[0]:
		ysdk.getLeaderboards().then(_js_get_lbs_for_player_entry_then)
	else:
		emit_signal("response_lb_get_player_entry", "not available", {})
		if callback_lb_player_entry != null:
			callback_lb_player_entry.call("not available", {})
			callback_lb_player_entry = Callable()


func _on_js_get_lbs_for_player_entry_then(args):
	args[0].getLeaderboardPlayerEntry(lb_entry_name).then(_js_lb_player_entry_then).catch(_js_lb_player_entry_catch)

func _on_js_lb_player_entry_then(args):
	var result: Dictionary = _lb_entry(args[0], lb_entry_size_avatar)
	if callback_lb_player_entry != null:
		callback_lb_player_entry.call("ok", result)
	emit_signal("response_lb_get_player_entry", "ok", result)
	callback_lb_player_entry = Callable()


func _on_js_lb_player_entry_catch(args):
	if callback_lb_player_entry != null:
		callback_lb_player_entry.call("error")
	emit_signal("response_lb_get_player_entry", "error")
	callback_lb_player_entry = Callable()



func leaderboard_set_score(lb_name: String, score: int, data: String = "", callback: Callable = Callable()) -> void :
	if not is_ysdk_started:
		if callback.is_valid(): callback.call("error")
		emit_signal("response_lb_set_score", "error", {})
		return
	lb_set_name = lb_name
	lb_set_score = score
	lb_set_data = data
	callback_lb_set_score = callback
	ysdk.isAvailableMethod("leaderboards.setLeaderboardScore").then(_js_lb_set_score_is_available_then)

func _on_js_lb_set_score_is_available_then(args):
	if args[0]:
		ysdk.getLeaderboards().then(_js_get_lbs_for_set_score_then)
	else:
		if callback_lb_set_score != null:
			callback_lb_set_score.call("not available")
			callback_lb_set_score = Callable()
		emit_signal("response_lb_set_score", "error", {})

func _on_js_get_lbs_for_set_score_then(args):
	if lb_set_data != "":
		args[0].setLeaderboardScore(lb_set_name, lb_set_score, lb_set_data)
	else:
		args[0].setLeaderboardScore(lb_set_name, lb_set_score)
	if callback_lb_set_score != null:
		callback_lb_set_score.call("set")
		callback_lb_set_score = Callable()
	emit_signal("response_lb_set_score", "ok", {})


func leaderboard_get_description(board_name: String, callback = null):
	if not is_ysdk_started:
		if callback: callback.call_func("error")
		emit_signal("response_lb_get_description", "error", {})
		return
	lb_description_name = board_name
	callback_lb_description = callback
	ysdk.getLeaderboards().then(_js_get_lbs_for_description_then)

func _on_js_get_lbs_for_description_then(args):
	args[0].getLeaderboardDescription(lb_description_name).then(_js_get_lb_description_then)

func _on_js_get_lb_description_then(args):
	if callback_lb_description:
		callback_lb_description.call(js_obj_to_dict(args[0]))
		callback_lb_description = Callable()
	emit_signal("response_lb_get_description", "ok", js_obj_to_dict(args[0]))


func _lb_entry(entry: JavaScriptObject, avatar_size: String = "medium") -> Dictionary:
	if typeof(entry) != 17: return {}
	var result: Dictionary = {}
	result.id = entry.player.uniqueID
	result.public_name = entry.player.publicName
	var url_src = entry.player.getAvatarSrc(avatar_size)
	var url_src_set = entry.player.getAvatarSrcSet(avatar_size)
	result.avatar_src = url_src
	result.avatar_src_set = url_src_set
	result.score = entry.score
	result.formatted_score = entry.formattedScore
	result.data = entry.extraData
	result.rank = entry.rank
	result.lang = entry.player.lang
	return result


func clipboard_add(text: String) -> void :
	if not is_ysdk_started: return
	ysdk.clipboard.writeText(text)


func dict_to_js_obj(dict) -> JavaScriptObject:
	var d = JavaScriptBridge.create_object("Object")
	for key in dict.keys():
		if typeof(dict[key]) < 5:
			d[key] = dict[key]
		else:
			d[key] = arr_to_js_arr(dict[key])
	return d


func js_obj_to_dict(data) -> Dictionary:
	if data == null:
		return {}
	var keys = object.keys(data)
	var length = keys.length
	var result = {}
	for i in range(length):
		match js_typeof(data[keys[i]]):
			"array":
				result[keys[i]] = js_arr_to_arr(data[keys[i]])
			"object":
				result[keys[i]] = js_obj_to_dict(data[keys[i]])
			"null": result[keys[i]] = null
			"function": 1
			"promise": 1
			_:
				result[keys[i]] = data[keys[i]]
	return result


func js_arr_to_arr(js_array) -> Array:
	if js_array == null:
		return []
	var a = []
	var l = js_array.length
	for j in range(l):
		a.append(js_array[j])
	return a


func arr_to_js_arr(_array) -> JavaScriptObject:
	var a = JavaScriptBridge.create_object("Array")
	for i in _array:
		a.push(i)
	return a


func js_typeof(value) -> String:
	return window.typeOf(value)

func _encrypt_data(data) -> String:
	return var_to_str(crypto.encrypt(crypto_key_private, str(data).to_utf8_buffer()))

func _decrypt_data(data: String):
	return crypto.decrypt(crypto_key_private, str_to_var(data)).get_string_from_utf8()


func _js_script_to_document(script_text: String):
	if not active: return
	var scr = document.createElement("script");
	scr.text = script_text;
	scr.type = "text/JavaScriptBridge"
	scr.async = true
	document.body.appendChild(scr);
