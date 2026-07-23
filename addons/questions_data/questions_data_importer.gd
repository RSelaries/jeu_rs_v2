@tool @abstract
extends EditorImportPlugin


var database: QuestionsDatabase


@abstract func _get_visible_name()
@abstract func _get_question_type() -> String
@abstract func _get_database() -> QuestionsDatabase


func _get_importer_name():
	return ".questions_data_importer"


func _get_priority():
	# The built-in Translation importer needs a restart to switch to other importer
	return 1.9

func _get_import_order():
	return 0

func _get_recognized_extensions():
	return ["csv"]


func _get_save_extension():
	return "res"


func _get_resource_type():
	return "Resource"


func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	database = _get_database()
	
	var lines = _get_csv_lines(source_file)
	
	var headers = lines[0]
	for i in range(1, lines.size()):
		var fields = lines[i]
		if fields.size() > headers.size():
			printerr("Line %d has more fields than headers" % i)
			return ERR_PARSE_ERROR
		
		var new_question = load(_get_question_type()).new()
		for j in headers.size():
			var name = headers[j]
			var raw_value = fields[j] if j < fields.size() else null
			if name in new_question:
				var expected_type := typeof(new_question.get(name))
				new_question.set(name, _convert_value(raw_value, expected_type))
		database.questions.append(new_question)
	
	var filename = save_path + "." + _get_save_extension()
	var err = ResourceSaver.save(database, filename)
	if err != OK:
		printerr("Failed to save resource: ", err)
	return err


func _get_csv_lines(source_file) -> Array:
	var file := FileAccess.open(source_file, FileAccess.READ)
	if not file:
		printerr("Failed to open file: ", source_file)
		return []
	
	var lines: Array
	while not file.eof_reached():
		var line := file.get_csv_line()
		lines.append(line)
	file.close()
	
	# Remove trailing empty line
	if not lines.is_empty() and lines.back().size() == 1 and lines.back()[0] == "":
		lines.pop_back()
	
	if lines.is_empty():
		printerr("Can't find header in empty file")
		return []
	
	return lines


func _convert_value(value, expected_type: int):
	if value == null:
		match expected_type:
			TYPE_STRING: return ""
			TYPE_INT: return 0
			TYPE_FLOAT: return 0.0
			TYPE_BOOL: return false
			_: return value
	
	match expected_type:
		TYPE_STRING:
			return str(value)
		TYPE_INT:
			return int(value) if str(value).is_valid_int() else 0
		TYPE_FLOAT:
			return float(value) if str(value).is_valid_float() else 0.0
		TYPE_BOOL:
			return str(value).nocasecmp_to("true") == 0
		_:
			return value
