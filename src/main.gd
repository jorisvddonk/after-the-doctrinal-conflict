extends Node2D

var Bullet = load("res://Bullet.tscn")
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	$PlayerShip.shoot.connect(_on_Ship_shoot.bind($PlayerShip))
	$PlayerShip.debug.connect(_on_Debug)
	#$Ship.shoot.connect(_on_Ship_shoot.bind($Ship))
	#$Ship2.shoot.connect(_on_Ship_shoot.bind($Ship2))
	$Ship3.shoot.connect(_on_Ship_shoot.bind($Ship3))

func _on_Ship_shoot(shotBaseSpeed, targetpos, ship):
	var bullet = Bullet.instantiate()
	var rot = ship.rotation
	if targetpos != null:
		rot = Vector2.UP.angle_to(targetpos - ship.position)
	bullet.set_velocity((ship.velocity * 1) + Vector2(0, -shotBaseSpeed).rotated(rot))
	bullet.position = ship.position
	bullet.rotation = ship.rotation
	add_child(bullet)

func _on_Debug():
	#$Ship2.rotation = rng.randf_range(-10.0, 10.0)
	$Ship3.rotation = rng.randf_range(-10.0, 10.0)
