tool
extends EditorSpatialGizmoPlugin

var NavBridgeLink = preload("res://addons/navgraph_plugin/NavBridgeLink.gd")

func _init():
    create_material("main", Color(1,0,0))
    create_handle_material("handles")

func get_name():
    return "NavBridgeLinkGizmo"

func has_gizmo(node):
    # print("Has gizmo: ", node, node is NavBridgeLink)
    return node is NavBridgeLink

func redraw(gizmo):
    print("Redrawing ", gizmo)
    gizmo.clear()

    var bridge_link = gizmo.get_spatial_node()
    if !(bridge_link is NavBridgeLink):
        print("Not a bridge link!", bridge_link)
        return
    
    var spaces = bridge_link.get_spaces()
    if spaces == null or spaces[0] == null or spaces[1] == null:
        print("Spaces are empty.")
        return
    
    # print(bridge_link, spaces)

    var space_0_local_origin = (spaces[0].global_transform.origin)
    var space_1_local_origin = (spaces[1].global_transform.origin)

    print("Ends: ", space_0_local_origin, " ", space_1_local_origin)

    var vertices = PoolVector3Array()
    var a = space_0_local_origin
    var b = space_1_local_origin
    var c = Vector3(0,0,0)
    vertices.push_back(a)
    vertices.push_back(b)
    vertices.push_back(c)
    vertices.push_back(c)
    vertices.push_back(b)
    vertices.push_back(a)
    
    # Initialize the ArrayMesh.
    var arr_mesh = ArrayMesh.new()
    var arrays = []
    arrays.resize(ArrayMesh.ARRAY_MAX)
    arrays[ArrayMesh.ARRAY_VERTEX] = vertices
    # Create the Mesh.
    arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    
    gizmo.add_mesh(arr_mesh, true, null, get_material("main", gizmo))