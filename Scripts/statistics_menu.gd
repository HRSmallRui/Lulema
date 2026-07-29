extends Control
class_name StatisticsMenu

static var instance: StatisticsMenu

@onready var stats_grid: GridContainer = $VBox/StatsGrid
@onready var total_label: Label = $VBox/StatsGrid/TotalCard/VBox/ValueLabel
@onready var streak_label: Label = $VBox/StatsGrid/StreakCard/VBox/ValueLabel
@onready var longest_label: Label = $VBox/StatsGrid/LongestCard/VBox/ValueLabel
@onready var month_label: Label = $VBox/StatsGrid/MonthCard/VBox/ValueLabel
@onready var week_label: Label = $VBox/WeekCard/HBox/ValueLabel
@onready var background: ColorRect = $Background

var cal: Calendar = Calendar.new()


func _init() -> void:
	instance = self
	pass


func _ready() -> void:
	await get_tree().process_frame
	background.hide()
	cal.first_weekday = Time.WEEKDAY_SUNDAY
	update_statistics()
	_draw_chart()


func update_statistics() -> void:
	var sav: AppSaver = AppSaver.get_app_saver()
	var records: Array[DateStruct] = sav.recorded_dates
	var today: Calendar.Date = cal.get_today()
	
	# 1. 总记录次数
	total_label.text = str(records.size())
	
	# 2. 本月记录（去重）
	var month_count: int = 0
	for r: DateStruct in records:
		if r.year == today.year and r.month == today.month:
			month_count += 1
	month_label.text = "%d 次" % month_count
	
	# 3. 当前连续（从昨天开始往前推）
	var streak: int = 0
	var check_date: Calendar.Date = today.duplicate()
	check_date.subtract_days(1)
	while true:
		if _has_record_on_date(check_date):
			streak += 1
			check_date.subtract_days(1)
		else:
			break
	streak_label.text = "%d 天" % streak
	
	# 4. 最长连续
	var longest: int = _calc_longest_streak(records)
	longest_label.text = "%d 天" % longest
	
	# 5. 本周打卡进度（周日到周六）
	var week_count: int = _get_week_progress(today, records)
	week_label.text = "%d / 7" % week_count


func _has_record_on_date(date: Calendar.Date) -> bool:
	var records: Array[DateStruct] = AppSaver.get_app_saver().recorded_dates
	for r: DateStruct in records:
		if r.year == date.year and r.month == date.month and r.day == date.day:
			return true
	return false


func _calc_longest_streak(records: Array[DateStruct]) -> int:
	if records.is_empty():
		return 0
	# 提取所有日期并转为 Calendar.Date 以便排序
	var sorted: Array[Calendar.Date] = []
	for r: DateStruct in records:
		sorted.append(Calendar.Date.new(r.year, r.month, r.day))
	
	sorted.sort_custom(func(a: Calendar.Date, b: Calendar.Date) -> bool:
		return a.is_before(b)
	)
	
	var longest: int = 1
	var current: int = 1
	for i: int in range(1, sorted.size()):
		var diff: int = sorted[i - 1].days_to(sorted[i])
		if diff == 1:
			current += 1
			longest = max(longest, current)
		elif diff > 1:
			current = 1
	return longest


func _get_week_progress(today: Calendar.Date, records: Array[DateStruct]) -> int:
	var weekday: int = today.get_weekday()  # 0=周日
	var week_start: Calendar.Date = today.duplicate()
	week_start.subtract_days(weekday)
	
	var count: int = 0
	for r: DateStruct in records:
		var record_date: Calendar.Date = Calendar.Date.new(r.year, r.month, r.day)
		var diff: int = week_start.days_to(record_date)
		if diff >= 0 and diff <= 6:
			count += 1
	return count


func _draw_chart() -> void:
	var container: HBoxContainer = $VBox/ChartContainer
	# 清空旧内容
	for child: Node in container.get_children():
		child.queue_free()
	await get_tree().process_frame

	# ---- 1. 准备数据：最近12个月 ----
	var today: Calendar.Date = cal.get_today()
	var records: Array[DateStruct] = AppSaver.get_app_saver().recorded_dates
	var months_data: Array[int] = []  # 每个月有记录的天数
	var month_labels: Array[String] = []

	for i: int in range(11, -1, -1):  # 从11个月前到本月
		var target_year: int = today.year
		var target_month: int = today.month - i
		while target_month <= 0:
			target_month += 12
			target_year -= 1
		
		# 统计该月有记录的天数（去重）
		var days_in_month: Array[int] = []
		for r: DateStruct in records:
			if r.year == target_year and r.month == target_month:
				if not r.day in days_in_month:
					days_in_month.append(r.day)
		months_data.append(days_in_month.size())
		month_labels.append("%d月" % target_month)

	# ---- 2. 计算绘图参数 ----
	var max_value: int = max(months_data.max(), 1)  # 防止除以0
	var chart_width: float = container.size.x - 60.0   # 左右留边距
	var chart_height: float = container.size.y - 80.0  # 上下留边距
	var bottom_margin: float = 40.0
	var top_margin: float = 20.0
	var left_margin: float = 30.0
	var right_margin: float = 30.0
	var plot_width: float = chart_width - left_margin - right_margin
	var plot_height: float = chart_height - bottom_margin - top_margin

	# ---- 3. 创建绘图控件 ----
	var chart_draw: Control = Control.new()
	chart_draw.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chart_draw.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(chart_draw)

	# 用 draw 回调绘制
	chart_draw.draw.connect(func():
		var draw: CanvasItem = chart_draw

		# ---- 4. 绘制网格线（可选） ----
		for i: int in range(5):
			var y_ratio: float = float(i) / 4.0
			var y_pos: float = top_margin + plot_height * (1.0 - y_ratio)
			draw.draw_line(
				Vector2(left_margin, y_pos),
				Vector2(left_margin + plot_width, y_pos),
				Color(0.8, 0.8, 0.8, 0.5), 1.0
			)
			# 纵轴数值标签
			var val_label: Label = Label.new()
			val_label.text = str(roundi(y_ratio * float(max_value)))
			val_label.add_theme_font_size_override("font_size", 16)
			val_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			val_label.position = Vector2(0, y_pos - 10)
			chart_draw.add_child(val_label)

		# ---- 5. 绘制折线 ----
		var points: Array[Vector2] = []
		var point_positions: Array[Vector2] = []
		for i: int in months_data.size():
			var x: float = left_margin + (float(i) / float(months_data.size() - 1)) * plot_width
			var y: float = top_margin + plot_height * (1.0 - float(months_data[i]) / float(max_value))
			var pos: Vector2 = Vector2(x, y)
			points.append(pos)
			point_positions.append(pos)

		# 画折线
		if points.size() >= 2:
			for i: int in range(points.size() - 1):
				draw.draw_line(points[i], points[i + 1], Color(0.3, 0.6, 0.9, 0.9), 6.0)

		# 画数据点（圆点）
		for pos: Vector2 in point_positions:
			draw.draw_circle(pos, 6.0, Color(0.3, 0.6, 0.9, 0.9))
			draw.draw_circle(pos, 4.0, Color.WHITE)

		# ---- 6. 绘制横轴月份标签 ----
		for i: int in month_labels.size():
			var x: float = left_margin + (float(i) / float(month_labels.size() - 1)) * plot_width
			var label: Label = Label.new()
			label.text = month_labels[i]
			label.add_theme_font_size_override("font_size", 24)
			label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
			label.position = Vector2(x - 20, chart_height - bottom_margin + 10)
			chart_draw.add_child(label)

		# ---- 7. 在每个数据点上方显示数值 ----
		for i: int in point_positions.size():
			var val_label: Label = Label.new()
			val_label.text = str(months_data[i])
			val_label.add_theme_font_size_override("font_size", 16)
			val_label.add_theme_color_override("font_color", Color(0.2, 0.4, 0.7))
			var pos: Vector2 = point_positions[i]
			val_label.position = Vector2(pos.x - 12, pos.y - 30)
			chart_draw.add_child(val_label)
	)
	
	# 强制刷新绘制
	chart_draw.queue_redraw()


func _get_short_weekday(date: Calendar.Date) -> String:
	var wd: int = date.get_weekday()
	var names: Array[String] = ["日", "一", "二", "三", "四", "五", "六"]
	return names[wd]
