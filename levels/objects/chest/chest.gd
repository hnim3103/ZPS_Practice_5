class_name Chest 
extends Node3D

## A chest that opens with a key. Press "interact™ next to it: with a key in the inventory. 
@export var reward_coins := 5
## How far from the chest the coins land, in meters.
@export var spread := 1.5
## How high the coins fly above the straight line to their landing spot, in meters.
@export var fly_height := 1.5
@export var fly_time := 0.6

@onready var _sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var _area: InteractiveArea3D = $InteractiveArea3D
@onready var _coin_factory: Node3DFactory = $CoinFactory


func _ready() -> void: 
	_sprite.play("close")
	_area.interacted.connect(_on_interacted)


func _on_interacted() -> void:
	var fox := _fox_in_reach() 
	if fox == null: 
		return
	if not Inventory.use_key(): 
		Conversation.play("chest_locked", fox) 
		return 
	_area.queue_free() 
	_sprite.play("open") 
	_sprite.animation_finished.connect(_on_opened.bind(fox), CONNECT_ONE_SHOT)


## The coins pop out and land around the chest; each one counts when the fox picks it up.
func _on_opened(_fox: Player) -> void:
	var ground := global_position
	for i in reward_coins:
		var coin := _coin_factory.create() as Pickup
		if coin == null:
			return
		# Spread evenly around the chest, with a little jitter so it doesn't look stamped.
		var dir := Vector3.FORWARD.rotated(Vector3.UP, (i + randf() * 0.5) * TAU / reward_coins)
		_fly(coin, coin.global_position, ground + dir * spread * randf_range(0.6, 1.0))


## Arcs `coin` from `from` to `to`: straight line plus a bump of fly_height, 4h·t(1−t), peaking halfway.
func _fly(coin: Pickup, from: Vector3, to: Vector3) -> void:
	# The fox stands right next to the chest: no catching coins in mid-air.
	coin.monitoring = false
	var tween := coin.create_tween()
	tween.tween_method(func(t: float) -> void:
		coin.global_position = from.lerp(to, t) + Vector3.UP * fly_height * 4.0 * t * (1.0 - t),
		0.0, 1.0, fly_time)
	tween.tween_callback(func() -> void: coin.monitoring = true)


func _fox_in_reach() -> Player: 
	for body: Node3D in _area.get_overlapping_bodies(): 
		if body is Player: 
			return body 
	return null