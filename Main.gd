extends Spatial

"""
Set Minimap Vieport World.
Push according to Player position and look direction.
"""

onready var world: Spatial = $World #$ViewportContainer/Viewport/World
onready var player: Spatial = $"Player view/Viewport/Player" #world.get_node("Player")
onready var rotation_helper: Spatial = player.get_node("Rotation_Helper")

onready var fps: Label = $Panel/MarginContainer/VBoxContainer/FPS

func _ready() -> void:
	randomize()
	
	$Minimap/Viewport.world = world
	$"Player view/Viewport".world = $World

func _process(delta: float) -> void:
	fps.text = "FPS: " + str(Engine.get_frames_per_second())
	
	if Input.is_action_just_pressed("ui_accept"):
		var position = player.translation.floor()
		var look_direction = rotation_helper.global_transform.basis.z.round()
		
		if rotation_helper.global_transform.basis.z.abs().max_axis() == Vector3.AXIS_X:
			var row = position.x - look_direction.x
			
			if row >= 0 and row <= world.SIZE - 1:
				world._push_row(row)
		else:
			var column = position.z - look_direction.z
			
			if column >= 0 and column <= world.SIZE - 1:
				world._push_column(column)


func _on_Help_pressed() -> void:
	$PopupDialog.popup()
