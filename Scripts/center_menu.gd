extends Control

@onready var background: ColorRect = $Background
@onready var status_label: Label = $VBox/StatusLabel
@onready var streak_label: Label = $VBox/StreakLabel
@onready var button: Button = $VBox/CenterContainer/Button
@onready var button_sprite: Sprite2D = $VBox/CenterContainer/Button/ButtonSprite

var scale_tween: Tween
var sav: AppSaver


func _ready() -> void:
	#background.hide()
	update_state()
	pass


func update_state():
	var today = Time.get_datetime_dict_from_system()
	print(today)
	sav = AppSaver.get_app_saver()
	if sav == null:
		sav = AppSaver.new()
		AppSaver.save_app_saver(sav)
	var today_struct: DateStruct = DateStruct.new()
	today_struct.year = today.year
	today_struct.month = today.month
	today_struct.day = today.day
	
	if sav.latest_date != null:
		if DateStruct.is_the_same_day(sav.latest_date,today_struct):
			status_label.text = "今日已记录"
		else:
			status_label.text = "今日尚未记录"
	pass


func _on_button_pressed() -> void:
	var today = Time.get_datetime_dict_from_system()
	var today_struct: DateStruct = DateStruct.new()
	today_struct.year = today.year
	today_struct.month = today.month
	today_struct.day = today.day
	sav = AppSaver.get_app_saver()
	if sav == null:
		sav = AppSaver.new()
	
	if sav.latest_date == null:
		sav.latest_date = today_struct
		sav.recorded_dates.append(today_struct)
	elif DateStruct.is_the_same_day(sav.latest_date, today_struct):
		sav.recorded_dates.remove_at(-1)
		sav.latest_date = null if sav.recorded_dates.is_empty() else sav.recorded_dates[-1]
	else:
		sav.latest_date = today_struct
		sav.recorded_dates.append(today_struct)
	AppSaver.save_app_saver(sav)
	update_state()
	pass # Replace with function body.


func _on_button_button_up() -> void:
	if scale_tween != null: scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(button_sprite,"scale",Vector2.ONE*0.328,0.1)
	pass # Replace with function body.


func _on_button_button_down() -> void:
	if scale_tween != null: scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(button_sprite,"scale",Vector2.ONE*0.2,0.1)
	pass # Replace with function body.
