class_name Aether
extends Node

const Hz = 1
const W = 1
const m = 0.001
const u = 0.001 * m
const n = 0.001 * u
const K = 1000
const M = 1000 * K
const G = 1000 * M

var transmitters = []
var receivers = []
var receivers_per_transmitter = {}
var frequency_smear = 0.1
var base_distance_squared = 10
var timer = null

func _ready():
	self.timer = $Timer
	self.timer.wait_time = 1
	self.timer.connect("timeout", self, "tick")
	self.timer.start()
	debug_info.log("timer", timer.is_stopped())

func frequency_matching(tx, rx):
	var freq_smear_size = self.frequency_smear*tx.frequency
	var freq_delta = abs(rx.frequency - tx.frequency)
	var freq_delta_frac = freq_delta / freq_smear_size
	var freq_match = clamp(1 - freq_delta_frac, 0, 1)
	return freq_match

func register_transmitter(tx):
	self.transmitters.push_back(tx)
	var freq_match = 0
	self.receivers_per_transmitter[tx] = []
	for rx in self.receivers:
		freq_match = self.frequency_matching(tx, rx)
		debug_info.log("freq match", freq_match)
		if freq_match > 0:
			self.receivers_per_transmitter[tx].push_back(rx)

func register_receiver(rx):
	self.receivers.push_back(rx)
	var freq_match = 0
	for tx in self.transmitters:
		freq_match = self.frequency_matching(tx, rx)
		debug_info.log("freq match", freq_match)
		if freq_match > 0:
			self.receivers_per_transmitter[tx].push_back(rx)

func tick():
	var freq_match = 0
	var strength = 0
	var distance_squared = 0
	for tx in self.transmitters:
		for rx in self.receivers_per_transmitter[tx]:
			freq_match = self.frequency_matching(tx, rx)
			distance_squared = (tx.global_transform.origin - rx.global_transform.origin).length_squared()
			if distance_squared > 0:
				strength = freq_match*tx.power*base_distance_squared/distance_squared
			rx.detect_signal_from(tx, strength)
