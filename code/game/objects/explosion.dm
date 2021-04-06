proc/explosion(atom/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range,cap = 1)
	if(!epicenter)
		return 0 //Why are we blowing up a null location?
	spawn()
		if(!istype(epicenter,/turf))
			var/turf/T = epicenter.loc
			if(istype(T,/turf))
				epicenter = T //makes the epicenter a turf
		var/area/AREAEX = epicenter.loc
		if(!istype(AREAEX,/area) || !epicenter)
			return //Why are we blowing up a different object?
		message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z])")
		defer_powernet_rebuild = 1
		if(cap ==1)
			if(devastation_range > 3)
				devastation_range = 3
			if(heavy_impact_range > 7)
				heavy_impact_range = 7
			if(light_impact_range > 9)
				light_impact_range = 9

		for(var/i in 1 to min(100,light_impact_range*11)) //no big explosion
			var/obj/Particle/Explosion/A = new(epicenter)
			A.x_pos = 16
			A.y_pos = 16
			A.x_spd = (rand(-30,30)/2)
			A.y_spd = (rand(-30,30)/2)

		playsound(epicenter, 'explosionfar.ogg', 100, 1, round(devastation_range*2,1) )
		playsound(epicenter, "explosion", 100, 1, round(devastation_range,1) )

		if(heavy_impact_range > 1)
			spawn()
				var/obj/explosion/E = new
				E.loc = locate(epicenter.x,epicenter.y,epicenter.z)
				E.exSize = light_impact_range
				E.DoShit()
		for(var/client/i in clients)
			if(i.mob)
				spawn()
					if(AREAEX.HARM_MOBS)
						var/distance = round(abs(get_dist_alt(epicenter, i.mob)))
						if(distance < devastation_range)
							i.mob.ex_act(1)
						else if(distance < heavy_impact_range)
							i.mob.ex_act(2)
						else if(distance < light_impact_range)
							i.mob.ex_act(3)
				var/dist = round(abs(get_dist_alt(epicenter, i.mob)))
				shake_camera(i.mob, 1, 15/((dist/10)+1)) //shakes the screen rly hard
		for(var/atom/T in range(light_impact_range, epicenter)) // fun fact these explosions are faster than tg LOL
			Check_Explosion_tick() //i think we should do this more often
			var/distance = round(abs(get_dist_alt(epicenter, T)))
			var/turf/BE = locate(T.x,T.y,T.z)
			if(BE && istype(BE,/turf))
				var/area/A = BE.loc
				if(A && istype(A,/area))
					if(A.CAN_GRIFE)
						//world << "ex_act on [T] [T.type]" //i was checking a crash and trying to fix it
						if(distance < devastation_range)
							T.ex_act(1)
							//Check_Explosion_tick()
						else if(distance < heavy_impact_range)
							T.ex_act(2)
							//Check_Explosion_tick()
						else if(distance < light_impact_range)
							T.ex_act(3)
							//Check_Explosion_tick()

		makepowernets()
		defer_powernet_rebuild = 0
	return 1

proc/get_dist_alt(atom/A, atom/B)
	return sqrt((B.x-A.x)**2 + (B.y-A.y)**2)

var/explosion_acts = 0
proc/Check_Explosion_tick()
	if(explosion_acts > 6 || world.cpu > CPU_CHECK_MAX)
		sleep(tick_lag_original)
		explosion_acts = explosion_acts = 0
	else
		explosion_acts = explosion_acts + 1
obj
	explosion
		//can_move = 0
		anchored = 1
		icon = 'extra images/explosion.dmi'
		var/exSize = 0
		alpha = 200
		plane = BELOW_SHADING
		pixel_x = -496
		pixel_y = -496
		New()
			..()
			var/matrix/M = matrix()
			M.Scale(0)
			src.transform = M
		proc/DoShit()
			var/matrix/M = matrix()
			M.Scale(exSize/25)
			animate(src, transform = M, alpha = 0, time = exSize, easing = SINE_EASING | EASE_OUT)
			spawn(exSize)
				del src
		ex_act()
			return