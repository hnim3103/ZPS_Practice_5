extends Pickup

@export var powerup: PowerupDecoratorData


func _collect(fox: Player) -> void: 
	if powerup == null: 
		push_warning("%s has no power-up" % name) 
		return 
	fox.decorator_manager.apply(powerup)