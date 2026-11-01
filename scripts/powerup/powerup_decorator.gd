class_name PowerupDecorator
extends RefCounted

## One power-up running on the fox — a link of a chain (Decorator Pattern). Each link asks the next
## one for a value, then changes it: the head of the chain has the last word. DecoratorManager keeps
## the chain sorted by priority, highest at the head, so a higher priority applies later.
##
## The numbers come from `data`. A power-up that does more than change numbers subclasses this and
## overrides on_apply() / on_remove() (OrbitBladeDecorator).

var fox: Player
var data: PowerupDecoratorData
var next_decorator: PowerupDecorator = null
## Seconds left. Not used when data.duration is -1.
var time_remaining := 0.0


func _init(target: Player, decorator_data: PowerupDecoratorData) -> void:
	fox = target
	data = decorator_data
	time_remaining = data.duration


func get_speed(base: float) -> float:
	var speed := next_decorator.get_speed(base) if next_decorator != null else base
	return speed * data.speed_multiplier


func get_damage(base: int) -> int:
	var damage := next_decorator.get_damage(base) if next_decorator != null else base
	return int(damage * data.damage_multiplier) + data.damage_bonus


## The first tint from here down the chain; white = none.
func get_tint() -> Color:
	if data.color_modulate != Color.WHITE:
		return data.color_modulate
	return next_decorator.get_tint() if next_decorator != null else Color.WHITE


## Counts its time down. True once it has run out.
func update(delta: float) -> bool:
	if data.duration < 0.0:
		return false
	time_remaining -= delta
	return time_remaining <= 0.0


## True if it takes the next hit for the fox — it is then used up (ShieldDecorator).
func blocks_hit() -> bool:
	return false


## Called once it is in the chain.
func on_apply() -> void:
	pass


## Called once it has left the chain.
func on_remove() -> void:
	pass
