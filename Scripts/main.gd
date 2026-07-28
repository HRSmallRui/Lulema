extends Control

@onready var camera_2d: Camera2D = $Camera2D
@onready var h_box_container: HBoxContainer = $HBoxContainer

var current_id: int = 1
var move_tween: Tween

func _ready() -> void:
	
	pass


func snap_to_component():
	if move_tween != null: move_tween.kill()
	var target_node: Control = h_box_container.get_child(current_id)
	move_tween = create_tween()
	move_tween.tween_property(camera_2d,"position:x",target_node.global_position.x,0.2)
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if move_tween != null: move_tween.kill()
	elif event.is_action_released("click"):
		if move_tween != null: move_tween.kill()
		var mouse_velocity: Vector2 = Input.get_last_mouse_screen_velocity()
		print(mouse_velocity.x)
		if mouse_velocity.x > 100:
			current_id -= 1
		elif mouse_velocity.x < -100:
			current_id += 1
		else:
			var target_id: int = 0
			var nearest_length: float = 10000
			for i in h_box_container.get_child_count():
				var target_node: Control = h_box_container.get_child(i)
				if abs(target_node.global_position.x - camera_2d.position.x) < nearest_length:
					nearest_length = abs(target_node.global_position.x - camera_2d.position.x)
					target_id = i
			current_id = target_id
		current_id = clampi(current_id,0,2)
		snap_to_component()
	
	if event is InputEventScreenDrag:
		camera_2d.position.x -= event.screen_relative.x
		if camera_2d.position.x < -1280 or camera_2d.position.x > 1280:
			back()
	pass


func back():
	snap_to_component()
	pass
