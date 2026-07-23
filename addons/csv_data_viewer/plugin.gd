@tool
extends EditorPlugin


const MainScreenScene = preload("res://addons/csv_data_viewer/main_screen_tab.tscn")

var main_screen_tab: Control

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	main_screen_tab = MainScreenScene.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_screen_tab)
	_make_visible(false)


func _exit_tree() -> void:
	if main_screen_tab:
		main_screen_tab.queue_free()


func _make_visible(visible: bool) -> void:
	if main_screen_tab:
		main_screen_tab.visible = visible


func _has_main_screen():
	return true


func _get_plugin_name() -> String:
	return "CSV Data Viewer"


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("Object", "EditorIcons")
