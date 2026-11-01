extends Pickup


## The magnet power-up finds coins through this group.
func _ready() -> void:
	super()
	add_to_group("coins")


## One coin.
func _collect(_fox: Player) -> void: 
	Inventory.add_coin(1) 
	EventBus.item_collected.emit("coin", 1)