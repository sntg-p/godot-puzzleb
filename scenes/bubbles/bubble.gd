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
		if indexInRow == 0: return true
		if indexInRow == (7 - isOdd): return true
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


func type_matches(projectile: ProjectileBubble):
	return projectile.type == self.type


func add_sibling_bubble(sibling: Bubble):
	var group: BubbleGroup = get_parent()
	group.add_bubble(sibling)


var _origin: Vector2
var _target: Vector2
var _animating: bool = false
var _animation_progress: float = 1
var _animation_speed = 25


func animate_spawn(origin: Vector2, target: Vector2):
	#print('animating bubble spawn')
	position = origin
	_animating = true
	_animation_progress = 0
	_origin = origin
	_target = target


func _update_animation(delta: float):
	if not _animating: return
	
	if _animation_progress > 1:
		_animating = false
		position = _target
		return
	
	#print('updating bubble spawn animation, progress: %s' % [_animation_progress])
	var step = delta * _animation_speed
	_animation_progress += step
	position = _origin.lerp(_target, _animation_progress)


func _ready() -> void:
	name = "Bubble_%s_%s" % [row, indexInRow]


func _enter_tree() -> void:
	var group: BubbleGroup = get_parent()
	$Label.text = "%s-%s\nt: %s; g: %s" % [
		row, indexInRow, self.type, group.name.get_slice('_', 1)
	]


func _process(delta: float) -> void:
	_update_animation(delta)
