class_name BubbleBreakParticles extends GPUParticles2D


@export var colors = [
	Color.RED,
	Color.from_hsv(.15, 1, 1),
	Color.from_hsv(.61, 1, 1),
	Color.from_hsv(.33, 1, 1),
	Color.from_hsv(0, 0, .8),
	Color.from_hsv(.77, 1, 1),
	Color.from_hsv(.08, 1, 1),
]


var type: int:
	set(value):
		var color = colors[value]
		var material: ShaderMaterial = self.material
		material.set_shader_parameter("color", color)
		self.emitting = true


func _on_finished() -> void:
	queue_free()
