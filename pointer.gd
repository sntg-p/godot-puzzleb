extends Node

@export var projectile_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance2D.process_mode = Node.PROCESS_MODE_DISABLED
	$MeshInstance2D.hide()

var isPointing = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				print(event.position)
				isPointing = event.pressed
				if (isPointing):
					$MeshInstance2D.process_mode = Node.PROCESS_MODE_INHERIT
					$MeshInstance2D.position = event.position
					$MeshInstance2D.show()
				else:
					$MeshInstance2D.process_mode = Node.PROCESS_MODE_DISABLED
					$MeshInstance2D.hide()
					var projectile: ProjectileBubble = projectile_scene.instantiate()
					projectile.position = Vector2(720 / 2, 1120)
					var angle = event.position.angle_to_point(projectile.position)
					print(angle)
					projectile.linear_velocity = Vector2(-1000, 0).rotated(angle)
					get_parent().add_child(projectile)

	if isPointing and event is InputEventMouseMotion:
		$MeshInstance2D.position = event.position

	pass
