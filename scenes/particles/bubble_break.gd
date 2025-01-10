class_name BubbleBreakParticles extends GPUParticles2D


static var colors = [
	Color.RED,
	Color.YELLOW,
	Color.BLUE,
	Color.GREEN,
	Color.GRAY,
	Color.PURPLE,
	Color.ORANGE,
]


var type: int:
	set(value):
		var color = colors[value]
		self.process_material.color = color
		self.emitting = true


func _on_finished() -> void:
	queue_free()
