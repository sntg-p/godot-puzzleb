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

@onready var main: Main = get_node('/root/Main')


func add_dependent(group: BubbleGroup) -> void:
	_dependents.add(group)


func _init(type: int):
	self.type = type


func check_count():
	var count = get_child_count()
	print('group child count: %s' % [count])
	if count >= 3:
		#for dependent in dependents.values():
			#main.remove_group(dependent)
		
		main.remove_group(self)


func destroy():
	var tween = create_tween()
	
	var children = get_children()
	for child: Bubble in children:
		tween.parallel().tween_property(child, "scale", Vector2.ZERO, .15).set_trans(Tween.TRANS_BACK)
	
	tween.tween_callback(self.queue_free)
