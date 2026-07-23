@tool
extends "res://addons/questions_data/questions_data_importer.gd"


func _get_visible_name():
	return "VraiFauxData"


func _get_question_type() -> String:
	return "res://addons/questions_data/question_types/vrai_faux_question.gd"


func _get_database() -> QuestionsDatabase:
	return VFDatabase.new()
