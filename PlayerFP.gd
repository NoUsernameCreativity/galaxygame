extends CharacterBody3D

@export var DEBUG = false

const SPEED = 1
const MAX_SPEED = 3
const JUMP_VELOCITY = 4
const mouseSensitivity = 0.005

var gravityStrength = 0.2

var cameraRotation = Vector2.ZERO

var planetNode: Node3D = null

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var gravityDirNormal = Vector3.UP
	if planetNode != null:
		gravityDirNormal = (planetNode.position - self.position).normalized()
	
	up_direction = -gravityDirNormal
	
	# get separation vector (to rotate along)
	var separationAxis = basis.y.cross(-gravityDirNormal).normalized()
	# angle between vectors (using dot(a,b)=|a||b|cos(theta))
	var separationAngle = acos(clamp(-gravityDirNormal.dot(basis.y), -1, 1))
	# rotate basis along this axis by this angle to fix the rotation
	if separationAxis != Vector3.ZERO:
		var targetBasis = basis.rotated(separationAxis, separationAngle)
		basis = basis.orthonormalized()
		#assert(basis == basis.orthonormalized(), "basis not normalized: " + str(basis) + ". Target basis " + str(targetBasis))
		basis = basis.slerp(targetBasis, 0.6)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var inputDir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var inputUpDown = Input.get_axis("move_down", "move_up")
	var direction = (self.basis * Vector3(inputDir.x, 0, inputDir.y).rotated(Vector3.UP, cameraRotation.x)).normalized()
	if DEBUG:
		direction = ($camera.basis * Vector3(inputDir.x, inputUpDown, inputDir.y)).normalized()
	
	# deal with input
	if direction != Vector3.ZERO:
		var testVelocity = velocity + direction * SPEED
		# use max velocity
		var velocityTowardsPlanet = VectorResolute(testVelocity, -self.basis.y)
		var velocityPerpendicularToPlanet = testVelocity - velocityTowardsPlanet
		# clamp motion side to side (not jump) to max speed
		velocityPerpendicularToPlanet =  velocityPerpendicularToPlanet.normalized() * clamp(velocityPerpendicularToPlanet.length(), 0, MAX_SPEED)
		# set final velocity
		velocity = velocityTowardsPlanet + velocityPerpendicularToPlanet
	else:
		# slows down movement but not in gravity dir.
		velocity = velocity.move_toward(Vector3.ZERO+VectorResolute(velocity, -self.basis.y), SPEED)
	
	if Input.is_action_just_pressed("fp_jump") and is_on_floor():
		velocity += (self.basis.y * JUMP_VELOCITY)
	
	velocity -= self.basis.y * gravityStrength
	
	move_and_slide()
	
	# lock camera rotation so player can't look upside down and get confused
	cameraRotation.y = clamp(cameraRotation.y, -PI/2, PI/2)

func VectorResolute(vectorToProject, projectOnto) -> Vector3:
	var projectOntoNormalised = projectOnto.normalized()
	return (vectorToProject.dot(projectOntoNormalised)) * projectOntoNormalised

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		cameraRotation += Vector2(-event.relative.x, -event.relative.y) * mouseSensitivity
		$camera.rotation = Vector3(cameraRotation.y, cameraRotation.x, 0)

