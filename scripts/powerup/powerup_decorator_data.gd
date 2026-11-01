class_name PowerupDecoratorData
extends Resource

## One power-up, set up in the Inspector: what it changes, for how long, how it stacks. Saved as a
## .tres in data/powerup/ and listed in powerup_database.tres. Picking a power-up up turns this
## data into a running PowerupDecorator.

@export var id := ""
@export var display_name := ""

@export_group("Decorator")
## The script of its running decorator. GenericPowerupDecorator only applies the numbers below;
## a power-up that does more (the orbit blades) names its own subclass.
@export var decorator_script: Script = preload("res://scripts/powerup/generic_powerup_decorator.gd")
## The chain applies higher priorities later — on top of the lower ones.
@export var priority := 0
## Seconds it runs; -1 = until the fox dies.
@export var duration := 10.0
## False: picking it up again while it runs restarts its time instead of adding a second one.
@export var can_stack := false

@export_group("Modifiers")
@export var speed_multiplier := 1.0
@export var damage_multiplier := 1.0
## Added after the multiplier, at this decorator's place in the chain.
@export var damage_bonus := 0
## Tints the fox while it runs; white = no tint.
@export var color_modulate := Color.WHITE


func create_decorator(fox: Player) -> PowerupDecorator:
	return decorator_script.new(fox, self)
