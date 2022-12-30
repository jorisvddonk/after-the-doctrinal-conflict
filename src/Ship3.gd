extends "res://AIShipBase.gd"

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
	selfShootVec = (Vector2(0, -self.shootBaseSpeed).rotated(rotation))
	selfRelShootVec = targetRelVec * 1 + (Vector2(0, -self.shootBaseSpeed).rotated(rotation))
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
			try_shoot()

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
		
	super(delta)
