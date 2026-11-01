extends Area3D

## Touch it and it becomes the place the fox comes back to after dying. Saves the game right away.

## This checkpoint's name — unique within its stage. The save file stores this, not coordinates.
@export var id := ""

@onready var _sprite: AnimatedSprite3D = $AnimatedSprite3D


func _ready() -> void:
	add_to_group("spawn_points")
	body_entered.connect(_on_body_entered)
	_sprite.play("turn" if _is_current() else "idle")


func _on_body_entered(body: Node3D) -> void:
	if not (body is Player) or _is_current():
		return
	if not (owner is Stage):
		# Saved in another scene (the test yard, a sub-scene): a session continuing from here
		# wouldn't land in a stage. Place checkpoints directly in a level.
		push_warning("Checkpoint '%s' is not placed directly in a Stage — ignored" % id)
		return
	GameManager.set_checkpoint(owner.scene_file_path, id)
	_sprite.play("turn")


## `owner` is the root of the scene this checkpoint was saved in — the stage. (GameManager's
## current_stage won't do: while this stage's nodes run _ready(), it still points at the PREVIOUS
## stage.)
func _is_current() -> bool:
	return owner is Stage and GameManager.checkpoint_id == id \
		and GameManager.checkpoint_stage == owner.scene_file_path
