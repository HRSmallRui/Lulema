extends Control

var is_scrolling: bool = true
var nearest_node: Control
var step: float = 1280
var move_tween: Tween

@onready var h_box_container: HBoxContainer = $ScrollContainer/HBoxContainer
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var calendar_menu: Control = $ScrollContainer/HBoxContainer/CalendarMenu
@onready var center_menu: Control = $ScrollContainer/HBoxContainer/CenterMenu
@onready var statistics_menu: Control = $ScrollContainer/HBoxContainer/StatisticsMenu


func _process(delta: float) -> void:
	
	pass


func snap_to_scroll():
	if nearest_node == null: return
	if move_tween != null:
		move_tween.kill()
	move_tween = create_tween()
	move_tween.tween_property(scroll_container,"scroll_horizontal",nearest_node.position.x, 0.2)
	pass


func _on_scroll_container_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		is_scrolling = true
		if move_tween != null: move_tween.kill()
	elif event.is_action_released("click"):
		is_scrolling = false
		for component: Control in h_box_container.get_children():
			if nearest_node == null: 
				nearest_node = component
				continue
			if abs(nearest_node.global_position.x) > abs(component.global_position.x):
				nearest_node = component
		snap_to_scroll()
	pass # Replace with function body.
