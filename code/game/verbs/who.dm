/mob/verb/who()
	set name = "Who"

	usr << "<b>Current Players:</b>"

	var/list/peeps = list()


	for (var/client/C in clients)
		usr << "[C.key]"

	usr << "<b>Total Players: [length(peeps)]</b>"

/client/verb/adminwho()
	set category = "Commands"

	usr << "<b>Current Admins:</b>"

	for (var/mob/M in world)
		if(M && M.client && M.client.holder)
			if(usr.client.holder)
				usr << "[M.key] is a [M.client.holder.rank][M.client.stealth ? " <i>(as [M.client.fakekey])</i>" : ""]"
			else if(!M.client.stealth)
				usr << "\t[M.client]"
