extends Node2D

signal shoot

@export var velocity = Vector2(150,0)
@export var acceleration = 230
@export var rotationSpeed = 0.015
@export var maxSpeed = 300
@export var showDebugInfo = false
@export var shootBaseSpeed = 1000
@export var battMax = 16
@export var battRegen = 2
@export var shotBatt = 1
@export var shotCooldown = 0.1

var batt = battMax
var try_shooting = false
var primaryCooldown = 0

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta
	batt = min(battMax, batt + (battRegen * delta))
	primaryCooldown = max(0, primaryCooldown - delta)
	if try_shooting:
		if primaryCooldown <= 0:
			try_shooting = false
			if batt > shotBatt:
				batt = max(0, batt - shotBatt)
				primaryCooldown = shotCooldown
				emit_signal("shoot", shootBaseSpeed, null)
	queue_redraw()

func turn_to(targetPos, angle_mod):
		var turn_angle = Vector2.UP.rotated(rotation).angle_to(targetPos - self.position)
		var turn_angle_c = clamp(turn_angle, -PI * rotationSpeed, PI * rotationSpeed) as float
		if !is_nan(turn_angle):
			rotation += turn_angle_c * angle_mod
			return turn_angle_c

func _draw():
	draw_set_transform(Vector2.ZERO, get_global_transform().inverse().get_rotation(), Vector2.ONE) # undo global rotation
	draw_line(Vector2(-20, 20), Vector2(20, 20), Color(0.25,0,0,1), 5.0)
	draw_line(Vector2(-20, 20), Vector2(-20 + ((batt * 40) / battMax), 20), Color(1,0,0,1), 5.0)

func thrust(vel, delta):
	velocity += Vector2(0, -acceleration*delta*vel).rotated(rotation)

func rotate_(angle: float):
	rotation += clamp(angle, -PI * rotationSpeed, PI * rotationSpeed) as float

func try_shoot():
	try_shooting = true;
