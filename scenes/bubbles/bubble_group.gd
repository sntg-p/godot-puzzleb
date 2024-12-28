class_name BubbleGroup extends Node

var type = -1


var is_touching_wall: bool:
	get:
		var children = get_children()
		for child: Bubble in children:
			if child.is_touching_wall: return true
		
		return false

var _dependents = Set.new()
var dependents: Set:
	get: return _dependents


func add_dependent(group: BubbleGroup) -> void:
	_dependents.add(group)


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
