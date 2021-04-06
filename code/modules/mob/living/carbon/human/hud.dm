#define UIHUDLAYER 2
atom
	appearance_flags = PIXEL_SCALE

/obj/hud
	plane = HUD_PLANE

/mob
	var/obj/screen_alt/plane_master_turf2/plane_master_turf = null
	var/obj/screen_alt/plane_master_turf3/lighting_master = null
	var/obj/screen_alt/plane_master_parallax_layer_1/parallax_master_1 = null
	var/obj/screen_alt/plane_master_parallax_layer_2/parallax_master_2 = null

/obj/screen_alt/plane_master_turf2
	plane = WALL_PLANE
	screen_loc = "1,1"
	filters = filter(type="drop_shadow", x=0, y=0,size=5, offset=2, color=rgb(0,0,0,190))
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER | PLANE_MASTER

/obj/screen_alt/plane_master_parallax_layer_1
	plane = SPACE_PLANE_0
	screen_loc = "1,1"
	appearance_flags = PIXEL_SCALE | PLANE_MASTER | TILE_BOUND

/obj/screen_alt/plane_master_parallax_layer_2
	plane = SPACE_PLANE_1
	screen_loc = "1,1"
	appearance_flags = PIXEL_SCALE | PLANE_MASTER | TILE_BOUND


/obj/screen
	plane = HUD_PLANE
	layer = 1

/obj/hud/proc/instantiate_plane_master()
	if(!mymob.plane_master_turf)
		mymob.plane_master_turf = new
	if(!mymob.lighting_master)
		mymob.lighting_master = new
	if(!mymob.parallax_master_1)
		mymob.parallax_master_1 = new
	if(!mymob.parallax_master_2)
		mymob.parallax_master_2 = new

	mymob.client.screen += mymob.plane_master_turf
	mymob.client.screen += mymob.lighting_master
	mymob.client.screen += mymob.parallax_master_1
	mymob.client.screen += mymob.parallax_master_2

	return

/obj/hud/proc/parallax()
	if(!mymob)
		return
	for(var/obj/screen_alt/spaceParallax/g in mymob.space_parallax_list_1 + mymob.space_parallax_list_2)
		del g
	mymob.space_parallax_list_1 = list()
	mymob.space_parallax_list_2 = list()
	for(var/xA in 0 to 2)
		for(var/yA in 0 to 2)
			var/matrix/M = matrix()
			M.Translate(xA*1024,yA*1024)
			var/obj/screen_alt/spaceParallax/g = new()
			g.transform = M
			g.plane = SPACE_PLANE_0
			mymob.space_parallax_list_1 += g
			var/obj/screen_alt/spaceParallax/g2 = new()
			g2.transform = M
			g2.plane = SPACE_PLANE_1
			mymob.space_parallax_list_2 += g2

	mymob.client.screen += mymob.space_parallax_list_1
	mymob.client.screen += mymob.space_parallax_list_2

mob
	sight = SEE_BLACKNESS

/obj/hud/proc/instantiate()

	if(!mymob)
		world << "<font color='red'>ALERT : No mob/client found. HUD will break. Not adding hud."
		return
	if(!mymob.client)
		return
	mymob.client.screen = list()

	//world << "<font color='red'>Parallax time."

	//world << "<font color='red'>init"
	parallax()

	instantiate_plane_master()


	mymob.ParallaxMove()

	if(mymob.uses_hud)
		spawn()
			if(istype(mymob, /mob/living/carbon/human))
				instantiate_height_calculator() //we need to instantiate the height calculator
				src.human_hud()
				//return

			if(istype(mymob, /mob/living/silicon/ai))
				src.ai_hud()
				//return

			if(istype(mymob, /mob/living/silicon/robot))
				src.robot_hud()
				//return

			if(istype(mymob, /mob/dead/observer))
				src.ghost_hud()
				//return

/obj/screen_alt/spaceParallax
	icon = 'extra images/parallax.dmi'
	name = "space parallax image"
	screen_loc = "1,1"
	icon_state = "layer1"
	appearance_flags = PIXEL_SCALE | TILE_BOUND
	layer = 1
	mouse_opacity = 0
	var/xF = 0
	var/yF = 0

mob
	can_push = 0
	var/list/space_parallax_list_1 = list()
	var/list/space_parallax_list_2 = list()
	var/space_parallax_layer_1_old = ""
	var/space_parallax_layer_2_old = ""
	//var/obj/screen_alt/plane_master_turf2/plane_master_turf = null

	proc/ParallaxMove()
		if(!client)
			return
		var/turf/T = loc
		var/area/A = null
		var/cando = 0
		if(T)
			A = T.loc
		if(istype(A,/area))
			cando = A.parallax_type
		switch(cando)
			if(2)
				ParallaxLayer(parallax_master_1,space_parallax_list_1,0.25,0.25,"layer1",0,0)
				ParallaxLayer(parallax_master_2,space_parallax_list_2,2,2,"layer2alt",(world.time),(world.time/2))
			if(1)
				ParallaxLayer(parallax_master_1,space_parallax_list_1,1,0,"layer",(world.time),0)
				ParallaxLayer(parallax_master_2,space_parallax_list_2,2,2,"layer2alt",(world.time/2),(world.time/4))
			if(0)
				ParallaxLayer(parallax_master_1,space_parallax_list_1,0.5,0.5,"layer1",0,0)
				ParallaxLayer(parallax_master_2,space_parallax_list_2,1,1,"layer2",0,0)
	proc/ParallaxLayer(var/obj/screen_alt/G,var/list/space_list,var/mult_1,var/mult_2,var/iconA,var/offsetX,var/offsetY)
		if(!client)
			return //don't do this.
		if(!client.eye)
			return //you shouldn't be doing it without a proper location, dumbass
		if(space_list.len <= 0)
			return //no space? no process
		var/yoffset = client.pixel_z + client.pixel_y
		var/xoffset = client.pixel_x + client.pixel_w
		var/atom/eye = client.eye
		var/xAxis = round((((eye.x+(xoffset/32))*mult_1) + offsetX)) % 1024
		var/yAxis = round((((eye.y+(yoffset/32))*mult_2) + offsetY)) % 1024

		var/can_change_icon = 0
		if(space_list == space_parallax_list_1)
			if(iconA != space_parallax_layer_1_old)
				space_parallax_layer_1_old = iconA
				can_change_icon = 1
		else
			if(iconA != space_parallax_layer_2_old)
				space_parallax_layer_2_old = iconA
				can_change_icon = 1

		if(can_change_icon)
			for(var/obj/screen_alt/spaceParallax/g in space_list)
				if(g.icon_state != iconA)
					g.icon_state = iconA
		var/matrix/M = matrix()
		M.Translate(-xAxis,-yAxis)
		G.transform = M
/mob/verb/use_hotkey()
	set hidden = 1
	set name = "use_hotkey"
	var/obj/item/G = null
	//attack_self(mob/user)
	if (!( src.hand ))
		G = r_hand
	else
		G = l_hand
	if(G)
		G.attack_self(src)
/mob/verb/toggle_throw()
	set hidden = 1
	set name = "toggle_throw"
	if (!usr.stat && isturf(usr.loc) && !usr.restrained())
		usr:toggle_throw2_mode()

/mob/verb/switch_intent(ass as text)
	set hidden = 1
	set name = "switch_intent" //LOL
	switch(ass)
		if("disarm")
			usr.a_intent = "disarm"
			usr.hud_used.action_intent.icon_state = "disarm"
		if("hurt")
			usr.a_intent = "hurt"
			usr.hud_used.action_intent.icon_state = "harm"
		if("grab")
			usr.a_intent = "grab"
			usr.hud_used.action_intent.icon_state = "grab"
		if("help")
			usr.a_intent = "help"
			usr.hud_used.action_intent.icon_state = "help"
/mob
	var/obj/screen/HUDPosSel = null

/obj/screen/Click(location, control, params)

	var/list/pa = params2list(params)
	//world << "screen click"
	usr.db_click(src.name, null)
	switch(src.name)
		if("map")

			usr.clearmap()
		if("maprefresh")
			var/obj/machinery/computer/security/seccomp = usr.machine

			if(seccomp!=null)
				seccomp.drawmap(usr)
			else
				usr.clearmap()


		if("act_intent")
			if(pa.Find("left"))
				switch(usr.a_intent)
					if("help")
						usr.a_intent = "disarm"
						usr.hud_used.action_intent.icon_state = "disarm"
					if("disarm")
						usr.a_intent = "hurt"
						usr.hud_used.action_intent.icon_state = "harm"
					if("hurt")
						usr.a_intent = "grab"
						usr.hud_used.action_intent.icon_state = "grab"
					if("grab")
						usr.a_intent = "help"
						usr.hud_used.action_intent.icon_state = "help"
			else
				switch(usr.a_intent)
					if("help")
						usr.a_intent = "grab"
						usr.hud_used.action_intent.icon_state = "grab"
					if("disarm")
						usr.a_intent = "help"
						usr.hud_used.action_intent.icon_state = "help"
					if("hurt")
						usr.a_intent = "disarm"
						usr.hud_used.action_intent.icon_state = "disarm"
					if("grab")
						usr.a_intent = "hurt"
						usr.hud_used.action_intent.icon_state = "harm"

		if("mov_intent")
			usr << "Use shift instead."

		if("intent")
			if (!( usr.intent ))
				switch(usr.a_intent)
					if("help")
						usr.intent = "13,15"
					if("disarm")
						usr.intent = "14,15"
					if("hurt")
						usr.intent = "15,15"
					if("grab")
						usr.intent = "12,15"
			else
				usr.intent = null
		if("m_intent")
			if (!( usr.m_int ))
				switch(usr.m_intent)
					if("run")
						usr.m_int = "13,14"
					if("walk")
						usr.m_int = "14,14"
					if("face")
						usr.m_int = "15,14"
			else
				usr.m_int = null
		if("walk")
			usr.m_intent = "walk"
			usr.m_int = "14,14"
		if("face")
			usr.m_intent = "face"
			usr.m_int = "15,14"
		if("run")
			usr.m_intent = "run"
			usr.m_int = "13,14"
		if("hurt")
			usr.a_intent = "hurt"
			usr.intent = "15,15"
		if("grab")
			usr.a_intent = "grab"
			usr.intent = "12,15"
		if("disarm")
			if (istype(usr, /mob/living/carbon/human))
				var/mob/M = usr
				M.a_intent = "disarm"
				M.intent = "14,15"
		if("help")
			usr.a_intent = "help"
			usr.intent = "13,15"
		if("Reset Machine")
			usr.machine = null
		if("internal")
			if ((!( usr.stat ) && usr.canmove && !( usr.restrained() )))
				usr.internal = null
		if("pull")
			usr.pulling = null
		if("sleep")
			usr.sleeping = !( usr.sleeping )
		if("rest")
			usr.resting = !( usr.resting )
		if("throw2")
			if (!usr.stat && isturf(usr.loc) && !usr.restrained())
				usr:toggle_throw2_mode()
		if("drop")
			usr.drop_item_v()

		/*if("swap")
			usr:swap_hand() 0 is right apparently and 1 is left*/
		if("l_hand")
			usr:swap_hand2(1)
		if("r_hand")
			usr:swap_hand2(0)

		if("hand")
			usr:swap_hand()
		if("resist")
			if (usr.next_move < world.time)
				return
			usr.next_move = world.time + 20
			if ((!( usr.stat ) && usr.canmove && !( usr.restrained() )))
				for(var/obj/O in usr.requests)
					del(O)
				for(var/obj/item/weapon/grab/G in usr.grabbed_by)
					if (G.state == 1)
						del(G)
					else
						if (G.state == 2)
							if (prob(25))
								for(var/mob/O in viewers(usr, null))
									O.show_message(text("\red [] has broken free of []'s grip!", usr, G.assailant), 1)
								del(G)
						else
							if (G.state == 3)
								if (prob(5))
									for(var/mob/O in viewers(usr, null))
										O.show_message(text("\red [] has broken free of []'s headlock!", usr, G.assailant), 1)
									del(G)
				for(var/mob/O in viewers(usr, null))
					O.show_message(text("\red <B>[] resists!</B>", usr), 1)

			if(usr:handcuffed && usr:canmove && (usr.last_special <= world.time))
				usr.next_move = world.time + 100
				usr.last_special = world.time + 100
				usr << "\red You attempt to remove your handcuffs. (This will take around 2 minutes and you need to stand still)"
				for(var/mob/O in viewers(usr))
					O.show_message(text("\red <B>[] attempts to remove the handcuffs!</B>", usr), 1)
				spawn(0)
					if(do_after(usr, 1200))
						if(!usr:handcuffed) return
						for(var/mob/O in viewers(usr))
							O.show_message(text("\red <B>[] manages to remove the handcuffs!</B>", usr), 1)
						usr << "\blue You successfully remove your handcuffs."
						usr:handcuffed:loc = usr:loc
						usr:handcuffed = null


/obj/hud
	name = "hud"
	var/mob/mymob = null
	var/list/adding = null

	var/list/intents = null
	var/list/mov_int = null
	var/list/mon_blo = null
	var/list/m_ints = null
	var/obj/screen/druggy = null
	var/vimpaired = null
	var/obj/screen/alien_view = null
	var/obj/screen/g_dither = null
	var/obj/screen/blurry = null
	var/list/darkMask = null
	var/obj/screen/station_explosion = null
	var/h_type = /obj/screen



/obj/hud/proc/human_hud()

	src.adding = list(  )

	src.intents = list(  )
	src.mon_blo = list(  )
	src.m_ints = list(  )
	src.mov_int = list(  )
	src.vimpaired = list(  )
	src.darkMask = list(  )


	src.g_dither = new src.h_type( src )
	src.g_dither.screen_loc = "WEST,SOUTH to EAST,NORTH"
	src.g_dither.name = "Mask"
	src.g_dither.icon_state = "dither12g"
	src.g_dither.layer = 0
	src.g_dither.mouse_opacity = 0

	src.alien_view = new src.h_type(src)
	src.alien_view.screen_loc = "WEST,SOUTH to EAST,NORTH"
	src.alien_view.name = "Alien"
	src.alien_view.icon_state = "alien"
	src.alien_view.layer = 0
	src.alien_view.mouse_opacity = 0

	src.blurry = new src.h_type( src )
	src.blurry.screen_loc = "WEST,SOUTH to EAST,NORTH"
	src.blurry.name = "Blurry"
	src.blurry.icon_state = "blurry"
	src.blurry.layer = 0
	src.blurry.mouse_opacity = 0

	src.druggy = new src.h_type( src )
	src.druggy.screen_loc = "WEST,SOUTH to EAST,NORTH"
	src.druggy.name = "Druggy"
	src.druggy.icon_state = "druggy"
	src.druggy.layer = 0
	src.druggy.mouse_opacity = 0

	// station explosion cinematic
	src.station_explosion = new src.h_type( src )
	src.station_explosion.icon = 'icons/effects/station_explosion.dmi'
	src.station_explosion.icon_state = "start"
	src.station_explosion.layer = 200
	src.station_explosion.mouse_opacity = 0
	src.station_explosion.screen_loc = "1,3"

	var/obj/screen/using

	using = new src.h_type( src )
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon_state = (mymob.a_intent == "hurt" ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	using.layer = 1
	src.adding += using
	action_intent = using

	using = new src.h_type( src )
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = 1
	src.adding += using
	move_intent = using


	using = new src.h_type( src )
	using.name = "drop"
	using.icon_state = "act_drop"
	using.screen_loc = ui_dropbutton
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.name = "i_clothing"
	using.dir = SOUTH
	using.icon_state = "center"
	using.screen_loc = ui_iclothing
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.name = "o_clothing"
	using.dir = SOUTH
	using.icon_state = "equip"
	using.screen_loc = ui_oclothing
	using.layer = UIHUDLAYER
	src.adding += using

/*	using = new src.h_type( src )
	using.name = "headset"
	using.dir = SOUTHEAST
	using.icon_state = "equip"
	using.screen_loc = ui_headset
	using.layer = UIHUDLAYER
	if(istype(mymob,/mob/living/carbon/monkey)) using.overlays += blocked
	src.adding += using*/

	using = new src.h_type( src )
	using.name = "r_hand"
	using.dir = WEST
	using.icon_state = "equip"
	using.screen_loc = ui_rhand
	using.layer = 1
	src.adding += using

	using = new src.h_type( src )
	using.name = "l_hand"
	using.dir = EAST
	using.icon_state = "equip"
	using.screen_loc = ui_lhand
	using.layer = 1
	src.adding += using

	mymob.HUDPosSel = new src.h_type( src )
	mymob.HUDPosSel.name = "selectedUISlot"
	mymob.HUDPosSel.icon_state = "selectedUISlot"
	if (!( mymob.hand ))
		mymob.HUDPosSel.screen_loc = ui_rhand
	else
		mymob.HUDPosSel.screen_loc = ui_lhand
	mymob.HUDPosSel.layer = UIHUDLAYER
	src.adding += mymob.HUDPosSel

	using = new src.h_type( src )
	using.name = "id"
	using.dir = SOUTHWEST
	using.icon_state = "equip"
	using.screen_loc = ui_id
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.name = "mask"
	using.dir = NORTH
	using.icon_state = "equip"
	using.screen_loc = ui_mask
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.name = "back"
	using.dir = NORTHEAST
	using.icon_state = "equip"
	using.screen_loc = ui_back
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.name = "storage1"
	using.icon_state = "pocket"
	using.screen_loc = ui_storage1
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.name = "storage2"
	using.icon_state = "pocket"
	using.screen_loc = ui_storage2
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.name = "resist"
	using.icon_state = "act_resist"
	using.screen_loc = ui_resist
	using.layer = UIHUDLAYER
	src.adding += using



/*
	using = new src.h_type( src )
	using.name = "intent"
	using.icon_state = "intent"
	using.screen_loc = "15,15"
	using.layer = 20
	src.adding += using

	using = new src.h_type( src )
	using.name = "m_intent"
	using.icon_state = "move"
	using.screen_loc = "15,14"
	using.layer = 20
	src.adding += using
*/

	using = new src.h_type( src )
	using.name = "gloves"
	using.icon_state = "gloves"
	using.screen_loc = ui_gloves
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.name = "eyes"
	using.icon_state = "glasses"
	using.screen_loc = ui_glasses
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.name = "ears"
	using.icon_state = "ears"
	using.screen_loc = ui_ears
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.name = "head"
	using.icon_state = "hair"
	using.screen_loc = ui_head
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.name = "shoes"
	using.icon_state = "shoes"
	using.screen_loc = ui_shoes
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.name = "belt"
	using.icon_state = "belt"
	using.screen_loc = ui_belt
	using.layer = UIHUDLAYER
	src.adding += using

/*
	using = new src.h_type( src )
	using.name = "grab"
	using.icon_state = "grab"
	using.screen_loc = "12:-11,15"
	using.layer = UIHUDLAYER
	src.intents += using
	//ICONS
	using = new src.h_type( src )
	using.name = "hurt"
	using.icon_state = "harm"
	using.screen_loc = "15:-11,15"
	using.layer = UIHUDLAYER
	src.intents += using
	src.m_ints += using

	using = new src.h_type( src )
	using.name = "disarm"
	using.icon_state = "disarm"
	using.screen_loc = "14:-10,15"
	using.layer = UIHUDLAYER
	src.intents += using

	using = new src.h_type( src )
	using.name = "help"
	using.icon_state = "help"
	using.screen_loc = "13:-10,15"
	using.layer = UIHUDLAYER
	src.intents += using
	src.m_ints += using

	using = new src.h_type( src )
	using.name = "face"
	using.icon_state = "facing"
	using.screen_loc = "15:-11,14"
	using.layer = UIHUDLAYER
	src.mov_int += using

	using = new src.h_type( src )
	using.name = "walk"
	using.icon_state = "walking"
	using.screen_loc = "14:-11,14"
	using.layer = UIHUDLAYER
	src.mov_int += using

	using = new src.h_type( src )
	using.name = "run"
	using.icon_state = "running"
	using.screen_loc = "13:-11,14"
	using.layer = UIHUDLAYER
	src.mov_int += using
*/

	using = new src.h_type( src )
	using.name = null
	using.icon_state = "dither50"
	using.screen_loc = "WEST,SOUTH to EAST,NORTH"
	using.layer = 0
	using.mouse_opacity = 0
	src.vimpaired += using

	mymob.throw2_icon = new /obj/screen(null)
	mymob.throw2_icon.icon_state = "act_throw2_off"
	mymob.throw2_icon.name = "throw2"
	mymob.throw2_icon.screen_loc = ui_throw2
	mymob.throw2_icon.layer = UIHUDLAYER

	mymob.oxygen = new /obj/screen( null )
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

/*
	mymob.i_select = new /obj/screen( null )
	mymob.i_select.icon_state = "selector"
	mymob.i_select.name = "intent"
	mymob.i_select.screen_loc = "16:-11,15"

	mymob.m_select = new /obj/screen( null )
	mymob.m_select.icon_state = "selector"
	mymob.m_select.name = "moving"
	mymob.m_select.screen_loc = "16:-11,14"
*/

	mymob.toxin = new /obj/screen( null )
	mymob.toxin.icon = 'icons/mob/screen1.dmi'
	mymob.toxin.icon_state = "tox0"
	mymob.toxin.name = "toxin"
	mymob.toxin.screen_loc = ui_toxin

	mymob.internals = new /obj/screen( null )
	mymob.internals.icon_state = "internal0"
	mymob.internals.name = "internal"
	mymob.internals.screen_loc = ui_internal

	mymob.fire = new /obj/screen( null )
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	mymob.bodytemp = new /obj/screen( null )
	mymob.bodytemp.icon_state = "temp1"
	mymob.bodytemp.name = "body temperature"
	mymob.bodytemp.screen_loc = ui_temp

	mymob.healths = new /obj/screen( null )
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.shields = new /obj/screen( null )
	mymob.shields.icon_state = "health0"
	mymob.shields.name = "health"
	mymob.shields.screen_loc = ui_health

	mymob.pullin = new /obj/screen( null )
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_pull

	mymob.blind = new /obj/screen( null )
	mymob.blind.icon_state = "black"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "WEST,SOUTH to EAST,NORTH"
	mymob.blind.layer = 0
	mymob.blind.mouse_opacity = 0

	mymob.flash = new /obj/screen( null )
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "WEST,SOUTH to EAST,NORTH"
	mymob.flash.layer = 0
	mymob.flash.mouse_opacity = 0

	mymob.sleep = new /obj/screen( null )
	mymob.sleep.icon_state = "sleep0"
	mymob.sleep.name = "sleep"
	mymob.sleep.screen_loc = ui_sleep

	mymob.rest = new /obj/screen( null )
	mymob.rest.icon_state = "rest0"
	mymob.rest.name = "rest"
	mymob.rest.screen_loc = ui_rest

	/*/Monkey blockers

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_ears
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_belt
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_shoes
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_storage2
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_glasses
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_gloves
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_storage1
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_headset
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_oclothing
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_iclothing
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_id
	using.layer = 20
	src.mon_blo += using

	using = new src.h_type( src )
	using.name = "blocked"
	using.icon_state = "blocked"
	using.screen_loc = ui_head
	using.layer = 20
	src.mon_blo += using
//Monkey blockers
*/

	mymob.zone_sel = new /obj/screen/zone_sel( null )
	mymob.zone_sel.overlays = null
	mymob.zone_sel.overlays += image("icon" = 'icons/mob/zone_sel.dmi', "icon_state" = text("[]", mymob.zone_sel.selecting))

	//, mymob.i_select, mymob.m_select
	mymob.client.screen += list(mymob.throw2_icon, mymob.zone_sel, mymob.oxygen, mymob.toxin, mymob.bodytemp, mymob.internals, mymob.fire, mymob.healths, mymob.shields, mymob.pullin, mymob.blind, mymob.flash, mymob.rest, mymob.sleep) //, mymob.mach )
	mymob.client.screen += src.adding

	//if(istype(mymob,/mob/living/carbon/monkey)) mymob.client.screen += src.mon_blo

	return

	/*
	using = new src.h_type( src )
	using.dir = WEST
	using.screen_loc = "1,3 to 2,3"
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.dir = NORTHEAST
	using.screen_loc = "3,3"
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.dir = NORTH
	using.screen_loc = "3,2"
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.dir = SOUTHEAST
	using.screen_loc = "3,1"
	using.layer = UIHUDLAYER
	src.adding += using

	using = new src.h_type( src )
	using.dir = SOUTHWEST
	using.screen_loc = "1,1 to 2,2"
	using.layer = UIHUDLAYER
	src.adding += using
	*/