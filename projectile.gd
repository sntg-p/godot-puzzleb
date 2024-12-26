class_name ProjectileBubble extends Area2D


@export var linear_velocity = Vector2.ZERO

var radius = 45
var right = 0
var bottom = 0
var type = -1

@onready var main: Main = get_node('/root/Main')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('new projectile')
	var viewport_rect_size = get_viewport_rect().size
	right = viewport_rect_size.x
	bottom = viewport_rect_size.y
	#type = randi() % 6
	type = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var left_wall_collision = position.x - radius <= 0
	if left_wall_collision:
		linear_velocity.x *= -1
	
	var right_wall_collision = position.x + radius >= right
	if right_wall_collision:
		linear_velocity.x *= -1
	
	var top_wall_collistion = position.y - radius <= 0
	if top_wall_collistion:
		linear_velocity.y *= -1
	
	var bottom_wall_collision = position.y - radius >= bottom
	if bottom_wall_collision:
		self.queue_free()
	
	position += linear_velocity * delta
	pass


# Returns a group when possible
func _find_or_create_group(row: int, indexInRow: int) -> BubbleGroup:
	#var neighborIndexes = []
	#var neighbors: Array[Bubble] = []
	var isOdd = row % 2
	var isEven = 0 if isOdd == 1 else 1
	var topRow = row - 1
	var bottom_row = row + 1
	
	var neighborIndexes = [
		# top left
		[topRow, indexInRow - isEven],
		
		# top right
		[topRow, indexInRow + 1 - isEven],
		
		# center right
		[row, indexInRow + 1],
		
		# bottom right
		[bottom_row, indexInRow + 1 - isEven],
		
		# bottom left
		[bottom_row, indexInRow - isEven],
		
		# center_left
		[row, indexInRow - 1]
	]
	
	#print(neighborIndexes)
	
	var existing_neighbors = 0
	var matches_amount = 0
	var matching_groups = Set.new()
	var last_group: BubbleGroup
	
	# find matching groups and bubbles amount
	for bubblePosition in neighborIndexes:
		var bubble: Bubble = main.get_bubble(
			bubblePosition[0], bubblePosition[1]
		)

		if !bubble: continue
		existing_neighbors += 1
		
		if bubble.type == self.type:
			print('%s-%s is of same type' % [bubble.row, bubble.indexInRow])
			var group = bubble.get_parent()
			if matching_groups.has(group): continue
			
			assert(group != null, 'bubble %s-%s parent is null' % [bubble.row, bubble.indexInRow])
			matches_amount += group.get_child_count()
			matching_groups.add(group)
			last_group = group
	
	print('%s neighbor(s), %s of same type in contact' % [existing_neighbors, matches_amount])

	if matches_amount >= 2:
		for group: BubbleGroup in matching_groups.values():
			var children = group.get_children()
			for child in children:
				assert(child is Bubble)
				main.remove_bubble(child)
			
			print('freeing group %s' % [group.name])
			group.queue_free()
		
		return null
	
	if matches_amount == 0:
		assert(!last_group)
		last_group = main.new_group(self.type)
	
	for group: BubbleGroup in matching_groups.values():
		if group == last_group: continue
		
		var children = group.get_children()
		for child in children:
			assert(child is Bubble)
			last_group.add_bubble(child)
		
		group.queue_free()
	
	return last_group


func _collapse(row: int, indexInRow: int, collision: Bubble):
	if main.has_bubble(row, indexInRow):
		print('bubble exists, skipping')
		return
	
	var group = _find_or_create_group(row, indexInRow)
	if group:
		print('spawning bubble at %s-%s' % [row, indexInRow])
		var bubble: Bubble = main.new_bubble(row, indexInRow, self.type)
		group.add_bubble(bubble)
		main.add_child(group)
	
	self.queue_free()


func _on_area_entered(area: Area2D) -> void:
	if self.is_queued_for_deletion():
		print('projectile already queued for deletion, skipping collision check')
		return
	
	var parent = area.get_parent()
	if (parent is not Bubble): return
	
	var collision: Bubble = parent
	var row = collision.row
	var indexInRow = collision.indexInRow
	
	var xDiff = self.position.x - collision.position.x
	var yDiff = self.position.y - collision.position.y
	
	var collapseAbove = yDiff <= -15
	var collapseBelow = yDiff >= 15
	var collapseSame = 1 if !(collapseAbove || collapseBelow) else 0
	var collapseBefore = xDiff < 0 
	var collapseAfter = xDiff > 0
	
	if collapseAbove:
		row -= 1
	elif collapseBelow:
		row += 1
	
	var isOdd = row % 2
	var isEven = 1 if isOdd == 0 else 0
	var isLast = 1 if indexInRow == (7 - isOdd) else 0
	
	if collapseBefore and (isOdd + collapseSame) > 0:
		indexInRow -= 1
	elif collapseAfter and (isEven - isLast + collapseSame) > 0:
		indexInRow += 1
	
	#print('above: %s; below: %s; before: %s; after: %s;' % [
		#collapseAbove, collapseBelow, collapseBefore, collapseAfter,
	#])
	
	#print('isOdd: %s; row: %s; indexInRow: %s' % [isOdd, row, indexInRow])
	
	print('collision between %s-%s and %s-%s' % [
		row, indexInRow, collision.row, collision.indexInRow
	])
	
	_collapse(row, indexInRow, collision)
	
