extends Pickup


func _collect(fox: Player) -> void: 
	fox.speed_up(3, 8.0)