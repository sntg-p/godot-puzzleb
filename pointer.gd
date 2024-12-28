extends Node

@export var projectile_scene: PackedScene
@export var bubble_types: Array[Resource]


@onready var main: Main = get_node('/root/Main')

var bubble_type = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MouseIndicator.process_mode = Node.PROCESS_MODE_DISABLED
	$MouseIndicator.hide()


var isPointing = false

func handle_mouse_pointer(event: InputEventMouseButton):
	isPointing = event.pressed

	if (isPointing):
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
	
	pass


func update_bubble_types():
	bubble_type = main.get_random_bubble_type()
	$NextBubble.texture = bubble_types[bubble_type]


func _on_main_level_loaded() -> void:
	print('_on_main_level_loaded')
	bubble_type = main.get_random_bubble_type()
	$NextBubble.texture = bubble_types[bubble_type]
	pass # Replace with function body.
