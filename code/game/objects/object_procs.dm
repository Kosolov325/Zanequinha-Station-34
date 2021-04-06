/obj/proc/updateUsrDialog()
	for(var/mob/M in range(1,src))
		if ((M.client && M.machine == src))
			src.attack_hand(M)
	if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
		if (!(usr in range(1,src)))
			if (usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
				src.attack_ai(usr)

/obj/proc/updateDialog()
	for(var/mob/M in range(1,src))
		if ((M.client && M.machine == src))
			src.attack_hand(M)
	AutoUpdateAI(src)


/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)

