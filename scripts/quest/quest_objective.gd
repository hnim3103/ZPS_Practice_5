class_name QuestObjective
extends Resource

## One thing a quest asks for: kill or collect `amount` of `target_id`. Matched against EventBus
## events — enemy_died(enemy_id) for KILL, item_collected(item_id, amount) for COLLECT.

enum Type {KILL, COLLECT}

@export var type := Type.KILL
## EnemyCharacter.enemy_id for KILL ("crab"), the item's id for COLLECT ("coin").
@export var target_id := ""
@export var amount := 1
## Shown on the HUD when a quest has more than one objective.
@export var label := ""
