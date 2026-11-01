extends CanvasLayer

## Always on screen: the coins and keys the fox carries (part 2), and the quest being worked on
## (part 8). An autoload, so a stage change doesn't reset it. It keeps no counts of its own — it
## shows what Inventory and QuestManager say, each time they say something changed.

@onready var _coins: Label = %CoinLabel
@onready var _keys: Label = %KeyLabel
@onready var _quest: Label = %QuestLabel
@onready var _toast: Label = %Toast
@onready var _toast_timer: Timer = %ToastTimer

## The state each quest had when the HUD last looked: a toast only when a quest changes state, not
## on every coin it counts.
var _shown_states := {}


func _ready() -> void:
	Inventory.changed.connect(_on_inventory_changed)
	_on_inventory_changed()
	QuestManager.quest_changed.connect(_on_quest_changed)
	_toast_timer.timeout.connect(_toast.hide)
	_on_quest_changed("")


func _on_inventory_changed() -> void:
	_coins.text = str(Inventory.coins)
	_keys.text = str(Inventory.keys)


func _on_quest_changed(id: String) -> void:
	_show_quest_line()
	if id == "":
		_shown_states = QuestManager.states.duplicate()    # reset / reloaded: no toast
		return
	var state := QuestManager.get_state(id)
	if _shown_states.get(id, "") == state:
		return
	_shown_states[id] = state
	var title := QuestManager.DATABASE.get_quest(id).title
	match state:
		"active":
			_show_toast("Nhận nhiệm vụ: " + title)
		"completed":
			_show_toast("Hoàn thành: " + title)
		"turned_in":
			_show_toast("Đã nhận thưởng: " + title)


## "Gom xu 2/5"; with several objectives, "<title> <label> 1/3, <label> 0/2"; once done,
## "<title>: về gặp <giver>"; nothing when no quest is followed.
func _show_quest_line() -> void:
	var quest := QuestManager.active_quest()
	if quest == null:
		_quest.text = ""
		return
	if QuestManager.is_completed(quest.id):
		_quest.text = "%s: về gặp %s" % [quest.title, quest.giver]
		return
	var parts: Array[String] = []
	for i in quest.objectives.size():
		var objective := quest.objectives[i]
		var count := "%d/%d" % [QuestManager.get_progress(quest.id, i), objective.amount]
		parts.append(count if quest.objectives.size() == 1 else "%s %s" % [objective.label, count])
	_quest.text = "%s %s" % [quest.title, ", ".join(parts)]


func _show_toast(text: String) -> void:
	_toast.text = text
	_toast.show()
	_toast_timer.start()
