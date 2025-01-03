class_name BubbleGroup extends Node2D


var type = -1

var is_touching_wall: bool:
	get:
		var children = get_children()
		for child: Bubble in children:
			if child.is_touching_wall: return true
		
		return false


@export var dependents: Set = Set.new():
	get: return dependents

@export var dependencies: Set = Set.new():
	get: return dependencies


@onready var main: Main = get_node('/root/Main')
@onready var group_debug: GroupDebug = get_node('/root/Main/GroupDebug')


func add_dependent(group: BubbleGroup) -> void:
	if group == self:
		print('prevent adding group %s as dependent of itself' % [name])
		return
	
	dependents.add(group)
	group._add_dependency(self)


func _exit_tree() -> void:
	print('group %s exiting tree' % [name])
	group_debug.queue_redraw()


func remove_from_dependencies() -> void:
	var list = dependencies.values()
	for dep in list:
		if not is_instance_valid(dep):
			print('skipping freed group')
			continue
		
		var group: BubbleGroup = dep
		print('removing group %s from group %s dependents' % [name, group.name])
		
		group.dependents.erase(self)
		dependencies.erase(group)
	
	print('updated dependencies for group %s' % [name])
	group_debug.queue_redraw()


func _add_dependency(group: BubbleGroup) -> void:
	dependencies.add(group)


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


func clean():
	remove_from_dependencies()
	queue_free()


func destroy():
	for dependent in dependents.values():
		if not is_instance_valid(dependent):
			print('skipping freed group')
			continue
		
		var group: BubbleGroup = dependent
		if group.dependencies.size() != 1:
			print('%s group has %s as dependencies' % [group.name, group.dependencies.values()])
			continue
		
		main.remove_group(group)
	
	var tween = create_tween()
	
	var children = get_children()
	for child: Bubble in children:
		tween.parallel().tween_property(child, "scale", Vector2.ZERO, .15).set_trans(Tween.TRANS_BACK)
	
	tween.tween_callback(self.clean)
	
