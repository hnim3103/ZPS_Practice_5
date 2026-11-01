extends MeshInstance3D

## Draws the exact path of `projectile` as a line, from launch until it is back at the launch
## height:  x = vx·t,  y = vy·t − ½·g·t²  (vx = speed·cos a, vy = speed·sin a). The line to compare
## the stepped flight with. Given code — 3D has no Line2D, so the line is built with an
## ImmediateMesh: one vertex per point, joined in order (PRIMITIVE_LINE_STRIP).

@export var projectile: Node3D
## How many segments the line has.
@export var points := 64


func _ready() -> void:
	redraw()


func redraw() -> void:
	var a := deg_to_rad(projectile.angle)
	var vx: float = projectile.speed * cos(a)
	var vy: float = projectile.speed * sin(a)
	var flight_time: float = 2.0 * vy / projectile.gravity
	var line := ImmediateMesh.new()
	line.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for i in points + 1:
		var t := flight_time * i / points
		line.surface_add_vertex(projectile.position
			+ Vector3(vx * t, vy * t - 0.5 * projectile.gravity * t * t, 0.0))
	line.surface_end()
	mesh = line
