extends Node3D

## Moves along a cubic Bézier curve computed by hand — no Path3D. The curve starts at p0 and ends at
## p3; p1 and p2 pull it without being on it. t goes from 0 to 1 in `duration` seconds, then
## starts over. Each Bézier is lerps of lerps: a quadratic one is 3 lerps, a cubic one 6.

@export var p0 := Vector3(0, 0, 0)
@export var p1 := Vector3(-0.6, 3, 0)
@export var p2 := Vector3(3, 3, 0)
@export var p3 := Vector3(7, 0, 0)
## Seconds for one run along the curve.
@export var duration := 4.0

var t := 0.0


func _physics_process(delta: float) -> void:
	t = fmod(t + delta / duration, 1.0)
	position = cubic_bezier(p0, p1, p2, p3, t)


## Three points: lerp a→b and b→c, then lerp between those two.
static func quadratic_bezier(a: Vector3, b: Vector3, c: Vector3, t: float) -> Vector3:
	var ab := a.lerp(b, t)
	var bc := b.lerp(c, t)
	return ab.lerp(bc, t)


## Four points: the quadratic curve of the first three, the quadratic curve of the last three, then
## a lerp between those two.
static func cubic_bezier(a: Vector3, b: Vector3, c: Vector3, d: Vector3, t: float) -> Vector3:
	return quadratic_bezier(a, b, c, t).lerp(quadratic_bezier(b, c, d, t), t)
