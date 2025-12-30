@tool
extends EditorPlugin
var explagin
var export_settings_dialog:Control


func _enter_tree()->void:
	export_settings_dialog = preload("res://addons/builder/export_settings_dialog.tscn").instantiate()
	add_control_to_container(CONTAINER_PROJECT_SETTING_TAB_RIGHT, export_settings_dialog)
	export_settings_dialog.start_dialog()


func _exit_tree()->void:
	#remove_export_plugin(explagin)
	remove_control_from_container(CONTAINER_PROJECT_SETTING_TAB_RIGHT, export_settings_dialog)
	export_settings_dialog.queue_free()



#CONTAINER_PROJECT_SETTING_TAB_RIGHT
