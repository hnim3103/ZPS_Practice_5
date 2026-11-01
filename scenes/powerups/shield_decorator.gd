class_name ShieldDecorator
extends PowerupDecorator

## Takes the next hit for the fox, then DecoratorManager takes it off. A shield icon floats over the
## fox while it holds.

const ICON := preload("res://assets/items/shield.png")

var _icon: Sprite3D


func blocks_hit() -> bool:
	return true


func on_apply() -> void:
	_icon = Sprite3D.new()
	_icon.texture = ICON
	_icon.pixel_size = 0.04
	_icon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_icon.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	_icon.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_icon.position.y = 2.0
	fox.add_child(_icon)


func on_remove() -> void:
	if is_instance_valid(_icon):
		_icon.queue_free()
