
/obj/item/weapon/bedsheet/ex_act(severity)
	if (severity <= 2)
		del(src)
		return
	return

/obj/item/weapon/bedsheet/attack_self(mob/user as mob)
	user.drop_item()
	src.layer = 5
	add_fingerprint(user)
	return



/obj/item/weapon/extinguisher/New()
	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src
	R.add_reagent(/datum/reagent/water, 100)

/obj/item/weapon/extinguisher/examine()
	set src in usr

	usr << text("\icon[] [] contains [] units of water left!", src, src.name, src.reagents.total_volume)
	..()
	return

/obj/item/weapon/extinguisher/afterattack(atom/target, mob/user , flag)
	//TODO; Add support for reagents in water.

	if( istype(target, /obj/reagent_dispensers/watertank) && get_dist(src,target) <= 1)
		var/obj/o = target
		o.reagents.trans_to(src, 50)
		user << "\blue Extinguisher refilled"
		playsound(src, 'sound/effects/zzzt.ogg', 50, 1, -6)
		return

	if (!safety)
		if (src.reagents.total_volume < 1)
			return

		if (world.time < src.last_use + 20)
			return

		src.last_use = world.time

		playsound(src, 'sound/effects/spray.ogg', 75, 1, -3)

		var/direction = get_dir(src,target)

		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T,turn(direction, 90))
		var/turf/T2 = get_step(T,turn(direction, -90))

		var/list/the_targets = list(T,T1,T2)

		for(var/a=0, a<5, a++)
			spawn(0)
				var/obj/effects/water/W = new /obj/effects/water( get_turf(src) )
				var/turf/my_target = pick(the_targets)
				var/datum/reagents/R = new/datum/reagents(5)
				if(!W) return
				W.reagents = R
				R.my_atom = W
				if(!W || !src) return
				src.reagents.trans_to(W,1)
				for(var/b=0, b<5, b++)
					step_towards(W,my_target)
					if(!W) return
					W.reagents.reaction(get_turf(W))
					for(var/atom/atm in get_turf(W))
						if(!W) return
						W.reagents.reaction(atm)
					if(W.loc == my_target) break
					sleep(2)

		if(istype(usr.loc, /turf/space))
			user.inertia_dir = get_dir(target, user)
			step(user, user.inertia_dir)

	else
		return ..()
	return

/obj/item/weapon/extinguisher/attack_self(mob/user as mob)
	if (safety)
		src.icon_state = "fire_extinguisher1"
		src.desc = "The safety is off."
		user << "The safety is off."
		safety = 0
	else
		src.icon_state = "fire_extinguisher0"
		src.desc = "The safety is on."
		user << "The safety is on."
		safety = 1
	return

/obj/item/weapon/pen/sleepypen/attack_paw(mob/user as mob)
	return src.attack_hand(user)
	return

/obj/item/weapon/pen/sleepypen/New()
	var/datum/reagents/R = new/datum/reagents(300)
	reagents = R
	R.my_atom = src
	R.add_reagent(/datum/reagent/stoxin, 100)
	R.add_reagent(/datum/reagent/impedrezene, 100)
	R.add_reagent(/datum/reagent/cryptobiolin, 100)
	..()
	return

/obj/item/weapon/pen/sleepypen/attack(mob/M as mob, mob/user as mob)
	if (!( istype(M, /mob) ))
		return
	if (reagents.total_volume)
		//for(var/mob/O in viewers(M, null))
		//	O.show_message(text("\red [] has been stabbed with [] by [].", M, src, user), 1)
		user << "\red You stab [M] with the pen."
		M << "\red You feel a tiny prick!"
		if(M.reagents) reagents.trans_to(M, 150)
	return

/obj/item/weapon/Bump(mob/M as mob)
	spawn( 0 )
		..()
	return

/obj/manifest/New()

	src.invisibility = 101
	return

/obj/manifest/proc/manifest()
	var/dat = "<B>Crew Manifest</B>:<BR>"
	for(var/mob/living/carbon/human/M in world)
		dat += text("    <B>[]</B> -  []<BR>", M.name, (istype(M.wear_id, /obj/item/weapon/card/id) ? text("[]", M.wear_id.assignment) : "Unknown Position"))
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( src.loc )
	P.info = dat
	P.name = "paper- 'Crew Manifest'"
	//SN src = null
	del(src)
	return

/obj/screen/close/Click()
	if (src.master)
		src.master:close(usr)
	return



/mob/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
		else
	if (locate(/obj/item/weapon/grab, src))
		var/mob/safe = null
		if (istype(src.l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.l_hand
			if ((G.state == 3 && get_dir(src, user) == src.dir))
				safe = G.affecting
		if (istype(src.r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.r_hand
			if ((G.state == 3 && get_dir(src, user) == src.dir))
				safe = G.affecting
		if (safe)
			return safe.attackby(W, user)
	if ((!( shielded ) || !( W.flags ) & 32))
		spawn( 0 )
			W.attack(src, user)
			return
	return





/obj/item/brain/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	src.add_fingerprint(user)

	if(!(user.zone_sel.selecting == ("head")) || !istype(M, /mob/living/carbon/human))
		return ..()

	if(!(locate(/obj/machinery/optable, M.loc) && M.resting))
		return ..()

	var/mob/living/carbon/human/H = M
	if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
		// you can't stab someone in the eyes wearing a mask!
		user << "\blue You're going to need to remove that mask/helmet/glasses first."
		return

//since these people will be dead M != usr

	if(M:brain_op_stage == 4.0)
		for(var/mob/O in viewers(M, null))
			if(O == (user || M))
				continue
			if(M == user)
				O.show_message(text("\red [user] inserts [src] into his head!"), 1)
			else
				O.show_message(text("\red [M] has [src] inserted into his head by [user]."), 1)

		if(M != user)
			M << "\red [user] inserts [src] into your head!"
			user << "\red You insert [src] into [M]'s head!"
		else
			user << "\red You insert [src] into your head!"

		if(M.client)
			M.client.mob = new/mob/dead/observer(M)
		//a mob can't have two clients so get rid of one

		if(src.owner)
		//if the brain has an owner corpse
			if(src.owner.client)
			//if the player hasn't ghosted
				src.owner.client.mob = M
				//then put them in M
			else
			//if the player HAS ghosted
				for(var/mob/dead/observer/O in world)
					if(O.corpse == src.owner && O.client)
					//find their ghost
						O.client.mob = M
						//put their mob in M
						del(O)
						//delete thier ghost

		M:brain_op_stage = 3.0

		del(src)
	else
		..()
	return

/obj/item/weapon/stamp/attack_paw(mob/user as mob)

	return src.attack_hand(user)

/obj/item/weapon/stamp/New()

	..()
	return
