extends Control
## A simple chat box that uses networking to communicate with other users.


## If set to true, automatically becomes visible when connecting to a server
## and automatically disappears when disconnected from a server.
@export var autohide: bool = true

@onready var _chat_text := %ChatText as RichTextLabel
@onready var _input_message := %InputMessage as LineEdit


func _ready() -> void:
	if autohide:
		hide()
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _on_connected_to_server() -> void:
	# If you're the server, clear the chat box
	if multiplayer.is_server():
		_chat_text.text = "[i]New server created[/i]"
	
	if autohide:
		show()
	
	# Simulate you entering the chat
	_on_peer_connected(multiplayer.get_unique_id())


func _on_server_disconnected() -> void:
	if autohide:
		hide()


func _on_peer_connected(multiplayer_id: int) -> void:
	send_system_message(str(multiplayer_id) + " has joined the server")


func _on_peer_disconnected(multiplayer_id: int) -> void:
	send_system_message(str(multiplayer_id) + " has left the server")


func _on_input_message_text_submitted(_new_text: String) -> void:
	# This is the exact same thing as if you pressed the "Send" button
	_on_send_pressed()


func _on_send_pressed() -> void:
	send_message(_input_message.text)
	
	# Empty the input box
	_input_message.text = ""


## Sends a message to all online users
func send_message(message: String) -> void:
	# Do nothing if there is no message
	if message == "":
		return
	
	var message_formatted: String = (
			str(multiplayer.get_unique_id()) + ": " + message
	)
	
	rpc("new_message", message_formatted)


func send_system_message(message: String) -> void:
	if not multiplayer.is_server():
		return
	
	rpc("new_message", "System: " + message)


@rpc("any_peer", "call_local", "reliable")
func new_message(message: String) -> void:
	if _chat_text.text != "":
		_chat_text.text += "\n"
	
	_chat_text.text += message
