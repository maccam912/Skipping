extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$FrictionValue.set_text(str($FrictionSlider.get_value()))
	$XValue.set_text(str($XSlider.get_value()))
	$YValue.set_text(str($YSlider.get_value()))


func _on_curl_button_pressed():
	Input.action_press("AddStone");
	Input.action_release("AddStone");


func _on_ff_button_button_down():
	
	Input.action_press("FastForward");

func _on_ff_button_button_up():
	Input.action_release("FastForward");
