extends Node2D

@export var enable_bubble_generation = true
@export var bubble_scenes: Array[PackedScene]

var bubbleRadius = 45
var bubbleDiameter = bubbleRadius * 2
var verticalOffset = sqrt(pow(bubbleDiameter, 2) - pow(bubbleRadius, 2))

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
		var oddRowOffset = bubbleRadius * isOdd
		for indexInRow in range(8 - isOdd):
			var bubbleIndex = row * 8 + indexInRow;
			var bubbleType = levelData[bubbleIndex]
			#print("row: %s; index: %s; bubbleType: %s" % [row, indexInRow, bubbleType])
			
			if bubbleType == -1:
				continue
			
			var bubble: Node2D = bubble_scenes[bubbleType].instantiate()
			bubble.position.x = bubbleRadius + bubbleDiameter * indexInRow + oddRowOffset
			bubble.position.y = bubbleRadius + verticalOffset * row
			add_child(bubble)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
