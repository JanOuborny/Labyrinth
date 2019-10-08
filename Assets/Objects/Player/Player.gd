extends KinematicBody

"""
The Player movement.

Taken and adjusted from:
https://docs.godotengine.org/en/3.1/tutorials/3d/fps_tutorial/part_one.html#making-the-fps-movement-logic
'All assets provided (unless otherwise noted) were originally created by TwistedTwigleg, with
changes/additions by the Godot community. All original assets provided for this tutorial are
released under the MIT license.'
"""

const GRAVITY = 0.0
var vel = Vector3()
const MAX_SPEED = 1
const JUMP_SPEED = 18
const ACCEL = 4.5

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.05

const LightBall: PackedScene = preload("res://Assets/Objects/Light Ball/Light Ball.tscn")

func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper

	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	
	if Input.is_action_just_pressed("fire"):
		var light_ball: Spatial = LightBall.instance()
		
		light_ball.move_direction = -self.global_transform.basis.z
		
		get_parent().add_child(light_ball)
		
		light_ball.translation = self.translation + Vector3(0.0, 0.2, 0.0)

func process_input(delta):
	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------
	
	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()
	
	vel.y += delta * GRAVITY
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir
	target *= MAX_SPEED
	
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	translation.y = 0.0

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# look up and down based on mouse relative y movement
		rotation_helper.rotate_x(deg2rad(-event.relative.y) * MOUSE_SENSITIVITY)
		rotation_helper.rotation_degrees.x = clamp(rotation_helper.rotation_degrees.x, -70, 70)
		
		$SpotLight.rotation_degrees = rotation_helper.rotation_degrees
		$SpotLight.rotation_degrees.x += 5
		
		# turn left right based on mouse relative x movement
		self.rotate_y(deg2rad(-event.relative.x) * MOUSE_SENSITIVITY)
