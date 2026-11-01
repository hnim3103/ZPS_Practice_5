class_name DecoratorManager
extends Node

## The power-ups running on the fox. A child of the fox, created by Player._ready(): when the fox
## dies its stage reloads, and the power-ups go with it.

const DATABASE: PowerupDatabase = preload("res://data/powerup/powerup_database.tres")

var fox: Player

var _head: PowerupDecorator = null
var _running: Array[PowerupDecorator] = []


func _ready() -> void:
	fox = get_parent()


## Applies the power-up `id` of the database. False (with an error) when there is none.
func apply_powerup(id: String) -> bool:
	var data := DATABASE.get_powerup(id)
	if data == null:
		push_error("No power-up '%s' in %s" % [id, DATABASE.resource_path])
		return false
	apply(data)
	return true


## Starts `data` on the fox. Unless it can stack, a copy already running is removed first — its
## time starts over.
func apply(data: PowerupDecoratorData) -> void:
	if not data.can_stack:
		remove_powerup(data.id)
	var decorator := data.create_decorator(fox)
	_insert(decorator)
	_running.append(decorator)
	decorator.on_apply()
	_refresh_tint()


func remove_powerup(id: String) -> void:
	for decorator: PowerupDecorator in _running.duplicate():
		if decorator.data.id == id:
			_remove(decorator)


func has_powerup(id: String) -> bool:
	return count(id) > 0


func count(id: String) -> int:
	return _running.filter(func(d: PowerupDecorator) -> bool: return d.data.id == id).size()


## Seconds left of the power-up `id` (the longest if it stacks); 0 when it isn't running.
func time_left(id: String) -> float:
	var left := 0.0
	for decorator: PowerupDecorator in _running:
		if decorator.data.id == id:
			left = maxf(left, decorator.time_remaining)
	return left


## True when a running power-up took this hit instead of the fox; that power-up is used up.
func block_hit() -> bool:
	for decorator: PowerupDecorator in _running:
		if decorator.blocks_hit():
			_remove(decorator)
			return true
	return false


func get_effective_speed(base: float) -> float:
	return _head.get_speed(base) if _head != null else base


func get_effective_damage(base: int) -> int:
	return _head.get_damage(base) if _head != null else base


func _process(delta: float) -> void:
	for decorator: PowerupDecorator in _running.duplicate():
		if decorator.update(delta):
			_remove(decorator)


## Higher priority closer to the head; equal priorities: the newer one in front.
func _insert(decorator: PowerupDecorator) -> void:
	if _head == null or decorator.data.priority >= _head.data.priority:
		decorator.next_decorator = _head
		_head = decorator
		return
	var current := _head
	while current.next_decorator != null \
			and current.next_decorator.data.priority > decorator.data.priority:
		current = current.next_decorator
	decorator.next_decorator = current.next_decorator
	current.next_decorator = decorator


func _remove(decorator: PowerupDecorator) -> void:
	if _head == decorator:
		_head = decorator.next_decorator
	else:
		var current := _head
		while current != null and current.next_decorator != decorator:
			current = current.next_decorator
		if current != null:
			current.next_decorator = decorator.next_decorator
	decorator.next_decorator = null
	_running.erase(decorator)
	decorator.on_remove()
	_refresh_tint()


func _refresh_tint() -> void:
	fox.sprite.modulate = _head.get_tint() if _head != null else Color.WHITE
