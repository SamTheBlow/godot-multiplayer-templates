extends Node3D
## A simple 3D example for multiplayer games.


@export var _player_scene: PackedScene


func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_connected_to_server() -> void:
	add_player(multiplayer.get_unique_id())


func _on_server_disconnected() -> void:
	# Remove all players
	for child in get_children():
		if child is Player:
			remove_child(child)
			child.queue_free()


func _on_peer_connected(multiplayer_id: int) -> void:
	if multiplayer.is_server():
		# The server should send each player to the new peer
		rpc_id(multiplayer_id, "new_player", multiplayer.get_unique_id())
		for peer_id in multiplayer.get_peers():
			if peer_id == multiplayer_id:
				continue
			rpc_id(multiplayer_id, "new_player", peer_id)
		
		# It should also send the new peer to everyone
		rpc("new_player", multiplayer_id)


func _on_peer_disconnected(multiplayer_id: int) -> void:
	remove_player(multiplayer_id)


func _on_player_out_of_bounds(player: Player) -> void:
	add_player(player.get_multiplayer_authority())


func add_player(multiplayer_id: int) -> void:
	if not multiplayer.is_server():
		return
	
	rpc("new_player", multiplayer_id)


@rpc("authority", "call_local", "reliable")
func new_player(multiplayer_id: int) -> void:
	remove_player(multiplayer_id)
	
	var player := _player_scene.instantiate() as Player
	player.name = str(multiplayer_id)
	player.position.y = 10.0
	player.out_of_bounds.connect(_on_player_out_of_bounds)
	add_child(player)
	player.give_authority_to(multiplayer_id)


func remove_player(multiplayer_id: int) -> void:
	var player: Player = _player_from_multiplayer_id(multiplayer_id)
	
	if player:
		# This is important so that we can immediately create
		# a new node with the same name as this one
		remove_child(player)
		
		player.queue_free()


func _player_from_multiplayer_id(multiplayer_id: int) -> Player:
	for child in get_children():
		if not child is Player:
			continue
		
		if child.get_multiplayer_authority() == multiplayer_id:
			return child as Player
	
	return null
