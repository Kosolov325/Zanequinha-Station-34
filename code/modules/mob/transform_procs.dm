/mob/living/carbon/AIize()
	if (src.transforming)
		return
	for(var/obj/item/weapon/W in src)
		src.u_equip(W)
		if (src.client)
			src.client.screen -= W
		if (W)
			W.loc = src.loc
			W.dropped(src)
			W.plane = ITEM_PLANE
			W.layer = initial(W.layer)
			del(W)
	src.update_clothing()
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101
	for(var/t in src.organs)
		del(src.organs[text("[]", t)])


	..()


/mob/proc/AIize()
	src.client.screen.len = null
	var/mob/living/silicon/ai/O = new /mob/living/silicon/ai( src.loc )

	O.invisibility = 0
	O.canmove = 0
	O.name = src.name
	O.real_name = src.real_name
	O.anchored = 1
	O.aiRestorePowerRoutine = 0
	O.lastKnownIP = src.client.address

	mind.transfer_to(O)

	var/obj/loc_landmark
	//if (ticker.mode.name  == "AI malfunction")
		//loc_landmark = locate("landmark*ai")
	//else
	loc_landmark = locate(text("start*AI"))

	O.loc = loc_landmark.loc

	O << "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>"
	O << "<B>To look at other parts of the station, double-click yourself to get a camera menu.</B>"
	O << "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>"
	O << "To use something, simply double-click it."
	O << "Currently right-click functions will not work for the AI (except examine), and will either be replaced with dialogs or won't be usable by the AI."

	if (ticker.mode.name != "AI malfunction")
		O.laws_object = new /datum/ai_laws/asimov
		O.show_laws()
		O << "<b>These laws may be changed by other players, or by you being the traitor.</b>"
	else
		O.verbs += /mob/living/silicon/ai/proc/choose_modules
		O.laws_object = new /datum/ai_laws/malfunction
		O:malf_picker = new /datum/game_mode/malfunction/AI_Module/module_picker
		O.show_laws()
		O << "<b>Kill all.</b>"
	O.verbs += /mob/living/silicon/ai/proc/ai_call_shuttle
	O.verbs += /mob/living/silicon/ai/proc/show_laws_verb
	O.verbs += /mob/living/silicon/ai/proc/ai_camera_track
	O.verbs += /mob/living/silicon/ai/proc/ai_alerts
	O.verbs += /mob/living/silicon/ai/proc/ai_camera_list
	O.verbs += /mob/living/silicon/ai/proc/lockdown
	O.verbs += /mob/living/silicon/ai/proc/disablelockdown
	O.verbs += /mob/living/silicon/ai/proc/ai_statuschange

//	O.verbs += /mob/living/silicon/ai/proc/ai_cancel_call
	O.job = "AI"

	spawn(0)
		var/randomname = pick(ai_names)
		var/newname = input(O,"You are the AI. Would you like to change your name to something else?", "Name change",randomname)

		if (length(newname) == 0)
			newname = randomname

		if (newname)
			if (length(newname) >= 26)
				newname = copytext(newname, 1, 26)
			newname = dd_replacetext(newname, ">", "'")
			O.real_name = newname
			O.name = newname

		world << text("<b>[O.real_name] is the AI!</b>")
		del(src)

	return O

//human -> robot
/mob/living/carbon/human/proc/Robotize()
	if (src.transforming)
		return
	for(var/obj/item/weapon/W in src)
		src.u_equip(W)
		if (src.client)
			src.client.screen -= W
		if (W)
			W.loc = src.loc
			W.dropped(src)
			W.plane = ITEM_PLANE
			W.layer = initial(W.layer)
			del(W)
	src.update_clothing()
	src.transforming = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101
	for(var/t in src.organs)
		del(src.organs[text("[t]")])
	//src.client.screen -= main_hud1.contents
	src.client.screen -= src.hud_used.contents
	src.client.screen -= src.hud_used.adding
	src.client.screen -= src.hud_used.mon_blo
	src.client.screen -= list( src.oxygen, src.throw2_icon, src.i_select, src.m_select, src.toxin, src.internals, src.fire, src.healths, src.shields, src.pullin, src.blind, src.flash, src.rest, src.sleep, src.mach )
	src.client.screen -= list( src.zone_sel, src.oxygen, src.throw2_icon, src.i_select, src.m_select, src.toxin, src.internals, src.fire, , src.healths, src.pullin, src.blind, src.flash, src.rest, src.sleep, src.mach )
	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot( src.loc )

	// cyborgs produced by Robotize get an automatic power cell
	O.cell = new(O)
	O.cell.maxcharge = 7500
	O.cell.charge = 1500


	O.gender = src.gender
	O.invisibility = 0
	O.name = "Cyborg"
	O.real_name = "Cyborg"
	O.lastKnownIP = src.client.address
	if (src.client)
		src.client.mob = O
	O.loc = src.loc
	O << "<B>You are playing a Robot. A Robot can interact with most electronic objects in its view point.</B>"
	O << "<B>You must follow the laws that the AI has. You are the AI's assistant to the station basically.</B>"
	O << "To use something, simply double-click it."
	O << {"Use say ":s to speak to fellow cyborgs and the AI through binary."}

	O.job = "Cyborg"



	del(src)
	return O