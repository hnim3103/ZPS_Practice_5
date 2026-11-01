extends Node

## Where every quest stands, for the whole game: an autoload, so it outlives stage changes and
## respawning; GameManager writes it into the save file. The quests themselves (QuestData, .tres)
## never change while the game runs — their state lives here, in two Dictionaries:
##   states:   quest id -> "active" | "completed" | "turned_in"   (not in it = not taken yet)
##   progress: quest id -> [count, ...]                           (one count per objective)
## Progress comes from EventBus: enemies and pickups report what happened, and the objectives of
## the ACTIVE quests that match count it.

## A quest was taken, advanced, completed or turned in. "" = everything was reset or reloaded.
signal quest_changed(id: String)

const DATABASE: QuestDatabase = preload("res://data/quests/quest_database.tres")
const STATES: Array[String] = ["active", "completed", "turned_in"]

var states: Dictionary = {}
var progress: Dictionary = {}


func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.item_collected.connect(_on_item_collected)


## "" (not taken), "active", "completed" or "turned_in".
func get_state(id: String) -> String:
	return states.get(id, "")


func is_active(id: String) -> bool:
	return get_state(id) == "active"


func is_completed(id: String) -> bool:
	return get_state(id) == "completed"


func is_turned_in(id: String) -> bool:
	return get_state(id) == "turned_in"


func can_start(id: String) -> bool: 
	var quest := DATABASE.get_quest(id) 
	if quest == null or get_state(id) != "":
		return false
	return quest.prerequisite == "" or is_turned_in(quest.prerequisite)


func start_quest(id: String) -> void: 
	if not can_start(id): 
		return 
	var counts: Array[int] = [] 
	counts.resize(DATABASE.get_quest(id).objectives.size()) 
	counts.fill(0) 
	states[id] = "active" 
	progress[id] = counts 
	quest_changed.emit(id)


## Pays the reward of a completed quest, once. 
func turn_in(id: String) -> void: 
	if not is_completed(id):
		return 
	var quest := DATABASE.get_quest(id) 
	states[id] = "turned_in"
	if quest.reward_coins > 0: 
		Inventory.add_coin(quest.reward_coins)
	if quest.reward_keys > 0: 
		Inventory.add_key(quest.reward_keys)
	quest_changed.emit(id)


## How far objective `index` of quest `id` has got; 0 when the quest isn't taken.
func get_progress(id: String, index: int) -> int:
	var counts: Array = progress.get(id, [])
	return counts[index] if index < counts.size() else 0


## The quest the HUD follows: the first active or completed one, in database order; null if none.
func active_quest() -> QuestData:
	for quest: QuestData in DATABASE.quests:
		if is_active(quest.id) or is_completed(quest.id):
			return quest
	return null


## For the save file.
func to_dict() -> Dictionary:
	var data := {}
	for id: String in states:
		data[id] = {"state": states[id], "progress": progress.get(id, [])}
	return data


## Restores the quests from the save file. A quest the database doesn't know, or a state that
## isn't one of STATES, is dropped; each count is a whole number between 0 and its amount (JSON
## reads numbers back as floats). An active quest whose counts are all reached is completed — after
## its amounts were lowered, say — or nothing would ever complete it.
func from_dict(data: Dictionary) -> void:
	states.clear()
	progress.clear()
	for id: Variant in data:
		var quest := DATABASE.get_quest(str(id))
		var entry: Variant = data[id]
		if quest == null or not entry is Dictionary or not entry.get("state") is String 				or not STATES.has(entry.state):
			continue
		var saved: Variant = entry.get("progress", [])
		var counts: Array[int] = []
		for i in quest.objectives.size():
			var value: Variant = saved[i] if saved is Array and i < saved.size() else 0
			var count := int(value) if value is int or value is float else 0
			counts.append(clampi(count, 0, quest.objectives[i].amount))
		var done := true
		for i in counts.size():
			done = done and counts[i] >= quest.objectives[i].amount
		states[quest.id] = "completed" if entry.state == "active" and done else entry.state
		progress[quest.id] = counts
	quest_changed.emit("")


## Forgets every quest, as in a new game.
func reset() -> void:
	states.clear()
	progress.clear()
	quest_changed.emit("")


func _on_enemy_died(enemy_id: String) -> void:
	_advance(QuestObjective.Type.KILL, enemy_id, 1)


func _on_item_collected(item_id: String, amount: int) -> void:
	_advance(QuestObjective.Type.COLLECT, item_id, amount)


func _advance(type: QuestObjective.Type, target_id: String, amount: int) -> void:
	for quest: QuestData in DATABASE.quests:
		if not is_active(quest.id):
			continue
		var counts: Array = progress[quest.id]
		var counted := false
		var done := true
		for i in quest.objectives.size():
			var objective := quest.objectives[i]
			if objective.type == type and objective.target_id == target_id \
			and counts[i] < objective.amount:
				counts[i] = mini(counts[i] + amount, objective. amount)
				counted = true
			done = done and counts[i] >= objective.amount
		if not counted:
			continue
		if done:
			states[quest.id] = "completed"
		quest_changed.emit(quest.id)
