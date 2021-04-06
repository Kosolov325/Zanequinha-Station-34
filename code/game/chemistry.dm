#define REGULATE_RATE 5

/obj/item/weapon/grenade
	icon_state = "flashbang"
	var/state = null
	var/firestrength = 100
	var/det_time = 20.0
	can_throw = 0
	w_class = 2.0
	item_state = "flashbang"
	throw2_speed = 4
	throw2_range = 20

	plane = MOB_PLANE_ALT
	flags =  FPRINT | TABLEPASS | CONDUCT | ONBELT

	New()
		..()
		special_processing += src
		s = new()
		s.icon_state = "shadowsmall"
	Del()
		del s
		special_processing -= src
		..()


	var/spd = 0
	var/ang = 0
	var/h = 0
	pixel_z = -8
	var/y_speed = 0
	var/nextmove = 0
	var/obj/shadow/s = null
	layer = 4

	special_process()
		var/turf/T = loc
		if(istype(T,/turf))
			s.loc = src.loc
			if(world.time > nextmove && spd > 1 && h > 0.2)
				glide_size = 32 / (2.5-((spd/25)*2)) * tick_lag_original
				step(src,dir)
				nextmove = world.time + (2.5-((spd/25)*2))
			s.pixel_z = T.TurfHeight
			if(y_speed > -4)
				y_speed = y_speed - 0.1
			h = h + y_speed
			if(h < T.TurfHeight)
				y_speed = y_speed * -0.8
				spd = spd * 0.5
				h = T.TurfHeight
			ang = ang + spd
			var/matrix/M = matrix()
			M.Turn(ang)
			transform = M
			pixel_y = round(h)
		else
			s.loc = null
	thrown(mob/user)
		spd = rand(15,25)
		ang = 0
		h = user.heightZ
		y_speed = 3
		nextmove = world.time
		dir = user.dir

/obj/item/weapon/grenade/explosiongrenade
	desc = "It is set to detonate in 3 seconds."
	name = "grenade"
	icon = 'icons/obj/grenade.dmi'


/obj/item/weapon/grenade/explosiongrenade/attack_self(mob/user as mob)
	if (user.equipped() == src)
		if (!( src.state ))
			user << "\red You prime the grenade! [det_time/10] seconds! Throw it!"
			state = 1
			icon_state = "flashbang1"
			spawn( src.det_time )
				prime()
				return
		playsound(user, 'armbomb.ogg', 75, 1, -3)
		src.add_fingerprint(user)
	return

/obj/item/weapon/grenade/explosiongrenade/proc/prime()
	playsound(src, 'nice.ogg', 75, 1, -2)
	explosion(locate(x,y,z),2,4,6,4)
	del src

/obj/item/weapon/storage/beakerbox
	name = "Beaker Box"
	icon_state = "beaker"
	item_state = "syringe_kit"

/obj/item/weapon/storage/beakerbox/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )

/obj/item/weapon/paper/alchemy/
	name = "paper- 'Chemistry Information'"

/obj/item/weapon/storage/trashcan
	name = "disposal unit"
	w_class = 4.0
	anchored = 1.0
	density = 1.0
	var/processing = null
	var/locked = 1
	req_access = list(access_janitor)
	desc = "A compact incineration device, used to dispose of garbage."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "trashcan"
	item_state = "syringe_kit"

/obj/item/weapon/storage/trashcan/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (src.contents.len >= 7)
		user << "The trashcan is full!"
		return
	if (istype(W, /obj/item/weapon/disk/nuclear))
		user << "This is far too important to throw2 away!"
		return
	if (istype(W, /obj/item/weapon/storage/))
		return
	if (istype(W, /obj/item/weapon/grab))
		user << "You cannot fit the person inside."
		return
	var/t
	for(var/obj/item/weapon/O in src)
		t += O.w_class
		//Foreach goto(46)
	t += W.w_class
	if (t > 30)
		user << "You cannot fit the item inside. (Remove larger classed items)"
		return
	user.u_equip(W)
	W.loc = src
	if ((user.client && user.s_active != src))
		user.client.screen -= W
	src.orient2hud(user)
	W.dropped(user)
	W.plane = ITEM_PLANE
	add_fingerprint(user)
	user.visible_message("\blue [user] has put [W] in [src]!")

	if (src.contents.len >= 7)
		src.locked = 1
		src.icon_state = "trashcan1"
	spawn (200)
		if (src.contents.len < 7)
			src.locked = 0
			src.icon_state = "trashcan"
	return

/obj/item/weapon/storage/trashcan/attack_hand(mob/user as mob)
	if(src.allowed(usr))
		locked = !locked
	else
		user << "\red Access denied."
		return
	if (src.processing)
		return
	if (src.contents.len >= 7)
		user << "\blue You begin the emptying procedure."
		var/area/A = src.loc.loc		// make sure it's in an area
		if(!A || !isarea(A))
			return
//		var/turf/T = src.loc
		A.use_power(250, EQUIP)
		src.processing = 1
		src.contents.len = 0
		src.icon_state = "trashmelt"
		if (istype(loc, /turf))
			loc:hotspot_expose(1000,10)
		sleep (60)
		src.icon_state = "trashcan"
		src.processing = 0
		return
	else
		src.icon_state = "trashcan"
		user << "\blue Due to conservation measures, the unit is unable to start until it is completely filled."
		return


