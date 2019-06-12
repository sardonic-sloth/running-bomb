extends Node2D

export(String, FILE, '*.png') var contents

func _physics_process(delta):
    if Input.is_action_pressed('ui_accept') and $Area.get_overlapping_bodies():
        open_chest()

func open_chest():
    $Sprite.play('open')
    $OpenSound.play()

    var texture = ImageTexture.new()
    texture.load(contents)
    $Contents.texture = texture
    $Chest.play('Up')
