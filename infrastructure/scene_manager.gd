extends Node

var current_scene = "res://infrastructure/menus/main_menu.tscn"

func goto_scene(var s):
	current_scene = s
	get_tree().change_scene(s)

func reload_scene():
	goto_scene(current_scene)

func goto_main_menu():
	goto_scene("res://infrastructure/menus/main_menu.tscn")

func goto_prototypes_menu():
	goto_scene("res://infrastructure/menus/prototypes_menu.tscn")

func goto_interactions_prototype():
	goto_scene("res://levels/prototypes/interactions.tscn")
