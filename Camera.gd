extends Camera

onready var player_camera: Camera = $"../World/Player/Rotation_Helper/Camera"

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	self.global_transform = player_camera.global_transform