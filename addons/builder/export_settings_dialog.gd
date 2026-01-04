@tool
extends MarginContainer
class_name ExportSettingsDialog

const SETTINGS_CONFIG_PATH = "res://addons/builder/configs/settings_config.cfg"


var settings_config:ConfigFile
var source_path:String = ""
var platforms:Array[String]

@onready var header_container: VBoxContainer = $VBoxContainer/MarginContainer/HeaderContainer
@onready var row_container: VBoxContainer = $VBoxContainer/MarginContainer2/ScrollContainer/RowContainer

@onready var file_dialog: FileDialog = $FileDialog


@onready var build_template_button: Button = $VBoxContainer/MarginContainer/HeaderContainer/ButtonRow/BuildTemplate
@onready var copy_commands_button: Button = $VBoxContainer/MarginContainer/HeaderContainer/ButtonRow/CopyCommands
@onready var copy_path_button: Button = $VBoxContainer/MarginContainer/HeaderContainer/ButtonRow/CopyPath
@onready var scons_clean_button: Button = $VBoxContainer/MarginContainer/HeaderContainer/ButtonRow/SconsClean
@onready var reset_to_default_button: Button = $VBoxContainer/MarginContainer/HeaderContainer/ButtonRow/ResetToDefaultButton
@onready var all_reset_button: Button = $VBoxContainer/MarginContainer/HeaderContainer/ButtonRow/AllReset
@onready var path_value: LineEdit = $VBoxContainer/MarginContainer/HeaderContainer/SourcePathRow/HBoxContainer/Value
@onready var path_button: Button = $VBoxContainer/MarginContainer/HeaderContainer/SourcePathRow/HBoxContainer/Button
@onready var platform_option: OptionButton = $VBoxContainer/MarginContainer/HeaderContainer/PlatformRoww/HBoxContainer/Option


var field_scene := preload("res://addons/builder/ui/field.scn")
var flag_scene := preload("res://addons/builder/ui/flag.scn")
var list_scene := preload("res://addons/builder/ui/list.scn")
var path_scene := preload("res://addons/builder/ui/path.scn")


var current_path_row:NodePath
#
#signal list_changed(key, value)
#
func _init():
	settings_config = ConfigFile.new()
	if settings_config.load(SETTINGS_CONFIG_PATH) != OK: 
		settings_config.save(SETTINGS_CONFIG_PATH)


func start_dialog() -> void:
	print('_enter_tree')
	
	if !settings_config.has_section_key("settings", "path"): return
	source_path = settings_config.get_value("settings", "path")
	if source_path == "": return
	copy_path_button.disabled = false
	if settings_config.has_section_key("settings", "platforms"): 
		platforms = settings_config.get_value("settings", "platforms")
	path_value.text = source_path
	print(platforms)
	if platforms.size() == 0: 
		platforms = get_platforms(source_path)
		if platforms.size() == 0: return
		else: 
			print("tested platforms: ", platforms)
			settings_config.set_value("settings", "platforms", platforms)
			settings_config.set_value("parameters", "platform", platforms[0])
			settings_config.save(SETTINGS_CONFIG_PATH)
	if platforms.size() == 0: return
	if !settings_config.has_section_key("parameters", "platform"):
		settings_config.set_value("parameters", "platform", platforms[0])
		settings_config.save(SETTINGS_CONFIG_PATH)
	var attributes := get_scons_attribute_list(settings_config.get_value("parameters", "platform"))
	#print("attributes: ", attributes)
	var parsed_array := parsing_help(attributes)
	#print("parsed_array: ", parsed_array)
	if parsed_array.size() > 0:
		add_rows_to_ui(parsed_array)
	if platforms.size() != 0:
		for p in platforms:
			platform_option.add_item(p)
		platform_option.disabled = false
	
	#if config.has_section("Parameters"):
			#for key in config.get_section_keys("Parameters"):
				#print("key")


func get_platforms(path:String) -> Array[String]:
	var result:Array[String]
	var commands = ["-Command", "scons", "platform=list"]
	var directory = path
	directory = directory.replace("/", "\\")
	commands.append("--directory=" + directory)
	var output = []
	OS.execute("powershell.exe", commands, output, false, true)
	if output.size() == 0: return result
	if output[0].find("scons: *** No SConstruct file found.") > -1:
		return result
	var a:Array = output[0].replace("\n ", "").rsplit("\n")
	var start:bool = false
	for row in a:
		row = row.strip_edges()
		if start and row.length() > 0: 
			result.append(row)
		if row == "The following platforms are available:":
			start = true
	result.remove_at(result.size() - 1)
	return result


func get_scons_attribute_list(platform:String) -> Array:
	var result:PackedStringArray
	if platform == "": return result
	var commands = ["-Command", "scons", "-h", "platform=" + platform]
	var directory = source_path
	directory = directory.replace("/", "\\")
	commands.append("--directory=" + directory)
	print("commands: ", commands)
	var output:Array = []
	OS.execute("powershell.exe", commands, output, true, true)
	result = output[0].rsplit("\n")
	return Array(result)


func _on_path_button_pressed(extra_arg_0: String) -> void:
	var current_path:String = get_node(extra_arg_0).get_child(0).get_child(2).text
	current_path_row = extra_arg_0
	if current_path != "" and current_path.is_absolute_path():
		file_dialog.current_path = current_path
	file_dialog.popup()


func _on_file_dialog_dir_selected(dir: String) -> void:
	if dir == null: return
	print("_on_file_dialog_dir_selected dir:", dir, " current_path_row: ",  current_path_row)
	var call_row = get_node(current_path_row)
	if call_row == null: return
	var name = call_row.get_child(0).get_child(0).text
	match name:
		"--directory":
			var res:PackedStringArray = get_platforms(dir)
			remove_rows_from_ui()
			if res.size() == 0: return
			path_value.text = dir
			clean_option(platform_option)
			for p in res:
				platform_option.add_item(p)
			platform_option.disabled = false
			#copy_path_button.disabled = false
			settings_config.set_value("parameters", "platform", platform_option.get_item_text(platform_option.get_selected_id()))
			settings_config.save(SETTINGS_CONFIG_PATH)
			print("target: ", platform_option.get_item_text(platform_option.get_selected_id()))
			var attributes := get_scons_attribute_list(platform_option.get_item_text(platform_option.get_selected_id()))
			#print("attributes: ", attributes)
			var rows_data := parsing_help(attributes)
			#print("rows_data: ",rows_data)
			if rows_data.size() > 0:
				add_rows_to_ui(rows_data)
		_:
			call_row.set_value(dir)


func remove_rows_from_ui() -> void:
	for row in row_container.get_children():
		if row is BuildRow:
			if is_connected("_changed", row_changed): row.disconnect("_changed", row_changed)
		row_container.remove_child(row)
		row.queue_free()


func row_changed(row_name:String, value)->void:
	if !value: 
		print("returned to default")
		if settings_config.load(SETTINGS_CONFIG_PATH) != OK: return
		if settings_config.has_section_key("parameters", row_name):
			settings_config.erase_section_key("parameters", row_name)
			settings_config.save(SETTINGS_CONFIG_PATH)
	else:
		print("new value")
		if settings_config.load(SETTINGS_CONFIG_PATH) != OK: return
		settings_config.set_value("parameters", row_name, value)
		settings_config.save(SETTINGS_CONFIG_PATH)


func clean_option(opt:OptionButton) -> void:
	if opt == null: return
	while opt.get_item_count() > 0:
		opt.remove_item(0)


func add_row_to_container(row:Dictionary, container:Control) -> void:
	var res:BuildRow
	match row.type:
		"field":
			res = field_scene.instantiate()
			res.name = row.name
			res.default = row.default
			res.tooltip_text = row.description
		"list":
			res = list_scene.instantiate()
			res.name = row.name
			var opt:OptionButton = res.get_child(0).get_child(2)
			for v in row.value:
				opt.add_item(v)
			res.tooltip_text = row.description
			res.default = row.value.find(row.default)
		"flag":
			res = flag_scene.instantiate()
			res.name = row.name
			res.default = row.default
			res.tooltip_text = row.description
		"path":
			res = path_scene.instantiate()
			res.name = row.name
			res.default = row.default
			res.tooltip_text = row.description
			container.add_child(res)
			res.button.pressed.connect(_on_path_button_pressed.bind([res.get_path()]))
			return
	container.add_child(res)
	res.connect("_changed", row_changed)


func parsing_help(output:Array) -> Array:
	var result:Array
	var succes:bool = false
	for row in output:
		if row.begins_with("scons: done reading SConscript files."):
			succes = true
			break
	if !succes: return []
	var started:bool = false
	var line:String
	while output.size() > 0:
		line = output.pop_front().strip_edges()
		if line.begins_with("platform:") and !started:
			started = true
			line = output.pop_front().strip_edges()
			while line.length() > 1:
				line = output.pop_front()
			continue
		if started:
			if line.begins_with("Use scons -H"): return result
			var row:Dictionary
			var default:String
			row.name = line.substr(0, line.find(":"))
			row.description = line.substr(line.find(":") + 1, line.find("(") - line.find(":") - 1).strip_edges()
			var spliter:String = "|" if line.find("|") > -1 else "/"
			var pool:PackedStringArray
			if line.find("(") > -1: pool = line.substr(line.rfind("(") + 1, line.rfind(")") - line.rfind("(") - 1).split(spliter)
			while line.length() > 1:
				line = output.pop_front().strip_edges()
				if line.begins_with("actual:"):
					default = line.substr(line.find(":") + 1).strip_edges()
					if default == "None": default = ""
			#print("row: ", row, " pool: ", pool, " ", line, " ", line.rfind(")") - line.rfind(")") - 2)
			if pool.size() == 0:
				row.type = "path" if row.name in ["custom_modules", "build_profile"] else "field"
				row.default = default
				result.append(row)
			elif pool.has("yes"):
				row.type = "flag"
				row.default = "yes" if default == "True" else "no"
				row.value = pool
				result.append(row)
			elif pool.size() > 1:
				row.type = "list"
				if default.length() == 0: pool.append("")
				row.default = default
				row.value = pool
				result.append(row)
			else:
				row.type = "field"
				row.default = default
				row.value = pool
				result.append(row)
	return result


func add_rows_to_ui(rows:Array) -> void:
	for row in rows:
		add_row_to_container(row, row_container)


func _platform_selected(index: int) -> void:
	print("_platform_selected: ", platform_option.get_item_text(index))
	settings_config.set_value("parameters", "platform", platform_option.get_item_text(index))


#func _on_ReadSconsHelp_pressed() -> void:
	#remove_rows_from_ui()
	#if !settings_config.has_section_key("settings", "path"): return
	#var path:String = settings_config.get_value("settings", "path")
	#var list:PackedStringArray = get_scons_help(path)
	#print("scons_help: ", list)
	#var ret = parsing_help(list)
	#print("parsed rows: ", ret)
	#if ret.size() > 0:
		#add_rows_to_ui(ret)
		#reset_to_default.disabled = false
		#build_button.disabled = false
#
#
#func _on_AllReset_pressed() -> void:
	#remove_rows_from_ui()
	#source_path_label.text = ""
	#clean_option(platform_option)
	#read_scons_help_button.disabled = true
	#reset_to_default.disabled = true
	#build_button.disabled = true
	#copy_path_button.disabled = true
#
##переделать
#func _on_ResetToDefaultButton_pressed():
	#for i in range(0, row_container.get_child_count(), 2):
		#row_container.get_child(i)._on_Reset_pressed()
#
#
#func _on_OptionButton_item_selected(index):
	#pass
	##config.set_value("Parameters",$ScrollContainer/PanelContainer/VBoxContainer/TargetHBC/Label.text, $ScrollContainer/PanelContainer/VBoxContainer/TargetHBC/OptionButton.get_item_text(index))
	##config.save(CONFIG_PATH)
##	emit_signal("list_changed",$ScrollContainer/PanelContainer/VBoxContainer/TargetHBC/Label.text,$ScrollContainer/PanelContainer/VBoxContainer/TargetHBC/OptionButton.get_item_text(index))
#
##на удаление или изменение
#func load_parameters_from_config() -> void:
	#print("load_parameters_from_config")
	#if !settings_config.has_section_key("settings", "path"): return
	#var path:String = settings_config.get_value("settings", "path")
	#print("path: ", path )
	#if path == "": return
	#copy_path_button.disabled = false
	#$ScrollContainer/PanelContainer/VBoxContainer2/HeaderContainer/PathRow/Value.text = path
	#$ScrollContainer/PanelContainer/VBoxContainer2/HeaderContainer/ButtonRow/ReadSconsHelp.disabled = false
	#platforms = get_platforms(path)
	#if platforms.size() != 0:
		#for p in platforms:
			#$ScrollContainer/PanelContainer/VBoxContainer2/HeaderContainer/PlatformRow/Option.add_item(p)
		#$ScrollContainer/PanelContainer/VBoxContainer2/HeaderContainer/PlatformRow/Option.disabled = false
	##if config.has_section("Parameters"):
		##for key in config.get_section_keys("Parameters"):
			##print("key")
#
#
#func build() -> void:
	#var commands:Array = ["scons", "platform=" + platform_option.text]
	#for i in range(0, row_container.get_child_count(), 2):
		#var row:Container = row_container.get_child(i)
		#if row.changed:
			#commands.append(row.get_parameter())
	#var directory = source_path_label.text
	#directory = directory.replace("/", "\\")
	#commands.append("--directory=" + directory)
	#var output = []
	##OS.execute("powershell", commands, true, output, false, true)
	#
	#print(output)
	#print(str(commands))
#
#
## временно использована кнопка под тест добавлятора платформ - переделать
#func _on_BuildTemplate_pressed():
	#build()
#
#
#func _on_CopyPath_pressed():
	#if source_path_label.text != "":
		#DisplayServer.clipboard_set(source_path_label.text)
#
#
#func get_template_path() -> String:
	##config.load(CONFIG_PATH)
	#var path:String
	##if config.has_section_key("Source", "path"):
		##path = config.get_value("Source", "path") + "/bin/"
	#var dir = DirAccess.open(path)
	#dir.list_dir_begin()
	#var file = dir.get_next()
	#while file != "":
		#if file.get_extension() == "zip":
			#path +=file
			#file = ""
		#else:
			#file = dir.get_next()
	#return path
#
#
#func _on_ReadSconsHelp_pressed() -> void:
	#remove_rows_from_ui()
	#if !settings_config.has_section_key("settings", "path"): return
	#var path:String = settings_config.get_value("settings", "path")
	#var list:PackedStringArray = get_scons_help(path)
	#print("scons_help: ", list)
	#var ret = parsing_help(list)
	#print("parsed rows: ", ret)
	#if ret.size() > 0:
		#add_rows_to_ui(ret)
		#reset_to_default.disabled = false
		#build_button.disabled = false
#
#
#func remove_rows_from_ui() -> void:
	#for row in row_container.get_children():
		#if row is BuildRow:
			#if is_connected("_changed", row_changed): row.disconnect("_changed", row_changed)
		#row_container.remove_child(row)
		#row.queue_free()
#
## неплохо бы переделать под универсальную функцию для 
## обращения к командной строке за данными с передачей нужных параметров
#func get_scons_help(platform:String="windows") -> PackedStringArray:
	#var result:PackedStringArray
	#var commands = ["-Command", "scons", "-h", "platform=" + platform]
	#var directory = source_path_label.text
	#directory = directory.replace("/", "\\")
	#commands.append("--directory=" + directory)
	#var output:Array = []
	#OS.execute("powershell.exe", commands, output, true, true)
	#print("output: ", output)
	#result = output[0].replace("\n ", "").rsplit("\n")
	#return output[0].rsplit("\n")
#
## Исправитиь затем проверку scons, чтобы получать данные по конкретной платформе 
## сейчас тестовая по умолчанию
#func parsing_help(output:PackedStringArray) -> Array:
	#var success:bool = true
	#var result:Array
	#
	#for row in output:
		#if row.find("SCons Options:") > -1:
			#success = false
			#break
	#if !success: return []
	#success = false
	#for row in output:
		#if row.find("platform:") > -1:
			#output.remove_at(0)
			#success = true
			#break
		#else:
			#output.remove_at(0)
	#for row in output:
		#if row.length() > 1:
			#output.remove_at(0)
		#else:
			#output.remove_at(0)
			#break
	#if !success: return []
	#for i in range(0, output.size() - 4, 4):
		#var row:Dictionary
		#var c:String = output[i]
		#row.name = c.substr(0, c.find(":")).strip_edges()
		#row.description = c.substr(c.find(":") + 1).strip_edges()
		#var start:int = c.rfind("(") + 1
		#if start == 0: 
			#row.type = "path" if row.name == "custom_modules" else "field"
			#row.default = output[i + 2].substr(output[i + 2].find(":") + 1).strip_edges()
			#result.append(row)
			#continue
		#var end:int = c.rfind(")")
		#var length:int = end - start
		#var description:String = c.substr(start, length)
		#var spliter:String = "|" if c.find("|") > -1 else "/"
		#var pool:PackedStringArray = description.split(spliter)
		#c = output[i + 2]
		#if pool.has("yes"):
			#row.type = "flag"
			#row.default = "yes" if c.find("True") > -1 else "no"
			#row.value = pool
			#result.append(row)
			#continue
		#if pool.size() > 1 :
			#row.type = "list"
			#row.default = c.substr(c.find(":") + 1).strip_edges()
			#if row.default.length() == 0: pool.append(row.default)
			#row.value = pool
			#result.append(row)
			#continue
		#row.type = "field"
		#row.default = c.substr(c.find(":") + 1).strip_edges()
		#result.append(row)
	#print(result)
	#return result
#
#
#func add_rows_to_ui(rows:Array) -> void:
	#for row in rows:
		#add_row_to_container(row, row_container)
		#row_container.add_child(HSeparator.new())
#
#
#func add_row_to_container(row:Dictionary, container:Control) -> void:
	#var res:Container
	#match row.type:
		#"field":
			#res = field_scene.instance()
			#res.name = row.name
			#res.default = row.default
			#res.hint_tooltip = row.description
		#"list":
			#res = list_scene.instance()
			#res.name = row.name
			#var opt:OptionButton = res.get_child(2)
			#for v in row.value:
				#opt.add_item(v)
			#res.hint_tooltip = row.description
			#res.default = row.value.find(row.default)
		#"flag":
			#res = flag_scene.instance()
			#res.name = row.name
			#res.default = row.default
			#res.hint_tooltip = row.description
		#"path":
			#res = path_scene.instance()
			#res.name = row.name
			#res.default = row.default
			#res.hint_tooltip = row.description
			#container.add_child(res)
			#res.button.connect("pressed", path_button_pressed, [res.get_path()])
			#return
	#container.add_child(res)
	#res.connect("_changed", row_changed)
#
### передается path как аргумент, возможно потом поменять

#
#
#func path_button_pressed(extra_arg_0: String) -> void:
	#print("path_button_pressed")
	#var current_path:String = get_node(extra_arg_0).get_child(2).text
	#current_path_row = extra_arg_0
	#if current_path.is_absolute_path():
		#file_dialog.current_path = current_path
	#file_dialog.popup()
#
#
#func _on_FileDialog_dir_selected(dir:String) -> void:
	#if dir == null: return
	#var call_row = get_node(current_path_row)
	#if call_row == null: return
	#var name = call_row.get_child(0).text
	#match name:
		#"Source":
			#var res:PackedStringArray = get_platforms(dir)
			#remove_rows_from_ui()
			#if res.size() == 0: return
			#source_path_label.text = dir
			#clean_option(platform_option)
			#for p in res:
				#platform_option.add_item(p)
##			header_container.add_child(HSeparator.new())
			#platform_option.disabled = false
			#read_scons_help_button.disabled = false
			#copy_path_button.disabled = false
			#settings_config.set_value("settins", "path", dir)
			#settings_config.set_value("settings", "platform", platform_option.get_item_text(platform_option.get_selected_id()))
			#settings_config.save(SETTINGS_CONFIG_PATH)
			#
			#
		#_:
			#call_row.set_value(dir)
#
#
#func clean_option(opt:OptionButton) -> void:
	#if opt == null: return
	#while opt.get_item_count() > 0:
		#opt.remove_item(0)
#
#
#func _on_Option_item_selected(index: int) -> void:
##	_on_ReadSconsHelp_pressed()
	#pass
#
#
#
#func _on_SconsClear_pressed() -> void:
	#var commands = ["scons", "--clean"]
	#var directory = source_path_label.text
	#directory = directory.replace("/", "\\")
	#commands.append("--directory=" + directory)
	##OS.execute("powershell", commands, true, [], false, true)
#
#
#func _on_CopyCommands_pressed() -> void:
	#print("Copy Commands")
#
#
#func row_changed(row_name:String, value:bool)->void:
	#if !value: 
		#print("returned to default")
		##if config.load(CONFIG_PATH) != OK: return
		##if config.has_section_key("Parameters", row_name):
			##config.erase_section_key("Parameters", row_name)
			##config.save(CONFIG_PATH)
	#else:
		#print("new value")
		##if config.load(CONFIG_PATH) != OK: return
		##config.set_value("Parameters", row_name, value)
		##config.save(CONFIG_PATH)
