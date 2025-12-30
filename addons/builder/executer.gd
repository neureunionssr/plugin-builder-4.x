@tool
class_name Executer
extends Node


func _init() -> void:
	#OS.execute_with_pipe(path: String, arguments: PackedStringArray, blocking: bool = true)
	set_process(false)



#func get_scons_help(platform:String="windows") -> PackedStringArray:
	#var result:PackedStringArray
	#var commands = ["scons", "-h", "platform=" + platform]
	#var directory = source_path_label.text
	#directory = directory.replace("/", "\\")
	#commands.append("--directory=" + directory)
	#var output:Array = []
	##OS.execute("powershell", commands, true, output, false, true)
	#result = output[0].replace("\n ", "").rsplit("\n")
	#print(output[0])
	#return output[0].rsplit("\n")


func get_platforms(path:String) -> PackedStringArray:
	var result:PackedStringArray
	var commands = ["-Command", "scons", "platform=list"]
	var directory = path
	directory = directory.replace("/", "\\")
	commands.append("--directory=" + directory)
	#var output = []
	#OS.execute("powershell", commands, true, output, false, true)
	var output:Dictionary = OS.execute_with_pipe("powershell.exe", commands, false)
	print(output)
	set_process(true)
	return result
