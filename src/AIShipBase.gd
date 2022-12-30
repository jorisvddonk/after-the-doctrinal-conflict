extends "res://ShipBase.gd"

var PIDController = load("res://PIDController.gd")

var distancePID = PIDController.new(-0.45, -0.2, -80, -10, 10, -10, 10)
const OFFSET_ALLOWED = 0.0872664626 # 5 degrees
const SHOOT_OFFSET_ALLOWED = OFFSET_ALLOWED * 0.1

var P1
var P2
var intercepting
var selfShootVec
var selfRelShootVec
var targetRelVec

var debugpoints = []
var debuglines = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)

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
	super()

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
