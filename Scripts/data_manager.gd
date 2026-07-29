extends Node

var cal = Calendar.new()
var record_dates: Array[Calendar.Date] = []

func has_record(date: Calendar.Date) -> bool:
	for r in record_dates:
		if r.is_equal(date):
			return true
	return false

func add_record(date: Calendar.Date):
	# 防止重复
	for r in record_dates:
		if r.is_equal(date):
			return
	record_dates.append(date)

func get_last_record() -> Calendar.Date:
	if record_dates.is_empty():
		return null
	var latest = record_dates[0]
	for r in record_dates:
		if r.is_after(latest):
			latest = r
	return latest
