class_name Bubble extends MeshInstance2D


static var radius = 45
static var diameter = radius * 2
static var verticalOffset = sqrt(pow(diameter, 2) - pow(radius, 2))

@export var type = -1
@export var row = -1
@export var indexInRow = -1

var isOdd:
	get:
		assert(row > -1)
		assert(indexInRow > -1)
		return row % 2

var isEven:
	get:
		assert(row > -1)
		assert(indexInRow > -1)
		return 1 if row % 2 == 0 else 0 


var is_touching_wall: bool:
	get:
		if row == 0: return true
		return false


static func get_neighbor_indexes(row: int, index_in_row: int) -> Array:
	var is_even = 0 if row % 2 == 1 else 1
	var top_row = row - 1
	var bottom_row = row + 1
	
	return [
		# top left
		[top_row, index_in_row - is_even],
		
		# top right
		[top_row, index_in_row + 1 - is_even],
		
		# center right
		[row, index_in_row + 1],
		
		# bottom right
		[bottom_row, index_in_row + 1 - is_even],
		
		# bottom left
		[bottom_row, index_in_row - is_even],
		
		# center_left
		[row, index_in_row - 1]
	]


static func calculate_position(row: int, indexInRow: int):
	var isOdd = row % 2
	var rowOffset = Bubble.radius * isOdd
	var x = Bubble.radius + Bubble.diameter * indexInRow + rowOffset
	var y = Bubble.radius + Bubble.verticalOffset * row
	return Vector2(x, y)


# Returns a group when possible
static func find_or_create_group(neighbor_list: Array[Bubble], type: int) -> BubbleGroup:
	var matches = 0
	var matching_groups = Set.new()
	var last_group: BubbleGroup

	for bubble in neighbor_list:
		if bubble.type == type:
			print('%s-%s is of same type' % [bubble.row, bubble.indexInRow])
			var group = bubble.get_parent()
			if matching_groups.has(group): continue
			
			assert(group != null, 'bubble %s-%s parent is null' % [bubble.row, bubble.indexInRow])
			matches += group.get_child_count()
			matching_groups.add(group)
			last_group = group
	
	print('%s neighbor(s), %s of same type in contact' % [neighbor_list.size(), matches])
	
	if not last_group:
		return BubbleGroup.new(type)
	
	for group: BubbleGroup in matching_groups.values():
		if group == last_group: continue
		
		var children = group.get_children()
		for child in children:
			assert(child is Bubble)
			group.remove_child(child)
			last_group.add_child(child)
		
		var dependents = group.dependents.values()
		for dep in dependents:
			if not is_instance_valid(dep): continue
			last_group.add_dependent(dep)
		
		group.queue_free()
	
	return last_group


func type_matches(projectile: ProjectileBubble):
	return projectile.type == self.type


func add_sibling_bubble(sibling: Bubble):
	var group: BubbleGroup = get_parent()
	group.add_child(sibling)


func animate_spawn(origin: Vector2, target: Vector2, tween: Tween):
	position = target
	tween.tween_property(self, "position", target, .15).from(origin)
	tween.set_trans(Tween.TRANS_EXPO)
	pass


func _ready() -> void:
	name = "Bubble_%s_%s" % [row, indexInRow]


func _enter_tree() -> void:
	var group: BubbleGroup = get_parent()
	$Label.text = "%s-%s\nt: %s; g: %s" % [
		row, indexInRow, self.type, group.name.get_slice('@', 2)
	]
