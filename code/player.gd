extends CharacterBody3D

# ========================
# CONSTANTS
# ========================
const SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 6.0
const SENS = 0.005

# Head bobbing
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
const SPRINT_BOB_MULT = 1.4

# Footstep sound
const WALK_STEP_PITCH = 1.0
const SPRINT_STEP_PITCH = 1.1

# ========================
# VARIABLES
# ========================
var t_bob := 0.0
var last_bob_value := 0.0
var can_play_step := true

@onready var footsteps: AudioStreamPlayer3D = $Node3D/AudioStreamPlayer3D
@onready var head = $head
@onready var cam = $head/Camera3D
@onready var cam_origin = cam.position

# ========================
# READY
# ========================
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# ========================
# MOUSE LOOK
# ========================
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENS)
		cam.rotate_x(-event.relative.y * SENS)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-60), deg_to_rad(65))

# ========================
# PHYSICS
# ========================
func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# ========================
	# MOVEMENT
	# ========================
	var input_dir = Input.get_vector("left", "right", "back", "forward")

	var cam_basis = head.global_transform.basis

	var forward = -cam_basis.z
	forward.y = 0
	forward = forward.normalized()

	var right = cam_basis.x
	right.y = 0
	right = right.normalized()

	var direction = right * input_dir.x + forward * input_dir.y

	var is_sprinting = Input.is_action_pressed("spint") and is_on_floor()
	var current_speed = SPRINT_SPEED if is_sprinting else SPEED

	if direction.length() > 0:
		direction = direction.normalized()
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# ========================
	# HEAD BOB + FOOTSTEPS
	# ========================
	if is_on_floor() and direction.length() > 0:
		var bob_speed = current_speed * (SPRINT_BOB_MULT if is_sprinting else 1.0)
		t_bob += delta * BOB_FREQ * bob_speed

		var bob_value = sin(t_bob)
		cam.position.y = cam_origin.y + bob_value * BOB_AMP

		# Play footstep (no overlap, pitch-based speed)
		if last_bob_value > 0 and bob_value <= 0 and can_play_step:
			footsteps.pitch_scale = SPRINT_STEP_PITCH if is_sprinting else WALK_STEP_PITCH
			if not footsteps.playing:
				footsteps.play()
			can_play_step = false

		# Reset trigger
		if bob_value > 0.2:
			can_play_step = true

		last_bob_value = bob_value
	else:
		# Stop footsteps immediately
		if footsteps.playing:
			footsteps.stop()

		footsteps.pitch_scale = WALK_STEP_PITCH
		t_bob = 0.0
		last_bob_value = 0.0
		cam.position.y = lerp(cam.position.y, cam_origin.y, delta * 8.0)

	# Match body rotation
	rotation.y = head.rotation.y

	# Move character
	move_and_slide()
