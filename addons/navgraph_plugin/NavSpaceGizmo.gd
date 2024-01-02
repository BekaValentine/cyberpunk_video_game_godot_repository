tool
extends EditorSpatialGizmoPlugin

var NavSpace = preload("res://addons/navgraph_plugin/NavSpace.gd")

func _init():
    create_material("main", Color(0,1,0), false, true)

func get_name():
    return "NavSpaceGizmo"

func has_gizmo(node):
    # print("Has gizmo: ", node, node is NavBridgeLink)
    return node is NavSpace

func redraw(gizmo):
    gizmo.clear()

    var space = gizmo.get_spatial_node()
    if !(space is NavSpace):
        print("Not a nav space!", space)
        return
    
    var ltf = Vector3(-0.1, 0.1, 0.1)
    var ltb = Vector3(-0.1, 0.1,-0.1)
    var lbf = Vector3(-0.1,-0.1, 0.1)
    var lbb = Vector3(-0.1,-0.1,-0.1)
    var rtf = Vector3( 0.1, 0.1, 0.1)
    var rtb = Vector3( 0.1, 0.1,-0.1)
    var rbf = Vector3( 0.1,-0.1, 0.1)
    var rbb = Vector3( 0.1,-0.1,-0.1)
        
    var vertices = PoolVector3Array([
        # top
        ltf, ltb, rtb,
        ltf, rtb, rtf,
        
        # front
        ltf, rtf, rbf,
        ltf, rbf, lbf,

        # left
        ltb, ltf, lbf,
        ltb, lbf, lbb,

        # right
        rtf, rtb, rbb,
        rtf, rbb, rbf,

        # back
        rtb, ltb, lbb,
        rtb, lbb, rbb,

        # bottom
        lbf, rbf, rbb,
        lbf, rbb, lbb
    ])
    
    # Initialize the ArrayMesh.
    var arr_mesh = ArrayMesh.new()
    var arrays = []
    arrays.resize(ArrayMesh.ARRAY_MAX)
    arrays[ArrayMesh.ARRAY_VERTEX] = vertices
    # Create the Mesh.
    arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    
    gizmo.add_mesh(arr_mesh, false, null, get_material("main", gizmo))