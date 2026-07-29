extends Control

@onready var stats_grid: GridContainer = $VBox/StatsGrid
@onready var total_label = $VBox/StatsGrid/TotalCard/VBox/ValueLabel
@onready var streak_label = $VBox/StatsGrid/StreakCard/VBox/ValueLabel
@onready var longest_label = $VBox/StatsGrid/LongestCard/VBox/ValueLabel
@onready var month_label = $VBox/StatsGrid/MonthCard/VBox/ValueLabel
@onready var week_label = $VBox/WeekCard/HBox/ValueLabel

var cal = Calendar.new()


func _ready():
	cal.first_weekday = Time.WEEKDAY_SUNDAY
	# 调试：打印记录数量
	print("记录数量：", DataManager.record_dates.size())
	update_statistics()
	#_draw_chart()


func update_statistics():
	var records = DataManager.record_dates
	var today = cal.get_today()
	
	# 1. 总记录次数
	total_label.text = str(records.size())
	
	# 2. 本月记录（去重）
	var month_count = 0
	for r in records:
		if r.year == today.year and r.month == today.month:
			month_count += 1
	month_label.text = "%d 次" % month_count
	
	# 3. 当前连续（从昨天开始往前推）
	var streak = 0
	var check_date = today.duplicate()
	check_date.subtract_days(1)  # 从昨天开始
	while true:
		if _has_record_on_date(check_date):
			streak += 1
			check_date.subtract_days(1)
		else:
			break
	streak_label.text = "%d 天" % streak
	
	# 4. 最长连续
	var longest = _calc_longest_streak(records)
	longest_label.text = "%d 天" % longest
	
	# 5. 本周打卡进度（周日到周六）
	var week_count = _get_week_progress(today, records)
	week_label.text = "%d / 7" % week_count


func _has_record_on_date(date: Calendar.Date) -> bool:
	for r in DataManager.record_dates:
		if r.is_equal(date):
			return true
	return false


func _calc_longest_streak(records: Array) -> int:
	if records.is_empty():
		return 0
	# 提取所有日期并排序（升序）
	var sorted = records.duplicate()
	sorted.sort_custom(func(a, b): return a.is_before(b))
	
	var longest = 1
	var current = 1
	for i in range(1, sorted.size()):
		# 检查是否连续（相差1天）
		var diff = sorted[i-1].days_to(sorted[i])
		if diff == 1:
			current += 1
			longest = max(longest, current)
		elif diff > 1:
			current = 1
	return longest


func _get_week_progress(today: Calendar.Date, records: Array) -> int:
	# 获取本周周日（先计算今天是一周第几天，往前推到周日）
	var weekday = today.get_weekday()  # 0=周日
	var week_start = today.duplicate()
	week_start.subtract_days(weekday)  # 回到本周周日
	
	var count = 0
	for r in records:
		# 检查记录是否在本周范围内（>= 本周日 且 <= 本周六）
		var diff = week_start.days_to(r)
		if diff >= 0 and diff <= 6:
			# 还要确保是同一周（防止跨年干扰）
			# 简单做法：比较 week_start 所在周和 r 所在周的周日
			count += 1
	return count


func _draw_chart():
	var container = $VBox/ChartContainer
# 清空旧内容
	for child in container.get_children():
		child.queue_free()
	await get_tree().process_frame

	var today = cal.get_today()
	var records = DataManager.record_dates
	var max_count = 1  # 防止除以0

	# 收集最近7天的数据（从今天往前推6天）
	var dates: Array[Calendar.Date] = []
	var counts: Array[int] = []
	for i in range(6, -1, -1):  # 从6天前到0（今天）
		var d = today.duplicate()
		d.subtract_days(i)
		dates.append(d)
		var cnt = 0
		for r in records:
			if r.is_equal(d):
				cnt += 1
		counts.append(cnt)
		max_count = max(max_count, cnt)

	# 生成柱子
	for i in range(7):
		var col = VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.alignment = BoxContainer.PRESET_CENTER_BOTTOM
		col.theme_override_constants["separation"] = 4

		# 柱子（ColorRect）
		var bar = ColorRect.new()
		var height_ratio = float(counts[i]) / float(max_count) if max_count > 0 else 0.0
		bar.custom_minimum_size = Vector2(0, max(10, height_ratio * 200))  # 最大200px高
		bar.color = Color(0.5, 0.75, 0.9, 0.8)
		if counts[i] == 0:
			bar.color = Color(0.8, 0.8, 0.8, 0.4)
		bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
		col.add_child(bar)

		# 日期标签（日/一/二等）
		var label = Label.new()
		label.text = _get_short_weekday(dates[i])
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		col.add_child(label)

		container.add_child(col)


func _get_short_weekday(date: Calendar.Date) -> String:
	var wd = date.get_weekday()
	var names = ["日", "一", "二", "三", "四", "五", "六"]
	return names[wd]
