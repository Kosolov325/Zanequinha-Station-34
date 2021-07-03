/mob/living/carbon/human
	var/species = "human"
	var/species_icon = 'icons/mob/human.dmi'
	var/species_color = null

	//var/animating = 0
	var/tail = "none"
	var/tail_color = null
	var/cat_ears = 0
	//var/icon/fullplayericon = null

	var/horn_icon = ""
	var/alternian_blood_type = ""
	var/sign = ""
	var/pickedSignOverlay = ""

/mob/living/carbon/human/New()
	..()


	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

	if (!dna)
		dna = new /datum/dna( null )
	spawn (1)
		var/datum/organ/external/chest/chest = new /datum/organ/external/chest( src )
		chest.owner = src
		var/datum/organ/external/groin/groin = new /datum/organ/external/groin( src )
		groin.owner = src
		var/datum/organ/external/head/head = new /datum/organ/external/head( src )
		head.owner = src
		var/datum/organ/external/l_arm/l_arm = new /datum/organ/external/l_arm( src )
		l_arm.owner = src
		var/datum/organ/external/r_arm/r_arm = new /datum/organ/external/r_arm( src )
		r_arm.owner = src
		var/datum/organ/external/l_hand/l_hand = new /datum/organ/external/l_hand( src )
		l_hand.owner = src
		var/datum/organ/external/r_hand/r_hand = new /datum/organ/external/r_hand( src )
		r_hand.owner = src
		var/datum/organ/external/l_leg/l_leg = new /datum/organ/external/l_leg( src )
		l_leg.owner = src
		var/datum/organ/external/r_leg/r_leg = new /datum/organ/external/r_leg( src )
		r_leg.owner = src
		var/datum/organ/external/l_foot/l_foot = new /datum/organ/external/l_foot( src )
		l_foot.owner = src
		var/datum/organ/external/r_foot/r_foot = new /datum/organ/external/r_foot( src )
		r_foot.owner = src

		if(gender == FEMALE && species == "human") //gamer catgirl pee
			cat_ears = 1
			src << "<b>Something's nya~t right."

		src.organs["chest"] = chest
		src.organs["groin"] = groin
		src.organs["head"] = head
		src.organs["l_arm"] = l_arm
		src.organs["r_arm"] = r_arm
		src.organs["l_hand"] = l_hand
		src.organs["r_hand"] = r_hand
		src.organs["l_leg"] = l_leg
		src.organs["r_leg"] = r_leg
		src.organs["l_foot"] = l_foot
		src.organs["r_foot"] = r_foot

		update_body()

		update_clothing()

		if(src.sign != "Mutant")
			src.real_name += " [src.sign]"
			src.name += " [src.sign]"

/atom
	var/can_push = 1
/mob/living/carbon/human/Bump(atom/movable/AM as mob|obj, yes)
	if(!AM.can_push)
		return
	if ((!( yes ) || src.now_pushing))
		return
	src.now_pushing = 1
	if (ismob(AM))
		var/mob/tmob = AM
		if(tmob.a_intent == "help" && src.a_intent == "help" && tmob.canmove && src.canmove) // mutual brohugs all around!
			var/turf/oldloc = src.loc
			src.loc = tmob.loc
			tmob.loc = oldloc
			src.now_pushing = 0
			return
		if(istype(src.equipped(), /obj/item/weapon/baton)) // add any other item paths you think are necessary
			if(src.loc:sd_lumcount < 3 || src.blinded)
				var/obj/item/weapon/W = src.equipped()
				if((prob(40)) || (prob(95) && src.mutations & 16))
					src << "\red You accidentally stun yourself with the [W.name]."
					src.weakened = max(12, src.weakened)
				else
					for(var/mob/M in viewers(src, null))
						if(M.client)
							M << "\red <B>[src] accidentally bumps into [tmob] with the [W.name]."
					tmob.weakened = max(4, tmob.weakened)
					tmob.stunned = max(4, tmob.stunned)
				playsound(src, 'sound/weapons/Egloves.ogg', 50, 1, -1)
				W:charges--
				return
		if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & 32)
			if(prob(40) && !(src.mutations & 32))
				for(var/mob/M in viewers(src, null))
					if(M.client)
						M << "\red <B>[src] fails to push [tmob]'s fat ass out of the way.</B>"
				src.now_pushing = 0
				return
	src.now_pushing = 0
	spawn(0)
		..()
		if (!istype(AM, /atom/movable))
			return
		if (!src.now_pushing)
			src.now_pushing = 1
			if (!AM.anchored)
				var/t = get_dir(src, AM)
				step(AM, t, step_size)
			src.now_pushing = null
		return
	return

/mob/living/carbon/human/movement_delay()
	var/tally = 0

	if(src.reagents.has_reagent(/datum/reagent/hyperzine)) return 0

	var/health_deficiency = (maxhealth - src.health)
	if(health_deficiency >= 40) tally += (health_deficiency / 20)

	if(src.wear_suit)
		switch(src.wear_suit.type)
			if(/obj/item/clothing/suit/straight_jacket)
				tally += 15
	else
		var/turf/T = locate(x,y,z)
		if(istype(T,/turf))
			if(heightZ <= T.water_height)
				switch(T.water_height)
					if(1 to 4) //feet
						tally += 1
					if(5 to 8) //knees
						tally += 2
					if(9 to 16) //chest
						tally += 4
					if(17 to 24) //neck
						tally += 5
				if(T.water_height >= 25)
					tally += 7
	if (istype(src.shoes, /obj/item/clothing/shoes))
		if (src.shoes.chained)
			tally += 15
		else
			tally += -1.0
	var/obj/lattice/LAT = locate(/obj/lattice) in loc
	if(LAT)
		if(heightZ == 0)
			tally += 3
	if(src.mutations & 32)
		tally += 1.5
	if (src.bodytemperature < 283.222)
		tally += (283.222 - src.bodytemperature)/75

	return tally

/mob/living/carbon/human/Stat()
	..()
	statpanel("Status")
	stat(null, "Intent: [src.a_intent]")
	stat(null, "Move Mode: [src.m_intent]")

	if (src.client.statpanel == "Status")
		if (src.internal)
			if (!src.internal.air_contents)
				del(src.internal)
			else
				stat("Internal Atmosphere Info", src.internal.name)
				stat("Tank Pressure", src.internal.air_contents.return_pressure())
				stat("Distribution Pressure", src.internal.distribute_pressure)
	if(istype(src.back, /obj/item/weapon/tank/jetpack))
		var/obj/item/weapon/tank/jetpack/J = src.back
		stat("Jetpack Pressure", J.air_contents.return_pressure())




/mob/living/carbon/human/ex_act(severity)
	animate_flash("flash", src.flash)

	if (src.stat == 2 && src.client)
		src.gib(1)
		return

	else if (src.stat == 2 && !src.client)
		var/virus = src.virus
		gibs(src.loc, virus)
		del(src)
		return

	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
			break

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			ySpeed = 8
			b_loss += 500
			src.gib(1)
			return

		if (2.0)
			ySpeed = 6
			if (!shielded)
				b_loss += 60

			f_loss += 60

			if (!istype(src.ears, /obj/item/clothing/ears/earmuffs))
				src.ear_damage += 30
				src.ear_deaf += 120

		if(3.0)
			ySpeed = 4
			b_loss += 30
			if (prob(50) && !shielded)
				src.paralysis += 10
			if (!istype(src.ears, /obj/item/clothing/ears/earmuffs))
				src.ear_damage += 15
				src.ear_deaf += 60

	for(var/organ in src.organs)
		var/datum/organ/external/temp = src.organs[text("[]", organ)]
		if (istype(temp, /datum/organ/external))
			switch(temp.name)
				if("head")
					temp.take_damage(b_loss * 0.2, f_loss * 0.2)
				if("chest")
					temp.take_damage(b_loss * 0.4, f_loss * 0.4)
				if("groin")
					temp.take_damage(b_loss * 0.1, f_loss * 0.1)
				if("l_arm")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("r_arm")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("l_hand")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
				if("r_hand")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
				if("l_leg")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("r_leg")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("l_foot")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
				if("r_foot")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)

	src.UpdateDamageIcon()

/mob/living/carbon/human/blob_act()
	if (src.stat == 2)
		return
	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
	var/damage = null
	if (src.stat != 2)
		damage = rand(1,20)

	if(shielded)
		damage /= 4

		//src.paralysis += 1

	src.show_message("\red The blob attacks you!")

	var/list/zones = list("head","chest","chest", "groin", "l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")

	var/zone = pick(zones)

	var/datum/organ/external/temp = src.organs["[zone]"]

	switch(zone)
		if ("head")
			if ((((src.head && src.head.body_parts_covered & HEAD) || (src.wear_mask && src.wear_mask.body_parts_covered & HEAD)) && prob(99)))
				if (prob(20))
					temp.take_damage(damage, 0)
				else
					src.show_message("\red You have been protected from a hit to the head.")
				return
			if (damage > 4.9)
				if (src.weakened < 10)
					src.weakened = rand(10, 15)
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>The blob has weakened []!</B>", src), 1, "\red You hear someone fall.", 2)
			temp.take_damage(damage)
		if ("chest")
			if ((((src.wear_suit && src.wear_suit.body_parts_covered & UPPER_TORSO) || (src.w_uniform && src.w_uniform.body_parts_covered & UPPER_TORSO)) && prob(85)))
				src.show_message("\red You have been protected from a hit to the chest.")
				return
			if (damage > 4.9)
				if (prob(50))
					if (src.weakened < 5)
						src.weakened = 5
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>The blob has knocked down []!</B>", src), 1, "\red You hear someone fall.", 2)
				else
					if (src.stunned < 5)
						src.stunned = 5
					for(var/mob/O in viewers(src, null))
						if(O.client)	O.show_message(text("\red <B>The blob has stunned []!</B>", src), 1)
				if(src.stat != 2)	src.stat = 1
			temp.take_damage(damage)
		if ("groin")
			if ((((src.wear_suit && src.wear_suit.body_parts_covered & LOWER_TORSO) || (src.w_uniform && src.w_uniform.body_parts_covered & LOWER_TORSO)) && prob(75)))
				src.show_message("\red You have been protected from a hit to the lower chest.")
				return
			else
				temp.take_damage(damage, 0)


		if("l_arm")
			temp.take_damage(damage, 0)
		if("r_arm")
			temp.take_damage(damage, 0)
		if("l_hand")
			temp.take_damage(damage, 0)
		if("r_hand")
			temp.take_damage(damage, 0)
		if("l_leg")
			temp.take_damage(damage, 0)
		if("r_leg")
			temp.take_damage(damage, 0)
		if("l_foot")
			temp.take_damage(damage, 0)
		if("r_foot")
			temp.take_damage(damage, 0)

	src.UpdateDamageIcon()
	return

/mob/living/carbon/human/u_equip(obj/item/W as obj)
	if (W == src.wear_suit)
		src.wear_suit = null
	else if (W == src.w_uniform)
		W = src.r_store
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.plane = ITEM_PLANE
				W.layer = initial(W.layer)
		W = src.l_store
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.plane = ITEM_PLANE
				W.layer = initial(W.layer)
		W = src.wear_id
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.plane = ITEM_PLANE
				W.layer = initial(W.layer)
		W = src.belt
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.plane = ITEM_PLANE
				W.layer = initial(W.layer)
		src.w_uniform = null
	else if (W == src.gloves)
		src.gloves = null
	else if (W == src.glasses)
		src.glasses = null
	else if (W == src.head)
		src.head = null
	else if (W == src.ears)
		src.ears = null
	else if (W == src.shoes)
		src.shoes = null
	else if (W == src.belt)
		src.belt = null
	else if (W == src.wear_mask)
		if(internal)
			if (src.internals)
				src.internals.icon_state = "internal0"
			internal = null
		src.wear_mask = null
	else if (W == src.wear_id)
		src.wear_id = null
	else if (W == src.r_store)
		src.r_store = null
	else if (W == src.l_store)
		src.l_store = null
	else if (W == src.back)
		src.back = null
	else if (W == src.handcuffed)
		src.handcuffed = null
	else if (W == src.r_hand)
		src.r_hand = null
	else if (W == src.l_hand)
		src.l_hand = null

	update_clothing()

/mob/living/carbon/human/db_click(text, t1)
	var/obj/item/W = src.equipped()
	var/emptyHand = (W == null)
	if ((!emptyHand) && (!istype(W, /obj/item)))
		return
	if (emptyHand)
		usr.next_move = usr.prev_move
	switch(text)
		if("mask")
			if (src.wear_mask)
				if (emptyHand)
					src.wear_mask.Click()
				return
			if (!( istype(W, /obj/item/clothing/mask) ))
				return
			src.u_equip(W)
			src.wear_mask = W
			W.equipped(src, text)
		if("back")
			if (src.back)
				if (emptyHand)
					src.back.Click()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.flags & ONBACK ))
				return
			src.u_equip(W)
			src.back = W
			W.equipped(src, text)

/*		if("headset")
			if (src.ears)
				if (emptyHand)
					src.ears.Click()
				return
			if (!( istype(W, /obj/item/device/radio/headset) ))
				return
			src.u_equip(W)
			src.w_radio = W
			W.equipped(src, text) */
		if("o_clothing")
			if (src.wear_suit)
				if (emptyHand)
					src.wear_suit.Click()
				return
			if (!( istype(W, /obj/item/clothing/suit) ))
				return
			if (src.mutations & 32 && !(W.flags & ONESIZEFITSALL))
				src << "\red You're too fat to wear the [W.name]!"
				return
			src.u_equip(W)
			src.wear_suit = W
			W.equipped(src, text)
		if("gloves")
			if (src.gloves)
				if (emptyHand)
					src.gloves.Click()
				return
			if (!( istype(W, /obj/item/clothing/gloves) ))
				return
			src.u_equip(W)
			src.gloves = W
			W.equipped(src, text)
		if("shoes")
			if (src.shoes)
				if (emptyHand)
					src.shoes.Click()
				return
			if (!( istype(W, /obj/item/clothing/shoes) ))
				return
			src.u_equip(W)
			src.shoes = W
			W.equipped(src, text)
		if("belt")
			if (src.belt)
				if (emptyHand)
					src.belt.Click()
				return
			if (!W || !W.flags || !( W.flags & ONBELT ))
				return
			src.u_equip(W)
			src.belt = W
			W.equipped(src, text)
		if("eyes")
			if (src.glasses)
				if (emptyHand)
					src.glasses.Click()
				return
			if (!( istype(W, /obj/item/clothing/glasses) ))
				return
			src.u_equip(W)
			src.glasses = W
			W.equipped(src, text)
		if("head")
			if (src.head)
				if (emptyHand)
					src.head.Click()
				return
			if (( istype(W, /obj/item/weapon/paper) ))
				src.u_equip(W)
				src.head = W
			else if (!( istype(W, /obj/item/clothing/head) ))
				return
			src.u_equip(W)
			src.head = W
			W.equipped(src, text)
		if("ears")
			if (src.ears)
				if (emptyHand)
					src.ears.Click()
				return
			if (!( istype(W, /obj/item/clothing/ears) ) && !( istype(W, /obj/item/device/radio/headset) ))
				return
			src.u_equip(W)
			src.ears = W
			W.equipped(src, text)
		if("i_clothing")
			if (src.w_uniform)
				if (emptyHand)
					src.w_uniform.Click()
				return
			if (!( istype(W, /obj/item/clothing/under) ))
				return
			if (src.mutations & 32 && !(W.flags & ONESIZEFITSALL))
				src << "\red You're too fat to wear the [W.name]!"
				return
			src.u_equip(W)
			src.w_uniform = W
			W.equipped(src, text)
		if("id")
			if (src.wear_id)
				if (emptyHand)
					src.wear_id.Click()
				return
			if (!src.w_uniform)
				return
			if (!( istype(W, /obj/item/weapon/card/id) ))
				return
			src.u_equip(W)
			src.wear_id = W
			W.equipped(src, text)
		if("storage1")
			if (src.l_store)
				if (emptyHand)
					src.l_store.Click()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 2 || !( src.w_uniform )))
				return
			src.u_equip(W)
			src.l_store = W
		if("storage2")
			if (src.r_store)
				if (emptyHand)
					src.r_store.Click()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 2 || !( src.w_uniform )))
				return
			src.u_equip(W)
			src.r_store = W

	update_clothing()

	return

/mob/living/carbon/human/Move(a, b, flag)

	if (src.buckled)
		return

	if (src.restrained())
		src.pulling = null

	var/t7 = 1
	if (src.restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (src.pulling && ((get_dist(src, src.pulling) <= 1 || src.pulling.loc == src.loc) && (src.client && src.client.moving)))))
		var/turf/T = src.loc
		. = ..()

		if (src.pulling && src.pulling.loc)
			if(!( isturf(src.pulling.loc) ))
				src.pulling = null
				return
			else
				if(Debug)
					diary <<"src.pulling disappeared? at [__LINE__] in mob.dm - src.pulling = [src.pulling]"
					diary <<"REPORT THIS"

		///// what's with the long ass comment? ~AlcaroIsAFrick
		if(src.pulling && src.pulling.anchored)
			src.pulling = null
			return

		if (!src.restrained())
			var/diag = get_dir(src, src.pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, src.pulling) > 1 || diag))
				if (ismob(src.pulling))
					var/mob/M = src.pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [] has been pulled from []'s grip by []", G.affecting, G.assailant, src), 1)
								//G = null
								del(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/t = M.pulling
						M.pulling = null

//this is the gay blood on floor shit (hey goons stop swearing -alcaro)
//						if (M.lying && (prob(M.bruteloss / 6)))
//							var/turf/location = M.loc
//							if (istype(location, /turf/simulated))
//								location.add_blood(M)


						step(src.pulling, get_dir(src.pulling.loc, T))
						M.pulling = t
				else
					if (src.pulling)
						step(src.pulling, get_dir(src.pulling.loc, T))
	else
		src.pulling = null
		. = ..()
	if ((src.s_active && !( s_active in src.contents ) ))
		src.s_active.close(src)

/mob/living/carbon/human/update_clothing()
	..()
	if(ANIMATION_RUNNING)
		return

	if (src.transforming)
		return

	src.overlays = null

	if (src.mutations & 2)
		src.overlays += image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "fire_s")

	if (src.mutations & 1)
		src.overlays += image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "telekinesishead_s")
	if(!src.face_standing)
		src.update_face()
	if(!src.stand_icon)
		src.update_body()

	if(src.buckled)
		if(istype(src.buckled, /obj/stool/bed))
			src.lying = 1
		else
			src.lying = 0

	// Automatically drop anything in store / id / belt if you're not wearing a uniform.
	if (!src.w_uniform)
		for (var/obj/item/thing in list(src.r_store, src.l_store, src.wear_id, src.belt))
			if (thing)
				u_equip(thing)
				if (src.client)
					src.client.screen -= thing

				if (thing)
					thing.loc = src.loc
					thing.dropped(src)
					thing.plane = ITEM_PLANE
					thing.layer = initial(thing.layer)


	//if (src.zone_sel)
	//	src.zone_sel.overlays = null
	//	src.zone_sel.overlays += src.body_standing
	//	src.zone_sel.overlays += image("icon" = 'zone_sel.dmi', "icon_state" = text("[]", src.zone_sel.selecting))
	src.icon = src.stand_icon

	src.overlays += src.body_standing

	if (src.face_standing)
		src.overlays += src.face_standing

	// Uniform
	if (src.w_uniform)
		if (src.mutations & 32 && !(src.w_uniform.flags & ONESIZEFITSALL))
			src << "\red You burst out of the [src.w_uniform.name]!"
			var/obj/item/clothing/c = src.w_uniform
			src.u_equip(c)
			if(src.client)
				src.client.screen -= c
			if(c)
				c:loc = src.loc
				c:dropped(src)

				c:layer = initial(c:layer)
				c.plane = ITEM_PLANE
		src.w_uniform.screen_loc = ui_iclothing
		if (istype(src.w_uniform, /obj/item/clothing/under))
			var/t1 = src.w_uniform.color2
			if (!t1)
				t1 = src.icon_state
			var/image/unif_image = image("icon" = 'icons/mob/uniform.dmi', "icon_state" = "overlay_s")
			unif_image.color = list(null,null,null,w_uniform.overlay_color)
			src.overlays += unif_image
			src.overlays += image("icon" = 'icons/mob/uniform.dmi', "icon_state" = "overlay2_s")
			if (src.w_uniform.blood_DNA)
				var/icon/stain_icon = icon('icons/effects/blood.dmi', "uniformblood")
				src.overlays += image("icon" = stain_icon)

	if (src.wear_id)
		src.overlays += image("icon" = 'icons/mob/mob.dmi', "icon_state" = "id")

	if (src.client)
		src.client.screen -= src.hud_used.intents
		src.client.screen -= src.hud_used.mov_int


	//Screenlocs for these slots are handled by the huds other_update()
	//because theyre located on the 'other' inventory bar.

	// Gloves
	if (src.gloves)
		src.overlays += image("icon" = 'icons/mob/hands.dmi', "icon_state" = text("[]", src.gloves.icon_state)) //, "layer" = MOB_LAYER)
		if (src.gloves.blood_DNA)
			var/icon/stain_icon = icon('icons/effects/blood.dmi', "bloodyhands")
			src.overlays += stain_icon
		gloves.screen_loc = ui_gloves
	else if (src.blood_DNA)
		var/icon/stain_icon = icon('icons/effects/blood.dmi', "bloodyhands")
		src.overlays += stain_icon
	// Glasses
	if (src.glasses)
		src.overlays += image("icon" = 'icons/mob/eyes.dmi', "icon_state" = text("[]", src.glasses.icon_state)) //, "layer" = MOB_LAYER)
		glasses.screen_loc = ui_glasses
	// Ears
	if (src.ears)
		src.overlays += image("icon" = 'icons/mob/ears.dmi', "icon_state" = text("[]", src.ears.icon_state)) //, "layer" = MOB_LAYER)
		ears.screen_loc = ui_ears
	// Shoes
	if (src.shoes)

		src.overlays += image("icon" = 'icons/mob/feet.dmi', "icon_state" = text("[]", src.shoes.icon_state)) //, "layer" = MOB_LAYER)
		if (src.shoes.blood_DNA)
			var/icon/stain_icon = icon('icons/effects/blood.dmi', "shoesblood")
			src.overlays += stain_icon
		src.shoes.screen_loc = ui_shoes
/*	if (src.w_radio)
		src.overlays += image("icon" = 'ears.dmi', "icon_state" = "headset[!src.lying ? "" : "2"]") */

	if (src.wear_mask)
		if (istype(src.wear_mask, /obj/item/clothing/mask))

			src.overlays += image("icon" = 'icons/mob/mask.dmi', "icon_state" = text("[]", src.wear_mask.icon_state)) //, "layer" = MOB_LAYER)

			if (!istype(src.wear_mask, /obj/item/clothing/mask/cigarette))
				if (src.wear_mask.blood_DNA)
					var/icon/stain_icon = icon('icons/effects/blood.dmi', "maskblood")
					src.overlays += stain_icon
			src.wear_mask.screen_loc = ui_mask


	if (src.client)
		if (src.i_select)
			if (src.intent)
				src.client.screen += src.hud_used.intents

				var/list/L = dd_text2list(src.intent, ",")
				L[1] += ":-11"
				src.i_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				src.i_select.screen_loc = null
		if (src.m_select)
			if (src.m_int)
				src.client.screen += src.hud_used.mov_int

				var/list/L = dd_text2list(src.m_int, ",")
				L[1] += ":-11"
				src.m_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				src.m_select.screen_loc = null


	if (src.wear_suit)
		if (src.mutations & 32 && !(src.wear_suit.flags & ONESIZEFITSALL))
			src << "\red You burst out of the [src.wear_suit.name]!"
			var/obj/item/clothing/c = src.wear_suit
			src.u_equip(c)
			if(src.client)
				src.client.screen -= c
			if(c)
				c:loc = src.loc
				c:dropped(src)
				c.plane = ITEM_PLANE
				c:layer = initial(c:layer)
		if (istype(src.wear_suit, /obj/item/clothing/suit))

			src.overlays += image("icon" = 'icons/mob/suit.dmi', "icon_state" = text("[]", src.wear_suit.icon_state)) //, "layer" = MOB_LAYER)

		if (src.wear_suit.blood_DNA)
			var/icon/stain_icon = null
			if (istype(src.wear_suit, /obj/item/clothing/suit/armor/vest || /obj/item/clothing/suit/wcoat || /obj/item/clothing/suit/armor/a_i_a_ptank))
				stain_icon = icon('icons/effects/blood.dmi', "armorblood")
			else if (istype(src.wear_suit, /obj/item/clothing/suit/det_suit || /obj/item/clothing/suit/labcoat))
				stain_icon = icon('icons/effects/blood.dmi', "coatblood")
			else
				stain_icon = icon('icons/effects/blood.dmi', "suitblood")
			src.overlays += image("icon" = stain_icon)
		src.wear_suit.screen_loc = ui_oclothing
		if (istype(src.wear_suit, /obj/item/clothing/suit/straight_jacket))
			if (src.handcuffed)
				src.handcuffed.loc = src.loc
				src.handcuffed.layer = initial(src.handcuffed.layer)
				src.handcuffed = null
			if ((src.l_hand || src.r_hand))
				var/h = src.hand
				src.hand = 1
				drop_item()
				src.hand = 0
				drop_item()
				src.hand = h

	// Head
	if (src.head)
		src.overlays += image("icon" = 'icons/mob/head.dmi', "icon_state" = text("[]", src.head.icon_state)) //, "layer" = MOB_LAYER)
		if (src.head.blood_DNA)
			var/stain_icon = icon('icons/effects/blood.dmi', "helmetblood")
			src.overlays += stain_icon
		src.head.screen_loc = ui_head

	// Belt
	if (src.belt)
		src.overlays += image("icon" = 'icons/mob/belt.dmi', "icon_state" = text("[]", src.belt.icon_state)) //, "layer" = MOB_LAYER)
		src.belt.screen_loc = ui_belt

	if ((src.wear_mask && !(src.wear_mask.see_face)) || (src.head && !(src.head.see_face))) // can't see the face
		if (src.wear_id && src.wear_id.registered)
			src.name = src.wear_id.registered
		else
			src.name = "Unknown"
	else
		if (src.wear_id && src.wear_id.registered != src.real_name)
			src.name = "[src.real_name] (as [src.wear_id.registered])"
		else
			src.name = src.real_name

	if (src.wear_id)
		src.wear_id.screen_loc = ui_id

	if (src.l_store)
		src.l_store.screen_loc = ui_storage1

	if (src.r_store)
		src.r_store.screen_loc = ui_storage2

	if (src.back)
		src.overlays += image("icon" = 'icons/mob/back.dmi', "icon_state" = text("[]", src.back.icon_state)) //, "layer" = MOB_LAYER)
		src.back.screen_loc = ui_back

	if (src.handcuffed)
		src.pulling = null
		src.overlays += image("icon" = 'icons/mob/mob.dmi', "icon_state" = "handcuff1")

	if (src.client)
		for(var/atom/e in src.contents)
			e.plane = HUD_PLANE_2
		src.client.screen += src.contents

	if (src.r_hand)
		src.overlays += image("icon" = 'icons/mob/items_righthand.dmi', "icon_state" = src.r_hand.icon_state) //, "layer" = MOB_LAYER+1)

		src.r_hand.screen_loc = ui_rhand

	if (src.l_hand)
		src.overlays += image("icon" = 'icons/mob/items_lefthand.dmi', "icon_state" = src.l_hand.icon_state) //, "layer" = MOB_LAYER+1)

		src.l_hand.screen_loc = ui_lhand

	if(tail != "none")
		var/image/taile = image("icon" = 'icons/mob/mob_acc.dmi', "icon_state" = "[tail]") //, "layer" = MOB_LAYER+0.9)
		taile.icon += tail_color
		src.overlays += taile

	if(cat_ears)
		var/image/catear = image("icon" = 'icons/mob/mob_acc.dmi', "icon_state" = "cat_ear") //, "layer" = MOB_LAYER+0.9)
		src.overlays += catear
		var/image/catearOV = image("icon" = 'icons/mob/mob_acc.dmi', "icon_state" = "cat_ear_over") //, "layer" = MOB_LAYER+0.9)
		catearOV.color = rgb(src.r_hair, src.g_hair, src.b_hair)
		src.overlays += catearOV

		var/image/tailcat = image("icon" = 'icons/mob/mob_acc.dmi', "icon_state" = "cat_tail") //, "layer" = MOB_LAYER+0.9)
		tailcat.color = rgb(src.r_hair, src.g_hair, src.b_hair)
		src.overlays += tailcat

	if(horn_icon != "Mutant")
		var/image/horn = image("icon" = 'icons/mob/alternian_horns.dmi', "icon_state" = "[src.key == "Roberto_candi" ? "robloko" :horn_icon]") //, "layer" = MOB_LAYER+0.9)
		src.overlays += horn

	var/shielded = 0
	for (var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
			break

	for (var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 2
			break

	if (shielded == 2)
		src.invisibility = 2
	else
		src.invisibility = 0

	if (shielded)
		src.overlays += image("icon" = 'icons/mob/mob.dmi', "icon_state" = "shield")

	for (var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			spawn (0)
				src.show_inv(M)
				return

	//fullplayericon = GetSplitIcon()
	if(MyShadow)
		MyShadow.underlays = underlays
		MyShadow.icon = icon
		MyShadow.overlays = overlays
	src.last_b_state = src.stat

	if(src.alternian_blood_type != "Mutant" && src.pickedSignOverlay == "")
		var/enum = pick(1,2,3)
		if(src.key == "Jogn_iceberg")
			src.pickedSignOverlay = "lezado"
			return
		switch(src.alternian_blood_type)
			if("Rust")
				if(src.sign)
					var/image/sign = image("icon" = 'icons/hs/signs.dmi', "icon_state" = "rust_[enum]")
					src.overlays += sign
					src.pickedSignOverlay = sign.icon_state
			if("Bronze")
				if(src.sign)
					var/image/sign = image("icon" = 'icons/hs/signs.dmi', "icon_state" = "bronze_[enum]")
					src.overlays += sign
					src.pickedSignOverlay = sign.icon_state
			if("Gold")
				if(src.sign)
					var/image/sign = image("icon" = 'icons/hs/signs.dmi', "icon_state" = "gold_[enum]")
					src.overlays += sign
					src.pickedSignOverlay = sign.icon_state
			if("Lime")
				if(src.sign)
					var/image/sign = image("icon" = 'icons/hs/signs.dmi', "icon_state" = "lime_[enum]")
					src.overlays += sign
					src.pickedSignOverlay = sign.icon_state
			if("Olive")
				if(src.sign)
					var/image/sign = image("icon" = 'icons/hs/signs.dmi', "icon_state" = "olive_[enum]")
					src.overlays += sign
					src.pickedSignOverlay = sign.icon_state
			if("Jade")
				if(src.sign)
					var/image/sign = image("icon" = 'icons/hs/signs.dmi', "icon_state" = "jade_[enum]")
					src.overlays += sign
					src.pickedSignOverlay = sign.icon_state
			if("Teal")
				if(src.sign)
					var/image/sign = image("icon" = 'icons/hs/signs.dmi', "icon_state" = "teal_[enum]")
					src.overlays += sign
					src.pickedSignOverlay = sign.icon_state
			if("Cerulean")
				if(src.sign)
					var/image/sign = image("icon" = 'icons/hs/signs.dmi', "icon_state" = "cerulean_[enum]")
					src.overlays += sign
					src.pickedSignOverlay = sign.icon_state
			if("Indigo")
				if(src.sign)
					var/image/sign = image("icon" = 'icons/hs/signs.dmi', "icon_state" = "indigo_[enum]")
					src.overlays += sign
					src.pickedSignOverlay = sign.icon_state
			if("Purple")
				if(src.sign)
					var/image/sign = image("icon" = 'icons/hs/signs.dmi', "icon_state" = "purple_[enum]")
					src.overlays += sign
					src.pickedSignOverlay = sign.icon_state
			if("Violet")
				if(src.sign)
					var/image/sign = image("icon" = 'icons/hs/signs.dmi', "icon_state" = "violet_[enum]")
					src.overlays += sign
					src.pickedSignOverlay = sign.icon_state
			if("Fuchsia")
				if(src.sign)
					var/image/sign = image("icon" = 'icons/hs/signs.dmi', "icon_state" = "fuchsia_[enum]")
					src.overlays += sign
					src.pickedSignOverlay = sign.icon_state
	else
		var/image/sign = image("icon" = 'icons/hs/signs.dmi', "icon_state" = "[pickedSignOverlay]")
		src.overlays += sign

	if(overlayList)
		for(var/image/ov in overlayList)
			var/image/overlay = image("icon" = ov.icon, "icon_state" = ov.icon_state)
			src.overlays += overlay

/mob/living/carbon/human/hand_p(mob/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (M.a_intent == "hurt")
		if (istype(M.wear_mask, /obj/item/clothing/mask/muzzle))
			return
		if (src.health > 0)
			if (istype(src.wear_suit, /obj/item/clothing/suit/space))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/space/santa))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/bio_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/armor))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
				var/damage = rand(1, 3)
				var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg", "groin")
				if (istype(src.organs[text("[]", dam_zone)], /datum/organ/external))
					var/datum/organ/external/temp = src.organs[text("[]", dam_zone)]
					if (temp.take_damage(damage, 0))
						src.UpdateDamageIcon()
					else
						src.UpdateDamage()
				src.updatehealth()
	return

/mob/living/carbon/human/attack_paw(mob/M as mob)
	if (M.a_intent == "help")
		src.sleeping = 0
		src.resting = 0
		if (src.paralysis >= 3) src.paralysis -= 3
		if (src.stunned >= 3) src.stunned -= 3
		if (src.weakened >= 3) src.weakened -= 3
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\blue The monkey shakes [] trying to wake him up!", src), 1)
	else
		if (istype(src.wear_mask, /obj/item/clothing/mask/muzzle))
			return
		if (src.health > 0)
			if (istype(src.wear_suit, /obj/item/clothing/suit/space))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/space/santa))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/bio_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/armor))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
				var/damage = rand(1, 3)
				var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg", "groin")
				if (istype(src.organs[text("[]", dam_zone)], /datum/organ/external))
					var/datum/organ/external/temp = src.organs[text("[]", dam_zone)]
					if (temp.take_damage(damage, 0))
						src.UpdateDamageIcon()
					else
						src.UpdateDamage()
				src.updatehealth()
	return

/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(src.loc, /turf) && istype(src.loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	if ((M.gloves && M.gloves.elecgen == 1 && M.a_intent == "hurt") /*&& (!istype(src:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
		if(M.gloves.uses > 0)
			M.gloves.uses--
			if (src.weakened < 5)
				src.weakened = 5
			if (src.stuttering < 5)
				src.stuttering = 5
			if (src.stunned < 5)
				src.stunned = 5
			for(var/mob/O in viewers(src, null))
				if (O.client)
					O.show_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>", 1, "\red You hear someone fall", 2)
		else
			M.gloves.elecgen = 0
			M << "\red Not enough charge! "
			return

	if (M.a_intent == "help")
		if (src.health > 0)
			if (src.w_uniform)
				src.w_uniform.add_fingerprint(M)
			src.sleeping = 0
			src.resting = 0
			if (src.paralysis >= 3) src.paralysis -= 3
			if (src.stunned >= 3) src.stunned -= 3
			if (src.weakened >= 3) src.weakened -= 3
			playsound(src, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	else
		if (M.a_intent == "grab")
			if (M == src)
				return
			if (src.w_uniform)
				src.w_uniform.add_fingerprint(M)
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
			G.assailant = M
			if (M.hand)
				M.l_hand = G
			else
				M.r_hand = G
			G.layer = 20
			G.affecting = src
			src.grabbed_by += G
			G.synch()
			playsound(src, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)
		else
			if (M.a_intent == "hurt" && !(M.gloves && M.gloves.elecgen == 1))
				if (src.w_uniform)
					src.w_uniform.add_fingerprint(M)
				var/damage = M.damageCheck()
				if(prob(50))
					damage = damage / 2 //HEHE
				if(M == src)
					damage = damage / 2
				src.TakeBruteDamage(abs(damage/rand(1,10)))
				var/datum/organ/external/affecting = src.organs["chest"]
				var/t = M.zone_sel.selecting
				if ((t in list( "eyes", "mouth" )))
					t = "head"
				var/def_zone = ran_zone(t)
				if (src.organs[text("[]", def_zone)])
					affecting = src.organs[text("[]", def_zone)]
				if ((istype(affecting, /datum/organ/external) && prob(90)))
					if (M.mutations & 8)
						damage += 5
						src.TakeBruteDamage(abs(damage/rand(8,10)))
						spawn(0)
							src.paralysis += 1
							step_away(src,M,15)
							sleep(3)
							step_away(src,M,15)
					playsound(src, "punch", 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has punched []!</B>", M, src), 1)

					if (def_zone == "head")
						if ((((src.head && src.head.body_parts_covered & HEAD) || (src.wear_mask && src.wear_mask.body_parts_covered & HEAD)) && prob(99)))
							if (prob(20))
								affecting.take_damage(damage, 0)
								src.TakeBruteDamage(abs(damage/rand(1,8)))
							else
								src.show_message("\red You have been protected from a hit to the head.")
							return
						if (damage > 4.9)
							if (src.weakened < 10)
								src.weakened = rand(10, 15)
							for(var/mob/O in viewers(M, null))
								O.show_message(text("\red <B>[] has weakened []!</B>", M, src), 1, "\red You hear someone fall.", 2)
						affecting.take_damage(damage)
						src.TakeBruteDamage(abs(damage/rand(10,30)))
					else
						if (def_zone == "chest")
							if ((((src.wear_suit && src.wear_suit.body_parts_covered & UPPER_TORSO) || (src.w_uniform && src.w_uniform.body_parts_covered & LOWER_TORSO)) && prob(85)))
								src.show_message("\red You have been protected from a hit to the chest.")
								return
							if (damage > 4.9)
								if (prob(50))
									if (src.weakened < 5)
										src.weakened = 5
									playsound(src, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
								else
									if (src.stunned < 5)
										src.stunned = 5
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
								if(src.stat != 2)	src.stat = 1
							affecting.take_damage(damage)
							src.TakeBruteDamage(abs(damage/rand(1,30)))
						else
							if (def_zone == "groin")
								if ((((src.wear_suit && src.wear_suit.body_parts_covered & LOWER_TORSO) || (src.w_uniform && src.w_uniform.body_parts_covered & LOWER_TORSO)) && prob(75)))
									src.show_message("\red You have been protected from a hit to the lower chest.")
									return
								if (damage > 4.9)
									if (prob(50))
										if (src.weakened < 3)
											src.weakened = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
									else
										if (src.stunned < 3)
											src.stunned = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
									if(src.stat != 2)	src.stat = 1
								affecting.take_damage(damage)
								src.TakeBruteDamage(abs(damage/2))

							else
								affecting.take_damage(damage)
								src.TakeBruteDamage(abs(damage))

					src.UpdateDamageIcon()

					src.updatehealth()
					sleep(20)
				else
					playsound(src, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has attempted to punch []!</B>", M, src), 1)
					return
			else
				if (!( src.lying ) && !(M.gloves && M.gloves.elecgen == 1))
					if (src.w_uniform)
						src.w_uniform.add_fingerprint(M)
					var/randn = rand(1, 100)
					if (randn <= 25)
						src.weakened = 2
						playsound(src, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							O.show_message(text("\red <B>[] has pushed down []!</B>", M, src), 1)
					else
						if (randn <= 60)
							src.drop_item()
							playsound(src, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has disarmed []!</B>", M, src), 1)
						else
							playsound(src, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has attempted to disarm []!</B>", M, src), 1)
	sleep(40)
	return

/mob/living/carbon/human/restrained()
	if (src.handcuffed)
		return 1
	if (istype(src.wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	return 0

/mob/living/carbon/human/proc/update_body()
	if(src.stand_icon)
		del(src.stand_icon)

	var/g = "m"
	if (src.gender == MALE)
		g = "m"
	else if (src.gender == FEMALE)
		g = "f"

	src.stand_icon = new /icon(species_icon, "blank")


	for (var/part in list("chest", "groin"))
		var/icon/ge =  new /icon(species_icon, "[part]_[g]_s")

		if (src.species_color != null && src.species != "human" && src.species != "alternian")
			ge += species_color

		src.stand_icon.Blend(ge, ICON_OVERLAY)

	for (var/part in list("leg_left", "leg_right", "foot_left", "foot_right"))
		var/icon/ge =  new /icon(species_icon, "[part]_s")

		if (src.species_color != null && src.species != "human" && src.species != "alternian")
			ge += species_color

		src.stand_icon.Blend(ge, ICON_OVERLAY)

	for (var/part in list("head", "arm_left", "arm_right", "hand_left", "hand_right"))
		var/icon/ge =  new /icon(species_icon, "[part]_s")

		if (src.species_color != null && src.species != "human" && src.species != "alternian")
			ge += species_color

		src.stand_icon.Blend(ge, ICON_OVERLAY)


	src.icon = src.stand_icon



/mob/living/carbon/human/proc/update_face()
	del(src.face_standing)

	var/g = "m"
	if (src.gender == MALE)
		g = "m"
	else if (src.gender == FEMALE)
		g = "f"

	var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "eyes_s")

	eyes_s.Blend(rgb(src.r_eyes, src.g_eyes, src.b_eyes), ICON_ADD)


	var/icon/hair_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[src.hair_icon_state]_s")
	hair_s.Blend(rgb(src.r_hair, src.g_hair, src.b_hair), ICON_ADD)

	var/icon/facial_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[src.face_icon_state]_s")
	facial_s.Blend(rgb(src.r_facial, src.g_facial, src.b_facial), ICON_ADD)

	var/icon/mouth_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "mouth_[g]_s")

	eyes_s.Blend(hair_s, ICON_OVERLAY)

	eyes_s.Blend(mouth_s, ICON_OVERLAY)
	eyes_s.Blend(facial_s, ICON_OVERLAY)


	src.face_standing = new /image()

	src.face_standing.icon = eyes_s


	del(mouth_s)
	del(facial_s)
	del(hair_s)
	del(eyes_s)

/mob/living/carbon/human/var/co2overloadtime = null
/mob/living/carbon/human/var/temperature_resistance = T0C+75

/mob/living/carbon/human/proc/TakeDamage(zone, brute, burn)
	var/datum/organ/external/E = src.organs[text("[]", zone)]
	if (istype(E, /datum/organ/external))
		if (E.take_damage(brute, burn))
			src.UpdateDamageIcon()
		else
			src.UpdateDamage()
	else
		return 0
	return

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)

	var/datum/organ/external/E = src.organs[text("[]", zone)]
	if (istype(E, /datum/organ/external))
		if (E.heal_damage(brute, burn))
			src.UpdateDamageIcon()
		else
			src.UpdateDamage()
	else
		return 0
	return

/mob/living/carbon/human/proc/UpdateDamage()

	var/list/L = list(  )
	for(var/t in src.organs)
		if (istype(src.organs[text("[]", t)], /datum/organ/external))
			L += src.organs[text("[]", t)]
	src.bruteloss = 0
	src.fireloss = 0
	for(var/datum/organ/external/O in L)
		src.bruteloss += O.brute_dam
		src.fireloss += O.burn_dam
	return

// new damage icon system
// now constructs damage icon for each organ from mask * damage field

/mob/living/carbon/human/proc/UpdateDamageIcon()
	var/list/L = list(  )
	for (var/t in src.organs)
		if (istype(src.organs[t], /datum/organ/external))
			L += src.organs[t]

	del(src.body_standing)
	src.body_standing = list()


	src.bruteloss = 0
	src.fireloss = 0

	for (var/datum/organ/external/O in L)
		src.bruteloss += O.brute_dam
		src.fireloss += O.burn_dam

		var/icon/DI = new /icon('icons/mob/dam_human.dmi', O.damage_state)			// the damage icon for whole human
		DI.Blend(new /icon('icons/mob/dam_mask.dmi', O.icon_name), ICON_MULTIPLY)		// mask with this organ's pixels

//		world << "[O.icon_name] [O.damage_state] \icon[DI]"

		body_standing += DI

		DI.Blend(new /icon('icons/mob/dam_mask.dmi', "[O.icon_name]2"), ICON_MULTIPLY)

//		world << "[O.r_name]2 [O.d_i_state]-2 \icon[DI]"


		//src.body_standing += new /icon( 'dam_zones.dmi', text("[]", O.d_i_state) )
		//src.body_lying += new /icon( 'dam_zones.dmi', text("[]2", O.d_i_state) )

/mob/living/carbon/human/show_inv(mob/user as mob)

	user.machine = src
	var/dat = {"
	<B><HR><FONT size=3>[src.name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(src.wear_mask ? src.wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(src.l_hand ? src.l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(src.r_hand ? src.r_hand : "Nothing")]</A>
	<BR><B>Gloves:</B> <A href='?src=\ref[src];item=gloves'>[(src.gloves ? src.gloves : "Nothing")]</A>
	<BR><B>Eyes:</B> <A href='?src=\ref[src];item=eyes'>[(src.glasses ? src.glasses : "Nothing")]</A>
	<BR><B>Ears:</B> <A href='?src=\ref[src];item=ears'>[(src.ears ? src.ears : "Nothing")]</A>
	<BR><B>Head:</B> <A href='?src=\ref[src];item=head'>[(src.head ? src.head : "Nothing")]</A>
	<BR><B>Shoes:</B> <A href='?src=\ref[src];item=shoes'>[(src.shoes ? src.shoes : "Nothing")]</A>
	<BR><B>Belt:</B> <A href='?src=\ref[src];item=belt'>[(src.belt ? src.belt : "Nothing")]</A>
	<BR><B>Uniform:</B> <A href='?src=\ref[src];item=uniform'>[(src.w_uniform ? src.w_uniform : "Nothing")]</A>
	<BR><B>(Exo)Suit:</B> <A href='?src=\ref[src];item=suit'>[(src.wear_suit ? src.wear_suit : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(src.back ? src.back : "Nothing")]</A> [((istype(src.wear_mask, /obj/item/clothing/mask) && istype(src.back, /obj/item/weapon/tank) && !( src.internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR><B>ID:</B> <A href='?src=\ref[src];item=id'>[(src.wear_id ? src.wear_id : "Nothing")]</A>
	<BR>[(src.handcuffed ? text("<A href='?src=\ref[src];item=handcuff'>Handcuffed</A>") : text("<A href='?src=\ref[src];item=handcuff'>Not Handcuffed</A>"))]
	<BR>[(src.internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];mach_close=mob[src.name]'>Close</A>
	<BR>"}
	user << browse(cssStyleSheetDab13 + dat, text("window=mob[src.name];size=340x480"))
	onclose(user, "mob[src.name]")
	return


// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/HasEntered(var/atom/movable/AM)
	var/obj/machinery/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOver(src)
