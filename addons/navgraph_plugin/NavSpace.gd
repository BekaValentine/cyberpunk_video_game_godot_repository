tool
class_name NavSpace
extends Area

var plugin
export var bridge_links : Array = []
export var stitch_links : Array = []

# func _init():
#     bridge_links = []
#     stitch_links = []

func _ready():
    self.set_notify_transform(true)

func _notification(note):
    if plugin != null:        
        if note == NOTIFICATION_PREDELETE:
            plugin.space_may_delete(self)
        elif note == NOTIFICATION_TRANSFORM_CHANGED:
            plugin.space_moved(self)

func _exit_tree():
    if plugin != null:
        plugin.space_may_delete(self)

func add_bridge_link(l):
    bridge_links.push_back(l)

func remove_bridge_link(l):
    if l != null:
        bridge_links.erase(l)
    else:
        var new_bridge_links = []
        for l in bridge_links:
            if l != null:
                new_bridge_links.push_back(l)
        bridge_links = new_bridge_links

func add_stitch_link(l):
    stitch_links.push_back(l)

func remove_stitch_link(l):
    if l != null:
        stitch_links.erase(l)
    else:
        var new_stitch_links = []
        for l in stitch_links:
            if l != null:
                new_stitch_links.push_back(l)
        stitch_links = new_stitch_links