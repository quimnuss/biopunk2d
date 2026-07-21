class_name Grabbable
extends Area2D

@onready var papa = get_parent()

@export var tooltype : ToolType

enum ToolType {
    NONE,
    SEED
}

static var tooltype_str : Dictionary[ToolType, String] = {
    ToolType.NONE: 'none',
    ToolType.SEED : 'seed'
}

signal focus_changed(is_focused : bool)

static func instantiate(tooltype : ToolType):
    match tooltype:
        ToolType.SEED:
            return preload("res://actors/misc/seed.tscn").instantiate()
    push_error("tool type" + tooltype_str[tooltype] + " not known")
