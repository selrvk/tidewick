extends Node2D
## The lighthouse beam. Turns toward the mouse and burns anything inside the cone.

@export var length := 130.0
@export var half_angle_deg := 14.0
## How fast the beam can swing, in radians per second. Lower = harder.
@export var turn_speed := 4.0
@export var color := Color("ffec27")  # PICO-8 yellow

@onready var light: Polygon2D = $Light
@onready var hitbox_shape: CollisionPolygon2D = $Hitbox/CollisionPolygon2D


func _ready() -> void:
	_build_cone()


func _process(delta: float) -> void:
	var target_angle := (get_global_mouse_position() - global_position).angle()
	rotation = rotate_toward(rotation, target_angle, turn_speed * delta)


## Builds the cone shape once, used for both the visible light and the hitbox.
func _build_cone() -> void:
	var half := deg_to_rad(half_angle_deg)
	var steps := 8
	var points := PackedVector2Array([Vector2.ZERO])
	var colors := PackedColorArray([Color(color, 0.85)])
	for i in steps + 1:
		var angle := lerpf(-half, half, float(i) / steps)
		points.append(Vector2.from_angle(angle) * length)
		colors.append(Color(color, 0.0))
	light.polygon = points
	light.vertex_colors = colors
	hitbox_shape.polygon = points
