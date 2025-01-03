class_name BubbleGroup extends Node2D


var type = -1

var is_touching_wall: bool:
	get:
		var children = get_children()
		for child: Bubble in children:
			if child.is_touching_wall: return true
		
		return false


@onready var main: Main = get_node('/root/Main')


func _exit_tree() -> void:
	print('group %s exiting tree' % [name])


func _init(type: int):
	self.type = type
	child_exiting_tree.connect(_on_child_exiting_tree)
	
	
func _on_child_exiting_tree(node: Node):
	print('%s exiting from %s' % [node.name, self.name])
	if get_child_count() == 1: self.queue_free()


func check_count():
	var count = get_child_count()
	print('group child count: %s' % [count])
	if count >= 3: main.remove_group(self)


func destroy():
	print('destroying group %s' % [self.name])
	
	var tween = create_tween()
	var children = get_children()
	for child: Bubble in children:
		tween.parallel().tween_property(child, "scale", Vector2.ZERO, .15).set_trans(Tween.TRANS_BACK)
	
	tween.tween_callback(self.queue_free)
