@tool
class_name ScreenSizeLabel
extends Label


func _enter_tree() -> void:
	if not OS.is_debug_build():
		free()


func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	var viewport_size := get_viewport_rect().size
	text = "%d:%d" % [viewport_size.x, viewport_size.y]


func _on_viewport_size_changed() -> void:
	var viewport_size := get_viewport_rect().size
	text = "%d:%d" % [viewport_size.x, viewport_size.y]
