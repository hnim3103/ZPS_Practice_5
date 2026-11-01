extends PathFollow3D

## Runs along its Path3D from start to end in `duration` seconds, then starts over. progress_ratio
## is a share of the curve's LENGTH: equal steps of it are equal distances — an even speed, unlike
## the t of ManualMover.

## Seconds for one run along the curve.
@export var duration := 4.0


func _physics_process(delta: float) -> void:
	progress_ratio = fmod(progress_ratio + delta / duration, 1.0)
