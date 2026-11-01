class_name QuestData
extends Resource

## One quest, set up in the Inspector and saved as a .tres in data/quests/. Read-only while the game
## runs: what has been done so far lives in QuestManager, not here.

@export var id := ""
@export var title := ""
@export_multiline var description := ""
## Who gives it and takes it back — the HUD says "về gặp <giver>" once it is done.
@export var giver := ""
## The id of a quest that must be turned in first; "" = none.
@export var prerequisite := ""
@export var objectives: Array[QuestObjective] = []

@export_group("Reward")
@export var reward_coins := 0
@export var reward_keys := 0
