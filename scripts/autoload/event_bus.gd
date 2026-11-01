extends Node

## Game events, as signals anyone may emit and anyone may listen to — without knowing each other.
## An enemy reports that it died; it doesn't know a quest counts crabs. A quest listens for dead
## crabs; it doesn't know who killed them.

## An enemy reached its Dead state. `enemy_id` is EnemyCharacter.enemy_id ("crab", "mushroom"…).
signal enemy_died(enemy_id: String)
## The fox picked something up in the stage ("coin", "key").
signal item_collected(item_id: String, amount: int)
