extends Node3D

@export var planetScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	# generate planets
	for i in range(10):
		var object = planetScene.instantiate()
		object.orbitRadius = i * 80 + 40
		object.orbitSpeed = 0#randf_range(0.1, 0.4)
		object.name = "planet " + str(i)
		call_deferred("add_child",object)
		
		# connect area signals
		var area3D: Area3D
		for child in object.get_children():
			if child is Area3D:
				area3D = child
		
		var player = get_parent().get_node("cameraController/playerShip")
		
		area3D.connect("body_entered", player.on_enter_planet_area.bind(object))
		area3D.connect("body_exited", player.on_exit_planet_area.bind(object))
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
