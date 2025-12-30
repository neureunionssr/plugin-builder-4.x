tool
extends EditorExportPlugin

class_name CustomExportPlugin
var target_path:String


#func _export_begin(features, is_debug, path, flags):
#	if "HTML5" in features:
#		build_html5_template()


func build_html5_template():
	var config:ConfigFile = ConfigFile.new()
	var commands = ["scons", "platform=javascript"]
	if config.load("res://addons/builder/settings.cfg") != OK:
		return
	else:
		var parameters = config.get_section_keys("Parameters")
		for param in parameters:
			commands.append(param + "=" + config.get_value("Parameters", param))
	var directory = config.get_value("Source", "path")
	directory = directory.replace("/", "\\")
	commands.append("--directory=" + directory)
	var output = []
	OS.execute("powershell", commands, true, output, false, true)
	print(output)


func _export_end():
	
	var commands = ["scons", "-h", ]
#	if config.load("res://addons/builder/settings.cfg") != OK:
#		return
#	else:
#		var parameters = config.get_section_keys("Parameters")
#		for param in parameters:
#			commands.append(param + "=" + config.get_value("Parameters", param))
#	var directory = config.get_value("Source", "path")
#	directory = directory.replace("/", "\\")
#	commands.append("--directory=" + directory)
#	print(commands)
#	var output = []
#	OS.execute("powershell", commands, true, output, false, true)
#	print(output)
	pass


func get_global_path_dir(path:String):
	var project_path = ProjectSettings.globalize_path("res://")
	var ret:String
	if path.begins_with("../"):
		var c = 0
		while path.begins_with("../"):
			c += 1
			path = path.substr(3, path.length())
		for i in range(c + 1):
			project_path = project_path.substr(0,project_path.rfind("/"))
		ret =  project_path + "/" + path
	elif path.find(":") >-1:
		ret = project_path
	else:
		ret = project_path + path
	return ret.get_base_dir()
