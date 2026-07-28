extends Resource
class_name AppSaver

@export var max_days: int
@export var recorded_dates: Array[DateStruct]


static func get_app_saver() -> AppSaver:
	if OS.get_name() == "Android":
		return load("user://sav.tres")
	else:
		return load("res://Savs/sav.tres")


static func save_app_saver(app_saver: AppSaver):
	if OS.get_name() == "Android":
		ResourceSaver.save(app_saver,"user://sav.tres")
	else:
		ResourceSaver.save(app_saver,"res://Savs/Sav.tres")
	pass
