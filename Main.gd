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
	
	# Connect networking signals
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")

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


func _on_player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player")
	
func _on_player_disconnected(id):
	get_node("Players").get_node(id).free()

func _on_Player_moved(new_position) -> void:
	rpc_unreliable("update_player_movement", new_position)

remote func register_player():
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	
	var player = preload("res://Assets/Objects/PlayerCharacter/PlayerCharacter.tscn").instance()
	player.set_name(str(id))
	get_node("Players").add_child(player)
	

remote func update_player_movement(new_position) -> void:
	var sender_id = get_tree().get_rpc_sender_id()
	get_node("Players").get_node(str(sender_id)).translation = new_position
