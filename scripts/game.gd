extends Node2D
## Runs the round: spawns fog creatures, tracks score and lives, handles game over.

const EnemyScene := preload("res://scenes/enemy.tscn")

@export var start_lives := 3
@export var spawn_interval_start := 2.5
@export var spawn_interval_min := 0.6
## Seconds taken off the spawn interval after each spawn.
@export var spawn_ramp := 0.04
@export var enemy_speed_start := 18.0
@export var enemy_speed_max := 45.0

var score := 0
var lives := 0
var is_over := false

@onready var lighthouse: Node2D = $Lighthouse
@onready var enemies: Node2D = $Enemies
@onready var spawn_timer: Timer = $SpawnTimer
@onready var score_label: Label = $UI/ScoreLabel
@onready var lives_label: Label = $UI/LivesLabel
@onready var game_over_label: Label = $UI/GameOverLabel


func _ready() -> void:
	lives = start_lives
	game_over_label.hide()
	spawn_timer.wait_time = spawn_interval_start
	spawn_timer.timeout.connect(_spawn_enemy)
	spawn_timer.start()
	_update_ui()


func _unhandled_input(event: InputEvent) -> void:
	if not is_over:
		return
	var pressed_r: bool = event is InputEventKey and event.pressed and event.keycode == KEY_R
	var clicked: bool = event is InputEventMouseButton and event.pressed
	if pressed_r or clicked:
		get_tree().reload_current_scene()


func _spawn_enemy() -> void:
	var enemy := EnemyScene.instantiate()
	enemy.position = _random_edge_point(12.0)
	enemy.target = lighthouse.get_node("HitPoint").global_position
	enemy.speed = minf(enemy_speed_start + score * 0.6, enemy_speed_max)
	enemy.burned.connect(_on_enemy_burned)
	enemy.reached_lighthouse.connect(_on_lighthouse_hit)
	enemies.add_child(enemy)

	spawn_timer.wait_time = maxf(spawn_timer.wait_time - spawn_ramp, spawn_interval_min)


## Picks a random point just outside the screen edge.
func _random_edge_point(margin: float) -> Vector2:
	var rect := get_viewport_rect().grow(margin)
	match randi() % 4:
		0: return Vector2(randf_range(rect.position.x, rect.end.x), rect.position.y)  # top
		1: return Vector2(randf_range(rect.position.x, rect.end.x), rect.end.y)       # bottom
		2: return Vector2(rect.position.x, randf_range(rect.position.y, rect.end.y))  # left
		_: return Vector2(rect.end.x, randf_range(rect.position.y, rect.end.y))       # right


func _on_enemy_burned() -> void:
	score += 1
	_update_ui()


func _on_lighthouse_hit() -> void:
	if is_over:
		return
	lives -= 1
	_update_ui()
	var tween := create_tween()
	tween.tween_property(lighthouse, "modulate", Color("ff004d"), 0.05)
	tween.tween_property(lighthouse, "modulate", Color.WHITE, 0.25)
	if lives <= 0:
		_game_over()


func _game_over() -> void:
	is_over = true
	spawn_timer.stop()
	enemies.process_mode = Node.PROCESS_MODE_DISABLED
	lighthouse.get_node("Beam").process_mode = Node.PROCESS_MODE_DISABLED
	game_over_label.text = "The light went out.\nScore: %d\n\nClick or press R to try again" % score
	game_over_label.show()


func _update_ui() -> void:
	score_label.text = "Score: %d" % score
	lives_label.text = "Lives: %d" % lives
