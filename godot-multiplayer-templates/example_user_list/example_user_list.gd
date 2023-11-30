extends Control
## A simple list of all online users on a server.


@export var _user_scene: PackedScene

## If set to true, automatically becomes visible when connected to a server
## and automatically disappears when disconnected from a server.
@export var autohide: bool = true

@onready var _user_list: Node = %Users


func _ready() -> void:
	if autohide:
		hide()
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _on_connected_to_server() -> void:
	_add_user(multiplayer.get_unique_id())
	
	if autohide:
		show()


func _on_server_disconnected() -> void:
	if autohide:
		hide()
	
	for child in _user_list.get_children():
		child.queue_free()


func _on_peer_connected(multiplayer_id: int) -> void:
	_add_user(multiplayer_id)


func _on_peer_disconnected(multiplayer_id: int) -> void:
	for child in _user_list.get_children():
		if not (child is User):
			continue
		
		if ((child as User).multiplayer_id == multiplayer_id):
			child.queue_free()
			break


func _add_user(multiplayer_id: int) -> void:
	var username: String = "User " + str(multiplayer_id)
	_new_user(multiplayer_id, username)


func _new_user(multiplayer_id: int, username: String) -> void:
	var user := _user_scene.instantiate() as User
	user.multiplayer_id = multiplayer_id
	_user_list.add_child(user)
	user.set_username(username)
