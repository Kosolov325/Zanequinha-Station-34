/obj/machinery/nuclearbomb/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/nuclearbomb/attack_hand(mob/user as mob)
	user.machine = src
	var/dat = "<TT><B>Nuclear Fission Explosive</B><BR><center>\nNuke controls. Do not use without dabber permission."
	dat += "<br><br><b><a href='byond://?src=\ref[src];timer=1'>Toggle</a></b>"

	user << browse(cssStyleSheetDab13 + dat, "window=nuclearbomb;size=300x400")
	onclose(user, "nuclearbomb")
	return

/obj/machinery/nuclearbomb/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["timer"])
			if(nuke_enabled == 0)
				ticker.nuke_enable()
			else
				ticker.nuke_disable()
		src.add_fingerprint(usr)
		for(var/mob/M in viewers(1, src))
			if ((M.client && M.machine == src))
				src.attack_hand(M)
	else
		usr << browse(null, "window=nuclearbomb")
		return
	return

//this whole thing is kryfrac level retarded???



/obj/machinery/nuclearbomb/ex_act(severity)
	del(src)
	return

/obj/machinery/nuclearbomb/blob_act()
	return

/obj/item/weapon/disk/nuclear/Del()
	if (ticker.mode && ticker.mode.name == "nuclear emergency")
		if(blobstart.len > 0)
			var/obj/D = new /obj/item/weapon/disk/nuclear(pick(blobstart))
			message_admins("[src] has been destroyed. Spawning [D] at ([D.x], [D.y], [D.z]).")
	..()
