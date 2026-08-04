extends CharacterBody2D

@export var interest_array = [0, 0, 0, 0, 0]
@export var speed := 50
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var change_state_timer: Timer = $ChangeStateTimer

var direction : Vector2 = Vector2.RIGHT
var initial_position : Vector2
@export_enum('idle', 'patrol', 'surprised', 'scared', 'sleep', 'threaten', 'chase', 'attack') var state = 'idle'
@export var MAX_DRIFTING_DISTANCE : float = 400
@export var MAX_CHASE_DISTANCE : float = 300

@export var target : Node2D
@export var is_player_close : bool = false

func _ready() -> void:
    initial_position = global_position
    animation_player.animation_finished.connect(_on_animation_finished)

func change_state(new_state):
    var previous_state = state
    
    # enter state
    state = new_state
    match state:
        'idle':
            animation_player.play('idle')
            change_state_timer.start(10.0 + randf())
        'patrol':
            animation_player.play('walk_horizontal')
            change_state_timer.start(2.0 + randf())
            if global_position.distance_to(initial_position) > MAX_DRIFTING_DISTANCE:
                direction = global_position.direction_to(initial_position)
        'threaten':
            animation_player.play('threaten')
        'chase':
            if not target:
                prints('requested chase but no target')
                change_state('idle')
            animation_player.play('walk_horizontal')
            if global_position.distance_to(target.global_position) > MAX_CHASE_DISTANCE:
                direction = global_position.direction_to(initial_position)
                change_state('idle')
        'attack':
            animation_player.play('attack')

func _on_animation_finished(anim_name : String):
    if anim_name == 'threaten':
        change_state('chase')
    elif anim_name == 'attack':
        if not is_player_close:
            change_state('chase')

func _physics_process(delta: float) -> void:
    
    if state == 'chase':
        direction = global_position.direction_to(target.global_position)
    
    if direction and state in ['patrol', 'chase']:
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


func _on_long_sensor_body_entered(body: Node2D) -> void:
    if body is Player:
        target = body
        #if body.tool == 'eye': change_state('fear')
        change_state('threaten')
        


func _on_close_sensor_body_entered(body: Node2D) -> void:
    if body is Player:
        is_player_close = true
        change_state('attack')


func _on_long_sensor_body_exited(body: Node2D) -> void:
    if body is Player:
        target = null
        change_state('idle')


func _on_close_sensor_body_exited(body: Node2D) -> void:
    if body is Player:
        is_player_close = false
        change_state('chase')


func _on_hitbox_body_entered(body: Node2D) -> void:
    if body is Player:
        body.damage()
