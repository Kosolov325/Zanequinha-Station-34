/datum/game_mode/battle_royale
	name = "Dabber Station 13 Battle Royale"
	config_tag = "fortnite"
	events_enabled = 0
	sandbox_allowed = 0
	do_kick = 1

/datum/game_mode/battle_royale/pre_setup()
	..()
	//244,202
	BATTLE_ROYALE_PLANE = new(locate(202+49,207,1))
	STORM = new(locate(202+49,202+49,1))
	var/list/objects = list(
	/obj/item/weapon/gun/pistol,
	/obj/item/weapon/gun/machine_gun,
	/obj/item/weapon/gun/shotgun,
	/obj/item/weapon/storage/backpack,
	/obj/item/weapon/grenade/explosiongrenade,
	/obj/item/clothing/suit/armor/vest,
	/obj/item/weapon/reagent_containers/food/drinks/cola,
	/obj/item/weapon/reagent_containers/food/drinks/slurp_juice
	)
	for(var/obj/loot_spawner/G in world)
		for(var/i in 1 to rand(2,3))
			var/A = pick(objects)
			var/location = locate(G.x+rand(-1,1),G.y+rand(-1,1),G.z)
			if(location:density == 0)
				new A(location)
			else
				new A(G.loc)
	return 1

var/client/lastplr = null
/datum/game_mode/battle_royale/ending()
	..()

/datum/game_mode/battle_royale/check_finished()
	if(!(world.port in PORTS_NOT_ALLOWED))
		if(plrs <= 1)
			if(lastplr)
				world << "<b><font size=6><font color='#00FFFF'>[lastplr.key] won!"
			world << 'victory.ogg'
			world.fps = 6 //slow mo effect
			sleep(22)
			world.fps = 60
			return 1
	return 0

var/dropped = 0
/obj/loot_spawner
	//random loot spawner
	density = 0
	anchored = 1
	icon = 'icons/obj/screen1.dmi'
	icon_state = "x2"
	mouse_opacity = 0
	New()
		..()
		alpha = 0

/area/var/storm = 0
/area/forest/storm = 1

/mob/var/used_to_be_in_storm = 0
/mob/var/INPLANE = 1

/mob/proc/ProcessBattleRoyale()
	if(istype(src,/mob/living/carbon))
		if(INPLANE)
			if (client && BATTLE_ROYALE_PLANE)
				//var/yG = 203
				spawn()
					if(BATTLE_ROYALE_PLANE.forced_drop == 0 && client && client.j == 0)
						loc = locate(BATTLE_ROYALE_PLANE.x,BATTLE_ROYALE_PLANE.y+2,BATTLE_ROYALE_PLANE.z)
						glide_size = BATTLE_ROYALE_PLANE.glide_size
						heightZ = 9999999 //Special case
						ySpeed = 0
					else
						loc = BATTLE_ROYALE_PLANE.loc
						heightZ = BATTLE_ROYALE_PLANE.pixel_z
						ySpeed = 0
						INPLANE = 0
						world << sound("sound/busdrop[rand(1,3)].ogg")
						spawn(20)
							dropped += 1
		if(STORM)
			if(get_dist_alt(src,STORM) > STORM.size/2)
				if(!used_to_be_in_storm)
					used_to_be_in_storm = 1
					src << 'stormenter.ogg'
				if(frm_counter % 60 == 1)
					TakeBruteDamage(2)
			else
				if(used_to_be_in_storm)
					used_to_be_in_storm = 0

turf
	proc
		init_storm()
			if(!shading)
				shading = new(locate(x,y,z))
				shading.icon_state = "storm" //easy to handle

var/obj/storm_overlay/STORM = null
#define TIMER_TOTAL 25
#define STORMSPEEDMULTIPLIER 0.25
#define STORMMOVESPEED 16
#define STORMMOVESFORSECS 25
obj/storm_overlay
	anchored = 1
	plane = SHADING_PLANE
	blend_mode = BLEND_ADD
	appearance_flags = RESET_COLOR | PIXEL_SCALE | LONG_GLIDE
	icon = 'extra images/bigcircle.dmi'
	icon_state = "circle"
	mouse_opacity = 0
	density = 0
	pixel_x = -2048+16
	pixel_y = -2048+16
	var/size = 128
	var/timer_left = TIMER_TOTAL
	var/decrementing = 0
	ex_act()
		return
	layer = LIGHT_LAYER + 1
	proc/updatestormsize()
		var/matrix/M = matrix()
		M.Scale(max(0,size/128))
		transform = M
		glide_size = 32 / STORMMOVESPEED * tick_lag_original
	special_process()
		timer_left -= world.tick_lag/10
		updatestormsize()
		if(timer_left < 0 && !decrementing)
			world << 'storm.ogg'
			walk_towards(src,locate(rand(202,299),rand(202,299),1),STORMMOVESPEED,0)
			decrementing = 1
		if(decrementing)
			size -= world.tick_lag*STORMSPEEDMULTIPLIER
			if(size < 16)
				size = 16
			if(timer_left < -STORMMOVESFORSECS)
				walk(src,0)
				decrementing = 0
				timer_left = TIMER_TOTAL*(1+(round(plrs/4)))
	New()
		..()
		special_processing += src
	Del()
		special_processing -= src
		..()

var/obj/plane_thing/BATTLE_ROYALE_PLANE = null
/obj/plane_thing
	//for battle royale
	icon = 'icons/obj/battle_royale_plane.dmi'
	plane = BELOW_SHADING //ontop everything
	var/forced_drop = 0
	var/obj/shadow/s = null
	pixel_x = -40+16
	pixel_z = 200
	New()
		..()
		special_processing += src
		s = new()
		s.icon = icon
		s.icon_state = icon_state
	Del()
		del s
		special_processing -= src
		..()
	special_process()
		if(y > 293)
			forced_drop = 1
		glide_size = 32 / 2.5 * tick_lag_original
		if(frm_counter % 15 == 1)
			y += 1
		s.pixel_x = pixel_x
		s.glide_size = glide_size
		s.loc = loc
		if(z == 0)
			del src
/mob/living/carbon/human/proc/Spawn_Fortain(rank, joined_late)
	src.equip_if_possible(new /obj/item/clothing/under(src), slot_w_uniform)
	src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)

	src.loc = locate(202,202,1)
	INPLANE = 1
	src << "Press space to jump into the map! You will be forced off automatically if you don't."
	return