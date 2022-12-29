extends Sprite2D
signal shoot
signal debug

@export var velocity = Vector2(0,0)
@export var acceleration = 230
@export var rotationSpeed = 3
@export var maxSpeed = 300


func check_velocity():
	if velocity.length() > maxSpeed:
		velocity = velocity.normalized() * maxSpeed # TODO: slowly ramp it down instead...

func _process(delta):
	if Input.is_key_pressed(KEY_W):
		velocity += Vector2(0, -acceleration*delta).rotated(rotation)
		check_velocity()
	if Input.is_key_pressed(KEY_A):
		rotation -= rotationSpeed*delta
	if Input.is_key_pressed(KEY_D):
		rotation += rotationSpeed*delta
	

		
	position += velocity * delta
	
	if Input.is_key_pressed(KEY_SPACE):
		emit_signal("shoot", 1500, null)
	if Input.is_key_pressed(KEY_ENTER):
		emit_signal("debug")

