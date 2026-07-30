class_name BiopunkItem
extends Resource

enum ItemType {FRUIT}
enum ItemTag {THROWABLE}

@export var item_id : String
@export var item_type : ItemType
@export var tags : ItemTag
@export var name : String
@export_multiline var description: String
@export var texture : Texture
@export var ui_texture : Texture
@export var quantity : int = 0
