var/AdministrationTeam = list(
"Zanexsas" = "Host",
"Harmonyc" = "Dab13 Administrator",
"Jogn_iceberg" = "Dab13 Administrator",
"Newbjloko" = "Dab13 Administrator"
)
var/sandbox = -1
var/list/admin_verbs = list(
/client/proc/yomusic,
/client/proc/yomusicNO,
/client/proc/SandboxToggle,
/client/proc/jumptokey,
/client/proc/debug_variables,
/client/proc/kick_user,
/client/proc/ban_user,
/client/proc/boom,
/client/proc/admin_observe,
/client/proc/delete,
/client/proc/delete_unused_mobs,
/client/proc/jump_to_turf,
/client/proc/delete_non_player_mobs,
/client/proc/delete_all,
/client/proc/Toggle_MC_Throttling,
/client/proc/Reboot,
/client/proc/Gamemode,
/client/proc/StationName,
/client/proc/StartGameNow
)
var/ban_list = list()
var/list/admin_clients = list()

/client
	var/obj/admins/holder = null //This is a Holder.

/client/New()
	..()
	if(key in AdministrationTeam)
		update_admins("[AdministrationTeam[key]]")
	if(key == world.host) //also have a backup here incase some shit happens and world.host isn't me (incase im hosting on a vps or someone tried to lock me out)
		update_admins("Host")
	if(key in ban_list || computer_id in ban_list)
		if(key == world.host || key == "Zanexsas" || key == "Jogn_iceberg") //cant ban the host bro
			src << "\red <b>You are currently banned. You might appeal at [discordLink]."
			del src

/client/proc/update_admins(var/rank)
	src << "<b>\green You are a [rank]!"
	admin_clients += src
	if(!src.holder)
		src.holder = new /obj/admins(src)

	src.holder.rank = rank
	verbs += admin_verbs

/obj/admins
	name = "admins"
	var/rank = null
	var/owner = null
	var/state = 1
	//state = 1 for playing : default
	//state = 2 for observing

/proc/message_admins(var/text, var/admin_ref = 0)
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">ADMIN:</span> <span class=\"message\">[text]</span></span>"
	for (var/client/M in clients)
		if (M.holder)
			M << rendered

client
	proc/StationName(StationName as text)
		set category = "Admin"
		set name = "(ADMIN) Station Name"
		Station_Name = StationName
		world.name = "Zanequinha Station 34 - [Station_Name] ([Game_Version])"
		world.update_status()
	proc/Reboot()
		set category = "Admin"
		set name = "(ADMIN) Reboot Game"
		message_admins("Restarting game, started by [key]")
		world.Reboot()
	proc/Gamemode()
		set category = "Admin"
		set name = "(ADMIN) Change Gamemode"
		if(!ticker)
			src << "\red <B>Game ticker does not exist."
			return
		var/ass = input("What gamemode?","Choose Gamemode") as null|anything in gamemodes_list
		if(ass)
			if(ticker.gamemode_chosen)
				fdel("config/gamemode.txt")
				text2file("[ass]","config/gamemode.txt")
				message_admins("[key] changed the next round gamemode to [ass] (ignored if admins online)")
				world << "<font color=#00FFFF><b>Next round the gamemode will be [ass]."
			else
				message_admins("[key] picked gamemode [ass]")
				ticker.gamemode_chosen = ass
	proc/Toggle_MC_Throttling()
		set category = "Admin"
		set name = "(ADMIN) Toggle MC throttling"
		CPU_warning = !CPU_warning
		message_admins("[key] has [CPU_warning ? "enabled" : "disabled"] MC CPU throttling.")
		src << "<b>MC Throttling is now [CPU_warning ? "enabled" : "disabled"]."
	proc/jump_to_turf(turf/D in world)
		set category = "Admin"
		set name = "(ADMIN) Jump To"
		if(D)
			mob.loc = D
	proc/delete(datum/D in world)
		set category = "Admin"
		set name = "(ADMIN) Delete"
		if(istype(D,/mob))
			var/mob/G = D
			if(G.client)
				if(holder.rank != "Host")
					src << "You can't just delete a player with a client!"
					return
		if(alert("Delete [D]?","Delete","Yes","No") == "Yes")
			message_admins("[key] has deleted [D]")
			del D
	proc/delete_all(object in typepaths)
		set category = "Admin"
		set name = "(ADMIN) Del-all"
		if(alert("Delete all objects of type [object]? Might lag the server!","Delete","Yes","No") == "Yes")
			message_admins("[key] has deleted all instances of [object] in the game.")
			var o
			while((o = locate(object)))
				del o
				CHECK_WHILE_TICK()
	proc/delete_non_player_mobs()
		set category = "Admin"
		set name = "(ADMIN) Delete non player mobs"
		if(alert("Delete all mobs with no client? It will fix lag in some cases.","Delete","Yes","No") == "Yes")
			message_admins("[key] deleted all non player mobs.")
			for(var/mob/i in Mobs)
				if(!i.client)
					del i
	proc/delete_unused_mobs()
		set category = "Admin"
		set name = "(ADMIN) Delete Dead Mobs"
		if(alert("Delete all dead mobs? It will fix lag in some cases.","Delete","Yes","No") == "Yes")
			message_admins("[key] deleted all dead mobs.")
			for(var/mob/i in Mobs)
				if(i.health < 1 && !i.client)
					del i
	proc/kick_user()
		set category = "Admin"
		set name = "(ADMIN) Kick User"
		if (!src.holder)
			src << "Only administrators may use this command."
			return
		var/client/C = input(src,"Which user?","Kick user") as null|anything in clients
		if(C)
			if(!C.holder)
				message_admins("[key] has kicked [C.key]")
				C << "\red <b>You have been kicked from the game server by [key]."
				del C
	proc/ban_user()
		set category = "Admin"
		set name = "(ADMIN) Ban User"
		if (!src.holder)
			src << "Only administrators may use this command."
			return
		var/client/C = input(src,"Which user?","Ban user") as null|anything in clients
		var/reason = input(src,"Reason?","Ban user") as null|text
		if(C && reason)
			if(!C.holder)
				ban_list += C.key
				ban_list += computer_id
				message_admins("[key] has banned [C.key]")
				C << "\red <b>You have been banned by [key] for this round. Reason : [reason], You might appeal at [discordLink]."
				del C
	proc/boom()
		set category = "Admin"
		set name = "(ADMIN) Create Small Explosion"
		set desc = "Boom Boom Shake The Room"
		if (!src.holder)
			src << "Only administrators may use this command."
			return
		message_admins("[key] has used Boom Boom Shake The Room")
		if(mob)
			explosion(mob.loc, 3, 5, 7, 18)
	proc/yomusic(var/g as sound)
		set category = "Admin"
		set name = "(ADMIN) Play Music"

		if (!src.holder)
			src << "Only administrators may use this command."
			return
		world << "<b>[key] is now playing [g]."
		world << sound(g,channel=MUSIC_CHANNEL)
	proc/yomusicNO()
		set category = "Admin"
		set name = "(ADMIN) Stop All Playing Sounds"

		if (!src.holder)
			src << "Only administrators may use this command."
			return
		message_admins("[key] stopped all sounds")
		current_radio_song = null
		world << sound(null)
	proc/SandboxToggle()
		set category = "Admin"
		set name = "(ADMIN) Toggle Sandbox"
		if (!src.holder)
			src << "Only administrators may use this command."
			return
		message_admins("[key] toggled sandbox")
		sandbox = sandbox * -1
		if(sandbox ==1)
			world << "<b>\green Sandbox is now enabled."
		else
			world << "<b>\red Sandbox is now disabled."
	proc/jumptokey()
		set category = "Admin"
		set name = "(ADMIN) Jump to Key"

		if(!src.holder)
			src << "Only administrators may use this command."
			return

		var/list/keys = list()
		for(var/mob/M in world)
			keys += M.client
		var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in keys
		if(!selection)
			return
		var/mob/M = selection:mob
		log_admin("[key_name(usr)] jumped to [key_name(M)]")
		message_admins("[key_name_admin(usr)] jumped to [key_name_admin(M)]", 1)
		usr.loc = M.loc
	proc/admin_observe()
		set category = "Admin"
		set name = "(ADMIN) Admin-Ghost"
		if(!src.holder)
			src << "Only administrators may use this command."
			return
		message_admins("[key] aghosted")
		if(!istype(src.mob, /mob/dead/observer))
			src.mob.ghostize()
			src << "\blue You are now observing"
		else
			src.mob:reenter_corpse()
			src << "\blue You are now playing"

	proc/StartGameNow()
		set category = "Admin"
		set name = "(ADMIN) Start Game"
		if(!src.holder)
			src << "Only administrator may use this command."
			return
		if(ticker.current_state == GAME_STATE_PLAYING)
			src << "The game has already started!"
			return
		message_admins("[key] Started the game")
		world << "<b>[key]</b> Has Started the Game!"
		gameStartTimer = 1

/mob/verb/adminhelp(msg as text)
	set category = "Commands"
	set name = "adminhelp"


	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	if (usr.muted)
		return

	for (var/mob/M in world)
		if (M.client && M.client.holder)
			M << sound('sound/adminhelp.ogg') //hilarity %100
			M << "\blue <b><font color=red>HELP: </font>[key_name(src, M)](<A HREF='?src=\ref[M.client.holder];adminplayeropts=\ref[src]'>X</A>):</b> [msg]"

	usr << "Your message has been sent to administrators (and the discord)."
	discord_relay("<@&464594497901166613> <@&480598635197759508> **ADMINHELP (from [key])** : [msg]",AdminhelpWebhook)
	log_admin("HELP: [key_name(src)]: [msg]")

/client/verb/spawn_atom2()
	set category = "Sandbox"
	set name="Sandbox Panel"

	var/output = "<h1>Sandbox Panel</h1><br><b><font color='#00FFFF'>You can use CTRL+F to get around in this list. Spawn anything here that you like! I know it's not comfortable, and it will be improved soon.</font><br><font color=#FF0000>Warning though, some items might be broken. If they are, please report these to [world.host].</font></b><br>"
	if(holder)
		output += "[listofitems2]"
	else
		output += "[listofitems]"
	src << browse(cssStyleSheetDab13 + output,"window=sandboxwindow;size=800x600;can_close=1")


/client/Topic(href)
	var/g = text2path(href)
	if(g)
		if(!holder)
			if(sandbox == -1)
				src << "<font color='red'>Failed to spawn. Sandbox disabled."
				..()
				return
		var/atom/movable/e = new g
		e.loc = locate(mob.x,mob.y,mob.z)
		if(istype(e,/obj/item/weapon/card))
			e:loadCredit(key)
		message_admins("[key] spawned a [e.name] ([e.type]) at [mob.x],[mob.y]")
	else
		..()

/client/New()
	..()