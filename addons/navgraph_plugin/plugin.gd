tool
extends EditorPlugin

var NavBridgeLink = preload("res://addons/navgraph_plugin/NavBridgeLink.gd")
var NavBridgeLinkGizmo = preload("res://addons/navgraph_plugin/NavBridgeLinkGizmo.gd")
var NavSpace = preload("res://addons/navgraph_plugin/NavSpace.gd")
var NavStitchLink = preload("res://addons/navgraph_plugin/NavStitchLink.gd")

var add_bridge_link_button
var add_nav_space_button
var add_stitch_link_button
var dock = preload("res://addons/navgraph_plugin/dock.tscn").instance()
var nav_bridge_link_gizmo = NavBridgeLinkGizmo.new()
var selection

func _ready():
	# add_custom_type("NavSpace", "Area", NavSpace, null)
	# add_custom_type("NavBridgeLink", "Spatial", NavBridgeLink, null)

	self.connect("scene_changed", self, "scene_changed")
	
	selection = get_editor_interface().get_selection()
	selection.connect("selection_changed", self, "selection_changed")

	add_nav_space_button = dock.get_node("AddNavSpaceButton")
	add_nav_space_button.disabled = false
	add_nav_space_button.connect("pressed", self, "add_nav_space")

	add_bridge_link_button = dock.get_node("AddBridgeLinkButton")
	add_bridge_link_button.disabled = true
	add_bridge_link_button.connect("pressed", self, "add_bridge_link")
	
	add_stitch_link_button = dock.get_node("AddStitchLinkButton")
	add_stitch_link_button.disabled = true
	add_stitch_link_button.connect("pressed", self, "add_stitch_link")

	attach_nodes()

func scene_changed(scene_root):
	attach_nodes()

func _enter_tree():
	dock.visible = true
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, dock)
	add_spatial_gizmo_plugin(nav_bridge_link_gizmo)

func _exit_tree():
	dock.queue_free()
	remove_spatial_gizmo_plugin(nav_bridge_link_gizmo)

func selection_changed():
	var selected = selection.get_selected_nodes()

	if len(selected) == 1 and selected[0] is NavSpace:
		add_bridge_link_button.disabled = true
		add_stitch_link_button.disabled = false
	
	elif len(selected) == 2 and selected[0] is NavSpace and selected[1] is NavSpace:
		add_bridge_link_button.disabled = false
		add_stitch_link_button.disabled = true
	
	else:
		add_bridge_link_button.disabled = true
		add_stitch_link_button.disabled = true





################ Attach Nodes ################

func attach_nodes():
	var nodes = [get_editor_interface().get_edited_scene_root()]
	var node
	while len(nodes) > 0:
		# print(nodes)
		node = nodes.pop_back()
		if node == null:
			continue

		if node is NavSpace or\
			node is NavBridgeLink or\
			node is NavStitchLink:

			node.plugin = self

		for c in node.get_children():
			nodes.push_back(c)




################ Nav Spaces ################

func add_nav_space():
	# print("Adding nav space")
	var space = NavSpace.new()
	space.name = "NavSpace"
	space.plugin = self

	var scene_root = get_editor_interface().get_edited_scene_root()
	scene_root.add_child(space, true)
	space.owner = scene_root

func space_may_delete(s):
	print("Space may delete: ", s)
	var bridge_links = []
	for np in s.bridge_links:
		bridge_links.push_back(s.get_node_or_null(np))

	var stitch_links = []
	for np in s.stitch_links:
		stitch_links.push_back(s.get_node_or_null(np))

	yield(get_tree().create_timer(0.1), "timeout")

	if s != null and s.get_parent() != null:
		# we haven't deleted the node, it just moved
		print("Space did not delete.")
		return
	
	# we must have deleted the node
	print("Space did delete.")
	
	delete_bridge_links(bridge_links)
	delete_stitch_links(stitch_links)

func delete_stitch_links(ls):
	print("Deleting stitch links: ", ls)
	# stitch links are only know by their now-deleted space, so we can
	# just delete the links from their parents
	for l in ls:
		if l != null:
			l.get_parent().remove_child(l)

func delete_bridge_links(ls):
	print("Deleting bridge links: ", ls)
	# bridge links are known by both their spaces, so one might need to be
	# informed of the deletion of the bridge link
	for l in ls:
		if l == null:
			continue
		
		var spaces = l.get_spaces()
		
		if spaces[0] != null:
			spaces[0].remove_bridge_link(l)
		
		if spaces[1] != null:
			spaces[1].remove_bridge_link(l)
		
		l.get_parent().remove_child(l)
	






################ Nav Bridge Links ################

func add_bridge_link():
	var scene_root = get_editor_interface().get_edited_scene_root()
	var sel = selection.get_selected_nodes()

	var space_0 = sel[0]
	var space_1 = sel[1]
	
	var bridge_link = NavBridgeLink.new()
	bridge_link.name = "BridgeLink[" + space_0.name + "," + space_1.name + "]"
	bridge_link.plugin = self
	bridge_link.update_gizmo()
	scene_root.add_child(bridge_link)
	bridge_link.owner = scene_root

	# Inform the nodes of each other
	bridge_link.set_spaces(bridge_link.get_path_to(space_0), bridge_link.get_path_to(space_1))
	space_0.add_bridge_link(space_0.get_path_to(bridge_link))
	space_1.add_bridge_link(space_1.get_path_to(bridge_link))

	print("Add bridge link between ", sel[0], " and ", sel[1], ": ", bridge_link)





################ Nav Stitch Links ################

func add_stitch_link():
	var scene_root = get_editor_interface().get_edited_scene_root()
	var sel = selection.get_selected_nodes()

	var space = sel[0]
	
	var stitch_link = NavStitchLink.new()
	stitch_link.name = "StitchLink[" + space.name + "]"
	stitch_link.plugin = self
	stitch_link.update_gizmo()
	scene_root.add_child(stitch_link)
	stitch_link.owner = scene_root
	
	# Inform the nodes of each other
	stitch_link.set_space(stitch_link.get_path_to(space))
	space.add_stitch_link(space.get_path_to(stitch_link))

	print("Add stitch link to ", space, ": ", stitch_link)