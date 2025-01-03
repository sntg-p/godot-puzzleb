class_name Main extends Node2D

@export var enable_bubble_generation = true
@export var bubble_scenes: Array[PackedScene]

signal level_loaded()


var bubbles = {}
#var bubbleGroups: Array[BubbleGroup] = []
#var bubble_groups: int = 0

var _current_types = {}


func has_bubble(row: int, indexInRow: int) -> bool:
	if !bubbles.has(row):
		bubbles[row] = {}
	
	return bubbles[row].has(indexInRow)


func get_bubble(row: int, indexInRow: int) -> Bubble:
	if !bubbles.has(row):
		bubbles[row] = {}
	
	var bubblesRow: Dictionary = bubbles[row]
	if bubblesRow.has(indexInRow):
		return bubblesRow.get(indexInRow)
	
	return null


func new_bubble(row: int, indexInRow: int, type: int, origin: Vector2 = Vector2.ZERO) -> Bubble:
	var bubble: Bubble = bubble_scenes[type].instantiate()
	
	var position = Bubble.calculate_position(row, indexInRow)
	if origin != Vector2.ZERO:
		bubble.animate_spawn(origin, position, get_tree().create_tween())
	else:
		bubble.position = position
	
	bubble.type = type
	bubble.row = row
	bubble.indexInRow = indexInRow
	bubbles[row][indexInRow] = bubble
	
	if _current_types.has(type):
		_current_types[type] += 1
	else:
		_current_types[type] = 1
	
	return bubble


func _remove_bubble(bubble: Bubble):
	if has_bubble(bubble.row, bubble.indexInRow):
		var bubblesRow: Dictionary = bubbles[bubble.row]
		print('removing bubble %s-%s' % [bubble.row, bubble.indexInRow])
		bubblesRow.erase(bubble.indexInRow)
		assert(
			_current_types[bubble.type] > 0,
			'amount of bubbles with type %s is not > 0' % [bubble.type]
		)
		_current_types[bubble.type] -= 1


func spawn_bubble(row: int, indexInRow: int, type: int, origin = Vector2.ZERO, defer_group_add = true):
	var neighbor_indexes = Bubble.get_neighbor_indexes(row, indexInRow)
	var neighbor_list: Array[Bubble] = []
	
	for index in neighbor_indexes:
		var bubble = get_bubble(index[0], index[1])
		if bubble: neighbor_list.push_back(bubble)
	
	var group = Bubble.find_or_create_group(neighbor_list, type)
	if group:
		print('spawning bubble at %s-%s' % [row, indexInRow])
		var bubble = new_bubble(row, indexInRow, type, origin)
		
		var is_new_group = false
		if group.get_parent() != self:
			is_new_group = true
			add_child(group)
		
		var update_group_deps = func ():
			if group.is_touching_wall: return
			for neighbor in neighbor_list:
				var neighbor_group: BubbleGroup = neighbor.get_parent()
				if neighbor_group == group: continue
				
				neighbor_group.add_dependent(group)
			
			print('updated dependencies for group %s' % [group.name])
			$GroupDebug.queue_redraw()
			pass
		
		if defer_group_add:
			var add_to_group = func ():
				group.add_child(bubble)
				group.check_count()
				update_group_deps.call()
			
			add_to_group.call_deferred()
		else:
			group.add_child(bubble)
			update_group_deps.call()


func remove_group(group: BubbleGroup):
	#var affected_groups: Array[BubbleGroup] = []
	
	var children = group.get_children()
	for child: Bubble in children:
		_remove_bubble(child)
	
	print('destroying group %s' % [group.name])
	group.destroy()
	
	


func get_random_bubble_type():
	var available_types = []
	var current_types = self._current_types.keys()
	
	var amount_per_type = []
	for type in current_types:
		var amount: int = self._current_types[type]
		amount_per_type.push_back('%s: %s' % [type, amount])
		if amount: available_types.push_back(type)
	
	var size = available_types.size()
	if size > 1:
		#print('available bubble types: %s' % [amount_per_type])
		return available_types[randi() % size]
	
	if size == 1: return available_types[0]
	if size == 0:
		print('no current bubble types available')
		return -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not enable_bubble_generation:
		print('level loading disabled, setting all bubble types as current')
		for i in range(6):
			_current_types[i] = 9223372036854775807 / 2
		
		level_loaded.emit()
		return
	
	#var file = "res://levels/01.json"
	var file = "res://levels/error_group_00.json"
	var levelText = FileAccess.get_file_as_string(file)
	var levelData: Array = JSON.parse_string(levelText)
	#print(levelData)
	
	for row in range(8):
		var isOdd = row % 2
		bubbles[row] = {}
		
		for indexInRow in range(8):
			var bubbleIndex = row * 8 + indexInRow;
			var bubbleType = levelData[bubbleIndex]
			if bubbleType == -1: continue
			
			spawn_bubble(row, indexInRow, bubbleType, Vector2.ZERO, false)
	
	level_loaded.emit()
