class_name Player
extends RefCounted


@export var name: String
@export var uid: int


func _init(player_name: String, player_uid: int) -> void:
	name = player_name
	uid = player_uid
