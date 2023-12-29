extends Node

#preload obstacles
var greenGift_scene = preload("res://Scenes/gift_green.tscn")
var blueGift_scene = preload("res://Scenes/gift_blue.tscn")
var redGift_scene = preload('res://Scenes/gift_red.tscn')
var regTree_scene = preload("res://Scenes/regular_tree.tscn")
var regRock_scene = preload("res://Scenes/regular_rock.tscn")
var snowyTree_scene = preload("res://Scenes/snowy_tree.tscn")
var snowyRock_scene = preload("res://Scenes/snowy_rock.tscn")
var gift_types = [greenGift_scene,blueGift_scene,redGift_scene]
var obstacles_types = [regTree_scene,regRock_scene,snowyTree_scene,snowyRock_scene]
var entities : Array
var gift_entities : Array
var obs_entities : Array
var entity_type
var entity_instance
var last_obs

const WIZARD_START_POS = Vector2i(180,570)
const CAMERA_START_POS = Vector2i(180,320)
const FOLLOW_THRESHOLD = 10 
var score = 0
var game_running : bool
var start_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	score = 0
	game_running = false
	get_tree().paused = false
	start_clock()
	$BGmusic.stop()
	
	#delete all obstacles
	for entity_instance in entities:
		entity_instance.queue_free()
	entities.clear()
	
	
	$Wizard.position = WIZARD_START_POS
	$Camera2D.position = CAMERA_START_POS
	
	#reset hud
	$HUD.get_node("NameLabel").show()
	$HUD.get_node("StartLabel").show()
	$HUD.get_node("ScoreLabel").hide()
	$GameOver.hide()
	$BGmusic.play()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		border()
		show_score()
		camera_follow()
		generate_entities()
		
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()
			$HUD.get_node("NameLabel").hide()
			$HUD.get_node("ScoreLabel").show()

func show_score():
	$HUD.get_node("ScoreLabel").text = "Score: " + str(score)

func camera_follow():
	var target_position = $Wizard.position
	var lerp_speed = 0.1 # Adjust this value for the desired smoothness
	var bottom_margin = 100  # Adjust this value based on the desired margin

	# Calculate the camera's target y-coordinate with an offset and bottom margin
	var target_y = target_position.y - CAMERA_START_POS.y + bottom_margin


	# Update the y-coordinate of the camera using linear interpolation
	$Camera2D.position.y = lerp($Camera2D.position.y, target_y, lerp_speed)

	# Keep the x-coordinate the same as the initial camera position
	$Camera2D.position.x = CAMERA_START_POS.x

func border():
	$ParallaxBackground/Walls.position.y = $Wizard.position.y

func generate_gift():
	entity_type = gift_types[randi() % gift_types.size()]
	var entity_instance = entity_type.instantiate()
	var type = "gift"
	spawn_entity(entity_instance, type)

func generate_obs():
	entity_type = obstacles_types[randi() % obstacles_types.size()]
	var entity_instance = entity_type.instantiate()
	var type = "obstacle"
	spawn_entity(entity_instance, type)
		
func generate_entities():
	if should_spawn_obs():
		generate_obs()
	elif should_spawn_gift():
		generate_gift()
		
func spawn_entity(entity_instance, type):
	add_child(entity_instance)
	if type == "gift":
		gift_entities.append(entity_instance)
	elif type == "obstacle":
		entity_instance.body_entered.connect(hit_obs)
		obs_entities.append(entity_instance)
	entities.append(entity_instance)
	
	entity_instance.position.x = randf_range(15, get_viewport().size.x - 15)
	entity_instance.position.y = randf_range(15, 100) + $Wizard.position.y - WIZARD_START_POS.y	

func should_spawn_obs():
	var current_time = get_elasped_time()
	var current_difficulty = difficulty(current_time)
	var spawn_probability = randf()
	var spawn_threshold = 0.009 
	return spawn_probability < spawn_threshold * current_difficulty or entities.is_empty()

func should_spawn_gift():
	var current_time = get_elasped_time()
	var current_difficulty = difficulty(current_time)
	var spawn_probability = randf()
	var spawn_threshold = 0.003 
	return spawn_probability < spawn_threshold * current_difficulty

func hit_gift(gift):
	increase_score()
	entities.erase(gift)
	gift.queue_free()
		
func hit_obs(body):
	if body.name == "Wizard":
		game_over()

func start_clock():
	start_time = Time.get_ticks_msec()
	
func get_elasped_time():
	var current_time = Time.get_ticks_msec()
	var elapsed_time = current_time - start_time
	return elapsed_time
	
func difficulty(current_time):
	var a = 1
	var b = 0.125
	var time_in_minutes = current_time / 60000
	var difficulty = a * (2.71828 ** (b * time_in_minutes))
	return difficulty

func increase_score():
	score += 1
	show_score()

func game_over():
	$GameOver.show()
	get_tree().paused = true
	game_running = false
