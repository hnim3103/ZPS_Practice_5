extends MeshInstance3D

## Draws the curve of `path` as a line: its baked points — the points Godot samples along the curve,
## every bake_interval metres — joined in order. Given code (3D has no Line2D: an ImmediateMesh).

@export var path: Path3D


func _ready() -> void:
	var line := ImmediateMesh.new()
	line.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for point: Vector3 in path.curve.get_baked_points():
		line.surface_add_vertex(path.transform * point)
	line.surface_end()
	mesh = line
