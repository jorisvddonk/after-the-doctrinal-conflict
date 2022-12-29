extends Node2D

signal shoot

var Bullet = load("res://Bullet.tscn")
var PIDController = load("res://PIDController.gd")

var distancePID = PIDController.new(-0.45, -0.2, -80, -10, 10, -10, 10)
const OFFSET_ALLOWED = 0.0872664626 # 5 degrees
const SHOOT_OFFSET_ALLOWED = OFFSET_ALLOWED * 0.1

@export var velocity = Vector2(150,0)
@export var acceleration = 230
@export var rotationSpeed = 0.015
@export var maxSpeed = 300
@export var showDebugInfo = false
@export var shootBaseSpeed = 1000

var P1
var P2
var intercepting
var selfShootVec
var selfRelShootVec
var targetRelVec

var debugpoints = []
var debuglines = []

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target : Node2D = self.owner.get_node("PlayerShip")
	var tgtError = target.position - position
	distancePID.setError(tgtError.length())
	distancePID.step()
	var isFacingTarget = position.direction_to(target.position).dot(Vector2.UP.rotated(rotation)) > 0.5
	
	
	
	# Determine if we need to lead our shot more, or lag our shot more:
	# Take our current "shooting angle" as an infinite line, and intersect it with the target ship's motion vector. This is point P1
	# Then, calculate how many seconds it takes for our shot to arrive at point P1.
	# Next, determine where the target would be at that time. This is point P2.
	# Calculate the distance P1 and P2. If this is smaller than the target's diameter, shoot!
	# Calculate the distance between the target and P1 (DPT1), and the distance between the target and P2 (DPT2).
	# If DPT1 > DPT2, our shot is 'leading'
	# If DPT2 > DPT1, our shot is 'trailing' (lagging)
	# Regardless of leading of lagging, we turn towards P2.
	
	var targetPos = target.position
	var targetRelPos = target.position - position
	var targetVec = target.velocity
	targetRelVec = target.velocity - velocity
	selfShootVec = (Vector2(0, -shootBaseSpeed).rotated(rotation))
	selfRelShootVec = targetRelVec * 1 + (Vector2(0, -shootBaseSpeed).rotated(rotation))
	var is_truly_stationary = false
	var forwards = Vector2.UP.rotated(rotation)
	
	if targetVec.length() == 0:
		is_truly_stationary = true
		targetVec = Vector2.UP.normalized() * 0.1
	
	P1 = self.intersect(position, selfShootVec * 1000, targetPos, targetVec * 1000)
	if P1 != null:
		intercepting = false
		var secondsUntilShotAtP1 = (P1 - position).length() / selfShootVec.length() # we can only do this because we know P1 is on our shoot vector
		var P2_rel = (targetRelVec * secondsUntilShotAtP1) # P2, but relative to the target ship's own center (as origin)
		P2 = P2_rel + targetPos
		var z = abs((P1 - P2).length())
		var moveCorrection = self.turn_to(P2, 1)
		var angleBetween = forwards.angle_to(selfShootVec)
		var shootVectorOffsetToTargetVec = targetRelPos - ((targetRelPos.dot(selfShootVec) / (selfShootVec.length() * selfShootVec.length())) * selfShootVec)
		debuglines.push_front(shootVectorOffsetToTargetVec)
		# when z is small, it's pretty much a guaranteed hit; when shootVectorOffsetToTargetVec.length() is small, it's not guaranteed but possible.
		if secondsUntilShotAtP1 > 0 && (z < 1 || shootVectorOffsetToTargetVec.length() < 60):
			emit_signal("shoot", shootBaseSpeed, null)

	else:
		P2 = null
		intercepting = true
		# just turn towards the player so we get a better angle on them...
		# use the interception function!
		var targetIntercept = self.intercept(position, selfShootVec.length(), targetPos, targetVec)
		P1 = targetIntercept
		self.turn_to(targetIntercept, 1)
		
	if isFacingTarget && distancePID.getError() < -70:
		self.thrust(1, delta)
		
	position += velocity * delta
	queue_redraw() # redraw

func turn_to(targetPos, angle_mod):
		var turn_angle = Vector2.UP.rotated(rotation).angle_to(targetPos - self.position)
		var turn_angle_c = clamp(turn_angle, -PI * rotationSpeed, PI * rotationSpeed) as float
		if !is_nan(turn_angle):
			rotation += turn_angle_c * angle_mod
			return turn_angle_c
	
func intersect(pos1, vec1, pos3, vec3):
	var pos2 = pos1 + vec1
	var pos4 = pos3 + vec3
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

	if (ua < 0): # if the point is behind pos1->pos2, ignore
		return null

	return Vector2(x1 + ua * (x2 - x1), y1 + ua * (y2 - y1))  

func thrust(vel, delta):
	#pass # temporarily disabled
	velocity += Vector2(0, -acceleration*delta*vel).rotated(rotation)

func rotate_(angle: float):
	rotation += clamp(angle, -PI * rotationSpeed, PI * rotationSpeed) as float

func _draw():
	if showDebugInfo:
		var inv = get_global_transform().inverse()
		var forwards = Vector2.UP.rotated(rotation)
		if selfShootVec != null:
			draw_set_transform(Vector2.ZERO, inv.get_rotation(), Vector2.ONE) # undo global rotation
			draw_line(Vector2.ZERO, selfShootVec, Color(0,1,0,0.25), 2.0)
		if P1 != null:
			draw_set_transform(inv.origin, inv.get_rotation(), Vector2.ONE) # undo global rotation and position
			draw_circle(P1, 30, Color(1,1,0,0.25) if intercepting else Color(0,1,0,0.25))
			if P2 != null:
				draw_circle(P2, 5, Color(0, 0.4, 0, 0.7))
				draw_circle(P1, 3, Color(0, 0, 0, 0.4))
		if selfShootVec != null:
			draw_set_transform(Vector2.ZERO, inv.get_rotation(), Vector2.ONE) # undo global rotation
			draw_line(Vector2.ZERO, forwards * 1000, Color(0, 1, 1, 0.25), 2.0)
			draw_line(Vector2.ZERO, targetRelVec, Color(0, 0, 0, 0.25), 2.0)
			draw_line(Vector2.ZERO, forwards * distancePID.getError(), Color(0, 0, 1, 0.25), 2.0)
		
		if debugpoints.size() > 0:
			draw_set_transform(Vector2.ZERO, inv.get_rotation(), Vector2.ONE) # undo global rotation
			print(debugpoints)
			for pt in debugpoints:
				draw_circle(pt, 10, Color(1,1,1,1))
			debugpoints.clear()
			
		if debuglines.size() > 0:
			draw_set_transform(Vector2.ZERO, inv.get_rotation(), Vector2.ONE) # undo global rotation
			print(debuglines)
			for pl in debuglines:
				draw_line(Vector2.ZERO, pl, Color(1,1,1,1), 2.0)
			debuglines.clear()

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
