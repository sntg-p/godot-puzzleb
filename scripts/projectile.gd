class_name ProjectileBubble extends Area2D


@export var linear_velocity = Vector2.ZERO

var right = 0
var bottom = 0
var type = -1

@export var texture: Texture2D:
	set(value):
		$MeshInstance2D.texture = value


@onready var main: BubblesController = get_node('../BubblesController')

func _ready() -> void:
	#print('new projectile')
	var viewport_rect_size = get_viewport_rect().size
	right = viewport_rect_size.x
	bottom = viewport_rect_size.y


func _process(delta: float) -> void:
	var left_wall_collision = position.x - Bubble.radius <= 0
	if left_wall_collision:
		linear_velocity.x *= -1
	
	var right_wall_collision = position.x + Bubble.radius >= right
	if right_wall_collision:
		linear_velocity.x *= -1
	
	var top_wall_collision = position.y - Bubble.radius <= 0
	if top_wall_collision:
		_handle_top_wall_collision()
		return
	
	var bottom_wall_collision = position.y - Bubble.radius >= bottom
	if bottom_wall_collision:
		self.queue_free()
	
	position += linear_velocity * delta


func _to_bubble(row: int, indexInRow: int):
	if main.has_bubble(row, indexInRow):
		print('bubble %s-%s exists, skipping' % [row, indexInRow])
		return
	
	main.spawn_bubble(row, indexInRow, type, position)
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
	
	#print('collision between %s-%s and %s-%s' % [
		#row, indexInRow, collision.row, collision.indexInRow
	#])
	
	_to_bubble(row, indexInRow)


func _handle_top_wall_collision():
	var row = 0
	var index_in_row = (int(position.x) / Bubble.diameter) % 8
	
	#print('_handle_top_wall_collision at x = %s, spawning bubble at %s-%s' % [position.x, row, index_in_row])
	
	_to_bubble(row, index_in_row)
