extends Node3D

## A door to another stage. Press `interact` in front of it: a locked door says so in a short
## dialogue; an open one plays its opening animation, then GameManager switches to `target_stage`
## and puts the fox at the door whose `id` is `target_door` there.

## This door's name as a spawn point. A door in another stage leads here with target_door = id.
@export var id := ""
@export_file("*.tscn") var target_stage := ""
@export var target_door := ""
## A locked door opens only once GameManager has the flag `unlock_flag` (see unlock_door()).
@export var locked := false
@export var unlock_flag := ""

@onready var _sprite: AnimatedSprite3D = $AnimatedSprite3D


func _ready() -> void:
	add_to_group("spawn_points")
	$InteractiveArea3D.interacted.connect(_on_interacted)
	# The fox is arriving through this door: it closes behind the fox. Closing's last frame is the
	# closed door, the same picture as idle.
	var arriving := id != "" and GameManager.pending_spawn == id
	_sprite.play("closing" if arriving else "idle")


func is_locked() -> bool:
	return locked and not GameManager.is_door_unlocked(unlock_flag)


func _on_interacted() -> void:
	if is_locked():
		_tell_locked()
		return
	if _sprite.animation == "opening":
		return    # already opening — a second press changes nothing
	_sprite.play("opening")
	await _sprite.animation_finished
	GameManager.change_stage(target_stage, target_door)


## A locked door says so — one line of dialogue (dialog/timelines/door_locked.dtl).
func _tell_locked() -> void:
	for body: Node3D in $InteractiveArea3D.get_overlapping_bodies():
		if body is Player:
			Conversation.play("door_locked", body)
			return
