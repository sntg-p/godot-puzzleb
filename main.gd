class_name Main extends Node2D

@export var enable_bubble_generation = true
@export var bubble_scenes: Array[PackedScene]

signal level_loaded()


var bubbles = {}
var bubbleGroups: Array[BubbleGroup] = []

var _current_types = {}


func has_bubble(row: int, indexInRow: int) -> bool:
	if !bubbles.has(row):
		bubbles[row] = {}
	
	return bubbles[row].has(indexInRow)


func get_bubble(row: int, indexInRow: int) -> Bubble:
	if !bubbles.has(row):
		bubbles[row] = {}
	
	var bubblesRow: Dictionary = bubbles[row]
	return bubblesRow.get(indexInRow)


func new_group(type: int) -> BubbleGroup:
	var group = BubbleGroup.new(type)
	group.name = "BubbleGroup_%s" % [bubbleGroups.size()]
	bubbleGroups.push_back(group)
	return group


func new_bubble(row: int, indexInRow: int, type: int, origin: Vector2 = Vector2.ZERO) -> Bubble:
	var bubble: Bubble = bubble_scenes[type].instantiate()
	
	var position = Bubble.calculate_position(row, indexInRow)
	if origin != Vector2.ZERO:
		bubble.animate_spawn(origin, position)
	else:
		bubble.position = position
	
	#bubble.position = position
	
	bubble.type = type
	bubble.row = row
	bubble.indexInRow = indexInRow
	bubbles[row][indexInRow] = bubble
	
	if _current_types.has(type):
		_current_types[type] += 1
	else:
		_current_types[type] = 1
	
	return bubble


func remove_bubble(bubble: Bubble):
	if has_bubble(bubble.row, bubble.indexInRow):
		var bubblesRow: Dictionary = bubbles[bubble.row]
		print('removing bubble %s-%s' % [bubble.row, bubble.indexInRow])
		bubblesRow.erase(bubble.indexInRow)
		assert(
			_current_types[bubble.type] > 0,
			'amount of bubbles with type %s is not > 0' % [bubble.type]
		)
		_current_types[bubble.type] -= 1


func remove_group(group: BubbleGroup):
	var children = group.get_children()
	for child in children:
		assert(child is Bubble)
		remove_bubble(child)
	
	print('freeing group %s' % [group.name])
	group.queue_free()


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
		print('available bubble types: %s' % [amount_per_type])
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
	
	var file = "res://levels/01.json"
	var levelText = FileAccess.get_file_as_string(file)
	var levelData: Array = JSON.parse_string(levelText)
	#print(levelData)
	
	for row in range(8):
		var isOdd = row % 2
		bubbles[row] = {}
		
		for indexInRow in range(8 - isOdd):
			var bubbleIndex = row * 8 + indexInRow;
			var bubbleType = levelData[bubbleIndex]
			
			if bubbleType == -1:
				continue
			
			var bubble: Bubble = new_bubble(row, indexInRow, bubbleType)
			var depends_on: BubbleGroup
			
			if indexInRow > 0:
				var leftBubble = get_bubble(row, indexInRow - 1)
				if leftBubble.type == bubbleType:
					leftBubble.add_sibling_bubble(bubble)
					continue
				
				if not bubble.is_touching_wall:
					var leftBubbleGroup: BubbleGroup = leftBubble.get_parent()
					if leftBubbleGroup.is_touching_wall:
						depends_on = leftBubbleGroup
			
			if row != 0:
				var upLeftBubble = get_bubble(row - 1, indexInRow)
				if upLeftBubble.type == bubbleType:
					upLeftBubble.add_sibling_bubble(bubble)
					continue
				
				var upLeftBubbleGroup: BubbleGroup = upLeftBubble.get_parent()
				if upLeftBubbleGroup.is_touching_wall:
					depends_on = upLeftBubbleGroup
			
				if isOdd:
					var upRightBubble = get_bubble(row - 1, indexInRow + 1)
					if upRightBubble.type == bubbleType:
						upRightBubble.add_sibling_bubble(bubble)
						continue
					
					var upRightBubbleGroup: BubbleGroup = upRightBubble.get_parent()
					if upRightBubbleGroup.is_touching_wall:
						depends_on = upRightBubbleGroup
			
			var group = new_group(bubble.type)
			group.add_bubble(bubble)
			
			if depends_on:
				print('adding %s-%s as dependent of %s' % [
					row, indexInRow, group.name
				])
				
				depends_on.add_dependent(group)
	
	for group in bubbleGroups:
		add_child(group)
	
	level_loaded.emit()
