class_name Transmitter
extends Node

var frequency = 1.5 * Aether.G * Aether.Hz
var power = 1
export(NodePath) var aether_path = null
var aether = null

func _ready():
	if self.aether_path:
		self.aether = get_node(self.aether_path)
		self.aether.register_transmitter(self)
