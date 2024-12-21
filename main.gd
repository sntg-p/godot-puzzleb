class_name Main extends Node2D

@export var enable_bubble_generation = true
@export var bubble_scenes: Array[PackedScene]


var bubbles = {}
var bubbleGroups: Array[BubbleGroup] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not enable_bubble_generation:
		return

	var file = "res://levels/01.json"
	var levelText = FileAccess.get_file_as_string(file)
	var levelData: Array = JSON.parse_string(levelText)
	#print(levelData)

	for row in range(8):
		var isOdd = row % 2
		var rowOffset = Bubble.radius * isOdd
		#var rowOffset = 0

		for indexInRow in range(8 - isOdd):
			var bubbleIndex = row * 8 + indexInRow;
			var bubbleType = levelData[bubbleIndex]
			#print("row: %s; index: %s; bubbleType: %s" % [row, indexInRow, bubbleType])

			if bubbleType == -1:
				continue

			var bubble: Bubble = bubble_scenes[bubbleType].instantiate()
			bubble.type = bubbleType
			bubble.row = row
			bubble.indexInRow = indexInRow
			bubble.name = "Bubble_%s_%s" % [row, indexInRow]
			bubbles[bubbleIndex] = bubble

			if (indexInRow > 0):
				var leftBubbleIndex = bubbleIndex - 1
				var leftBubbleType = levelData[leftBubbleIndex]
				if (leftBubbleType == bubbleType):
					var matchingBubble: Bubble = bubbles[leftBubbleIndex]
					matchingBubble.add_sibling(bubble)
					continue

			if row != 0:
				var upLeftBubbleIndex = bubbleIndex - (8 - isOdd)
				var upLeftBubbleType = levelData[upLeftBubbleIndex]
				if upLeftBubbleType == bubbleType:
					var matchingBubble: Bubble = bubbles[upLeftBubbleIndex]
					matchingBubble.add_sibling(bubble)
					continue

				if isOdd:
					var upRightBubbleIndex = upLeftBubbleIndex + 1
					var upRightBubbleType = levelData[upRightBubbleIndex]
					if upRightBubbleType == bubbleType:
						var matchingBubble: Bubble = bubbles[upRightBubbleType]
						matchingBubble.add_sibling(bubble)
						continue

			var group = BubbleGroup.new()
			group.name = "BubbleGroup_%s" % [bubbleGroups.size()]
			bubbleGroups.push_back(group)
			group.add_child(bubble)

	for group in bubbleGroups:
		add_child(group)
