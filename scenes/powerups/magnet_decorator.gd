class_name MagnetDecorator
extends PowerupDecorator

## Pulls the coins near the fox toward it while it runs; a coin is collected once it reaches the fox.

## How close a coin must be to get pulled, in meters.
const RADIUS := 4.0
## How fast a pulled coin flies toward the fox, in meters per second.
const PULL_SPEED := 10.0


func update(delta: float) -> bool:
	var target := fox.global_position
	for coin: Area3D in fox.get_tree().get_nodes_in_group("coins"):
		# A coin still flying out of a chest can't be picked up yet: leave it to its arc.
		if coin.monitoring and coin.global_position.distance_to(target) < RADIUS:
			coin.global_position = coin.global_position.move_toward(target, PULL_SPEED * delta)
	return super(delta)
