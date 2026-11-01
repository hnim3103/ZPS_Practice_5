extends Node3D

## A ball fired from where it stands, `angle` degrees above the horizontal toward +X, at `speed` m/s;
## gravity pulls it down. Space (`jump`) fires it, again and again. Its physics is stepped by hand,
## `step_time` seconds at a time:
##   velocity.y -= gravity · dt        position += velocity · dt
## The smaller the step, the closer it follows the exact parabola y = y0 + vy·t − ½·g·t², which
## TrajectoryPreview draws.

@export var speed := 15.0
@export_range(0.0, 90.0) var angle := 45.0
@export var gravity := 24.0
## When set, `angle` is aimed at this node on start (low arc). Keep it at z = 0: the ball flies along +X.
@export var target: Node3D
## Seconds per step. Try 0.1, 0.02, 0.001 and compare with the drawn path.
@export_range(0.001, 0.5, 0.001) var step_time := 0.02

## The smallest step it takes, whatever step_time says.
const MIN_STEP := 0.001

var velocity := Vector3.ZERO
var flying := false

var _start := Vector3.ZERO
## Frame time not stepped yet: a frame rarely holds a whole number of steps.
var _left_over := 0.0


func _ready() -> void:
	_start = position
	if target:
		var a := aim_angle(global_position, target.global_position, speed, gravity)
		if is_nan(a):
			push_warning("Target out of reach at speed %s" % speed)
		else:
			angle = a


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		launch()


## Back to the launch point, then off: velocity = (cos a, sin a, 0) · speed.
func launch() -> void:
	position = _start
	var a := deg_to_rad(angle)
	velocity = Vector3(cos(a), sin(a), 0.0) * speed
	flying = true
	_left_over = 0.0


func _physics_process(delta: float) -> void:
	if not flying:
		return
	_left_over += delta
	var dt := maxf(step_time, MIN_STEP)    # a step of 0 would never use up the frame
	while flying and _left_over >= dt:
		_left_over -= dt
		step(dt)


## One step of `dt` seconds. Once back down at the launch height it stops there.
func step(dt: float) -> void:
	if not flying:
		return
	velocity.y -= gravity * dt
	position += velocity * dt
	if position.y <= _start.y:
		position.y = _start.y
		flying = false


## Angle in degrees that hits `to` from `from`, or NAN when out of reach. Low arc preferred.
static func aim_angle(from: Vector3, to: Vector3, v: float, g: float) -> float:
	var d := to - from
	var x := Vector2(d.x, d.z).length() # horizontal distance
	var y := d.y
	var disc := v**4 - g * (g * x * x + 2.0 * y * v * v)
	if disc < 0.0:
		return NAN
	return rad_to_deg(atan2(v * v - sqrt(disc), g * x))
