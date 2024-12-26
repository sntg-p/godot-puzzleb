class_name BubbleGroup extends Node

var type = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _init(type: int):
	self.type = type

func add_bubble(bubble: Bubble, check_count: bool = false) -> void:
	if check_count and get_child_count() >= 2:
		print('get_child_count() >= 2, freeing group')
		var main: Main = get_node('/root/Main')
		for it in get_children():
			var bubbleRow: Dictionary = main.bubbles[it.row]
			bubbleRow.erase(it.indexInRow)

		queue_free()
		return

	add_child(bubble)
