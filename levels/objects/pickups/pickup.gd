class_name Pickup
extends Area3D

## Something lying in the stage that the fox picks up by walking into it. It bobs up and down while
## it waits; the first touch collects it — _collect() says what that does — then it plays its
## pickup effect and disappears. Coins and keys (and the power-up items of parts 4–5) extend this.
##
## Children: Sprite (the thing itself, any 3D sprite) — required; Effect (an AnimatedSprite3D,
## hidden, whose current animation plays once on pickup) — optional: without it the pickup simply
## disappears when collected.

## How high the bob goes above and below the rest height, in meters.
@export var bob_height := 0.15
## Seconds for one full bob.
@export var bob_time := 1.2

var _time := 0.0
var _taken := false

@onready var _sprite: Node3D = $Sprite
@onready var _effect: AnimatedSprite3D = get_node_or_null("Effect")
@onready var _rest_y: float = _sprite.position.y


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Start each pickup somewhere in its bob, so a row of coins doesn't move in lockstep.
	_time = randf() * bob_time


func _process(delta: float) -> void:
	_time += delta
	_sprite.position.y = _rest_y + sin(_time / bob_time * TAU) * bob_height


func _on_body_entered(body: Node3D) -> void:
	if _taken or not (body is Player):
		return
	_taken = true    # the fox can't trigger it again while the effect plays
	_collect(body)
	if _effect == null:
		queue_free()
		return
	_sprite.hide()
	_effect.show()
	_effect.play()
	_effect.animation_finished.connect(queue_free)


## What picking it up does. Every pickup overrides it.
func _collect(_fox: Player) -> void:
	pass
