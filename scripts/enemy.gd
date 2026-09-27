extends Area2D
## A fog creature. Drifts toward the lighthouse and dissolves if held in the beam.

signal burned
signal reached_lighthouse

@export var speed := 20.0
## Seconds the creature must stay in the beam before it dies. 0 = instant.
@export var burn_time := 0.3
@export var wobble_amount := 4.0
@export var wobble_speed := 3.0

var target := Vector2.ZERO

var _travel_pos := Vector2.ZERO  # position along the straight path, before wobble
var _time := 0.0
var _beams_touching := 0
var _burn := 0.0
var _dead := false


func _ready() -> void:
	_travel_pos = position
	_time = randf() * TAU
	area_entered.connect(func(area): if area.is_in_group("beam"): _beams_touching += 1)
	area_exited.connect(func(area): if area.is_in_group("beam"): _beams_touching -= 1)


func _process(delta: float) -> void:
	if _dead:
		return

	if _beams_touching > 0:
		_burn += delta
		if _burn >= burn_time:
			_die()
			return
	else:
		_burn = maxf(_burn - delta, 0.0)
	# Flash brighter the closer it is to burning up.
	modulate = Color.WHITE.lerp(Color(3, 3, 2.5), _burn / maxf(burn_time, 0.001))

	_time += delta
	_travel_pos = _travel_pos.move_toward(target, speed * delta)
	var side := (target - _travel_pos).normalized().orthogonal()
	position = _travel_pos + side * sin(_time * wobble_speed) * wobble_amount

	if _travel_pos.distance_to(target) < 12.0:
		_dead = true
		reached_lighthouse.emit()
		queue_free()


func _die() -> void:
	_dead = true
	burned.emit()
	set_deferred("monitoring", false)
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "scale", Vector2(1.8, 0.2), 0.15)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.chain().tween_callback(queue_free)
