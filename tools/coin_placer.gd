@tool
extends Node3D

## Places coins from a GridMap: every cell holding the item named `item_name` in `grid_map` gets an
## instance of `coin_scene`, added as a child of this node.
##
## How to use: add a Node3D (e.g. "Coins") to the stage, attach this script, drag the GridMap into
## `grid_map`, paint "coin" cells, then press **Place coins** in the Inspector. Press it again any
## time: old coins are removed and placed again from the current cells. The marker cells only show
## in the editor — they are erased when the game starts.

@export var grid_map: GridMap
@export var coin_scene: PackedScene = preload("res://levels/objects/pickups/coin.tscn")
@export var item_name := "Coin"
## GridMap cells (cell_center_y = false) have their origin at the bottom; hand-placed coins in
## stage_1 sit 1 m above that.
@export var height := 1.0
@export_tool_button("Place coins") var place_action := place_coins


func _ready() -> void:
	if Engine.is_editor_hint() or grid_map == null:
		return
	for cell in _cells():
		grid_map.set_cell_item(cell, GridMap.INVALID_CELL_ITEM)


func place_coins() -> void:
	if grid_map == null or coin_scene == null:
		push_error("%s: grid_map or coin_scene is not set" % name)
		return
	if _item_id() == -1:
		push_error("MeshLibrary of %s has no item '%s'" % [grid_map.name, item_name])
		return

	# free(), not queue_free(): old coins must go now, or the new coins' names get misnumbered.
	for child in get_children():
		child.free()
	var cells := _cells()
	for cell in cells:
		var coin: Node3D = coin_scene.instantiate()
		# true: readable names (Coin2, Coin3...) instead of @Area3D@123.
		add_child(coin, true)
		# Without an owner the coin shows in the editor but is NOT saved with the scene.
		coin.owner = get_tree().edited_scene_root
		coin.global_position = grid_map.to_global(grid_map.map_to_local(cell)) + Vector3.UP * height
	print("Placed %d coins in %s" % [cells.size(), name])


func _item_id() -> int:
	return grid_map.mesh_library.find_item_by_name(item_name) if grid_map.mesh_library else -1


func _cells() -> Array[Vector3i]:
	var id := _item_id()
	if id == -1:
		return []
	return grid_map.get_used_cells_by_item(id)
