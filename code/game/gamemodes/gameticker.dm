var/global/datum/controller/gameticker/ticker
var/gameStartTimer = 2000
var/kick_inactive_players = 0 //do_kick on mode handles.
#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4

/datum/controller/gameticker
	var/current_state = GAME_STATE_PREGAME

	var/hide_mode = 0
	var/datum/game_mode/mode = null
	var/event_time = null
	var/event = 0

	var/list/datum/mind/minds = list()

	var/pregame_timeleft = 0
	var/votes = 0
	var/gamemode_chosen = null

/datum/controller/gameticker/proc/pregame()
	current_state = GAME_STATE_SETTING_UP
	spawn setup()

/datum/game_mode
	var/events_enabled = 0


/datum/game_mode/proc/ending()
	return

/datum/controller/gameticker/proc/setup()
	if(!(world.port in PORTS_NOT_ALLOWED))
		for(var/i in 0 to gameStartTimer)
			if(gameStartTimer <= 1)
				break
			world << "<font color='#00FFFF'>Game starting in <b>[abs(gameStartTimer-i)] secs</b>"
			sleep(10)

	/*if(admin_clients.len > 0)
		world << "\red <B>Admins are currently connected. They will pick the gamemode."
		for(var/client/i in admin_clients)
			i.Gamemode()
		while(gamemode_chosen == null)
			sleep(1)
	else*/

	world << "\red <B>Loading gamemode from config file."
	gamemode_chosen=text2path(replacetext("[file2text("config/gamemode.txt")]","\n",""))

	if(gamemode_chosen)
		world << "<b>Loaded gamemode [gamemode_chosen]"
	else
		world << "\red <B>Error loading gamemode. Please set with administrator. Starting setup again."
		spawn setup()
		return

	src.mode = new gamemode_chosen
	var/can_continue = src.mode.pre_setup()

	if(!can_continue)
		del mode
		current_state = GAME_STATE_PREGAME
		world << "\red <B>Error setting up [master_mode].</B> Reverting to pre-game lobby."
		spawn()
			pregame()
		return 0

	world << "<FONT color='blue'><B><font size=4>Welcome to [Station_Name]!"
	world << 'sound/welcome.ogg'

	//Create player characters and transfer them
	create_characters()

	add_minds()

	data_core.manifest()


	if(!(world.port in PORTS_NOT_ALLOWED))
		spawn()
			call("ByondPOST.dll", "send_post_request")("[WebhookURL]", " { \"content\" : \"Round on [world.name] started, mode is [mode.name]\" } ", "Content-Type: application/json")

	current_state = GAME_STATE_PLAYING
	spawn(0)
		mode.post_setup()

		//Cleanup some stuff
		for(var/obj/landmark/start/S in world)
			//Deleting Startpoints but we need the ai point to AI-ize people later
			if (S.name != "AI")
				del(S)

	if(mode.do_kick == 1)
		world << "<b><font color='red'>Automatic kicking is enabled! After [TIMETOKICK/60] minutes of inactivity, you will be kicked."
		kick_inactive_players = 1
	if(mode.sandbox_allowed)
		sandbox = 1
	if(mode.events_enabled) //src.mob.ghostize()
		spawn (3000)
			start_events()
		spawn ((18000+rand(3000)))
			event()
	spawn master_controller.start_processing()

/datum/controller/gameticker

	proc/create_characters()
		for(var/mob/new_player/player in world)
			player << sound(null,channel=LOBBY_CHANNEL)
			if(player.mind )
				if(player.mind.assigned_role=="AI")
					player.close_spawn_windows()
					player.AIize()
				else
					//player.Equip_Rank("Assistant", 0)
					player.AttemptSpawn("Assistant", 10000)
	proc/add_minds()
		for(var/mob/living/carbon/human/player in world)
			if(player.mind)
				ticker.minds += player.mind


	proc/process()
		if(current_state == GAME_STATE_FINISHED)
			return
		mode.process()

		emergency_shuttle.process()

		if(mode.check_finished() || nuke_enabled == 2)
			current_state = GAME_STATE_FINISHED

			spawn
				declare_completion()
			if(!(world.port in PORTS_NOT_ALLOWED))
				spawn()
					call("ByondPOST.dll", "send_post_request")("[WebhookURL]", " { \"content\" : \"Round on [world.name] ended. Rebooting.\" } ", "Content-Type: application/json")
			spawn(50)
				mode.ending()
				//'titlesong.ogg'
				world << sound('music/karako.ogg',channel=LOBBY_CHANNEL,volume=100, repeat = 1)
				world << "\blue <B>Restarting in 10 seconds</B>"

				sleep(100)
				world.Reboot()

		return 1

/*
/datum/controller/gameticker/proc/timeup()

	if (shuttle_left) //Shuttle left but its leaving or arriving again
		check_win()	  //Either way, its not possible
		return

	if (src.shuttle_location == shuttle_z)

		move_shuttle(locate(/area/shuttle), locate(/area/arrival/shuttle))

		src.timeleft = shuttle_time_in_station
		src.shuttle_location = 1

		world << "<B>The Emergency Shuttle has docked with the station! You have [ticker.timeleft/600] minutes to board the Emergency Shuttle.</B>"

	else //marker2
		world << "<B>The Emergency Shuttle is leaving!</B>"
		shuttle_left = 1
		shuttlecoming = 0
		check_win()
	return
*/

/datum/controller/gameticker/proc/declare_completion()

	for (var/mob/living/silicon/ai/aiPlayer in world)
		if (aiPlayer.stat != 2)
			world << "<b>The AI's laws at the end of the game were:</b>"
		else
			world << "<b>The AI's laws when it was deactivated were:</b>"

		aiPlayer.show_laws(1)

	mode.declare_completion()

	return 1

/////
/////SETTING UP THE GAME
/////

/////
/////MAIN PROCESS PART
/////
/*
/datum/controller/gameticker/proc/game_process()

	switch(mode.name)
		if("deathmatch","monkey","nuclear emergency","Corporate Restructuring","revolution","traitor",
		"wizard","extended")
			do
				if (!( shuttle_frozen ))
					if (src.timing == 1)
						src.timeleft -= 10
					else
						if (src.timing == -1.0)
							src.timeleft += 10
							if (src.timeleft >= shuttle_time_to_arrive)
								src.timeleft = null
								src.timing = 0
				if (prob(0.5))
					spawn_meteors()
				if (src.timeleft <= 0 && src.timing)
					src.timeup()
				sleep(10)
			while(src.processing)
			return
//Standard extended process (incorporates most game modes).
//Put yours in here if you don't know where else to put it.
		if("AI malfunction")
			do
				check_win()
				ticker.AItime += 10
				sleep(10)
				if (ticker.AItime == 6000)
					world << "<FONT size = 3><B>Fucktrasen Update</B> AI Malfunction Detected</FONT>"
					world << "\red It seems we have provided you with a malfunctioning AI. We're very sorry."
			while(src.processing)
			return
//malfunction process
		if("meteor")
			do
				if (!( shuttle_frozen ))
					if (src.timing == 1)
						src.timeleft -= 10
					else
						if (src.timing == -1.0)
							src.timeleft += 10
							if (src.timeleft >= shuttle_time_to_arrive)
								src.timeleft = null
								src.timing = 0
				for(var/i = 0; i < 10; i++)
					spawn_meteors()
				if (src.timeleft <= 0 && src.timing)
					src.timeup()
				sleep(10)
			while(src.processing)
			return
//meteor mode!!! MORE METEORS!!!
		else
			return
//Anything else, like sandbox, return.
*/