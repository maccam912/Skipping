extends RigidBody2D

@export var Red = false;
var path_points = [] # This will hold the path points
var current_point_index = 0 # Track the current segment in the path
var is_animating = true # Control whether the stone is animating along the path
var lerp_factor = 0.2; # Adjust this value to control the speed of the interpolation
var total_delta = 0.0;
var rotation_speed = 0.1;
var ccw = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	if Red:
		var texture: CompressedTexture2D = load("res://Assets/RedStone.png");
		$Sprite2D.set_texture(texture);
	freeze = true;
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC; # Start with manual control
	set_contact_monitor(true);
	set_max_contacts_reported(16);

func _physics_process(delta):
	if is_animating and path_points.size() > 1 and current_point_index < path_points.size() - 1:
		# Calculate the next position using linear interpolation
		var current_position = position
		var target_position = path_points[current_point_index + 1]
		var begin_position = path_points[current_point_index]
		total_delta += delta;
		position.x = lerp(begin_position.x, target_position.x, total_delta/lerp_factor)
		position.y = lerp(begin_position.y, target_position.y, total_delta/lerp_factor)
		var dir = 1.0;
		if ccw:
			dir = -1.0;
		set_rotation(get_rotation()+(dir)*2*PI*rotation_speed*delta);
		#position = current_position.linear_interpolate(target_position, lerp_factor)
		
		# Check if close enough to the target point to consider it "reached"
		if (total_delta/lerp_factor) > 1.0:
			current_point_index += 1 # Move to the next segment
			total_delta = 0.0;

		# Check if the animation has reached the end of the path
		if current_point_index >= path_points.size() - 1:
			call_deferred("set_contact_monitor", false);
			call_deferred("set_max_contacts_reported", 0);
			call_deferred("deanimate")

func _on_body_entered(body):
	# This method should be connected to the RigidBody2D's body_entered signal
	if is_animating:
		call_deferred("set_contact_monitor", false);
		call_deferred("set_max_contacts_reported", 0);
		call_deferred("deanimate")

func deanimate():
	is_animating = false # Stop animating
	freeze = false # Switch to physics control upon collision
