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


static func calculate_position(row: int, indexInRow: int):
	var isOdd = row % 2
	var rowOffset = Bubble.radius * isOdd
	var x = Bubble.radius + Bubble.diameter * indexInRow + rowOffset
	var y = Bubble.radius + Bubble.verticalOffset * row
	return Vector2(x, y)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = "Bubble_%s_%s" % [row, indexInRow]
	position = calculate_position(row, indexInRow)
	var group: BubbleGroup = get_parent()
	group.type = type


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func type_matches(projectile: ProjectileBubble):
	var value = projectile.type == self.type
	if value:
		print('type matches')

	return value


func _on_top_left_body_entered(body: ProjectileBubble) -> void:
	print('_on_top_left_body_entered')

	if type_matches(body):
		_spawn_from_projectile(row - 1, indexInRow, body)


func _on_top_right_body_entered(body: Node2D) -> void:
	print('_on_top_right_body_entered')

	if type_matches(body):
		_spawn_from_projectile(row - 1, indexInRow + 1, body)


func _on_middle_left_body_entered(body: Node2D) -> void:
	print('_on_middle_left_body_entered')

	if type_matches(body):
		_spawn_from_projectile(row, indexInRow - 1, body)


func _on_middle_right_body_entered(body: Node2D) -> void:
	print('_on_middle_right_body_entered')

	if type_matches(body):
		_spawn_from_projectile(row, indexInRow + 1, body)


func _on_bottom_left_body_entered(body: Node2D) -> void:
	print('_on_bottom_left_body_entered')

	if type_matches(body):
		_spawn_from_projectile(row + 1, indexInRow - isEven, body)


func _on_bottom_right_body_entered(body: Node2D) -> void:
	print('_on_bottom_right_body_entered')

	if type_matches(body):
		_spawn_from_projectile(row + 1, indexInRow + isOdd, body)

func _spawn_from_projectile(row: int, indexInRow: int, body: ProjectileBubble):
	var main: Main = get_node('/root/Main')
	if main.has_bubble(row, indexInRow):
		print('bubble exists, skipping')
		return

	print('spawning bubble')
	var bubble: Bubble = main.bubble_scenes[body.type].instantiate()
	bubble.type = type
	bubble.row = row
	bubble.indexInRow = indexInRow
	add_sibling(bubble)
	body.queue_free()
