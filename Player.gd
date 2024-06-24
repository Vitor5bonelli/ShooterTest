extends CharacterBody3D

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var raycast = $Head/Camera3D/RayCast3D
@onready var kills_lbl = $Head/Camera3D/Kills
@onready var deaths_lbl = $Head/Camera3D/Deaths
@onready var name_3d = $Name
@onready var run_sfx = $run_sfx

# Game values
var speed
const WALK_SPEED = 7.5
const SPRINT_SPEED = 12

const JUMP_VELOCITY = 10.0
var gravity = 20

# Head bob variables:
const BOB_FREQ = 1.5
const BOB_AMP = 0.08
var t_bob = 0.0

# Player values
const SENSITIVITY = 0.005
var playerName = "placeholder"
var health = 100
var kills = 0
var deaths = 0

#fov variables
const BASE_FOV = 70.0
const FOV_CHANGE = 1.2

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	
	kills_lbl.text = str(kills)
	deaths_lbl.text = str(deaths)
	

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		run_sfx.stop()
	
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
		if !run_sfx.is_playing():
			run_sfx.play()
			
	else:
		speed = WALK_SPEED
		run_sfx.stop()
	
	if velocity.x == 0:
		run_sfx.stop()
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 1.6)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 1.6)
		
	#Head Bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	#FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	return pos

@rpc("any_peer")
func receive_damage(attacker_id):
	health -= 50
	
	if health <= 0:
		health = 100
		position = Vector3.ZERO
		deaths += 1
		deaths_lbl.text = str(deaths)
		killed_enemy.rpc(attacker_id)

@rpc("call_local")
func killed_enemy(attacker_id):
	if multiplayer.get_unique_id() == attacker_id:
		kills += 1
		kills_lbl.text = str(kills)
