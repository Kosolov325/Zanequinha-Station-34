turf
	var/obj/water_overlay/gW1
	var/obj/water_overlay/gW2
	var/water_height = 0
	var/old_water_height = 0
	var/fully_cover = 0

	proc/Render_Water_Icon()
		if(round(water_height) == round(old_water_height))
			return //We shouldn't update.
		var/rounded_height = round(water_height)
		if(fully_cover == 1 && round(water_height) < TurfHeight)
			return
		var/ass = (max(0,min(32,rounded_height))/32)*0.75
		var/ColorWater = rgb(35*(1-ass),137*(1-ass),218*(1-ass))
		gW1.color = ColorWater
		gW2.color = ColorWater
		gW1.icon_state = "[max(0,min(32,rounded_height))]"
		if(rounded_height >= TurfHeight)
			if(rounded_height > 0)
				gW2.icon_state = "[max(0,min(32,32-rounded_height ))]"
				gW2.pixel_y = max(0,min(32,rounded_height))
			else
				gW2.pixel_y = 0
				gW2.icon_state = "0"
		if(round(max(0,min(32,water_height)))==32)
			gW1.plane = TOP_PLANE
		else
			gW1.plane = MOB_PLANE_ALT
		old_water_height = water_height
	New()
		..()
		for(var/obj/water/G in src)
			G.hide()
		if(!gW1)
			gW1 = new(locate(x,y,z))
			gW1.Get_Layer_Y(0.1)
			gW1.plane = MOB_PLANE_ALT
		if(!gW2)
			gW2 = new(locate(x,y,z))
			gW2.plane = LIGHT_PLANE
			gW2.layer = TURF_LAYER+0.5
	Del()
		if(gW1)
			del gW1
		if(gW2)
			del gW2
		if(src in water_changed)
			water_changed -= src
		..()

#define DIR2PIXEL list("1" = list(0,1),"2" = list(0,-1),"4" = list(1,0),"8" = list(-1,0))
#define DIAGONALS list(SOUTHWEST,SOUTHEAST,NORTHWEST,NORTHEAST)
#define REVERSEDIRS(DIR) turn(DIR,180)
#define CARDINALS list(SOUTH,NORTH,EAST,WEST)
#define TEXT2DIR list("NORTH" = NORTH,"SOUTH" = SOUTH,"EAST" = EAST,"WEST" = WEST,"NORTHEAST" = NORTHEAST,"NORTHWEST" = NORTHWEST,"SOUTHEAST" = SOUTHEAST,"SOUTHWEST" = SOUTHWEST)
#define DIRTOHORVER list("1" = "VER","2" = "VER","4" = "HOR","8" = "HOR")
#define PIPE_DIRS list("HORIZONTAL" = EAST,"VERTICAL" = SOUTH,"TOP-RIGHT" = NORTHEAST,"TOP-LEFT" = NORTHWEST,"BOTTOM-RIGHT" = SOUTHEAST,"BOTTOM-LEFT" = SOUTHWEST,"4-WAY" = 99)
#define PIPE_DIRS_2 list("UP" = NORTH,"DOWN" = SOUTH,"RIGHT" = EAST,"LEFT" = WEST)
obj
	item
		water_pipe
			icon = 'icons/obj/water_pipes.dmi'
			icon_state = "pipe"
			var/amount = 50
			afterattack(atom/T, mob/user as mob)
				..()
				if(istype(T,/obj/item/water_pipe))
					var/obj/item/water_pipe/E = T
					amount += E.amount
					del T
				if(istype(T,/obj/water/pipes))
					var/obj/water/pipes/G = T
					if(G.water_pressure == 0)
						amount += 1
						user << "You disconnect the pipe on the floor and add it to your stack."
						del T
					else
						user << "\red <b>You cannot disconnect this pipe! Water is flowing through it currently."
				if(istype(T,/turf/simulated))
					var/obj/water/G = locate(/obj/water/pipes) in T
					if(G)
						usr << "\red <b>There is already a pipe device here."
						return
					if(amount > 0)
						amount -= 1
						new /obj/water/pipes(locate(T.x,T.y,T.z))
						if(amount == 0)
							del src
obj
	water_overlay
		icon = 'extra images/water sprites.dmi'
		anchored = 1
		mouse_opacity = 0
		color = rgb(35,137,218)
		alpha = 75
		ex_act()
			return
	water
		plane = CABLE_PLANE
		icon = 'icons/obj/water_pipes.dmi'
		hide()
			return
		pipes
			icon_state = "water_pipe"
			desc = "A pretty robust pipe for water to flow in. Use crowbar to remove, wrench to rotate."
			level = 1
			New()
				..()
				hide()
			hide()
				var/turf/T = locate(x,y,z)
				if(istype(T,/turf))
					alpha = level < T.level ? 0 : 255
			attackby(obj/item/weapon/G as obj, mob/user as mob)
				..()
				if(istype(G,/obj/item/weapon/crowbar))
					user << "\red <b>You pry the pipe out!"
					var/obj/item/water_pipe/A = new(locate(x,y,z))
					A.amount = 1
					del src
				if(istype(G,/obj/item/weapon/wrench))
					var/new_dir = input(user,"What direction should this pipe have?","Change direction") as null|anything in PIPE_DIRS
					if(new_dir)
						if(PIPE_DIRS[new_dir] == 99)
							var/four_way_dir = input(user,"What is the pipe that sends water to this 4-way?","Change direction") as null|anything in PIPE_DIRS_2
							if(four_way_dir)
								icon_state = "4-way"
								dir = PIPE_DIRS_2[four_way_dir]
						else
							icon_state = "water_pipe"
							dir = PIPE_DIRS[new_dir]
			Process_Water()
				hide()
				if(water_pressure > 100)
					damaged = 1
				if(damaged == 1)
					var/turf/simulated/T = locate(x,y,z)
					T.water_height += water_pressure
					message_admins("Pipe at [x],[y],[z] ruptured and blew up")
					for(var/i in 1 to round(water_pressure*5))
						var/obj/Particle/Water/A = new(locate(x,y,z))
						A.x_pos = 16
						A.y_pos = 16
						A.x_spd = (rand(-30,30)/10)
						A.y_spd = (rand(-30,30)/10)
					playsound(src, 'explosionfar.ogg', 100, 1, 30)
					playsound(src, "explosion", 100, 1, 15)
					del src
					return
				if(water_pressure > 0)
					if(icon_state != "4-way")
						if(water_pressure_direction != 0)
							Process_Direction(water_pressure_direction,1)
					else
						for(var/i in CARDINALS-dir)
							Process_Direction(i,3)
						water_pressure = 0
			proc/Process_Direction(DIRECTIONSEND,EMPTY)
				var/obj/water/pipes/G = locate(/obj/water/pipes) in get_step(src,DIRECTIONSEND)
				var/obj/water/device/D = locate() in get_step(src,DIRECTIONSEND)
				if(D)
					if(REVERSEDIRS(D.dir) == DIRECTIONSEND)
						D.water_pressure += water_pressure/EMPTY
						if(EMPTY == 1)
							water_pressure = 0
						return
				if(G)
					if(G.icon_state == "4-way")
						if(REVERSEDIRS(G.dir) == water_pressure_direction)
							G.water_pressure += water_pressure/EMPTY
							if(EMPTY == 1)
								water_pressure = 0
							return
						else
							return //Keep filling
					else
						if(G.dir in DIAGONALS)
							if(G.dir - REVERSEDIRS(DIRECTIONSEND) in CARDINALS)
								G.water_pressure += water_pressure/EMPTY
								G.water_pressure_direction = G.dir - REVERSEDIRS(DIRECTIONSEND)
								if(EMPTY == 1)
									water_pressure = 0
								return
						else
							if(DIRTOHORVER["[DIRECTIONSEND]"] == DIRTOHORVER["[G.dir]"])
								G.water_pressure += water_pressure/EMPTY
								G.water_pressure_direction = DIRECTIONSEND
								if(EMPTY == 1)
									water_pressure = 0
								return
				var/turf/simulated/T = get_step(src,DIRECTIONSEND)
				if(istype(T,/turf/simulated))
					T.water_height += water_pressure/EMPTY
					if(!(T in water_changed))
						water_changed += T
					if(T.water_height <= 16)
						for(var/i in 1 to round(water_pressure/EMPTY))
							CreateWaterParticle(DIRECTIONSEND)
				if(EMPTY == 1)
					water_pressure = 0
		device
			connector
				level = 1
				icon_state = "filler"
				New()
					..()
					hide()
				hide()
					var/turf/T = locate(x,y,z)
					if(istype(T,/turf))
						icon_state = level < T.level ? "filler_hidden" : "filler"
				Process_Water()
					hide()
		tank
			icon_state = "water_pump_1"
			desc = "Due to it's technology, it holds infinite water."
			water_pressure_direction = SOUTH
			density = 1
			water_pressure = 1 //now infinite
			var/outputting_pressure = 1
			var/on = 0
			attack_hand(mob/user as mob)
				if(!on)
					var/new_pres = input(user,"Change water output pressure (0-20)","Water Tank") as null|num
					if(new_pres)
						outputting_pressure = max(0,min(20,new_pres))
				on = !on
				user << "You flip the water tank's valve to <b>[on ? "<font color='green'>ON</font>" : "<font color='red'>OFF</font>"]</b>!"
				icon_state = "water_pump_[on]"
			Process_Water()
				if(water_pressure > 0 && on)
					var/obj/water/pipes/G = locate(/obj/water/pipes) in get_step(src,water_pressure_direction)
					if(G)
						if(G.dir in DIAGONALS)
							G.water_pressure_direction = G.dir - REVERSEDIRS(SOUTH)
						else
							G.water_pressure_direction = SOUTH
						G.water_pressure += outputting_pressure
		drain
			icon_state = "drain"
			desc = "Drains water in rooms."
			water_pressure_direction = SOUTH
			density = 1
			level = 1
			hide()
				var/turf/T = locate(x,y,z)
				if(istype(T,/turf))
					icon_state = level < T.level ? "drain_f" : "drain"
			Process_Water()
				hide()
				var/turf/T = locate(x,y,z)
				if(T)
					water_pressure += T.water_height
					T.water_height = 0
				water_pressure_direction = dir
				if(water_pressure > 0)
					var/obj/water/pipes/G = locate(/obj/water/pipes) in get_step(src,water_pressure_direction)
					if(G)
						if(G.dir in DIAGONALS)
							G.water_pressure_direction = G.dir - REVERSEDIRS(water_pressure_direction)
						else
							G.water_pressure_direction = water_pressure_direction
						G.water_pressure += water_pressure
					water_pressure = 0
		meter
			name = "meter"
			icon = 'icons/obj/meter.dmi'
			icon_state = "water"
			anchored = 1
			Click()
				var/t = null
				var/obj/water/pipes/G = locate(/obj/water/pipes) in loc
				if(G)
					t = text("<B>Pressure:</B> [G.water_pressure]m³")
				else
					usr << "\blue <B>You are too far away.</B>"

				usr << t
				return

		var/damaged = 0
		var/water_pressure = 0
		var/water_pressure_direction = 0
		anchored = 1

		New()
			..()
			water_objects += src
		Del()
			water_objects -= src
			..()
		ex_act(severity)
			switch(severity)
				if(1)
					del src
				if(2)
					damaged = prob(75)
				if(3)
					damaged = prob(35)
		proc
			Process_Water() //Called every time we want a process.
			CreateWaterParticle(DIRECTION)
				var/obj/Particle/Water/A = new(locate(x,y,z))
				A.x_pos = 16+(DIR2PIXEL["[DIRECTION]"][1]*16)
				A.y_pos = 16+(DIR2PIXEL["[DIRECTION]"][2]*16)
				A.x_spd = DIR2PIXEL["[DIRECTION]"][1]==0 ? rand(-20,20)/10 : DIR2PIXEL["[DIRECTION]"][1]*(rand(1,30)/10)
				A.y_spd = DIR2PIXEL["[DIRECTION]"][2]==0 ? rand(-20,20)/10 : DIR2PIXEL["[DIRECTION]"][2]*(rand(1,30)/10)

/atom/proc/water_act(height)
	return

/turf/proc/Water_Can_Pass(water_in_me)
	for(var/obj/obstacle in contents)
		if(istype(obstacle,/obj/window) || istype(obstacle,/obj/machinery/door))
			if(obstacle.density)
				return 0
	return !density

/turf/proc/water_mob_act(d,h)
	var/mob/living/carbon/human/to_push = locate(/mob/living/carbon/human) in locate(x,y,z)
	if(istype(to_push,/mob/living/carbon/human))
		if(to_push.heightZ <= water_height)
			if(!to_push.wear_suit)
				to_push.glide_size = 32 / tick_lag_original * tick_lag_original
				step(to_push,d)
				to_push.bruteloss += h/10

/turf/simulated
	var/list/listofconnections = list()
	proc/Get_Connections()
		listofconnections = list()
		for(var/DIRE in cardinal)
			CHECK_TICK_WATER()
			var/tmp/turf/simulated/to_add = get_step(src,DIRE)
			if(istype(to_add,/turf/simulated))
				if(to_add.Water_Can_Pass(water_height))
					listofconnections += to_add
	proc/Water_React()
		if(round(water_height) > 0)
			if(!(src in water_changed))
				water_changed += src
	proc/Can_Still_Process()
		if(round(water_height) == 0)
			//water_height = 0
			if(src in water_changed)
				water_changed -= src
/turf/simulated/proc/Process_Water()
	if(listofconnections.len < 1 || water_cycles % 5 == 1)
		Get_Connections()
		if(listofconnections.len == 0)
			if(src in water_changed)
				water_changed -= src
			return //Stop processing this as there's nothing to flood.
	for(var/a in listofconnections)
		if(istype(a,/turf/simulated))
			CHECK_TICK_WATER()
			var/turf/simulated/pe = a
			if(pe.water_height != 99999999) //only called if a flooded turf is gonna flood another
				if(round(water_height) > 0)
					if(pe.water_height < water_height)
						var/tmp/calc = (water_height != 99999999 ? water_height/(1+listofconnections.len) : 8)
						pe.water_height = pe.water_height + calc
						water_height = water_height - calc*(water_height != 99999999)
						if(calc > 5)
							pe.water_mob_act(get_dir(src,pe),calc)

					if(!(pe in water_changed))
						if(round(pe.water_height) > 0)
							water_changed += pe

					pe.Render_Water_Icon()
				pe.Can_Still_Process()
	Can_Still_Process()
	Render_Water_Icon()

var/global/datum/controller/water_system/water_master
datum
	controller
		water_system
			var/done = 0
			proc
				process()
					water_processed = 0
					done = 0
					while(done < water_objects.len)
						done += 1
						var/obj/water/W = water_objects[done]
						if(W)
							CHECK_TICK_WATER()
							W.Process_Water()
						done += 1
					done = 0
					while(done < water_changed.len)
						done += 1
						var/turf/simulated/T = water_changed[done]
						if(T)
							CHECK_TICK_WATER()
							T.Process_Water()