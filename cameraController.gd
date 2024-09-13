extends Node3D

@onready var playerFP = $playerFP
@onready var playerShip = $playerShip

const remountShipDistanceThreshold = 10

var shipView = true

# Called when the node enters the scene tree for the first time.
func _ready():
	# disable at beginning (ship first)
	playerFP.set_process_mode(self.PROCESS_MODE_DISABLED)
	playerFP.hide()
	$playerShip/camera.current = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ship_dismount"):
		if shipView:
			if playerShip.canDismount:
				playerFP.position = playerShip.get_node("rigidbody").position 
				playerFP.show()
				playerFP.set_process_mode(self.PROCESS_MODE_INHERIT)
				playerShip.controlsEnabled = false
				$playerFP/camera.current = true
				playerFP.planetNode = playerShip.currentPlanetArea
				shipView = false
		else:
			if (playerFP.position-$playerShip/rigidbody.position).length() < remountShipDistanceThreshold:
				playerFP.hide()
				playerFP.set_process_mode(self.PROCESS_MODE_DISABLED)
				playerShip.controlsEnabled = true
				$playerShip/camera.current = true
				shipView = true
	pass
