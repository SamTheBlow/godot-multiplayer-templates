class_name User
extends Control


var multiplayer_id: int

@onready var _username_label := $Margin/Username as Label


func set_username(username: String) -> void:
	_username_label.text = username
	
	if multiplayer_id == multiplayer.get_unique_id():
		_username_label.text += " (you)"
