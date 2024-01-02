tool
extends EditorSpatialGizmoPlugin

var NavBridgeLink = preload("res://addons/navgraph_plugin/NavBridgeLink.gd")

func _init():
    create_material("main", Color(1,0,0), false, true)
    create_material("alt", Color(1,0.5,0))
    # create_handle_material("handles")

func get_name():
    return "NavBridgeLinkGizmo"

func has_gizmo(node):
    # print("Has gizmo: ", node, node is NavBridgeLink)
    return node is NavBridgeLink

func redraw(gizmo):
    gizmo.clear()

    var bridge_link = gizmo.get_spatial_node()
    if !(bridge_link is NavBridgeLink):
        print("Not a bridge link!", bridge_link)
        return
    
    var spaces = bridge_link.get_spaces()
    if spaces == null or spaces[0] == null or spaces[1] == null:
        print("Spaces are empty.")
        return
    
    var space_0_local_origin = bridge_link.to_local(spaces[0].global_transform.origin)
    var space_1_local_origin = bridge_link.to_local(spaces[1].global_transform.origin)

    var a1 = space_0_local_origin
    var a2 = space_1_local_origin
    var b = Vector3(0,0.1,0)
    var c = Vector3(0,-0.1,0)

    var vertices = PoolVector3Array([
        a1,b,c,
        c,b,a1,
        b,a2,c,
        c,a2,b
    ])
    
    var arr_mesh = ArrayMesh.new()
    var arrays = []
    arrays.resize(ArrayMesh.ARRAY_MAX)
    arrays[ArrayMesh.ARRAY_VERTEX] = vertices
    arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    
    gizmo.add_mesh(arr_mesh, false, null, get_material("alt", gizmo))

    var dt = Vector3(0,0.2,0)
    var db = Vector3(0,-0.2,0)
    var dfl = Vector3(0.1,0,0.1)
    var dfr = Vector3(-0.1,0,0.1)
    var dbl = Vector3(0.1,0,-0.1)
    var dbr = Vector3(-0.1,0,-0.1)

    var vertices2 = PoolVector3Array([
        # top back
        dt, dbl, dbr,
        dbr, dbl, dt,

        # bottom back
        db, dbl, dbr,
        dbr, dbl, db,

        # top front
        dt, dfl, dfr,
        dfr, dfl, dt,

        # bottom front
        db, dfl, dfr,
        dfr, dfl, db,

        # top left
        dt, dfl, dbl,
        dbl, dfl, dt,

        # bottom left
        db, dfl, dbl,
        dbl, dfl, db,

        # top right
        dt, dfr, dbr,
        dbr, dfr, dt,

        # bottom right

        db, dfr, dbr,
        dbr, dfr, db
    ])

    var arr_mesh2 = ArrayMesh.new()
    var arrays2 = []
    arrays2.resize(ArrayMesh.ARRAY_MAX)
    arrays2[ArrayMesh.ARRAY_VERTEX] = vertices2

    arr_mesh2.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays2)
    
    gizmo.add_mesh(arr_mesh2, false, null, get_material("main", gizmo))