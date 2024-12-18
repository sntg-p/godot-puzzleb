class_name ProjectileBubble extends Area2D

@export var linear_velocity = Vector2.ZERO

var radius = 45
var right = 0
var bottom = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var viewport_rect_size = get_viewport_rect().size
	right = viewport_rect_size.x
	bottom = viewport_rect_size.y


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
