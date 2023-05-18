class_name Ladder
extends SimObject

var bottom_reference = null
var bottom_attachment_point = null
var top_reference = null
var top_attachment_point = null
var top_support = null

func _init():
	interactable = true

func _ready():
	highlight_shape = $CSGBox
	bottom_reference = $BottomReference
	bottom_attachment_point = $BottomAttachmentPoint
	top_reference = $TopReference
	top_attachment_point = $TopAttachmentPoint
	top_support = $TopSupport

func use(agent, tool_object):
	if agent.name == "player":
		agent.try_using_ladder(self)

func disable_top_support():
	top_support.disabled = true

func enable_top_support():
	top_support.disabled = false
