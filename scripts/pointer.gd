extends Node

@export var projectile_scene: PackedScene
@export var bubble_types: Array[Resource]


@onready var main: BubblesController = get_node('../BubblesController')

var bubble_type = -1
var next_bubble_type = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MouseIndicator.process_mode = Node.PROCESS_MODE_DISABLED
	$MouseIndicator.hide()


var isPointing = false

func handle_mouse_pointer(event: InputEventMouseButton):
	if loading: return
	
	isPointing = event.pressed

	if isPointing:
		$MouseIndicator.process_mode = Node.PROCESS_MODE_INHERIT
		$MouseIndicator.position = event.position
		$MouseIndicator.show()
	else:
		$MouseIndicator.process_mode = Node.PROCESS_MODE_DISABLED
		$MouseIndicator.hide()
		
		var projectile: ProjectileBubble = projectile_scene.instantiate()
		projectile.position = Vector2(720 / 2, 1120)
		projectile.type = bubble_type
		projectile.texture = bubble_types[projectile.type]
		update_bubble_types()
		
		var angle = event.position.angle_to_point(projectile.position)
		projectile.linear_velocity = Vector2(-1000, 0).rotated(angle)
		
		get_parent().add_child(projectile)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				handle_mouse_pointer(event)
	
	if isPointing and event is InputEventMouseMotion:
		$MouseIndicator.position = event.position


var loading = false

func update_bubble_types():
	loading = true
	bubble_type = next_bubble_type
	next_bubble_type = main.get_random_bubble_type()
	
	var nextBubble: Node2D = $NextBubble
	nextBubble.texture = bubble_types[bubble_type]
	
	var nextNextBubble = $NextBubble2
	nextNextBubble.texture = bubble_types[next_bubble_type]
	var tween = create_tween()
	var origin = nextNextBubble.position
	tween.tween_property(nextBubble, "position", nextBubble.position, .15).from(origin)
	tween.tween_callback(func (): loading = false)


func _on_main_level_loaded() -> void:
	print('_on_main_level_loaded')
	bubble_type = main.get_random_bubble_type()
	next_bubble_type = main.get_random_bubble_type()
	$NextBubble.texture = bubble_types[bubble_type]
	$NextBubble2.texture = bubble_types[next_bubble_type]
