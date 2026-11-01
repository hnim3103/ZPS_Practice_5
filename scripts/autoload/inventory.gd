extends Node

## What the fox carries: coins and keys. An autoload, so the counts outlive stage changes and
## respawning; GameManager writes them into the save file. Every change emits `changed` — the HUD
## listens to it instead of asking every frame.

signal changed

var coins := 0
var keys := 0


func add_coin(amount: int = 1) -> void:
	coins += amount
	changed.emit()


func add_key(amount: int = 1) -> void:
	keys += amount
	changed.emit()


## Spends one key. False — and nothing spent — when there is none.
func use_key() -> bool:
	if keys <= 0:
		return false
	keys -= 1
	changed.emit()
	return true


func has_key() -> bool:
	return keys > 0


## For the save file.
func to_dict() -> Dictionary:
	return {"coins": coins, "keys": keys}


## Restores the counts from the save file. JSON reads every number back as a float; anything that
## isn't a number, or is negative, counts as 0.
func from_dict(data: Dictionary) -> void:
	coins = _count(data.get("coins"))
	keys = _count(data.get("keys"))
	changed.emit()


## Empty pockets, as in a new game.
func reset() -> void:
	coins = 0
	keys = 0
	changed.emit()


static func _count(value: Variant) -> int:
	return maxi(int(value), 0) if value is int or value is float else 0
