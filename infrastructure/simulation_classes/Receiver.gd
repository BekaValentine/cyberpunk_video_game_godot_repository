class_name Receiver
extends Node

var frequency = 1.5 * Aether.G * Aether.Hz
var sensitivity = 1 * Aether.m * Aether.W
export(NodePath) var aether_path = null
var aether = null

func _ready():
	if self.aether_path:
		self.aether = get_node(self.aether_path)
		self.aether.register_receiver(self)

func detect_signal_from(transmitter, strength):
	debug_info.log("received signal", [transmitter, strength, sensitivity, randf()])
