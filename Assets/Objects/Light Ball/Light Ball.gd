extends VisibilityNotifier

"""
Move until invisible.
"""

var move_direction: Vector3

func _ready() -> void:
	$OmniLight.light_color = Color(rand_range(0.5, 1), rand_range(0.5, 1), rand_range(0.5, 1))

func _physics_process(delta: float) -> void:
	self.translation += 2 * delta * move_direction

func _on_Light_Ball_camera_exited(camera: Camera) -> void:
	self.queue_free()
