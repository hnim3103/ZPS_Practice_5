class_name QuestDatabase
extends Resource

## Every quest of the game, in one list (data/quests/quest_database.tres), in the order the HUD
## prefers them.

@export var quests: Array[QuestData] = []


## The quest with this id, or null.
func get_quest(id: String) -> QuestData:
	for quest: QuestData in quests:
		if quest.id == id:
			return quest
	return null
