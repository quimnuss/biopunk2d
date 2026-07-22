class_name Player 
extends CharacterBody2D
@onready var sprite_2d: Sprite2D = $Anchor/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hand : Node2D = $Hand
@export var last_obj : Node2D
@export var actors_node : Node2D

var last_walk_velocity : Vector2 = Vector2.ZERO
var looking_direction : Vector2 = Vector2.LEFT

const SPEED := 100.0
const THROWSPEED := 100.0

var grabbable_objects : Array[Grabbable]
@onready var tool: Sprite2D = $Hand/Tool

var tool_type : Grabbable.ToolType

var is_shooting : bool = false

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        if has_tool():
            drop_tool()
        elif last_obj:
            prints('grabbed', Grabbable.tooltype_str[last_obj.tooltype])
            equip_tool(last_obj.tooltype)
            last_obj.get_parent().queue_free()


func has_tool() -> bool:
    return tool_type != Grabbable.ToolType.NONE

func equip_tool(new_tool_type : Grabbable.ToolType):
    tool_type = new_tool_type
    tool.frame = tool_type

func drop_tool() -> Node2D:
    if tool_type != Grabbable.ToolType.NONE:
        var new_tool = Grabbable.instantiate(tool_type)
        actors_node.add_child(new_tool)
        new_tool.global_position = hand.global_position
        prints('dropped', new_tool)
        equip_tool(Grabbable.ToolType.NONE)
        return new_tool
    return null

func _physics_process(delta: float) -> void:
   
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if direction.x < 0:
        sprite_2d.flip_h = true
    elif direction.x > 0:
        sprite_2d.flip_h = false
    
    if direction:
        velocity = direction * SPEED
        looking_direction = direction
    else:
        velocity = Vector2.ZERO

    if Input.is_action_just_pressed("shoot"):
        if has_tool():
            shoot()

    if velocity.length() > 0:
        if abs(velocity.x) > 0:
            animation_player.play("walk_horizontal")
        elif velocity.y < 0:
            animation_player.play("walk_up")
        elif velocity.y > 0:
            animation_player.play("walk_down")
        last_walk_velocity = velocity
    else:
        if abs(last_walk_velocity.x) > 0:
            animation_player.play("idle_horizontal")
        elif last_walk_velocity.y < 0:
            animation_player.play("idle_up")
        elif last_walk_velocity.y > 0:
            animation_player.play("idle_down")
        else:
            animation_player.play("idle_horizontal")

    move_and_slide()

func closest_object(a : Node2D, b : Node2D):
    return self.global_position.distance_to(a.global_position) < self.global_position.distance_to(b.global_position)

func shoot():
    var spawned_drop : Node2D = drop_tool()
    #quick and dirty throw
    const THROWDISTANCE := THROWSPEED * 1.0
    var start_position := spawned_drop.global_position
    var arc_height := 48.0
    var final_position := start_position + looking_direction * THROWDISTANCE
    var tween := get_tree().create_tween()
    tween.tween_property(spawned_drop, "global_position", final_position, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.parallel().tween_property(spawned_drop, "rotation", 2*PI + randf()*PI, 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
    
    
func grabbable_changed():
    if not grabbable_objects and last_obj:
        last_obj.focus_changed.emit(false)
        last_obj = null
        return
    grabbable_objects.sort_custom(closest_object)
    var new_last_obj : Grabbable = grabbable_objects.get(0)
    if last_obj != new_last_obj:
        if last_obj:
            last_obj.focus_changed.emit(false)
        last_obj = new_last_obj
        last_obj.focus_changed.emit(true)

func _on_grab_area_2d_area_entered(area: Area2D) -> void:
    if area is Grabbable:
        prints('grabbable',area.get_parent().name,'entered')
        grabbable_objects.append(area)
        grabbable_changed()


func _on_grab_area_2d_area_exited(area: Area2D) -> void:
    if area is Grabbable:
        grabbable_objects.erase(area)
        grabbable_changed()
