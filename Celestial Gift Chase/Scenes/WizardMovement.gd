extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _process(_delta):
	var Flag = true
	var lastKey = true
	
	if Input.is_action_pressed("foward"):
		$Sprite2D2.play("foward")
		Flag = false
		
	if Input.is_action_pressed("backward"):
		$Sprite2D2.play("back")
		Flag = false
		lastKey = false
		
	if Input.is_action_pressed("left"):
		$Sprite2D2.play("left")
		Flag = false
		
	if Input.is_action_pressed("right"):
		$Sprite2D2.play("right")
		Flag = false
	
	if Flag == true && lastKey == true:
		$Sprite2D2.play("stationary front")
	elif Flag == true && lastKey == false:
		$Sprite2D2.play("stationary back")
		

func _physics_process(delta):
	# Add the gravity.
#	if not is_on_floor():
#		velocity.y += gravity * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	
	velocity = SPEED * Input.get_vector("left","right","foward","backward")
	velocity.limit_length()

	move_and_slide()
