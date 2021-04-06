/turf/Click()
	if(istype(usr, /mob/living/silicon/ai))
		return move_camera_by_click()
	if(usr.stat || usr.restrained() || usr.lying)
		return ..()
	/*
	if(usr.hand && istype(usr.l_hand, /obj/item/weapon/flamethrow2er))
		var/turflist = getline(usr,src)
		var/obj/item/weapon/flamethrow2er/F = usr.l_hand
		F.flame_turf(turflist)
		..()
	else if(!usr.hand && istype(usr.r_hand, /obj/item/weapon/flamethrow2er))
		var/turflist = getline(usr,src)
		var/obj/item/weapon/flamethrow2er/F = usr.r_hand
		F.flame_turf(turflist)
		..()
	else
	*/
	return ..()

/turf/New()
	..()
	if(lighting_inited)
		if(istype(src,/turf/space))
			del_lights()
		else
			var/area/a = loc
			if(a)
				if(a.forced_lighting == 1)
					if(a.sd_lighting == 1)
						init_light()
					else
						if(!istype(src,/turf/space))
							init_light()
	for(var/atom/movable/AM as mob|obj in src)
		spawn( 0 )
			src.Entered(AM)
			return
	return

/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if (!mover || !isturf(mover.loc))
		return 1


	//First, check objects to block exit that are not on the border
	for(var/obj/obstacle in mover.loc)
		if((obstacle.flags & ~ON_BORDER) && (mover != obstacle) && (forget != obstacle))
			if(!obstacle.CheckExit(mover, src))
				mover.Bump(obstacle, 1)
				return 0

	//Now, check objects to block exit that are on the border
	for(var/obj/border_obstacle in mover.loc)
		if((border_obstacle.flags & ON_BORDER) && (mover != border_obstacle) && (forget != border_obstacle))
			if(!border_obstacle.CheckExit(mover, src))
				mover.Bump(border_obstacle, 1)
				return 0

	//Next, check objects to block entry that are on the border
	for(var/obj/border_obstacle in src)
		if(border_obstacle.flags & ON_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != border_obstacle))
				mover.Bump(border_obstacle, 1)
				return 0

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in src)
		if(obstacle.flags & ~ON_BORDER)
			if(!obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != obstacle))
				mover.Bump(obstacle, 1)
				return 0
	return 1 //Nothing found to block so return success!


/turf/Entered(atom/movable/M as mob|obj)
	if(ismob(M) && !istype(src, /turf/space))
		var/mob/tmob = M
		tmob.inertia_dir = 0
	..()
	if(prob(1) && ishuman(M))
		var/mob/living/carbon/human/tmob = M
		if (!tmob.lying && istype(tmob.shoes, /obj/item/clothing/shoes/clown_shoes))
			if(istype(tmob.head, /obj/item/clothing/head/helmet))
				tmob << "\red You stumble and fall to the ground. Thankfully, that helmet protected you."
				tmob.weakened = max(rand(1,2), tmob.weakened)
			else
				tmob << "\red You stumble and hit your head."
				tmob.weakened = max(rand(3,10), tmob.weakened)
				tmob.stuttering = max(rand(0,3), tmob.stuttering)
				tmob.make_dizzy(150)
	for(var/atom/A as mob|obj|turf|area in src)
		spawn( 0 )
			if ((A && M))
				A.HasEntered(M, 1)
			return
	for(var/atom/A as mob|obj|turf|area in range(1))
		spawn( 0 )
			if ((A && M))
				A.HasProximity(M, 1)
			return
	return


/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(src.intact)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(0)

proc/ReplaceWithFloor(turf/simulated/floor/G)
	var/turf/simulated/floor/W

	W = new /turf/simulated/floor( locate(G.x, G.y, G.z) )
	W.opacity = 0
	W.sd_SetOpacity(0)
	W.levelupdate()
	return W

proc/ReplaceWithEngineFloor(turf/simulated/floor/G)
	var/turf/simulated/floor/engine/E = new /turf/simulated/floor/engine( locate(G.x, G.y, G.z) )
	return E

/turf/simulated/Entered(atom/A, atom/OL)
	if (istype(A,/mob/living/carbon))
		var/mob/M = A
		if(M.lying)
			return
		if(M.onFloor)
			if(istype(M, /mob/living/carbon/human) && istype(M:shoes, /obj/item/clothing/shoes/clown_shoes))
				if(M.m_intent == "run")
					if(M.footstep >= 2)
						M.footstep = 0
					else
						M.footstep++
					if(M.footstep == 0)
						playsound(src, "clownstep", 50, 1) // this will get annoying very fast.
				else
					playsound(src, "clownstep", 20, 1)
			switch (src.wet)
				if(1)
					if ((M.m_intent == "run") && (!istype(M:shoes, /obj/item/clothing/shoes/galoshes)))
						M.pulling = null
						step(M, M.dir)
						M << "\blue You slipped on the wet floor!"
						playsound(src, 'slip.ogg', 50, 1, -3)
						M.stunned = 8
						M.weakened = 5
					else
						M.inertia_dir = 0
						return
				if(2) //lube
					M.pulling = null
					step(M, M.dir)
					spawn(1) step(M, M.dir)
					spawn(2) step(M, M.dir)
					spawn(3) step(M, M.dir)
					spawn(4) step(M, M.dir)
					M.bruteloss += 5
					M << "\blue You slipped on the floor!"
					playsound(src, 'slip.ogg', 50, 1, -3)
					M.weakened = 10

	..()

proc/ReplaceTurfWithSpace(turf/G)
	var/turf/space/S = new /turf/space( locate(G.x, G.y, G.z) )
	return S

proc/ReplaceTurfWithLattice(turf/G)
	var/turf/space/S = new /turf/space( locate(G.x, G.y, G.z) )
	new /obj/lattice( locate(S.x, S.y, S.z) )
	return S

proc/ReplaceTurfWithWall(turf/G)
	var/turf/simulated/wall/S = new /turf/simulated/wall( locate(G.x, G.y, G.z) )
	return S

proc/ReplaceTurfWithRWall(turf/G)
	var/turf/simulated/wall/r_wall/S = new /turf/simulated/wall/r_wall( locate(G.x, G.y, G.z) )
	return S

/turf/simulated/wall
	var/smooth_shit = "metal"
	var/joinflag = 0
	r_wall
		smooth_shit = "rwall"

/turf/simulated/wall/New()
	..()
	AutoJoin()
	spawn(1)
		for(var/turf/simulated/wall/g in range(1,src))
			if(abs(src.x-g.x)-abs(src.y-g.y)) //doesn't count diagonal walls
				g.AutoJoin()

/turf/simulated/wall/proc/AutoJoin()

	var/junction = 0 //will be used to determine from which side the wall is connected to other walls

	for(var/turf/simulated/wall/W in orange(src,1))
		if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
			junction |= get_dir(src,W)

	icon_state = "[smooth_shit][junction]"
	return

/turf/simulated/wall/proc/dismantle_wall(devastated=0)
	if(istype(src,/turf/simulated/wall/r_wall))
		if(!devastated)
			playsound(src, 'Welder.ogg', 100, 1)
			new /obj/structure/girder/reinforced(src)
			new /obj/item/weapon/sheet/r_metal( src )
		else
			new /obj/item/weapon/sheet/metal( src )
			new /obj/item/weapon/sheet/metal( src )
			new /obj/item/weapon/sheet/r_metal( src )
	else
		if(!devastated)
			playsound(src, 'Welder.ogg', 100, 1)
			new /obj/structure/girder(src)
			new /obj/item/weapon/sheet/metal( src )
			new /obj/item/weapon/sheet/metal( src )
		else
			new /obj/item/weapon/sheet/metal( src )
			new /obj/item/weapon/sheet/metal( src )
			new /obj/item/weapon/sheet/metal( src )

	ReplaceWithFloor(src)

/turf/simulated/wall/examine()
	set src in oview(1)

	usr << "It looks like a regular wall."
	return

/turf/simulated/wall/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			ReplaceTurfWithSpace(src)
			del(src)
			return
		if(2.0)
			if (prob(50))
				dismantle_wall()
			else
				dismantle_wall(devastated=1)
		if(3.0)
			dismantle_wall()
		else
	return

/turf/simulated/wall/blob_act()
	if(prob(20))
		dismantle_wall()

/turf/simulated/wall/attack_paw(mob/user as mob)
	if ((user.mutations & 8))
		if (prob(40))
			usr << text("\blue You smash through the wall.")
			dismantle_wall(1)
			return
		else
			usr << text("\blue You punch the wall.")
			return

	return src.attack_hand(user)

/turf/simulated/wall/attack_hand(mob/user as mob)
	if ((user.mutations & 8))
		if (prob(40))
			usr << text("\blue You smash through the wall.")
			dismantle_wall(1)
			return
		else
			usr << text("\blue You punch the wall.")
			return

	user << "\blue You push the wall but nothing happens!"
	playsound(src, 'Genhit.ogg', 25, 1)
	src.add_fingerprint(user)
	return

/turf/simulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	if (istype(W, /obj/item/weapon/weldingtool) && W:welding)
		W:eyecheck(user)
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (W:get_fuel() < 5)
			user << "\blue You need more welding fuel to complete this task."
			return
		W:use_fuel(5)

		user << "\blue Now disassembling the outer wall plating."
		playsound(src, 'Welder.ogg', 100, 1)

		sleep(100)

		if ((user.loc == T && user.equipped() == W))
			user << "\blue You disassembled the outer wall plating."
			dismantle_wall()

	else
		return attack_hand(user)
	return

/turf/simulated/wall/r_wall/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	if (istype(W, /obj/item/weapon/weldingtool) && W:welding)
		W:eyecheck(user)
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (src.d_state == 2)
			user << "\blue Slicing metal cover."
			playsound(src, 'Welder.ogg', 100, 1)
			sleep(60)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 3
				user << "\blue You removed the metal cover."

		else if (src.d_state == 5)
			user << "\blue Removing support rods."
			playsound(src, 'Welder.ogg', 100, 1)
			sleep(100)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 6
				new /obj/item/weapon/rods( src )
				user << "\blue You removed the support rods."

	else if (istype(W, /obj/item/weapon/wrench))
		if (src.d_state == 4)
			var/turf/T = user.loc
			user << "\blue Detaching support rods."
			playsound(src, 'Ratchet.ogg', 100, 1)
			sleep(40)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 5
				user << "\blue You detach the support rods."

	else if (istype(W, /obj/item/weapon/wirecutters))
		if (src.d_state == 0)
			playsound(src, 'Wirecutter.ogg', 100, 1)
			src.d_state = 1
			new /obj/item/weapon/rods( src )

	else if (istype(W, /obj/item/weapon/screwdriver))
		if (src.d_state == 1)
			var/turf/T = user.loc
			playsound(src, 'Screwdriver.ogg', 100, 1)
			user << "\blue Removing support lines."
			sleep(40)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 2
				user << "\blue You removed the support lines."

	else if (istype(W, /obj/item/weapon/crowbar))

		if (src.d_state == 3)
			var/turf/T = user.loc
			user << "\blue Prying cover off."
			playsound(src, 'Crowbar.ogg', 100, 1)
			sleep(100)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 4
				user << "\blue You removed the cover."

		else if (src.d_state == 6)
			var/turf/T = user.loc
			user << "\blue Prying outer sheath off."
			playsound(src, 'Crowbar.ogg', 100, 1)
			sleep(100)
			if ((user.loc == T && user.equipped() == W))
				user << "\blue You removed the outer sheath."
				dismantle_wall()
				return

	else if ((istype(W, /obj/item/weapon/sheet/metal)) && (src.d_state))
		var/turf/T = user.loc
		user << "\blue Repairing wall."
		sleep(100)
		if ((user.loc == T && user.equipped() == W))
			src.d_state = 0
			src.icon_state = initial(src.icon_state)
			user << "\blue You repaired the wall."
			if (W:amount > 1)
				W:amount--
			else
				del(W)

	if(src.d_state > 0)
		//src.icon_state = "r_wall-[d_state]"

	else
		return attack_hand(user)
	return

/turf/simulated/wall/meteorhit(obj/M as obj)
	if (M.icon_state == "flaming")
		dismantle_wall()
	return 0

/turf/simulated/floor/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if ((istype(mover, /obj/machinery/vehicle) && !(src.burnt)))
		if (!( locate(/obj/machinery/mass_driver, src) ))
			return 0
	return ..()

/turf/simulated/floor/ex_act(severity)
	//set src in oview(1)
	var/area/A = src.loc
	if(A)
		if(A.indestructible_by_explosions)
			return
	switch(severity)
		if(1.0)
			ReplaceTurfWithSpace(src)
		if(2.0)
			switch(pick(1,2;75,3))
				if (1)
					ReplaceTurfWithLattice(src)
				if(2)
					ReplaceTurfWithSpace(src)
				if(3)
					if(prob(80))
						src.break_tile_to_plating()
					else
						src.break_tile()
					src.hotspot_expose(1000,CELL_VOLUME)
					if(prob(33)) new /obj/item/weapon/sheet/metal(src)
		if(3.0)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)
	return

/turf/simulated/floor/blob_act()
	return

turf/simulated/floor/proc/update_icon()


/turf/simulated/floor/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/simulated/floor/attack_hand(mob/user as mob)

	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.pulling = null
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

/turf/simulated/floor/engine/attackby(obj/item/weapon/C as obj, mob/user as mob)
	if(!C)
		return
	if(!user)
		return
	if(istype(C, /obj/item/weapon/wrench))
		user << "\blue Removing rods..."
		playsound(src, 'Ratchet.ogg', 80, 1)
		if(do_after(user, 30))
			new /obj/item/weapon/rods(src)
			new /obj/item/weapon/rods(src)
			ReplaceWithFloor(src)
			turf_to_plating(src)
			return

proc/turf_to_plating(turf/E)
	if(istype(E,/turf/simulated/floor/engine)) return
	var/turf/simulated/floor/plating/G = new(locate(E.x,E.y,E.z))
	G.has_cover = 0
	G.update_icon()
	return G

/turf/simulated/floor/proc/break_tile_to_plating()
	if(intact) turf_to_plating(src)
	break_tile()

/image/crack
	icon = 'icons/turf/floors.dmi'
	icon_state = "crack"

/turf/simulated/floor/proc/break_tile()
	if(istype(src,/turf/simulated/floor/engine)) return
	if(broken) return
	if(!icon_old) icon_old = icon_state
	overlays += new /image/crack()
	broken = 1

/turf/simulated/floor/proc/burn_tile()
	if(istype(src,/turf/simulated/floor/engine)) return
	if(broken || burnt) return
	if(!icon_old) icon_old = icon_state
	color = "#808080"
	burnt = 1

/turf/simulated/floor/attackby(obj/item/weapon/C as obj, mob/user as mob)

	if(!C || !user)
		return 0

	if(istype(C, /obj/item/weapon/crowbar))
		if(istype(src,/turf/simulated/floor/plating))
			if(src:has_cover)
				src:has_cover = 0
				update_icon()
				user << "\red You tear the cover off, and break it. You can now place floor tiles on this plating." //todo make this drop a thing or something.
				playsound(src, 'Crowbar.ogg', 80, 1)
		else
			if(intact)
				if(broken || burnt)
					user << "\red You get rid of the broken plating."
				else
					new /obj/item/weapon/tile(src)

				playsound(src, 'Crowbar.ogg', 80, 1)

				turf_to_plating(src)

				return

	if(istype(C, /obj/item/weapon/rods))
		if (!src.intact)
			if (C:amount >= 2)
				user << "\blue Reinforcing the floor..."
				C:amount -= 2
				if (C:amount <= 0) del(C) //wtf
				playsound(src, 'Deconstruct.ogg', 80, 1)
				ReplaceWithEngineFloor(src)
			else
				user << "\red You need more rods."
		else
			user << "\red You must remove the plating first."
		return

	if(istype(C, /obj/item/weapon/tile) && istype(src,/turf/simulated/floor/plating))
		if(!intact)
			if(src:has_cover)
				user << "\red You must remove the cover first."
			else
				var/obj/item/weapon/tile/T = C
				if(T.amount > 0)
					playsound(src, 'Genhit.ogg', 50, 1)
					if(--T.amount <= 0)
						del(T)
					ReplaceWithFloor(src)
				else
					del(T) //?

	if(istype(C, /obj/item/weapon/cable_coil))
		if(!intact)
			var/obj/item/weapon/cable_coil/coil = C
			coil.turf_place(src, user)
		else
			user << "\red You must remove the plating first."

/turf/unsimulated/floor/attack_paw(user as mob)
	return src.attack_hand(user)

/turf/unsimulated/floor/attack_hand(var/mob/user as mob)
	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.pulling = null
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

// imported from space.dm

/turf/space/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/space/attack_hand(mob/user as mob)
	if ((user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/t = M.pulling
		M.pulling = null
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

/turf/space/attackby(obj/item/weapon/C as obj, mob/user as mob)

	if (istype(C, /obj/item/weapon/rods))
		user << "\blue Constructing support lattice ..."
		playsound(src, 'Genhit.ogg', 50, 1)
		ReplaceTurfWithLattice(src)
		C:amount--

		if (C:amount < 1)
			user.u_equip(C)
			del(C)
			return
		return

	if (istype(C, /obj/item/weapon/tile))
		if(locate(/obj/lattice, src))
			var/obj/lattice/L = locate(/obj/lattice, src)
			del(L)
			playsound(src, 'Genhit.ogg', 50, 1)
			C:build(src)
			C:amount--

			if (C:amount < 1)
				user.u_equip(C)
				del(C)
				return
			return
		else
			user << "\red The plating is going to need some support."
	return


// Ported from unstable r355
