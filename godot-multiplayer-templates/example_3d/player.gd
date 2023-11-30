class_name Player
extends Node3D


signal out_of_bounds(this_player: Player)

@export var speed: float = 14.0
@export var camera_sensitivity: float = 0.002

# WIP.
var play_with_mouse: bool = false

var fall_acceleration: float = 50.0

var velocity := Vector3.ZERO
var body_rotation := Vector2.ZERO

@onready var _body := $Body as CharacterBody3D
@onready var _camera := $Body/Camera3D as Camera3D


func _ready() -> void:
	if play_with_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(_delta: float) -> void:
	if _body.global_position.y <= -10:
		out_of_bounds.emit(self)
	
	if play_with_mouse:
		if Input.is_physical_key_pressed(KEY_T):
			if Input.is_physical_key_pressed(KEY_CTRL):
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		var relative: Vector2 = Vector2.ZERO
		if Input.is_physical_key_pressed(KEY_LEFT):
			relative.x -= 10.0
		if Input.is_physical_key_pressed(KEY_RIGHT):
			relative.x += 10.0
		if Input.is_physical_key_pressed(KEY_UP):
			relative.y -= 10.0
		if Input.is_physical_key_pressed(KEY_DOWN):
			relative.y += 10.0
		_rotate_player(relative)


func _physics_process(delta: float) -> void:
	var direction := Vector3.ZERO
	if Input.is_physical_key_pressed(KEY_A):
		direction.z -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		direction.z += 1.0
	if Input.is_physical_key_pressed(KEY_W):
		direction.x += 1.0
	if Input.is_physical_key_pressed(KEY_S):
		direction.x -= 1.0
	
	if direction != Vector3.ZERO:
		direction = direction.normalized().rotated(Vector3.UP, body_rotation.x)
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	velocity.y -= fall_acceleration * delta
	_body.rotation = Vector3(body_rotation.y, body_rotation.x, 0)
	_body.set_velocity(velocity)
	_body.set_up_direction(Vector3.UP)
	_body.move_and_slide()
	velocity = _body.velocity


func _input(event: InputEvent) -> void:
	if play_with_mouse and event is InputEventMouseMotion:
		_rotate_player((event as InputEventMouseMotion).relative)


func give_authority_to(multiplayer_id: int) -> void:
	set_multiplayer_authority(multiplayer_id)
	_camera.current = multiplayer.get_unique_id() == multiplayer_id


func _rotate_player(relative: Vector2) -> void:
	body_rotation.x -= relative.x * camera_sensitivity
	body_rotation.y -= relative.y * camera_sensitivity
	body_rotation.y = clampf(body_rotation.y, -PI/2, PI/2)
