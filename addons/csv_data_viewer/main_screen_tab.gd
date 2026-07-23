@tool
extends Control


@onready var test_tree: Tree = $TabContainer/TestTree


func _ready() -> void:
	test_tree.hide_root = true
	test_tree.clear()
	test_tree.set_column_title(0, "Question")
	test_tree.set_column_title(1, "Response 1")
	test_tree.set_column_title(2, "Response 2")
	test_tree.set_column_title(3, "Response 3")
	test_tree.set_column_title(4, "Response 4")
	test_tree.set_column_title(5, "Response number")
	test_tree.set_column_title(6, "Mediation text")
	test_tree.columns = 7
	var root := test_tree.create_item()
	
	# Create 10 items
	for i in range(10):
		var new_item := test_tree.create_item()
		new_item.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
		new_item.set_text(0, "Question %d text blah blah blah" % i)
		new_item.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
		new_item.set_text(1, "Response 1 blah blah")
		new_item.set_cell_mode(2, TreeItem.CELL_MODE_STRING)
		new_item.set_text(2, "Response 2 blah blah")
		new_item.set_cell_mode(3, TreeItem.CELL_MODE_STRING)
		new_item.set_text(3, "Response 3 blah blah")
		new_item.set_cell_mode(4, TreeItem.CELL_MODE_STRING)
		new_item.set_text(4, "Response 4 blah blah")
		new_item.set_cell_mode(5, TreeItem.CELL_MODE_RANGE)
		new_item.set_range(5, randi_range(1, 4))
		new_item.set_range_config(5, 1, 4, 1, false)
		new_item.set_cell_mode(6, TreeItem.CELL_MODE_STRING)
		new_item.set_text(6, "mediation text blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah")
		for j in range(7):
			new_item.set_autowrap_mode(j, TextServer.AUTOWRAP_WORD_SMART)
			new_item.set_editable(j, true)
			new_item.set_edit_multiline(j, true)
