extends Pickup


func _collect(_fox: Player) -> void: 
	Inventory. add_key(1) 
	EventBus.item_collected.emit("key", 1)