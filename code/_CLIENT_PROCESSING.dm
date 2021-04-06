/*
TO-DO overly optimize
*/

mob
	Move(NewLoc,Dir,step_x,step_y)
		if(ANIMATION_RUNNING)
			return
		var/turf/OldLoc = src.loc

		..()
		//world << "hi this just got called"
		var/turf/TA = NewLoc //We need to check if we can get here actually.

		var/canStandHere = 1
		for(var/mob/i in TA.contents)
			if(i != src)
				//world << "heightZ >= i.heightZ = <font color='green'>[heightZ >= i.heightZ]</font> - heightZ <= i.heightZ+heightSize = <font color='green'>[heightZ <= i.heightZ+heightSize]</font>"
				if(heightZ+heightSize > i.heightZ && heightZ < i.heightZ+i.heightSize)
					//world << "<font color='red'>no you idiot dont stand on the [i]"
					canStandHere = 0
		for(var/atom/i in NewLoc)
			if(!istype(i,/mob))
				if(i.density)
					canStandHere = 0
		if(TA.density)
			canStandHere = 0
		if(heightZ < TA.TurfHeight)
			loc = OldLoc
		else
			if(canStandHere) //No dont go through... Dumb...
				loc = NewLoc
		for(var/mob/i in OldLoc.contents)
			if(i != src && i.heightZ == heightZ+heightSize)
				i.glide_size = glide_size
				i.Move(NewLoc,Dir,step_x,step_y)
		if(MyShadow)
			MyShadow.dir = dir
			MyShadow.loc = locate(x,y,z)

		if(loc == NewLoc)
			if(onFloor == 1) //we only make footsteps on ground.
				var/turf/T = locate(x,y,z)

				if(T && T.TurfStepSound != null)
					playsound(src, pick(T.TurfStepSound), 100, 0, 8, 0)
/client
	//animate_movement = 2
	var
		ping = 0
	verb
		ping(time as num)
			set instant = 1
			set waitfor = 0
			set hidden = 1
			ping = (world.time+tick_lag_original*world.tick_usage/100)-time
			sleep(1)
			ping(world.time+tick_lag_original*world.tick_usage/100)
			//winset(src,null,"command=ping+[world.time+tick_lag_original*world.tick_usage/100]")
	New()
		. = ..()
		ping()
	var/s = 0
	var/n = 0
	var/e = 0
	var/w = 0
	var/j = 0
	var/spri = 0

	var/mousedown
	verb/KeyDownM(a as text)
		set instant = 1
		set hidden = 1
		switch(a)
			if("east")
				e = 1
			if("west")
				w = 1
			if("south")
				s = 1
			if("north")
				n = 1
			if("jump")
				j = 1
			if("shift")
				spri = 1
	verb/KeyUpM(a as text)
		set instant = 1
		set hidden = 1
		switch(a)
			if("east")
				e = 0
			if("west")
				w = 0
			if("south")
				s = 0
			if("north")
				n = 0
			if("jump")
				j = 0
			if("shift")
				spri = 0
	DblClick(atom/object,location,control,params)
		..()
		if(object && spri)
			object.examineproc(mob)
	MouseDown(atom/object,location,control,params)
		..()
		mousedown = 1
		var/obj/item/weapon/gun/G = null
		if (!( mob.hand ))
			G = mob.r_hand
		else
			G = mob.l_hand
		if(istype(G,/obj/item/weapon/gun))
			if(!(object in screen))
				if(!G.automatic)
					if(mouse_position && eye && mousedown)
						var/mos_x = mouse_position.WorldX()
						var/mos_y = mouse_position.WorldY()
						G.fire(mob,mos_x,mos_y)
	MouseUp()
		..()
		mousedown = 0
	proc/GetDirection()
		var/obj/item/weapon/gun/G = null
		if (!( mob.hand ))
			G = mob.r_hand
		else
			G = mob.l_hand
		var/can_mo = 1
		if(istype(G,/obj/item/weapon/gun))
			if(mousedown)
				can_mo = 0
		if(mob)
			if(spri)
				mob.m_intent = "run"
				if(mob.hud_used)
					if(mob.hud_used.move_intent)
						mob.hud_used.move_intent.icon_state = "running"
			else
				mob.m_intent = "walk"
				if(mob.hud_used)
					if(mob.hud_used.move_intent)
						mob.hud_used.move_intent.icon_state = "walking"
		var/dirAA = (s*SOUTH)+(n*NORTH)+(e*EAST)+(w*WEST)
		if(dirAA != 0 && can_mo)
			Move(get_step(mob,dirAA),dirAA)
		if(j)
			mob.Jump()
		if(mouse_position && eye && mousedown)
			var/mos_x = mouse_position.WorldX()
			var/mos_y = mouse_position.WorldY()
			mob.dir = get_dir(mob.loc,locate((mos_x/32)+1,(mos_y/32)+1,mob.z))
			if(mob.MyShadow)
				mob.MyShadow.dir = mob.dir
			if(istype(G,/obj/item/weapon/gun) && G.automatic)
				G.fire(mob,mos_x,mos_y)
		if (isobj(src.mob.loc) || ismob(src.mob.loc))
			var/atom/O = src.mob.loc
			if (src.mob.canmove)
				return O.relaymove(src.mob, dirAA)
	Stat()
		..()
		if(mob)
			var/obj/item/weapon/gun/G = null
			if (!( mob.hand ))
				G = mob.r_hand
			else
				G = mob.l_hand
			if(istype(G,/obj/item/weapon/gun))
				stat("Gun ammo :","[G.ammo]/[G.ammo_max]")
/client/Move(n, direct)
	if (!( src.mob ))
		return
	if(src.mob.ANIMATION_RUNNING)
		return
	glide_size = mob.glide_size

	if(istype(src.mob, /mob/dead/observer))
		var/g = src.mob.Move(n,direct)
		if(mob)
			if(mob.MyShadow)
				mob.MyShadow.loc = mob.loc
		return g

	if (src.moving)
		return 0

	if (src.mob.stat == 2)
		return

	if (isobj(src.mob.loc) || ismob(src.mob.loc))
		return 0

	if(mob)
		if(mob.buckled)
			mob.glide_size = mob.buckled.glide_size
			glide_size = mob.glide_size
			if(mob.MyShadow)
				mob.MyShadow.glide_size = mob.glide_size
			var/boy = mob.buckled.relaymove(mob, direct)
			if(mob.MyShadow)
				mob.MyShadow.loc = mob.loc
			return boy

	if (world.time < src.move_delay)
		return

	if(istype(src.mob, /mob/living/silicon/ai))
		return AIMove(n,direct,src.mob)


	if (locate(/obj/item/weapon/grab, locate(/obj/item/weapon/grab, src.mob.grabbed_by.len)))
		var/list/grabbing = list(  )
		if (istype(src.mob.l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.mob.l_hand
			grabbing += G.affecting
		if (istype(src.mob.r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.mob.r_hand
			grabbing += G.affecting
		for(var/obj/item/weapon/grab/G in src.mob.grabbed_by)
			if (G.state == 1)
				if (!( grabbing.Find(G.assailant) ))
					del(G)
			else
				if (G.state == 2)
					src.move_delay = world.time + 10
					if (prob(25))
						mob.visible_message("\red [mob] has broken free of [G.assailant]'s grip!")
						del(G)
					else
						return
				else
					if (G.state == 3)
						src.move_delay = world.time + 10
						if (prob(5))
							mob.visible_message("\red [mob] has broken free of [G.assailant]'s headlock!")
							del(G)
						else
							return

	if (src.mob.canmove)


		var/j_pack = 0
		if ((istype(src.mob.loc, /turf/space)))
			if (!( src.mob.restrained() ))
				if (!( (locate(/obj/grille) in oview(1, src.mob)) || (locate(/turf/simulated) in oview(1, src.mob)) || (locate(/obj/lattice) in oview(1, src.mob)) ))
					if (istype(src.mob.back, /obj/item/weapon/tank/jetpack))
						var/obj/item/weapon/tank/jetpack/J = src.mob.back
						j_pack = J.allow_thrust(0.01, src.mob)
						if(j_pack)
							src.mob.inertia_dir = 0
						if (!( j_pack ))
							return 0
					else
						return 0
			else
				return 0



		if (isturf(src.mob.loc))
			src.move_delay = world.time

			if ((j_pack && j_pack < 1))
				src.move_delay += 5

			if (src.mob.drowsyness > 0)
				src.move_delay += 6

			switch(src.mob.m_intent)

				if("run")

					src.move_delay += 2

				if("walk")
					src.move_delay += 3

			src.move_delay += src.mob.movement_delay()
			if (src.mob.resting || src.mob.lying)
				return 0
			if (src.mob.restrained())
				for(var/mob/M in range(src.mob, 1))
					if (((M.pulling == src.mob && (!( M.restrained() ) && M.stat == 0)) || locate(/obj/item/weapon/grab, src.mob.grabbed_by.len)))
						src << "\blue You're restrained! You can't move!"
						return 0

			src.moving = 1

			var/RLMove = max(tick_lag_original,(src.move_delay - world.time))
			mob.glide_size = (world.icon_size/RLMove)*tick_lag_original

			glide_size = mob.glide_size
			if(mob.MyShadow)
				mob.MyShadow.glide_size = mob.glide_size

			if (locate(/obj/item/weapon/grab, src.mob))
				src.move_delay = max(src.move_delay, world.time + 7)

				var/list/L = src.mob.ret_grab()
				if (istype(L, /list))
					if (L.len == 2)
						L -= src.mob
						var/mob/M = L[1]
						if ((get_dist(src.mob, M) <= 1 || M.loc == src.mob.loc))
							var/turf/T = src.mob.loc
							. = ..()
							if (isturf(M.loc))
								var/diag = get_dir(src.mob, M)
								if ((diag - 1) & diag)
								else
									diag = null
								if ((get_dist(src.mob, M) > 1 || diag))
									step(M, get_dir(M.loc, T))
					else
						for(var/mob/M in L)
							M.other_mobs = 1
							if (src.mob != M)
								M.animate_movement = 2
						for(var/mob/M in L)
							spawn( 0 )
								step(M, direct)
								return
							spawn( 1 )
								M.other_mobs = null
								M.animate_movement = 2
								return

			else
				if(src.mob.confused)
					step(src.mob, pick(cardinal))
				else
					. = ..()
			src.moving = null
	if(mob)
		if(mob.MyShadow)
			mob.MyShadow.loc = mob.loc
	return .

var/current_radio_song = null

client/proc/ProcessClient()
	shake *= -0.95
	if(shake < 0.5 && shake > -0.5)
		shake = 0
	pixel_y4 = shake
	pixel_y = round(pixel_y1 + pixel_y2 + pixel_y3 + pixel_y4 + pixel_y5)
	GetDirection()
	if(mob)
		if(istype(mob,/mob/living))
			create_health()
		//Get_Number_Time()

		if(mouse_position)
			if(!(mouse_position.MouseCatcher in screen))
				screen += mouse_position.MouseCatcher
		else
			mouse_position =  new(src)
		var/A_S = 0
		for(var/sound/i in list(amb_sound,amb_sound_ext,amb_sound_area,radio_sound,amb_sound_water))
			if(i.status != SOUND_UPDATE)
				i.status = SOUND_UPDATE
				i.channel = SOUND_CHANNEL_1+A_S
				i.repeat = 1
				A_S = A_S + 1
		var/turf/T = mob.loc
		if(T)
			var/area/A = T.loc
			if(istype(A,/area))
				if(A.name != "Space" && !A.song && A.ambi == 1 && !istype(T,/turf/space))
					inc_volume()
				else
					if(A.song)
						if(A.song != old_song)
							old_song = A.song
							src << sound(null,channel=SOUND_CHANNEL_1+2)
							amb_sound_area.file = A.song
					dec_volume(A.song != null)
		else
			var/area/A = T.loc
			if(istype(A,/area))
				if(A.song)
					if(A.song != old_song)
						old_song = A.song
						src << sound(null,channel=SOUND_CHANNEL_1+2)
						amb_sound_area.file = A.song
				dec_volume(A.song != null)
		/*if(ticker)
			if(istype(ticker.mode,/datum/game_mode/battle_royale))
				mob.ProcessBattleRoyale()*/
		if(music_pitch < music_pitch_new)
			music_pitch += 0.0025
			if(music_pitch > music_pitch_new)
				music_pitch = music_pitch_new
		if(music_pitch > music_pitch_new)
			music_pitch -= 0.0025
			if(music_pitch < music_pitch_new)
				music_pitch = music_pitch_new
		amb_sound.volume = vol
		amb_sound_ext.volume = vol_ext
		amb_sound_ext.frequency = music_pitch
		if(istype(T,/turf))
			amb_sound_water.volume = (mob.heightZ+mob.heightSize<round(T.water_height))*100
		else
			amb_sound_water.volume = 0
		amb_sound.frequency = music_pitch
		radio_sound.frequency = music_pitch
		if(amb_sound_area.file)
			amb_sound_area.frequency = music_pitch
			amb_sound_area.volume = vol_area*music_vol_mult
			src << amb_sound_area
		src << amb_sound
		src << amb_sound_ext
		src << amb_sound_water
		if(current_radio_song != old_radio_sound)
			old_radio_sound = current_radio_song
			src << sound(null,channel=SOUND_CHANNEL_1+3)
			radio_sound.file = current_radio_song
		if(radio_sound && istype(mob,/mob/living/carbon/human))
			if(istype(mob:ears,/obj/item/device/radio/headset) && radio_sound.file)
				radio_sound.volume = 100
			else
				radio_sound.volume = 0
		else
			radio_sound.volume = 0
		src << radio_sound


/client/proc/create_health()
	if(health.len == 0)
		var/obj/screen_num/numbG2 = new()
		numbG2.icon = 'icons/mob/screen1.dmi'
		numbG2.screen_loc = "WEST,NORTH"
		numbG2.icon_state = "%"
		health += numbG2
		for(var/i in 1 to 3)
			var/obj/screen_num/numbG = new()
			numbG.icon = 'icons/mob/screen1.dmi'
			numbG.screen_loc = "WEST:[((i-1)*4)],NORTH"
			//screen += numbG
			health += numbG
	if(!(health in screen))
		screen += health
	var/plrText = "[round(max(0,(mob.health/mob.maxhealth)*100))]"
	if(length(plrText) == 2) //Can't be 50, must be something like _50
		plrText = " [plrText]"
	if(length(plrText) == 1)
		plrText = "  [plrText]"
	for(var/i in 1 to 3)
		var/obj/screen_num/numbG = health[i+1]
		if(numbG)
			numbG.icon_state = "healthnum[copytext(plrText,i,i+1)]" //Get every digit

client/proc/dec_volume(var/am_i)

	vol = vol - 5
	if(vol < 0)
		vol = 0
	if(am_i)
		vol_ext = vol_ext - 5
		vol_area = vol_area + 5
		if(vol_area > 100)
			vol_area = 100
		if(vol_ext < 0)
			vol_ext = 0
	else
		vol_area = vol_area - 5
		if(vol_area < 0)
			vol_area = 0
		vol_ext = vol_ext + 5
		if(vol_ext > 100)
			vol_ext = 100

client/proc/inc_volume()
	vol = vol + 5
	vol_area = vol_area - 5
	vol_ext = vol_ext - 5
	if(vol_area < 0)
		vol_area = 0
	if(vol_ext < 0)
		vol_ext = 0
	if(vol > 100)
		vol = 100
area
	var/ambi = 1

client
	control_freak = CONTROL_FREAK_ALL | CONTROL_FREAK_MACROS
	var/pixel_y1 = 0 //normal shit
	var/pixel_y2 = 0 //kart shit
	var/pixel_y3 = 0 //effects
	var/pixel_y4 = 0 //misc shit i think
	var/pixel_y5 = 0 //height system
	var/shake = 0
	var/music_vol_mult = 1

	var/list/health = list() //Health hud stuff
	var/sound/amb_sound = sound('music/interior.ogg')
	var/vol = 0 //Ambient sound vol
	var/sound/amb_sound_ext = sound('music/exterior.ogg')
	var/vol_ext = 0 //Ambient sound vol
	var/sound/amb_sound_area = sound('music/silence.ogg')
	var/sound/amb_sound_water = sound('music/water.ogg')
	var/old_song = 'music/silence.ogg'
	var/vol_area = 0 //Ambient sound vol
	var/sound/radio_sound = sound('music/silence.ogg')
	var/old_radio_sound = null
	var/music_pitch = 1
	var/music_pitch_new = 1
	verb
		Mute_Music()
			music_vol_mult = !music_vol_mult
			if(music_vol_mult)
				src << "<b>Music enabled."
			else
				src << "<b>Music disabled."
/obj/screen
	appearance_flags = PIXEL_SCALE | TILE_BOUND | NO_CLIENT_COLOR
/obj/screen_num
	plane = 10
	appearance_flags = PIXEL_SCALE | TILE_BOUND | NO_CLIENT_COLOR
/obj/screen_alt
	appearance_flags = PIXEL_SCALE | TILE_BOUND | NO_CLIENT_COLOR

/obj/screen_alt/heightCalc
	plane = 10
	icon = 'icons/mob/screen1.dmi'
	icon_state = "plr"
	screen_loc = "WEST+3, NORTH:0"
	heightG
		icon_state = "height"

/mob
	var/obj/screen_alt/heightCalc/c1 = null
	var/obj/screen_alt/heightCalc/heightG/c2 = null

/obj/hud/proc/instantiate_height_calculator()
	if(!mymob.c1)
		mymob.c1 = new
	if(!mymob.c2)
		mymob.c2 = new

	mymob.client.screen += mymob.c1
	mymob.client.screen += mymob.c2

