/*

VEHICLES

*/

atom
	proc
		Get_Position_X()
			return (x*world.icon_size) + pixel_x + pixel_w
		Get_Position_Y()
			return (y*world.icon_size) + pixel_y + pixel_z
		pixel_hit(atom/A)
atom/movable
	var
		real_pixel_x = 0
		real_pixel_y = 0
		pixel_collision_size_x = 32
		pixel_collision_size_y = 32
	Get_Position_X()
		return (x*world.icon_size) + real_pixel_x
	Get_Position_Y()
		return (y*world.icon_size) + real_pixel_y
	proc
		GetCollisionSizes()
			var/icon/I = new(icon)
			pixel_collision_size_x = I.Width()
			pixel_collision_size_y = I.Height()
			del I
		PixelCollision(atom/a)
			var/st1 = Get_Position_X()+pixel_collision_size_x >= a.Get_Position_X()
			var/st2 = Get_Position_X() <= a.Get_Position_X()+world.icon_size

			var/st3 = Get_Position_Y()+pixel_collision_size_y >= a.Get_Position_Y()
			var/st4 = Get_Position_Y() <= a.Get_Position_Y()+world.icon_size

			return (st1 && st2 && st3 && st4)*a.density
		PixelCollision2(atom/movable/a)
			var/st1 = Get_Position_X()+pixel_collision_size_x >= a.Get_Position_X()
			var/st2 = Get_Position_X() <= a.Get_Position_X()+a.pixel_collision_size_x

			var/st3 = Get_Position_Y()+pixel_collision_size_y >= a.Get_Position_Y()
			var/st4 = Get_Position_Y() <= a.Get_Position_Y()+a.pixel_collision_size_y

			return (st1 && st2 && st3 && st4)*a.density
		PixelMove(var/x_to_move,var/y_to_move,var/ignore)
			var/old_real_x = real_pixel_x
			var/old_real_y = real_pixel_y
			var/old_x = x
			var/old_y = y

			real_pixel_x += x_to_move
			real_pixel_y += y_to_move

			var pixel_x_to_move = round(real_pixel_x, 32)
			real_pixel_x -= pixel_x_to_move
			x += pixel_x_to_move / 32

			var pixel_y_to_move = round(real_pixel_y, 32)
			real_pixel_y -= pixel_y_to_move
			y += pixel_y_to_move / 32

			var/bumpedwalls = 0
			for(var/atom/e in orange(1,src))
				if(e != ignore)
					if(!istype(e,/mob))
						if(PixelCollision(e))
							if(istype(src,/obj/machinery/vehicle))
								if(round(src:velocity:SquareMagnitude()/50) > 80)
									explosion(e, 2, 3, 5, 10,0)
									del src
								else
									bumpedwalls += 1
							else
								pixel_hit(e)
								bumpedwalls += 1
					else
						if(PixelCollision2(e))
							pixel_hit(e)

			if(bumpedwalls > 0)
				x = old_x
				y = old_y
				real_pixel_y = old_real_y
				real_pixel_x = old_real_x
				return 0 //Didn't move
			else
				pixel_x = real_pixel_x
				pixel_y = real_pixel_y
				return 1 //Did move.
/*
Basic trigonometry

vx = v * cos(angle)
vy = v * sin(angle)
*/

/obj/machinery/vehicle
	name = "Vehicle Pod"
	icon = 'icons/obj/escapepod.dmi'
	icon_state = "recon"
	anchored = 1.0
	plane = MOB_PLANE_ALT
	animate_movement = 0 //set it
	var/forcedloc = null
	var
		vector2
			forward // Forward directional unit vector.
			velocity // Velocity of the ship in pixels per decisecond (p/ds).
		turning = 0
		accelerating = 0
		Spinning = 0
		CanMove = 0
	proc
		TurnRate() return 5
		// How fast you accelerate, in pixels per decisecond... per decisecond. (p/ds^2)
		Acceleration() return 1.6
	New()
		..()
		forward = Vector2_North // Initialize direction to north.
		velocity = Vector2_Zero // Initialize velocity to zero.

		special_processing += src
		var/icon/E = icon('icons/obj/escapepod.dmi',"recon")
		var/icon/I = icon('icons/obj/escapepod.dmi',"overlay")
		I += rgb(rand(0,255),rand(0,255),rand(0,255))
		I.Blend(E,ICON_OVERLAY)
		icon = I
		del E
		del I
	Del()
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
			A.ex_act(1)
		special_processing -= src
		..()


/obj/machinery/vehicle/special_process()
	if(CanMove == 1)

		density = 0

		if(frm_counter % 5 && accelerating)
			var/obj/Particle/Spark/Heat/S = new()
			S.loc = loc
			S.x_pos = pixel_x+rand(0,32)
			S.y_pos = pixel_y+rand(0,32)
			S.x_spd = forward.x*-5
			S.y_spd = forward.y*-5

		if(turning)
			// Turn the forward direction and keep it normalized.
			forward = forward.Turn((turning * TurnRate()) * tick_lag_original).Normalized()
			transform = initial(transform) * forward.ToRotation()

		if(accelerating)
			// Accelerate!
			velocity += forward * (Acceleration() * tick_lag_original)
		else
			velocity *= 0.99 //slowly stop accelerating
		//world << velocity.SquareMagnitude()

		if(velocity.SquareMagnitude() > 1)
			if(PixelMove(velocity.x*tick_lag_original,velocity.y*tick_lag_original)==0)
				velocity *= -1
		else
			if(!accelerating)
				velocity = Vector2_Zero
		pixel_x = real_pixel_x
		pixel_y = real_pixel_y
		for(var/mob/A as mob in src)

			if(A.client)
				A.client.pixel_x = pixel_x
				A.client.pixel_y2 = pixel_y
	else
		//animate(src,transform = initial(transform),time = 5)
		real_pixel_x = real_pixel_x * 0.9
		real_pixel_y = real_pixel_y * 0.9
		pixel_x = real_pixel_x
		pixel_y = real_pixel_y
		density = 1
/obj/machinery/vehicle/meteorhit(var/obj/O as obj)
	for(var/atom/movable/A as mob|obj in src)
		A.loc = src.loc
	del(src)

/obj/machinery/vehicle/ex_act(severity)
	for(var/atom/movable/A as mob|obj in src)
		A.loc = src.loc
		A.ex_act(severity)
	del(src)

/obj/machinery/vehicle/blob_act()
	for(var/atom/movable/A as mob|obj in src)
		A.loc = src.loc
	del(src)

/obj/machinery/vehicle/relaymove(mob/user as mob, direction)
	if (user.stat)
		return

	if ((user in src))
		turning = (direction & EAST) - (direction & WEST) // 0, 1, or -1.
		accelerating = direction & NORTH // 0 or 1.



/mob
	var/obj/machinery/vehicle/veh = null
	var/changingPOD = 0
	var/can_exit_pod = 1

/mob/verb/podCon()
	set name = "Pod Enter/Exit"
	var/mob/M = src
	if(!can_exit_pod)
		src << "<b>\red You cannot do this!"
		return
	if(changingPOD)
		return
	if(veh)
		changingPOD = 1
		veh.CanMove = 0
		sleep(5)
		M.loc = veh.loc
		if (M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE
			M.client.pixel_y2 = 0
			M.client.pixel_x = 0
		src << sound(null, channel=MOTOR_CHANNEL)
		//veh.forward = Vector2_North // Initialize direction to north.
		veh.velocity = Vector2_Zero // Initialize velocity to zero.
		veh = null
		changingPOD = 0
	else
		if(istype(src,/mob/dead) && src.health > 0 )
			return //Can't do this you fucking idiot
		var/list/faf = list()
		for(var/obj/machinery/vehicle/fef in oview(1))
			faf += fef
		var/obj/machinery/vehicle/a = input("Which pod to board?","Board") in faf
		var/turf/T = locate(x,y,z)
		if(T)
			if(a && istype(a,/obj/machinery/vehicle) && heightZ == T.TurfHeight)
				if(a.contents.len > 0)
					src << "<b>\red There is no room!"
				if (M.client)
					M.client.perspective = EYE_PERSPECTIVE
					M.client.eye = veh
					M.client.pixel_y2 = 0
					M.client.pixel_x = 0
				M.veh = a
				a.CanMove = 1
				a.velocity = Vector2_Zero // Initialize velocity to zero.
				M.loc = a
