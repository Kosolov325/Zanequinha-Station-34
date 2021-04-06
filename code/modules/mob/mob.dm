/mob/proc/Cell()
	set category = "Admin"
	set hidden = 1

	if(!loc) return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/t = "\blue Coordinates: [x],[y] \n"
	t+= "\red Temperature: [environment.temperature] \n"
	t+= "\blue Nitrogen: [environment.nitrogen] \n"
	t+= "\blue Oxygen: [environment.oxygen] \n"
	t+= "\blue Plasma : [environment.toxins] \n"
	t+= "\blue Carbon Dioxide: [environment.carbon_dioxide] \n"
	for(var/datum/gas/trace_gas in environment.trace_gases)
		usr << "\blue [trace_gas.type]: [trace_gas.moles] \n"

	usr.show_message(t, 1)

// fun if you want to typecast humans/monkeys/etc without writing long path-filled lines.
/proc/ishuman(A)
	if(A && istype(A, /mob/living/carbon/human))
		return 1
	return 0

/proc/isrobot(A)
	if(A && istype(A, /mob/living/silicon/robot))
		return 1
	return 0

/proc/isAI(A)
	if(A && istype(A, /mob/living/silicon/ai))
		return 1
	return 0

/proc/iscarbon(A)
	if(A && istype(A, /mob/living/carbon))
		return 1
	return 0

/proc/issilicon(A)
	if(A && istype(A, /mob/living/silicon))
		return 1
	return 0

/proc/hsl2rgb(h, s, l)
	return

/proc/ran_zone(zone, probability)

	if (probability == null)
		probability = 90
	if (probability == 100)
		return zone
	switch(zone)
		if("chest")
			if (prob(probability))
				return "chest"
			else
				var/t = rand(1, 15)
				if (t < 3)
					return "head"
				else if (t < 6)
					return "l_arm"
				else if (t < 9)
					return "r_arm"
				else if (t < 13)
					return "groin"
				else if (t < 14)
					return "l_hand"
				else if (t < 15)
					return "r_hand"
				else
					return "chest"

		if("groin")
			if (prob(probability * 0.9))
				return "groin"
			else
				var/t = rand(1, 8)
				if (t < 4)
					return "chest"
				else if (t < 5)
					return "r_leg"
				else if (t < 6)
					return "l_leg"
				else if (t < 7)
					return "l_hand"
				else if (t < 8)
					return "r_hand"
				else
					return "groin"
		if("head")
			if (prob(probability * 0.75))
				return "head"
			else
				if (prob(60))
					return "chest"
				else
					return "head"
		if("l_arm")
			if (prob(probability * 0.75))
				return "l_arm"
			else
				if (prob(60))
					return "chest"
				else
					return "l_arm"
		if("r_arm")
			if (prob(probability * 0.75))
				return "r_arm"
			else
				if (prob(60))
					return "chest"
				else
					return "r_arm"
		if("r_leg")
			if (prob(probability * 0.75))
				return "r_leg"
			else
				if (prob(60))
					return "groin"
				else
					return "r_leg"
		if("l_leg")
			if (prob(probability * 0.75))
				return "l_leg"
			else
				if (prob(60))
					return "groin"
				else
					return "l_leg"
		if("l_hand")
			if (prob(probability * 0.5))
				return "l_hand"
			else
				var/t = rand(1, 8)
				if (t < 2)
					return "l_arm"
				else if (t < 3)
					return "chest"
				else if (t < 4)
					return "groin"
				else if (t < 6)
					return "l_leg"
				else
					return "l_hand"

		if("r_hand")
			if (prob(probability * 0.5))
				return "r_hand"
			else
				var/t = rand(1, 8)
				if (t < 2)
					return "r_arm"
				else if (t < 3)
					return "chest"
				else if (t < 4)
					return "groin"
				else if (t < 6)
					return "r_leg"
				else
					return "r_hand"

		if("l_foot")
			if (prob(probability * 0.25))
				return "l_foot"
			else
				var/t = rand(1, 5)
				if (t < 2)
					return "l_leg"
				else
					if (t < 3)
						return "r_foot"
					else
						return "l_foot"
		if("r_foot")
			if (prob(probability * 0.25))
				return "r_foot"
			else
				var/t = rand(1, 5)
				if (t < 2)
					return "r_leg"
				else
					if (t < 3)
						return "l_foot"
					else
						return "r_foot"
		else
	return

/proc/stars(n, pr)

	if (pr == null)
		pr = 25
	if (pr <= 0)
		return null
	else
		if (pr >= 100)
			return n
	var/te = n
	var/t = ""
	n = length(n)
	var/p = null
	p = 1
	while(p <= n)
		if ((copytext(te, p, p + 1) == " " || prob(pr)))
			t = text("[][]", t, copytext(te, p, p + 1))
		else
			t = text("[]*", t)
		p++
	return t

/proc/stutter(n)
	var/te = html_decode(n)
	var/t = ""
	n = length(n)
	var/p = null
	p = 1
	while(p <= n)
		var/n_letter = copytext(te, p, p + 1)
		if (prob(80))
			if (prob(10))
				n_letter = text("[n_letter][n_letter][n_letter][n_letter]")
			else
				if (prob(20))
					n_letter = text("[n_letter][n_letter][n_letter]")
				else
					if (prob(5))
						n_letter = null
					else
						n_letter = text("[n_letter][n_letter]")
		t = text("[t][n_letter]")
		p++
	return copytext(sanitize(t),1,MAX_MESSAGE_LEN)

/proc/shake_camera(mob/M, duration, strength=1)
	if(!M || !M.client)
		return
	M.client.shake = strength


/proc/findname(msg)
	for(var/mob/M in world)
		if (M.real_name == text("[msg]"))
			return 1
	return 0

/obj/proc/alter_health()
	return 1

/atom/proc/relaymove()
	return

/obj/proc/hide(h)
	return

/obj/item/weapon/grab/proc/throw2()
	if(src.affecting)
		var/grabee = src.affecting
		spawn(0)
			del(src)
		return grabee
	return null

/obj/item/weapon/grab/proc/synch()
	if (src.assailant.r_hand == src)
		src.hud1.screen_loc = ui_rhand
	else
		src.hud1.screen_loc = ui_lhand
	return

/obj/item/weapon/grab/process()
	if(!src.assailant || !src.affecting)
		del(src)
		return
	if ((!( isturf(src.assailant.loc) ) || (!( isturf(src.affecting.loc) ) || (src.assailant.loc != src.affecting.loc && get_dist(src.assailant, src.affecting) > 1))))
		//SN src = null
		del(src)
		return
	if (src.assailant.client)
		src.assailant.client.screen -= src.hud1
		src.assailant.client.screen += src.hud1
	if (src.assailant.pulling == src.affecting)
		src.assailant.pulling = null
	if (src.state <= 2)
		src.allow_upgrade = 1
		if ((src.assailant.l_hand && src.assailant.l_hand != src && istype(src.assailant.l_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = src.assailant.l_hand
			if (G.affecting != src.affecting)
				src.allow_upgrade = 0
		if ((src.assailant.r_hand && src.assailant.r_hand != src && istype(src.assailant.r_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = src.assailant.r_hand
			if (G.affecting != src.affecting)
				src.allow_upgrade = 0
		if (src.state == 2)
			var/h = src.affecting.hand
			src.affecting.hand = 0
			src.affecting.drop_item()
			src.affecting.hand = 1
			src.affecting.drop_item()
			src.affecting.hand = h
			for(var/obj/item/weapon/grab/G in src.affecting.grabbed_by)
				if (G.state == 2)
					src.allow_upgrade = 0
				//Foreach goto(341)
		if (src.allow_upgrade)
			src.hud1.icon_state = "reinforce"
		else
			src.hud1.icon_state = "!reinforce"
	else
		if (!( src.affecting.buckled ))
			src.affecting.loc = src.assailant.loc
	if ((src.killing && src.state == 3))
		src.affecting.stunned = max(5, src.affecting.stunned)
		src.affecting.paralysis = max(3, src.affecting.paralysis)
		src.affecting.losebreath = min(src.affecting.losebreath + 2, 3)
	return

/obj/item/weapon/grab/proc/s_click(obj/screen/S as obj)
	if (src.assailant.next_move > world.time)
		return
	if ((!( src.assailant.canmove ) || src.assailant.lying))
		//SN src = null
		del(src)
		return
	switch(S.id)
		if(1.0)
			if (src.state >= 3)
				if (!( src.killing ))
					for(var/mob/O in viewers(src.assailant, null))
						O.show_message(text("\red [] has temporarily tightened his grip on []!", src.assailant, src.affecting), 1)
						//Foreach goto(97)
					src.assailant.next_move = world.time + 10
					src.affecting.stunned = max(2, src.affecting.stunned)
					src.affecting.paralysis = max(1, src.affecting.paralysis)
					src.affecting.losebreath = min(src.affecting.losebreath + 1, 3)
					src.last_suffocate = world.time
					flick("disarm/killf", S)
		else
	return


/obj/item/weapon/grab/New()
	..()
	src.hud1 = new /obj/screen/grab( src )
	src.hud1.icon_state = "reinforce"
	src.hud1.name = "Reinforce Grab"
	src.hud1.id = 1
	src.hud1.master = src
	return

/obj/item/weapon/grab/attack(mob/M as mob, mob/user as mob)
	if (M == src.affecting)
		s_click(src.hud1)
		return
	if(M == src.assailant && src.state >= 2)
		if(iscarbon(src.affecting))
			var/mob/living/carbon/attacker = user
			for(var/mob/N in viewers(user, null))
				if(N.client)
					N.show_message(text("\red <B>[user] is attempting to devour [src.affecting]!</B>"), 1)
			if(!do_mob(user, src.affecting)) return
			for(var/mob/N in viewers(user, null))
				if(N.client)
					N.show_message(text("\red <B>[user] devours [src.affecting]!</B>"), 1)
			src.affecting.loc = user
			attacker.stomach_contents.Add(src.affecting)
			del(src)

/obj/item/weapon/grab/dropped()
	del(src)
	return

/obj/item/weapon/grab/Del()
	del(src.hud1)
	..()
	return

/obj/screen/zone_sel/MouseDown(location, control,params)		//(location, icon_x, icon_y)
	// Changes because of 4.0


	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])

	if (icon_y < 2)
		return
	else if (icon_y < 5)
		if ((icon_x > 9 && icon_x < 23))
			if (icon_x < 16)
				src.selecting = "r_foot"
			else
				src.selecting = "l_foot"
	else if (icon_y < 11)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 16)
				src.selecting = "r_leg"
			else
				src.selecting = "l_leg"
	else if (icon_y < 12)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 14)
				src.selecting = "r_leg"
			else if (icon_x < 19)
				src.selecting = "groin"
			else
				src.selecting = "l_leg"
		else
			return
	else if (icon_y < 13)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 12)
				src.selecting = "r_hand"
			else if (icon_x < 13)
				src.selecting = "r_leg"
			else if (icon_x < 20)
				src.selecting = "groin"
			else if (icon_x < 21)
				src.selecting = "l_leg"
			else
				src.selecting = "l_hand"
		else
			return
	else if (icon_y < 14)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 12)
				src.selecting = "r_hand"
			else if (icon_x < 21)
				src.selecting = "groin"
			else
				src.selecting = "l_hand"
		else
			return
	else if (icon_y < 16)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 13)
				src.selecting = "r_hand"
			else if (icon_x < 20)
				src.selecting = "chest"
			else
				src.selecting = "l_hand"
		else
			return
	else if (icon_y < 23)
		if ((icon_x > 7 && icon_x < 25))
			if (icon_x < 12)
				src.selecting = "r_arm"
			else if (icon_x < 21)
				src.selecting = "chest"
			else
				src.selecting = "l_arm"
		else
			return
	else if (icon_y < 24)
		if ((icon_x > 11 && icon_x < 21))
			src.selecting = "chest"
		else
			return
	else if (icon_y < 25)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 16)
				src.selecting = "head"
			else if (icon_x < 17)
				src.selecting = "mouth"
			else
				src.selecting = "head"
		else
			return
	else if (icon_y < 26)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 15)
				src.selecting = "head"
			else if (icon_x < 18)
				src.selecting = "mouth"
			else
				src.selecting = "head"
		else
			return
	else if (icon_y < 27)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 15)
				src.selecting = "head"
			else if (icon_x < 16)
				src.selecting = "eyes"
			else if (icon_x < 17)
				src.selecting = "mouth"
			else if (icon_x < 18)
				src.selecting = "eyes"
			else
				src.selecting = "head"
		else
			return
	else if (icon_y < 28)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 14)
				src.selecting = "head"
			else if (icon_x < 19)
				src.selecting = "eyes"
			else
				src.selecting = "head"
		else
			return
	else if (icon_y < 29)
		if ((icon_x > 11 && icon_x < 21))
			if (icon_x < 15)
				src.selecting = "head"
			else if (icon_x < 16)
				src.selecting = "eyes"
			else if (icon_x < 17)
				src.selecting = "head"
			else if (icon_x < 18)
				src.selecting = "eyes"
			else
				src.selecting = "head"
		else
			return
	else if (icon_y < 31)
		if ((icon_x > 11 && icon_x < 21))
			src.selecting = "head"
		else
			return
	else
		return

	overlays = null
	overlays += image("icon" = 'icons/mob/zone_sel.dmi', "icon_state" = text("[]", selecting))

	return

/obj/screen/grab/Click()
	src.master:s_click(src)
	return

/obj/screen/grab/attack_hand()
	return

/obj/screen/grab/attackby()
	return

/mob/living/carbon/human/Topic(href, href_list)
	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		src.machine = null
		src << browse(null, t1)
	..()
	return

/mob/proc/show_message(msg, type, alt, alt_type)
	if(!src.client)	return
	if (type)
		if ((type & 1 && (src.sdisabilities & 1 || (src.blinded || src.paralysis))))
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
		if ((type & 2 && (src.sdisabilities & 4 || src.ear_deaf)))
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
				if ((type & 1 && src.sdisabilities & 1))
					return
	// Added voice muffling for Issue 41.
	if (src.stat == 1 || src.sleeping > 0)
		src << "<I>... You can almost hear someone talking ...</I>"
	else
		src << msg
	return

// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"

/mob/visible_message(var/message, var/self_message, var/blind_message)
	for(var/mob/M in viewers(src))
		var/msg = message
		if(self_message && M==src)
			msg = self_message
		M.show_message( msg, 1, blind_message, 2)

// Show a message to all mobs in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/atom/proc/visible_message(var/message, var/blind_message)
	for(var/mob/M in viewers(src))
		M.show_message( message, 1, blind_message, 2)


/mob/proc/findname(msg)
	for(var/mob/M in world)
		if (M.real_name == text("[]", msg))
			return M
	return 0

/mob/proc/movement_delay()
	return 0

/mob/proc/Life()
	return

/mob/proc/update_clothing()
	return

/mob/proc/death(gibbed)
	src.timeofdeath = world.time
	return ..(gibbed)

/mob/proc/restrained()
	if (src.handcuffed)
		return 1
	return

/mob/proc/db_click(text, t1)
	var/obj/item/weapon/W = src.equipped()
	switch(text)
		if("mask")
			if (src.wear_mask)
				return
			if (!( istype(W, /obj/item/clothing/mask) ))
				return
			src.u_equip(W)
			src.wear_mask = W
			W.equipped(src, text)
		if("back")
			if ((src.back || !( istype(W, /obj/item/weapon) )))
				return
			if (!( W.flags & 1 ))
				return
			src.u_equip(W)
			src.back = W
			W.equipped(src, text)
		else
	return


/mob/living/carbon/proc/swap_hand()
	src.hand = !( src.hand )
	//world << "swapping hand bro to [hand]"
	if (!( src.hand ))
		src.HUDPosSel.screen_loc = ui_rhand
	else
		src.HUDPosSel.screen_loc = ui_lhand
	return

/mob/living/carbon/proc/swap_hand2(var/toHand = 0)

	src.hand = toHand
	if (!( src.hand ))
		src.HUDPosSel.screen_loc = ui_rhand
	else
		src.HUDPosSel.screen_loc = ui_lhand
	return

/mob/proc/drop_item_v()
	if (src.stat == 0)
		drop_item()
	return

/mob/proc/drop_from_slot(var/obj/item/item)
	if(!item)
		return
	if(!(item in src.contents))
		return
	u_equip(item)
	if (src.client)
		src.client.screen -= item
	if (item)
		item.loc = src.loc
		item.dropped(src)
		if (item)
			item.plane = ITEM_PLANE
			item.layer = initial(item.layer)
	var/turf/T = get_turf(src.loc)
	T.Entered(item)
	return

/mob/proc/drop_item()
	var/obj/item/W = src.equipped()
	if (W)
		u_equip(W)
		if (src.client)
			src.client.screen -= W
		if (W)
			W.loc = src.loc
			W.dropped(src)
			if (W)
				W.layer = initial(W.layer)
				W.plane = ITEM_PLANE
		var/turf/T = get_turf(src.loc)
		T.Entered(W)
	return

/mob/proc/reset_view(atom/A)
	if (src.client)
		if (istype(A, /atom/movable))
			src.client.perspective = EYE_PERSPECTIVE
			src.client.eye = A
		else
			if (isturf(src.loc))
				src.client.eye = src.client.mob
				src.client.perspective = MOB_PERSPECTIVE
			else
				src.client.perspective = EYE_PERSPECTIVE
				src.client.eye = src.loc
	return

/mob/proc/equipped()
	if (src.hand)
		return src.l_hand
	else
		return src.r_hand
	return

/mob/proc/show_inv(mob/user as mob)
	user.machine = src
	var/dat = text("<TT>\n<B><FONT size=3>[]</FONT></B><BR>\n\t<B>Head(Mask):</B> <A href='?src=\ref[];item=mask'>[]</A><BR>\n\t<B>Left Hand:</B> <A href='?src=\ref[];item=l_hand'>[]</A><BR>\n\t<B>Right Hand:</B> <A href='?src=\ref[];item=r_hand'>[]</A><BR>\n\t<B>Back:</B> <A href='?src=\ref[];item=back'>[]</A><BR>\n\t[]<BR>\n\t[]<BR>\n\t[]<BR>\n\t<A href='?src=\ref[];item=pockets'>Empty Pockets</A><BR>\n<A href='?src=\ref[];mach_close=mob[]'>Close</A><BR>\n</TT>", src.name, src, (src.wear_mask ? text("[]", src.wear_mask) : "Nothing"), src, (src.l_hand ? text("[]", src.l_hand) : "Nothing"), src, (src.r_hand ? text("[]", src.r_hand) : "Nothing"), src, (src.back ? text("[]", src.back) : "Nothing"), ((istype(src.wear_mask, /obj/item/clothing/mask) && istype(src.back, /obj/item/weapon/tank) && !( src.internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : ""), (src.internal ? text("<A href='?src=\ref[];item=internal'>Remove Internal</A>", src) : ""), (src.handcuffed ? text("<A href='?src=\ref[];item=handcuff'>Handcuffed</A>", src) : text("<A href='?src=\ref[];item=handcuff'>Not Handcuffed</A>", src)), src, user, src.name)
	user << browse(cssStyleSheetDab13 + dat, text("window=mob[];size=325x500", src.name))
	onclose(user, "mob[src.name]")
	return

/mob/proc/u_equip(W as obj)
	if (W == src.r_hand)
		src.r_hand = null
	else if (W == src.l_hand)
		src.l_hand = null
	else if (W == src.handcuffed)
		src.handcuffed = null
	else if (W == src.back)
		src.back = null
	else if (W == src.wear_mask)
		src.wear_mask = null

	update_clothing()

/mob/proc/ret_grab(obj/list_container/mobl/L as obj, flag)
	if ((!( istype(src.l_hand, /obj/item/weapon/grab) ) && !( istype(src.r_hand, /obj/item/weapon/grab) )))
		if (!( L ))
			return null
		else
			return L.container
	else
		if (!( L ))
			L = new /obj/list_container/mobl( null )
			L.container += src
			L.master = src
		if (istype(src.l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.l_hand
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				G.affecting.ret_grab(L, 1)
		if (istype(src.r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.r_hand
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				G.affecting.ret_grab(L, 1)
		if (!( flag ))
			if (L.master == src)
				var/list/temp = list(  )
				temp += L.container
				//L = null
				del(L)
				return temp
			else
				return L.container
	return

/mob/verb/mode()
	set name = "Equipment Mode"

	set src = usr

	var/obj/item/W = src.equipped()
	if (W)
		W.attack_self(src)
	return

/*
/mob/verb/dump_source()

	var/master = "<PRE>"
	for(var/t in typesof(/area))
		master += text("[]\n", t)
		//Foreach goto(26)
	src << browse(cssStyleSheetDab13 + master)
	return
*/

/mob/verb/memory()
	set name = "Notes"

	mind.show_memory(src)

/mob/verb/add_memory(msg as message)
	set name = "Add Note"

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize(msg)

	mind.store_memory(msg)

/mob/proc/store_memory(msg as message, popup, sane = 1)
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if (sane)
		msg = sanitize(msg)

	if (length(src.memory) == 0)
		src.memory += msg
	else
		src.memory += "<BR>[msg]"

	if (popup)
		src.memory()


/mob/verb/abandon_mob()
	set name = "Respawn"
	abandon_mob_proc(0)

/mob/proc/abandon_mob_proc(var/confirm = 0)
	if(confirm)
		if(client)
			client.music_pitch_new = 0
			//client << sound(null,channel=SOUND_CHANNEL_1+4)
		if(alert(src,"You died!, Would you like to respawn?","You died!","Yes","No") == "No")
			src << "<b><font color='#BF5FFF'>Reminder, you can always respawn later by going into the commands tab, and using Respawn."
			return
	log_game("[name]/[key] used abandon mob.")
	if(!src.client)
		log_game("[key] AM failed due to disconnect.")
	else
		for(var/obj/screen/t in src.client.screen)
			del t
		var/mob/new_player/M = new /mob/new_player()
		M.key = src.client.key
		M.client.eye = M
		M.client.screen = list()
		M.Login()
		M.client.music_pitch_new = 1
		M.client.music_pitch = 1
		if(istype(src,/mob/dead))
			del(src)
	return



/mob/verb/succumb()
	set hidden = 1

	src.oxyloss = 9999
	src << "\blue You have given up life and succumbed to death."

/mob/verb/observe()
	set name = "Observe"
	var/is_admin = 0

	if (src.client.holder && src.client.holder.level >= 1 && ( src.client.holder.state == 2 || src.client.holder.level > 3 ))
		is_admin = 1
	else if (istype(src, /mob/new_player) || src.stat != 2)
		usr << "\blue You must be observing to use this!"
		return

	if (is_admin && src.stat == 2)
		is_admin = 0

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()

	for (var/obj/item/weapon/disk/nuclear/D in world)
		var/name = "Nuclear Disk"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = D

	for (var/obj/machinery/bot/B in world)
		var/name = "BOT: [B.name]"
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		creatures[name] = B


//THIS IS HOW YOU ADD OBJECTS TO BE OBSERVED

	creatures += getmobs()
//THIS IS THE MOBS PART: LOOK IN HELPERS.DM

	src.client.perspective = EYE_PERSPECTIVE

	var/eye_name = null

	if (is_admin)
		eye_name = input("Please, select a player!", "Admin Observe", null, null) as null|anything in creatures
	else
		eye_name = input("Please, select a player!", "Observe", null, null) as null|anything in creatures

	if (!eye_name)
		return

	var/mob/eye = creatures[eye_name]
	if (is_admin)
		if (eye)
			src.reset_view(eye)
			client.adminobs = 1
			if(eye == src.client.mob)
				client.adminobs = 0
		else
			src.reset_view(null)
			client.adminobs = 0
	else
		if (eye)
			src.client.eye = eye
		else
			src.client.eye = src.client.mob

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	src.reset_view(null)
	src.machine = null
	if(istype(src, /mob/living))
		if(src:cameraFollow)
			src:cameraFollow = null

/mob/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(ismob(mover))
		var/mob/moving_mob = mover
		if ((src.other_mobs && moving_mob.other_mobs))
			return 1
		return (!mover.density || !src.density || src.lying)
	else
		return (!mover.density || !src.density || src.lying)
	return

/mob/dead/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1

/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		src.machine = null
		src << browse(null, t1)

	if(href_list["priv_msg"])
		var/mob/M = locate(href_list["priv_msg"])
		if(M)
			if(src.muted)
				src << "You are muted have a nice day"
				return
			if (!( ismob(M) ))
				return
			var/t = input("Message:", text("Private message to [M.key]"))  as text
			if (!( t ))
				return
			if (usr.client && usr.client.holder)
				M << "\red Admin PM from-<b>[key_name(usr, M, 0)]</b>: [t]"
				usr << "\blue Admin PM to-<b>[key_name(M, usr, 1)]</b>: [t]"
			else
				if (M.client && M.client.holder)
					M << "\blue Reply PM from-<b>[key_name(usr, M, 1)]</b>: [t]"
				else
					M << "\red Reply PM from-<b>[key_name(usr, M, 0)]</b>: [t]"
				usr << "\blue Reply PM to-<b>[key_name(M, usr, 0)]</b>: [t]"

			log_admin("PM: [key_name(usr)]->[key_name(M)] : [t]")

			//we don't use message_admins here because the sender/receiver might get it too
			for (var/mob/K in world)
				if(K && K.client && K.client.holder && K.key != usr.key && K.key != M.key)
					K << "<b><font color='blue'>PM: [key_name(usr, K)]->[key_name(M, K)]:</b> \blue [t]</font>"
	..()
	return

/mob/proc/get_damage()
	return src.health

/mob/MouseDrop(mob/M as mob)
	..()
	if(M != usr) return
	if(usr == src) return
	if(get_dist(usr,src) > 1) return
	if(istype(M,/mob/living/silicon/ai)) return
	if(LinkBlocked(usr.loc,src.loc)) return
	src.show_inv(usr)



/atom/movable/Move(NewLoc, direct)
	if (direct & direct - 1)
		if (direct & 1)
			if (direct & 4)
				if (step(src, NORTH))
					step(src, EAST)
				else
					if (step(src, EAST))
						step(src, NORTH)
			else
				if (direct & 8)
					if (step(src, NORTH))
						step(src, WEST)
					else
						if (step(src, WEST))
							step(src, NORTH)
		else
			if (direct & 2)
				if (direct & 4)
					if (step(src, SOUTH))
						step(src, EAST)
					else
						if (step(src, EAST))
							step(src, SOUTH)
				else
					if (direct & 8)
						if (step(src, SOUTH))
							step(src, WEST)
						else
							if (step(src, WEST))
								step(src, SOUTH)
	else
		. = ..()
	return

/atom/movable/verb/pull()
	set src in oview(1)

	if (!( usr ))
		return
	if (!( src.anchored ))
		usr.pulling = src
	return

/atom/proc/examineproc(ass)
	if (!( ass ))
		return
	ass << "This is \an [src.name]."
	if(src.desc)
		ass << src.desc

/atom/verb/examine()
	set src in oview(12)	//make it work from farther away

	if (!( usr ))
		return
	examineproc(usr)
	return

/client
	North()
		return
	South()
		return
	East()
		return
	West()
		return
	Southeast()
		return
	Southwest()
		return
	Northeast()
		return

/client/South()
	..()

/client/West()
	..()

/client/East()
	..()


/client/New()
	if (((world.address == src.address || !(src.address)) && !(host)))
		host = src.key
		world.update_status()

	..()

	if (join_motd)
		src << "[join_motd]"

/client/Del()
	spawn(0)
		if(src.holder)
			del(src.holder)
	return ..()

/mob/proc/can_use_hands()
	if(src.handcuffed)
		return 0
	if(src.buckled && istype(src.buckled, /obj/stool/bed)) // buckling does not restrict hands
		return 0
	return ..()

/mob/proc/is_active()
	return (0 >= usr.stat)

/mob/proc/see(message)
	if(!src.is_active())
		return 0
	src << message
	return 1

/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		M.see(message)

/mob/proc/updatehealth()
	if (src.nodamage == 0)
		src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
	else
		src.health = 100
		src.stat = 0

//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/proc/burn_skin(burn_amount)
	if(istype(src, /mob/living/carbon/human) && (!src.mutations & 2))
		var/mob/living/carbon/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = (burn_amount)/(H.organs.len)
		var/datum/organ/external/affecting = null
		var/extradam = 0	//added to when organ is at max dam
		for(var/A in H.organs)
			if(!H.organs[A])	continue
			affecting = H.organs[A]
			if(!istype(affecting, /datum/organ/external))	continue
			if(affecting.take_damage(0, divided_damage+extradam))
				extradam = 0
			else
				extradam += divided_damage
		H.UpdateDamageIcon()
		H.updatehealth()
		return 1
	else if(istype(src, /mob/living/silicon/ai))
		return 0

/mob/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(istype(src, /mob/living/carbon/human))
//		world << "[src] ~ [src.bodytemperature] ~ [temperature]"
	return temperature

/mob/proc/gib(give_medal)
	if (istype(src, /mob/dead/observer))
		var/virus = src.virus
		gibs(src.loc, virus)
		return
	src.death(1)
	var/atom/movable/overlay/animation = null
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101
	if(ishuman(src))
		animation = new(src.loc)
		animation.icon_state = "blank"
		animation.icon = 'icons/mob/mob.dmi'
		animation.master = src
		flick("gibbed", animation)

	if (src.client)
		var/mob/dead/observer/newmob

		newmob = new/mob/dead/observer(src)
		src:client:mob = newmob
		src.mind.transfer_to(newmob)

		var/virus = src.virus
		gibs(src.loc, virus)

	else if (!src.client)
		var/virus = src.virus
		gibs(src.loc, virus)

	sleep(15)
	del(src)

/mob/proc/get_contents()
	var/list/L = list()
	L += src.contents
	for(var/obj/item/weapon/storage/S in src.contents)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in src.contents)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()
	return L

/mob/proc/check_contents_for(A)
	var/list/L = list()
	L += src.contents
	for(var/obj/item/weapon/storage/S in src.contents)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in src.contents)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0


// adds a dizziness amount to a mob
// use this rather than directly changing var/dizziness
// since this ensures that the dizzy_process proc is started
// currently only humans get dizzy

// value of dizziness ranges from 0 to 1000
// below 100 is not dizzy

/mob/proc/make_dizzy(var/amount)
	if(!istype(src, /mob/living/carbon/human)) // for the moment, only humans get dizzy
		return

	dizziness = min(1000, dizziness + amount)	// store what will be new value
													// clamped to max 1000
	if(dizziness > 100 && !is_dizzy)
		spawn(0)
			dizzy_process()


// dizzy process - wiggles the client's pixel offset over time
// spawned from make_dizzy(), will terminate automatically when dizziness gets <100
// note dizziness decrements automatically in the mob's Life() proc.
/mob/proc/dizzy_process()
	is_dizzy = 1
	while(dizziness > 100)
		if(client)
			var/amplitude = dizziness*(sin(dizziness * 0.044 * world.time) + 1) / 70
			client.pixel_x = amplitude * sin(0.008 * dizziness * world.time)
			client.pixel_y3 = amplitude * cos(0.008 * dizziness * world.time)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_dizzy = 0
	if(client)
		client.pixel_x = 0
		client.pixel_y3 = 0

// jitteriness - copy+paste of dizziness

/mob/proc/make_jittery(var/amount)
	if(!istype(src, /mob/living/carbon/human)) // for the moment, only humans get dizzy
		return

	jitteriness = min(1000, jitteriness + amount)	// store what will be new value
													// clamped to max 1000
	if(jitteriness > 100 && !is_jittery)
		spawn(0)
			jittery_process()


// dizzy process - wiggles the client's pixel offset over time
// spawned from make_dizzy(), will terminate automatically when dizziness gets <100
// note dizziness decrements automatically in the mob's Life() proc.
/mob/proc/jittery_process()
	var/old_x = pixel_x
	var/old_y = pixel_y
	is_jittery = 1
	while(jitteriness > 100)
//		var/amplitude = jitteriness*(sin(jitteriness * 0.044 * world.time) + 1) / 70
//		pixel_x = amplitude * sin(0.008 * jitteriness * world.time)
//		pixel_y = amplitude * cos(0.008 * jitteriness * world.time)

		var/amplitude = min(4, jitteriness / 100)
		pixel_x = rand(-amplitude, amplitude)
		pixel_y = rand(-amplitude/3, amplitude/3)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_jittery = 0
	pixel_x = old_x
	pixel_y = old_y


/client/proc/station_explosion_cinematic()
	if(src.mob)
		var/mob/M = src.mob
		M.loc = null // HACK, but whatever, this works
		var/obj/screen/boom = M.hud_used.station_explosion
		M.client.screen += boom
		if(ticker)
			switch(ticker.mode.name)
				if("nuclear emergency")
					flick("start_nuke", boom)
				if("AI malfunction")
					flick("start_malf", boom)
				else
					boom.icon_state = "start"
		sleep(40)
		M << sound('explosionfar.ogg')
		boom.icon_state = "end"
		flick("explode", boom)
		sleep(40)
		if(ticker)
			switch(ticker.mode.name)
				if("nuclear emergency")
					boom.icon_state = "loss_nuke"
				if("AI malfunction")
					boom.icon_state = "loss_malf"
				else
					boom.icon_state = "loss_general"
