class_name Grabbable
extends Area2D

@onready var papa = get_parent()
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var tooltype : ToolType

enum ToolType {
    NONE,
    SEED,
    EYE
}

static var tooltype_str : Dictionary[ToolType, String] = {
    ToolType.NONE : 'none',
    ToolType.SEED : 'seed',
    ToolType.EYE : 'eye'
}

signal focus_changed(is_focused : bool)

static func instantiate(tooltype : ToolType):
    match tooltype:
        ToolType.SEED:
            return preload("res://actors/misc/seed.tscn").instantiate()
        ToolType.EYE:
            var droppable_tool : GenericGrabbable = preload("res://actors/misc/generic_tool.tscn").instantiate()
            droppable_tool.tooltype = ToolType.EYE
            return droppable_tool
            
    push_error("tool type" + tooltype_str[tooltype] + " not known")

func activate():
    collision_shape_2d.disabled = false
    
func deactivate():
    collision_shape_2d.disabled = true
