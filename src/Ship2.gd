extends Node2D

signal shoot

var Bullet = load("res://Bullet.tscn")

const OFFSET_ALLOWED = 0.0872664626 # 5 degrees
const SHOOT_OFFSET_ALLOWED = OFFSET_ALLOWED * 0.1
const SHOT_BASE_SPEED = 700

var velocity = Vector2(0,0)
@export var acceleration = 230
@export var rotationSpeed = 0.007
@export var maxSpeed = 300

var P1
var P2
var intercepting

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target : Node2D = self.owner.get_node("PlayerShip")
	var possible_bullet_velocity = velocity.length() + SHOT_BASE_SPEED
	
	# Determine if we need to lead our shot more, or lag our shot more:
	# Take our current "shooting angle" as an infinite line, and intersect it with the target ship's motion vector. This is point P1
	# Then, calculate how many seconds it takes for the target ship to arrive at point P1.
	# Next, determine where our own shot would be at that time. This is point P2.
	# Calculate the distance between our own ship and points P1 and P2. This will be DPT1 and DPT2.
	# If DPT1 > DPT2, our shot is 'trailing' (lagging)
	# If DPT2 > DPT1, our shot is 'leading'
	# When leading, we need to rotate towards target.
	# When lagging, we need to rotate away from target.
	
	var selfShootVec = Vector2(0, -possible_bullet_velocity).rotated(rotation)
	var targetPos = target.position
	var targetVec = target.velocity
	var is_truly_stationary = false
	
	if targetVec.length() == 0:
		is_truly_stationary = true
		targetVec = Vector2.UP.normalized() * 0.1
	
	P1 = self.intersect(position, selfShootVec, targetPos, targetVec)
	if P1 != null:
		intercepting = false
		var secondsUntilTargetAtP1 = (P1 - targetPos).length() / targetVec.length() # we can only do this because we know P1 is on the velocity vector
		var P2_rel = (selfShootVec * secondsUntilTargetAtP1) # P2, but relative to this ship's own center (as origin)
		P2 = P2_rel + self.position
		var DPT1 = (P1 - self.position).length()
		var DPT2 = (P2 - self.position).length()
		if DPT1 > DPT2:
				print("lagging, rotate away from target")
				self.turn_to(targetPos, -1)
		if DPT2 > DPT1:
				print("leading, rotate towards target")
				self.turn_to(targetPos, 1)
		var z = abs(DPT1 - DPT2)
		if z < 30:
			emit_signal("shoot", SHOT_BASE_SPEED, P1)
			
	else:
		intercepting = true
		# just turn towards the player so we get a better angle on them...
		# use the interception function!
		var targetIntercept = self.intercept(position, possible_bullet_velocity, targetPos, targetVec)
		P1 = targetIntercept
		self.turn_to(targetIntercept, 1)
		
	# TODO: thrust....
	
	queue_redraw() # redraw

func turn_to(targetPos, angle_mod):
		var turn_angle = Vector2.UP.rotated(rotation).angle_to(targetPos - self.position)
		var turn_angle_c = clamp(turn_angle, -PI * rotationSpeed, PI * rotationSpeed) as float
		if !is_nan(turn_angle):
			rotation += turn_angle_c * angle_mod
	
func intersect(pos1, vec1, pos3, vec3):
	var pos2 = pos1 + (vec1.normalized() * 1000)
	var pos4 = pos3 + (vec3.normalized() * 1000)
	var x1 = pos1.x
	var y1 = pos1.y
	var x2 = pos2.x
	var y2 = pos2.y
	var x3 = pos3.x
	var y3 = pos3.y
	var x4 = pos4.x
	var y4 = pos4.y
	
	if ((x1 == x2 && y1 == y2) || (x3 == x4 && y3 == y4)):
		return null

	var denominator = ((y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1))

	if (denominator == 0):
		return null # parallel lines

	var ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denominator
	var ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denominator

	if (ua < 0 || ua > 1 || ub < 0 || ub > 1):
		return null # line is outside of the line segments defined by pos1-pos2 and pos3-pos4

	return Vector2(x1 + ua * (x2 - x1), y1 + ua * (y2 - y1))  

func thrust(vel, delta):
	#pass # temporarily disabled
	velocity += Vector2(0, -acceleration*delta*vel).rotated(rotation)

func rotate_(angle: float):
	rotation += clamp(angle, -PI * rotationSpeed, PI * rotationSpeed) as float

func _draw():
	var inv = get_global_transform().inverse()
	#if thrust_vec != null:
#		draw_set_transform(Vector2.ZERO, inv.get_rotation(), Vector2.ONE) # undo global rotation
#		draw_line(Vector2.ZERO, thrust_vec, Color.BLUE, 2.0)
	if P1 != null:
		draw_set_transform(inv.origin, inv.get_rotation(), Vector2.ONE) # undo global rotation and position
		draw_circle(P1, 10, Color.CYAN if intercepting else Color.BLUE)
		if P2 != null:
			draw_circle(P2, 5, Color.BLUE)

func intercept(shooter: Vector2, bullet_speed: float, target: Vector2, target_velocity: Vector2):
	var displacement = shooter - target
	var a = bullet_speed * bullet_speed - target_velocity.dot(target_velocity)
	var b = -2 * target_velocity.dot(displacement)
	var c = -displacement.dot(displacement)
	var lrg = largest_root_of_quadratic_equation(a, b, c)
	if lrg == NAN or lrg == null:
		return null
	else:
		var interception_world = target + (target_velocity * lrg)
		return interception_world

func largest_root_of_quadratic_equation(a, b, c):
	return (b + sqrt(b * b - 4 * a * c)) / (2 * a)
