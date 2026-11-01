extends Node3D

## A ring of blades around the fox's feet (a child of the fox, so it follows it). 
const BLADE := preload("res://scenes/powerups/orbit_blade.tscn")

@export var count := 3
@export var radius := 1.5
## Height above the fox's feet, in meters. 
@export var height := 0.6
## Seconds for one full turn.
@export var turn_time := 1.2

var angle := 0.0


func _ready() -> void: 
	for i in count: 
		add_child(BLADE.instantiate()) 
	_place_blades()


func _physics_process(delta: float) -> void: 
	angle = wrapf(angle + TAU / turn_time * delta, 0.0, TAU) 
	_place_blades()


func _place_blades() -> void: 
	for i in get_child_count(): 
		var a := angle + i * TAU / count 
		var blade: Node3D = get_child(i) 
		blade.position = Vector3(cos(a), 0.0, sin(a)) * radius + Vector3(0.0, height, 0.0)