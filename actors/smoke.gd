class_name Smoke
extends Node2D

signal smoke_ended

func _ready():
    $Area2D/CollisionShape2D.disabled = false

func _on_timer_timeout() -> void:
    smoke_ended.emit()
    queue_free()
