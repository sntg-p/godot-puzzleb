class_name GroupDebug extends Node2D


@onready var main: Main = get_node('/root/Main')


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _draw() -> void:
	print('rendering group debug')
	var children = main.get_children()
	for child in children:
		if child is not BubbleGroup: continue
		var group: BubbleGroup = child
		if group.get_child_count() == 0:
			print('skipping drawing group %s deps as it is empty' % [group.name])
			continue

		var list = group.dependents.values()
		for dep in list:
			if not is_instance_valid(dep):
				print('skipping freed dependent from group %s' % [group.name])
				continue
			
			if dep is not BubbleGroup: continue
			if dep.get_child_count() == 0:
				print('skipping drawing group %s deps as it is empty' % [group.name])
				continue
			
			var bubble1: Bubble = group.get_children()[0]
			var bubble2: Bubble = dep.get_children()[0]
			#print('drawing line from %s (%s) to %s (%s)' % [
				#group.name, bubble1.position, dep.name, bubble2.position
			#])
			
			draw_line(bubble1.position, bubble2.position, Color.GREEN)
