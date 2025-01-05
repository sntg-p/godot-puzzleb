class_name BubbleGroup extends Node2D


var type = -1

var is_touching_wall: bool:
	get:
		var children = get_children()
		for child: Bubble in children:
			if child.is_touching_wall: return true
		
		return false


func _exit_tree() -> void:
	print('group %s exiting tree' % [name])


func _init(type: int):
	self.type = type
	child_exiting_tree.connect(_on_child_exiting_tree)


func _on_child_exiting_tree(node: Node):
	print('%s exiting from %s' % [node.name, self.name])
	
	# last child is exiting tree
	if get_child_count() == 1: self.queue_free()


func check_count():
	var count = get_child_count()
	print('group child count: %s' % [count])
	if count >= 3:
		var main: BubblesController = get_parent()
		main.remove_group(self)


func destroy():
	print('destroying group %s' % [self.name])
	
	var tween = create_tween()
	var children = get_children()
	for child: Bubble in children:
		child.set_monitorable(false)
		var tweener = tween.parallel().tween_property(child, "scale", Vector2.ZERO, .15)
		tweener.set_trans(Tween.TRANS_BACK)
	
	tween.tween_callback(self.queue_free)


func fall(starting_index: int) -> int:
	print('destroying group %s with fall animation, index %s' % [self.name, starting_index])
	
	var index = starting_index
	var children = get_children()
	for child: Bubble in children:
		index = child.destroy(index)
	
	return index
