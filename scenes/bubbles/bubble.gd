class_name Bubble extends MeshInstance2D


static var radius = 45
static var diameter = radius * 2
static var verticalOffset = sqrt(pow(diameter, 2) - pow(radius, 2))

var type = -1
var row = -1
var indexInRow = -1

static func calculate_position(row: int, indexInRow: int):
	var isOdd = row % 2
	var rowOffset = Bubble.radius * isOdd
	var x = Bubble.radius + Bubble.diameter * indexInRow + rowOffset
	var y = Bubble.radius + Bubble.verticalOffset * row
	return Vector2(x, y)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = calculate_position(row, indexInRow)
	var group: BubbleGroup = get_parent()
	group.type = type


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func type_matches(projectile: ProjectileBubble):
	return projectile.type == self.type


func _on_top_left_body_entered(body: ProjectileBubble) -> void:
	if type_matches(body):
		print('type matches')
		var main: Main = get_node('/root/Main')

		# TODO: check if bubble already exists before instantiating
		var bubble: Bubble = main.bubble_scenes[body.type].instantiate()
		bubble.type = type
		bubble.row = row - 1
		bubble.indexInRow = indexInRow
		add_sibling(bubble)
		body.queue_free()


func _on_top_right_body_entered(body: Node2D) -> void:
	#print('_on_top_right_body_entered')
	pass # Replace with function body.


func _on_middle_left_body_entered(body: Node2D) -> void:
	#print('_on_middle_left_body_entered')
	pass # Replace with function body.


func _on_middle_right_body_entered(body: Node2D) -> void:
	#print('_on_middle_right_body_entered')
	pass # Replace with function body.


func _on_bottom_left_body_entered(body: Node2D) -> void:
	if type_matches(body):
		print('type matches')
		var main: Main = get_node('/root/Main')

		# TODO: check if bubble already exists before instantiating
		var bubble: Bubble = main.bubble_scenes[body.type].instantiate()
		bubble.type = type
		bubble.row = row + 1
		bubble.indexInRow = indexInRow
		add_sibling(bubble)
		body.queue_free()

	print('_on_bottom_left_body_entered')


func _on_bottom_right_body_entered(body: Node2D) -> void:
	#print('_on_bottom_right_body_entered')
	pass # Replace with function body.
