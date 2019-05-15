extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 20
const ACCELERATION = 7
const MAX_SPEED = 200
const JUMP_HEIGHT = -500

var motion = Vector2()
var jumping = false

func _physics_process(delta):
    var friction = false

    motion.y += GRAVITY

    if Input.is_action_pressed('ui_right'):
        motion.x = min(motion.x + ACCELERATION, MAX_SPEED)
        $Sprite.flip_h = false
        $Sprite.play('Walk')
    elif Input.is_action_pressed('ui_left'):
        motion.x = max(motion.x - ACCELERATION, -MAX_SPEED)
        $Sprite.flip_h = true
        $Sprite.play('Walk')
    else:
        friction = true
        if abs(motion.x) < (float(MAX_SPEED) / 2):
            $Sprite.play('Idle')

    if is_on_ceiling():
        if motion.y <= GRAVITY:
            motion.y += GRAVITY

    if is_on_floor():
        if Input.is_action_just_pressed('ui_up') or Input.is_action_just_pressed('ui_select'):
            jumping = true
            motion.y = JUMP_HEIGHT
            $Boing.play()
        else:
            jumping = false
            motion.y = 0
        if friction:
            motion.x = lerp(motion.x, 0, 0.1)
    else:
        if motion.y < 0:
            $Sprite.play('Jump')
        elif jumping or motion.y > 100:
            $Sprite.play('Fall')
        motion.x = lerp(motion.x, 0, 0.02)

    motion = move_and_slide(motion, UP)
