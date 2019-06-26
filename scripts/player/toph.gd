extends RigidBody2D

var WALK_ACCEL = 1200.0  # bigger value = faster horizontal acceleration while on the ground
var WALK_DEACCEL = 100.0  # bigger value = faster horizontal deceleration after releasing direction
var WALK_MAX_VELOCITY = 400.0  # bigger value = faster top horizontal speed
var AIR_ACCEL = 1200.0  # bigger value = faster horizontal acceleration when in the air
var AIR_DEACCEL = 400.0  # bigger value = horizontal momentum stops faster when you release direction while in the air
var JUMP_VELOCITY = 600  # bigger value = higher jumps
var STOP_JUMP_FORCE = 2000.0  # bigger value = smaller min jump height
var MAX_FLOOR_AIRBORNE_TIME = 0.01  # You can be off the floor for this long and still be considered 'on the floor'

var anim = ""  # Which animation is currently playing?
var jumping = false  # Is the character currently jumping (on the way up)?
var stopping_jump = false  # Did the player release jump on the way up?
var airborne_time = 0  # How long has the character been in the air?
var floor_h_velocity = 0.0  # ??? I think this is to handle moving platforms?

func _integrate_forces(state):
    var lv = state.get_linear_velocity()
    var step = state.get_step()

    var new_anim = anim

    # Get the controls
    var move_left = Input.is_action_pressed("move_left")
    var move_right = Input.is_action_pressed("move_right")
    var is_jump_pressed = Input.is_action_pressed("jump")

    # Turn on friction
    if move_left or move_right:
        physics_material_override.friction = 0
    else:
        physics_material_override.friction = 1

    # Deapply prev floor velocity
    lv.x -= floor_h_velocity
    floor_h_velocity = 0.0

    # Find the floor (a contact with upwards facing collision normal)
    var found_floor = false
    var floor_index = -1

    for x in range(state.get_contact_count()):
        var ci = state.get_contact_local_normal(x)
        if ci.dot(Vector2(0, -1)) > 0.6:
            found_floor = true
            floor_index = x

    if found_floor:
        airborne_time = 0.0
    else:
        airborne_time += step # Time it spent in the air

    var on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME

    # Process jump
    if jumping:
        if lv.y > 0:
            # Set off the jumping flag if going down
            jumping = false
        elif not is_jump_pressed:
            stopping_jump = true

        if stopping_jump:
            lv.y += STOP_JUMP_FORCE * step

    if on_floor:
        # Process logic when character is on floor
        if move_left and not move_right:
            if lv.x > -WALK_MAX_VELOCITY:
                lv.x -= WALK_ACCEL * step
        elif move_right and not move_left:
            if lv.x < WALK_MAX_VELOCITY:
                lv.x += WALK_ACCEL * step
        else:
            var xv = abs(lv.x)
            xv -= WALK_DEACCEL * step
            if xv < 0:
                xv = 0
            lv.x = sign(lv.x) * xv

        # Check jump
        if not jumping and is_jump_pressed:
            lv.y = -JUMP_VELOCITY
            jumping = true
            stopping_jump = false
            $Boing.play()

        if jumping:
            new_anim = "Jump"
        elif abs(lv.x) < 0.1:
            new_anim = "Idle"
        else:
            new_anim = "Walk"
    else:
        # Process logic when the character is in the air
        if move_left and not move_right:
            if lv.x > -WALK_MAX_VELOCITY:
                lv.x -= AIR_ACCEL * step
        elif move_right and not move_left:
            if lv.x < WALK_MAX_VELOCITY:
                lv.x += AIR_ACCEL * step
        else:
            var xv = abs(lv.x)
            xv -= AIR_DEACCEL * step
            if xv < 0:
                xv = 0
            lv.x = sign(lv.x) * xv

        if lv.y < 0:
            new_anim = "Jump"
        else:
            new_anim = "Fall"

    # Check facing
    if move_left:
        $Sprite.flip_h = true
    elif move_right:
        $Sprite.flip_h = false

    # Change animation
    if new_anim != anim:
        anim = new_anim
        $Sprite.play(anim)

    # Apply floor velocity
    if found_floor:
        floor_h_velocity = state.get_contact_collider_velocity_at_position(floor_index).x
        lv.x += floor_h_velocity

    # Finally, apply gravity and set back the linear velocity
    lv += state.get_total_gravity() * step
    state.set_linear_velocity(lv)
