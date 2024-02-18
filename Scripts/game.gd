extends Node2D

var stone = preload("res://Scenes/stone.tscn");

var stones = [];
var camera: Camera2D;

var friction = 0.98 # Friction coefficient
var curl_factor = 0.1 # Adjust the curl effect
var path_points = []
var last_path;

var normal_time_scale = 1.0;
var fast_forward_time_scale = 10.0; # Adjust as needed

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = $Camera2D;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("AddStone"):
		call_deferred("add_stone")

func _physics_process(delta):
	if Input.is_action_pressed("FastForward"):
		Engine.set_time_scale(fast_forward_time_scale);
	else:
		Engine.set_time_scale(normal_time_scale);
		
func dist(v1, v2):
	var xs = (v1.x-v2.x)**2
	var ys = (v1.y-v2.y)**2
	var hyp = sqrt(xs+ys)
	return hyp

func simulate_path():
	var position = Vector2(0, 21772);
	path_points.append(position);
	var initial_velocity_x = camera.get_node("CanvasLayer/Gui/XSlider").get_value();
	var initial_velocity_y = -1*camera.get_node("CanvasLayer/Gui/YSlider").get_value();
	var initial_velocity = Vector2(initial_velocity_x, initial_velocity_y);
	var velocity = initial_velocity;
	for i in range(100): # Arbitrary stop condition
		velocity = velocity * friction
		position += velocity
		# Apply curl based on velocity
		var dir = 1.0;
		if camera.get_node("CanvasLayer/Gui/ClockwiseCounterclockwise").button_pressed:
			dir = -1.0;
		var curl = dir*velocity.rotated(PI / 2) * 0.0012;
		velocity += curl
		path_points.append(position)
	draw_path()

func draw_path():
	var path = Line2D.new()
	path.width = 120
	path.default_color = Color(1, 0, 0, 0.33) # Red
	path.points = path_points
	add_child(path)
	last_path = path;

func add_stone():
	if last_path:
		remove_child(last_path)
	path_points = [];
	simulate_path();
	var new_stone: RigidBody2D = stone.instantiate();
	new_stone.path_points = path_points;
	var friction_slider = camera.get_node("CanvasLayer/Gui/FrictionSlider").get_value();
	new_stone.ccw = camera.get_node("CanvasLayer/Gui/ClockwiseCounterclockwise").button_pressed;
	new_stone.set_position(Vector2(0, 21772));
	new_stone.set_z_index(1);
	new_stone.set_linear_damp(friction_slider);
	#new_stone.freeze = true;
	if len(stones) % 2 == 0:
		new_stone.Red = true;
	$Stones.add_child(new_stone);
	var initial_velocity_x = camera.get_node("CanvasLayer/Gui/XSlider").get_value();
	var initial_velocity_y = camera.get_node("CanvasLayer/Gui/YSlider").get_value();
	var initial_velocity = Vector2(initial_velocity_x, initial_velocity_y);
	new_stone.apply_impulse(initial_velocity*5);
	var old_parent = camera.get_parent();
	old_parent.remove_child(camera);
	new_stone.add_child(camera);
	stones.append(new_stone); 
