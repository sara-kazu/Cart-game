extends Node2D

const CENTER := Vector2(480, 315)
const RADII := Vector2(350, 175)
const ROAD_HALF_WIDTH := 39.0
const MAX_SPEED := 245.0
const GRASS_SPEED := 85.0
const SEGMENTS := 96
var kart_position := Vector2.ZERO
var heading := 0.0
var speed := 0.0
var laps := 0
var next_gate := 0
var previous_angle := -PI / 2.0
var elapsed := 0.0
var lap_started := 0.0
var best_lap := 0.0
var paused := false
var on_road := true
var hud: Label
var status: Label
var kart: Node2D

# Static scenery is drawn once into this node. Only the kart and HUD update.
class Scenery extends Node2D:
	var race: Node2D
	func _draw() -> void:
		race.draw_course(self)

class Kart extends Node2D:
	func _draw() -> void:
		draw_rect(Rect2(-9, -5, 22, 14), Color("243a35"))
		for offset in [Vector2(-7, -9), Vector2(7, -9), Vector2(-7, 5), Vector2(7, 5)]:
			draw_rect(Rect2(offset, Vector2(6, 4)), Color("17252c"))
		draw_rect(Rect2(-11, -6, 22, 12), Color("bb3545"))
		draw_rect(Rect2(-8, -6, 16, 9), Color("f96857"))
		draw_rect(Rect2(6, -4, 6, 8), Color("ffe2a0"))
		draw_rect(Rect2(-10, -8, 3, 16), Color("fff1ce"))
		draw_circle(Vector2(-2, 0), 5, Color("202d49"))
		draw_rect(Rect2(-4, -4, 5, 4), Color("94d8db"))

func _ready() -> void:
	var scenery := Scenery.new()
	scenery.race = self
	add_child(scenery)
	kart = Kart.new()
	add_child(kart)
	hud = Label.new()
	hud.position = Vector2(28, 18)
	hud.add_theme_font_size_override("font_size", 20)
	add_child(hud)
	status = Label.new()
	status.position = Vector2(28, 548)
	status.add_theme_font_size_override("font_size", 16)
	add_child(status)
	reset_race()

func reset_race() -> void:
	kart_position = CENTER + Vector2(0, -RADII.y)
	heading = 0.0
	speed = 0.0
	laps = 0
	next_gate = 0
	previous_angle = -PI / 2.0
	elapsed = 0.0
	lap_started = 0.0
	best_lap = 0.0
	paused = false
	on_road = true
	refresh_display()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			reset_race()
		elif event.keycode == KEY_ESCAPE:
			paused = not paused
			refresh_display()

func _physics_process(delta: float) -> void:
	if paused:
		return
	var throttle := float(Input.is_physical_key_pressed(KEY_UP) or Input.is_physical_key_pressed(KEY_W))
	throttle -= float(Input.is_physical_key_pressed(KEY_DOWN) or Input.is_physical_key_pressed(KEY_S))
	var steer := float(Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_D))
	steer -= float(Input.is_physical_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_A))
	step_kart(delta, throttle, steer, Input.is_physical_key_pressed(KEY_SPACE))
	refresh_display()

func road_distance(point: Vector2) -> float:
	# Distance to the sampled centreline works on both straight-looking sides and bends.
	var closest := INF
	var a := CENTER + Vector2(RADII.x, 0)
	for i in range(1, SEGMENTS + 1):
		var angle := TAU * float(i) / SEGMENTS
		var b := CENTER + Vector2(cos(angle), sin(angle)) * RADII
		closest = minf(closest, point.distance_to(Geometry2D.get_closest_point_to_segment(point, a, b)))
		a = b
	return closest

func step_kart(delta: float, throttle: float, steer: float, braking: bool) -> void:
	elapsed += delta
	on_road = road_distance(kart_position) <= ROAD_HALF_WIDTH
	var limit := MAX_SPEED if on_road else GRASS_SPEED
	if braking:
		speed = move_toward(speed, 0, 360 * delta)
	elif throttle != 0:
		speed = move_toward(speed, limit if throttle > 0 else -limit * 0.38, 125 * delta)
	else:
		speed = move_toward(speed, 0, 48 * delta)
	if absf(speed) > limit:
		speed = move_toward(speed, signf(speed) * limit, 270 * delta)
	heading += steer * 2.4 * clampf(speed / 105.0, -1, 1) * delta
	kart_position += Vector2.from_angle(heading) * speed * delta
	var bounded := kart_position.clamp(Vector2(18, 104), Vector2(942, 518))
	if bounded != kart_position:
		speed *= 0.5
	kart_position = bounded
	update_progress(kart_position)

func update_progress(point: Vector2) -> void:
	var normalized := (point - CENTER) / RADII
	var angle := normalized.angle()
	var movement := wrapf(angle - previous_angle, -PI, PI)
	# Visit east, south, west, then the start line, clockwise and on the road.
	var target := -PI / 2.0 + (next_gate + 1) * PI / 2.0
	var to_gate := wrapf(target - previous_angle, 0, TAU)
	if movement > 0 and movement < PI / 3.0 and to_gate <= movement and road_distance(point) <= ROAD_HALF_WIDTH:
		next_gate += 1
		if next_gate == 4:
			laps += 1
			var duration := elapsed - lap_started
			if best_lap == 0 or duration < best_lap:
				best_lap = duration
			lap_started = elapsed
			next_gate = 0
	previous_angle = angle

func refresh_display() -> void:
	kart.position = kart_position
	kart.rotation = heading
	var best := "--:--" if best_lap == 0 else "%.2fs" % best_lap
	hud.text = "POCKET KART    /    MEADOW LOOP\nLAP  %02d     TIME  %05.1f     BEST  %s     SPEED  %03d" % [laps + 1, elapsed - lap_started, best, roundi(absf(speed))]
	status.text = "ARROWS / WASD  Drive     SPACE  Brake     R  Restart     ESC  Pause"
	if paused:
		status.text = "PAUSED   /   ESC to resume"
	elif not on_road:
		status.text += "     GRASS!"

func ellipse_points(radii: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(SEGMENTS + 1):
		var angle := TAU * float(i) / SEGMENTS
		points.append(CENTER + Vector2(cos(angle), sin(angle)) * radii)
	return points

func draw_course(canvas: Node2D) -> void:
	canvas.draw_rect(Rect2(0, 96, 960, 438), Color("669650"))
	for y in range(110, 530, 24):
		for x in range(8, 960, 32):
			canvas.draw_rect(Rect2(x + (y % 5), y, 3, 2), Color("83ad63"))
	canvas.draw_polyline(ellipse_points(RADII), Color("354c3d"), 94, false)
	canvas.draw_polyline(ellipse_points(RADII), Color("eee0b4"), 86, false)
	canvas.draw_polyline(ellipse_points(RADII), Color("56616a"), 76, false)
	for i in range(48):
		var a := TAU * float(i) / 48
		var b := a + 0.045
		canvas.draw_line(CENTER + Vector2(cos(a), sin(a)) * RADII, CENTER + Vector2(cos(b), sin(b)) * RADII, Color("a2aca1"), 2, false)
	# Red/cream kerbs on the four bends.
	for side in [-1, 1]:
		var radii: Vector2 = RADII + Vector2(41, 41) * side
		for i in range(SEGMENTS):
			var a := TAU * float(i) / SEGMENTS
			var b := TAU * float(i + 1) / SEGMENTS
			var color := Color("e87561") if i % 2 == 0 else Color("f5e8c7")
			canvas.draw_line(CENTER + Vector2(cos(a), sin(a)) * radii, CENTER + Vector2(cos(b), sin(b)) * radii, color, 5, false)
	for row in range(8):
		for col in range(2):
			canvas.draw_rect(Rect2(477 + col * 6, 102 + row * 9, 6, 9), Color("fff4d2") if (row + col) % 2 == 0 else Color("253342"))
	# Infield pond, islands and a compact pixel grandstand.
	canvas.draw_colored_polygon(PackedVector2Array([Vector2(360, 300), Vector2(392, 266), Vector2(508, 266), Vector2(552, 294), Vector2(532, 340), Vector2(398, 348)]), Color("477b78"))
	canvas.draw_rect(Rect2(408, 280, 112, 5), Color("77b6a5"))
	for x in [280, 620, 666]:
		canvas.draw_rect(Rect2(x - 3, 315, 6, 22), Color("705b42"))
		canvas.draw_rect(Rect2(x - 13, 290, 26, 27), Color("335e46"))
		canvas.draw_rect(Rect2(x - 9, 286, 18, 20), Color("48794e"))
	canvas.draw_rect(Rect2(405, 390, 150, 29), Color("384858"))
	for row in range(3):
		for col in range(15):
			canvas.draw_rect(Rect2(410 + col * 9, 394 + row * 7, 5, 4), Color("efbf73") if (row + col) % 3 == 0 else Color("82afa3"))
