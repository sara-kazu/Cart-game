extends SceneTree
var failures := 0
var checks := 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	var start: Vector2 = scene.kart_position
	for i in range(60):
		scene.step_kart(1.0 / 60, 1, 0, false)
	check(scene.kart_position.x > start.x + 40, "Throttle moves kart forward")
	check(scene.speed > 100, "Kart accelerates")
	var before: float = scene.heading
	for i in range(20):
		scene.step_kart(1.0 / 60, 1, 1, false)
	check(scene.heading > before + 0.1, "Steering rotates a moving kart")
	for i in range(120):
		scene.step_kart(1.0 / 60, 0, 0, true)
	check(is_zero_approx(scene.speed), "Brake stops kart")
	scene.kart_position = scene.CENTER
	scene.speed = 200
	scene.step_kart(0.1, 1, 0, false)
	check(not scene.on_road and scene.speed < 200, "Grass reduces speed")
	scene.reset_race()
	for i in range(1, 722):
		var a := -PI / 2 + TAU * i / 360.0
		scene.elapsed += 1.0 / 60
		scene.update_progress(scene.CENTER + Vector2(cos(a), sin(a)) * scene.RADII)
	check(scene.laps == 2, "Two clockwise circuits count two laps")
	check(scene.best_lap > 0, "Best lap recorded")
	scene.reset_race()
	for i in range(1, 362):
		var a := -PI / 2 - TAU * i / 360.0
		scene.update_progress(scene.CENTER + Vector2(cos(a), sin(a)) * scene.RADII)
	check(scene.laps == 0, "Reverse circuit cannot count a lap")
	scene.reset_race()
	for i in range(1, 362):
		var a := -PI / 2 + TAU * i / 360.0
		scene.update_progress(scene.CENTER + Vector2(cos(a), sin(a)) * scene.RADII * 0.4)
	check(scene.laps == 0, "Infield shortcut cannot count a lap")
	scene.reset_race()
	check(scene.laps == 0 and scene.elapsed == 0 and scene.speed == 0, "Restart clears race state")
	# Allow the actual scene's draw callbacks to execute as well.
	await process_frame
	await process_frame
	print("Smoke checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
