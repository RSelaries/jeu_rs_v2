@tool
extends EditorPlugin


const QCMImporter = preload("res://addons/questions_data/importers/qcm_importer.gd")
const VFImporter = preload("res://addons/questions_data/importers/vrai_faux_importer.gd")


var qcm_importer: EditorImportPlugin
var vf_importer: EditorImportPlugin


func _enter_tree() -> void:
	qcm_importer = QCMImporter.new()
	vf_importer = VFImporter.new()
	add_import_plugin(qcm_importer)
	add_import_plugin(vf_importer)


func _exit_tree() -> void:
	remove_import_plugin(qcm_importer)
	remove_import_plugin(vf_importer)
	qcm_importer = null
	vf_importer = null
