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


var group: BubbleGroup


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
	group = get_parent()
	group.type = type


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Label.text = "%s-%s\nt: %s; g: %s" % [row, indexInRow, self.type, group.name.get_slice('_', 1)]
	pass


func type_matches(projectile: ProjectileBubble):
	return projectile.type == self.type


func add_sibling_bubble(sibling: Bubble, check_count: bool = false):
	var group: BubbleGroup = get_parent()
	group.add_bubble(sibling, check_count)
