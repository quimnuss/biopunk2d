extends CharacterBody2D

@export var interest_array = [0, 0, 0, 0, 0]
@export var speed := 50
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Anchor/Sprite2D
@onready var change_state_timer: Timer = $ChangeStateTimer
@onready var status_label: Label = $StatusLabel
@onready var status_sprite: Sprite2D = $Anchor/StatusSprite

var direction : Vector2 = Vector2.RIGHT
var initial_position : Vector2
@export_enum('idle', 'patrol', 'surprised', 'scared', 'sleep', 'threaten', 'chase', 'attack', 'flee') var state = 'idle'
@export var MAX_DRIFTING_DISTANCE : float = 400
@export var MAX_CHASE_DISTANCE : float = 300

@export var PATROL_BASE_TIME : float = 2.0
@export var CHANGE_DIRECTION_BASE_TIME : float = 5.0
@export var FLEE_BASE_TIME : float = 5.0

@export var target : Node2D
@export var is_player_close : bool = false

func _ready() -> void:
    initial_position = global_position
    animation_player.animation_finished.connect(_on_animation_finished)


func change_state(new_state):
    var previous_state = state
    if previous_state == new_state:
        return
    match previous_state:
        'flee':
            status_sprite.visible = false
            target = null
        'chase':
            status_sprite.visible = false

    prints(self.name,previous_state,'->',new_state)
    # enter state
    state = new_state
    status_label.text = state
    match state:
        'idle':
            animation_player.play('idle')
            change_state_timer.start(PATROL_BASE_TIME + randf())
        'patrol':
            animation_player.play('walk_horizontal')
            change_state_timer.start(CHANGE_DIRECTION_BASE_TIME + randf())
            if global_position.distance_to(initial_position) > MAX_DRIFTING_DISTANCE:
                direction = global_position.direction_to(initial_position)
        'threaten':
            animation_player.play('threaten')
        'chase':
            if not target:
                prints('requested chase but no target')
                change_state('idle')
            else:
                animation_player.play('walk_horizontal')
                if global_position.distance_to(target.global_position) > MAX_CHASE_DISTANCE:
                    direction = global_position.direction_to(initial_position)
                    change_state('idle')
        'attack':
            animation_player.play('attack')
        'scared':
            animation_player.play('scared')
            status_label.text += ": " + target.name
            prints('scared from', target.name)
        'flee':
            prints('flee from', target.name)
            direction = -global_position.direction_to(target.global_position)
            animation_player.play("walk_horizontal")
            status_label.text += ": " + target.name
            change_state_timer.start(FLEE_BASE_TIME + randf())


func _on_animation_finished(anim_name : String):
    if anim_name == 'threaten':
        if target:
            change_state('chase')
        else:
            change_state('idle')
    elif anim_name == 'attack':
        if not is_player_close:
            change_state('chase')
        else:
            animation_player.play("attack")
    elif anim_name == 'scared':
        change_state('flee')
        

func _physics_process(delta: float) -> void:
    
    if state == 'chase':
        direction = global_position.direction_to(target.global_position)
    
    if direction and state in ['patrol', 'chase', 'flee']:
        velocity = speed * direction
    else:
        velocity = Vector2.ZERO
    
    if velocity.x < 0:
        sprite_2d.flip_h = true
    elif velocity.x > 0:
        sprite_2d.flip_h = false

    move_and_slide()

func _on_patrol_timer_timeout() -> void:
    direction = direction.rotated(randf()*PI/4)

func _on_change_state_timer_timeout() -> void:
    match state:
        'idle':
            change_state('patrol')
        'patrol':
            change_state('idle')
        'flee':
            change_state('idle')


func _on_long_sensor_body_entered(body: Node2D) -> void:
    if body is Player and state not in ['scared', 'flee']:
        target = body
        #if body.tool == 'eye': change_state('fear')
        change_state('threaten')
        



func _on_long_sensor_body_exited(body: Node2D) -> void:
    if body is Player:
        if state in ['threaten', 'chase', 'idle']:
            target = null
        if state == 'chase':
            change_state('idle')


func _on_close_sensor_body_entered(body: Node2D) -> void:
    if body is Player:
        is_player_close = true
        change_state('attack')


func _on_close_sensor_body_exited(body: Node2D) -> void:
    if body is Player:
        is_player_close = false


func _on_hitbox_body_entered(body: Node2D) -> void:
    if body is Player:
        body.damage()


func _on_long_sensor_area_entered(area: Area2D) -> void:
    var visitor : Node2D = area.get_parent()
    if visitor is EyePlant:
        if not target:
            target = visitor
        elif target is Player: # if was targetting player and saw an eyeplant, run
            target = visitor
            change_state('scared')
        elif target is EyePlant and state in ['scared', 'flee']: # if it was already fleeing an eyeplant, switch only if next is closer
            if self.global_position.distance_to(target.global_position) > self.global_position.distance_to(visitor.global_position):
                target = visitor
        if state != 'flee':
            change_state('scared')
