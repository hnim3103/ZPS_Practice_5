class_name PowerupDatabase
extends Resource

## Every power-up of the game, in one list (data/powerup/powerup_database.tres). Pickups and chests
## name a power-up by its id; DecoratorManager looks it up here.

@export var powerups: Array[PowerupDecoratorData] = []


## The power-up with this id, or null.
func get_powerup(id: String) -> PowerupDecoratorData:
	for powerup: PowerupDecoratorData in powerups:
		if powerup.id == id:
			return powerup
	return null
