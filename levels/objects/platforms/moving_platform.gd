extends AnimatableBody3D

## A platform that travels back and forth between where it was placed and `offset` away from
## there, pausing `wait_time` seconds at each end. The script moves it inside _physics_process(),
## and sync_to_physics (on by default) applies each move on the physics tick: the fox standing on
## top rides along through its own move_and_slide().

@export var offset := Vector3(0, 4, 0)
## Meters per second.
@export var speed := 2.0
## Seconds to wait at each end.
@export var wait_time := 1.0

var _start: Vector3
var _going_out := true
var _wait := 0.0


func _ready() -> void:
	_start = position


func _physics_process(delta: float) -> void:
	if _wait > 0.0:
		_wait -= delta
		return
	var target := _start + offset if _going_out else _start
	position = position.move_toward(target, speed * delta)
	if position.is_equal_approx(target):
		_going_out = not _going_out
		_wait = wait_time
