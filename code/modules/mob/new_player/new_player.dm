mob
	verb
		discord()
			src << link("[discord_link]")

mob/new_player
	anchored = 1

	var/datum/preferences/preferences
	var/ready = 1

	invisibility = 101

	density = 0
	stat = 2
	canmove = 0

	anchored = 1	//  don't get pushed around
	sight = (SEE_THRU|SEE_INFRA|SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS)
	Login()
		..()

		if(!preferences)
			preferences = new

		if(!mind)
			mind = new
			mind.key = key
			mind.current = src

		src << sound(pick(titleSongs),channel=LOBBY_CHANNEL,volume=100, repeat = 1)
		new_player_panel()

		loc = locate(230,91,1)

		if(!preferences.savefile_load(src, 0))
			preferences.ShowChoices(src)


	Logout()
		ready = 0
		..()
		return

	verb
		new_player_panel()
			set src = usr
			var/output = "<HR><B>Lobby</B><BR>"
			output += "<HR><br><a href='byond://?src=\ref[src];show_preferences=1'>Character Creator</A><BR><BR>"
			//if(istester(src.key))
			if(!ticker)
				output += "The game has not started yet.<BR>"
				ready = 1
			else
				if(ticker.current_state == GAME_STATE_PLAYING)
					ready = 0
					output += "<a href='byond://?src=\ref[src];late_join=1'>Join Game!</A><BR>"

			output += "<BR><a href='byond://?src=\ref[src];observe=1'>Spectate</A><BR><BR>"

			src << browse(cssStyleSheetDab13 + output,"window=playersetup;size=300x400;can_close=0")

	Topic(href, href_list[])
		if(href_list["show_preferences"])
			preferences.ShowChoices(src)
			return 1
		if(href_list["observe"])

			if(alert(src,"Are you sure you wish to spectate?","Player Setup","Yes","No") == "Yes")
				var/mob/dead/observer/observer = new()
				src << sound(null,channel=LOBBY_CHANNEL)
				close_spawn_windows()
				var/obj/machinery/sleeper/spawner/g = pick(rand_spawns)
				observer.loc = g.loc
				src << "\blue Now teleporting."
				observer.key = key
				observer.name = preferences.real_name
				observer.real_name = observer.name

				del(src)
				return 1

		if(href_list["late_join"])
			LateChoices()
			return 1

		if(href_list["SelectedJob"])

			switch(href_list["SelectedJob"])
				if ("1")
					AttemptLateSpawn("Captain", captainMax)
				if ("2")
					AttemptLateSpawn("Head of Security", hosMax)
				if ("3")
					AttemptLateSpawn("Head of Personnel", hopMax)
				if ("4")
					AttemptLateSpawn("Station Engineer", engineerMax)
				if ("5")
					AttemptLateSpawn("Barman", barmanMax)
				if ("6")
					AttemptLateSpawn("Scientist", scientistMax)
				if ("7")
					AttemptLateSpawn("Chemist", chemistMax)
				if ("8")
					AttemptLateSpawn("Geneticist", geneticistMax)
				if ("9")
					AttemptLateSpawn("Security Officer", securityMax)
				if ("10")
					AttemptLateSpawn("Medical Doctor", doctorMax)
				if ("11")
					AttemptLateSpawn("Atmospheric Technician", atmosMax)
				if ("12")
					AttemptLateSpawn("Detective", detectiveMax)
				if ("13")
					AttemptLateSpawn("Chaplain", chaplainMax)
				if ("14")
					AttemptLateSpawn("Janitor", janitorMax)
				if ("15")
					AttemptLateSpawn("Clown", clownMax)
				if ("16")
					AttemptLateSpawn("Chef", chefMax)
				if ("17")
					AttemptLateSpawn("Roboticist", roboticsMax)
				if ("18")
					AttemptLateSpawn("Assistant",999999)
				if ("19")
					AttemptLateSpawn("Quartermaster", cargoMax)
				if ("20")
					AttemptLateSpawn("Research Director", directorMax)
				if ("21")
					AttemptLateSpawn("Chief Engineer", chiefMax)
			return 1
		if(href_list["preferences"])
			preferences.process_link(src, href_list)
			return 1
		else
			new_player_panel()

	proc/IsJobAvailable(rank, maxAllowed)
		if(countJob(rank) < maxAllowed)
			return 1
		else
			return 0

	proc/AttemptLateSpawn(rank, maxAllowed)
		if(IsJobAvailable(rank, maxAllowed))
			src << sound(null,channel=LOBBY_CHANNEL)
			var/mob/living/carbon/human/character = create_character()

			character.Equip_Rank(rank, joined_late=1)

			//add to manifest
			for(var/datum/data/record/t in data_core.general)
				if((t.fields["name"] == character.real_name) && (t.fields["rank"] == "Unassigned"))
					t.fields["rank"] = rank

			if (ticker.current_state == GAME_STATE_PLAYING)
				for (var/mob/living/silicon/ai/A in world)
					if (!A.stat)
						A.say("[character.real_name] has signed up as [rank].")

			del(src)

		else
			src << alert("[rank] is not available. Please try another.")


	proc/AttemptSpawn(rank, maxAllowed)
		if(IsJobAvailable(rank, maxAllowed))
			src << sound(null,channel=LOBBY_CHANNEL)
			var/mob/living/carbon/human/character = create_character()

			character.Equip_Rank(rank, joined_late=0)

			//add to manifest
			for(var/datum/data/record/t in data_core.general)
				if((t.fields["name"] == character.real_name) && (t.fields["rank"] == "Unassigned"))
					t.fields["rank"] = rank

			if (ticker.current_state == GAME_STATE_PLAYING)
				for (var/mob/living/silicon/ai/A in world)
					if (!A.stat)
						A.say("[character.real_name] has signed up as [rank].")

			del(src)

		else
			src << alert("[rank] is not available. Please try another.")

// This fxn creates positions for assistants based on existing positions. This could be more elgant.
	proc/LateChoices()
		var/dat = "<html><body>"
		dat += "Choose from the following open positions:<br>"
		if (IsJobAvailable("Captain",captainMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=1'>Captain</a><br>"

		if (IsJobAvailable("Head of Security",hosMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=2'>Head of Security</a><br>"

		if (IsJobAvailable("Head of Personnel",hopMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=3'>Head of Personnel</a><br>"

		if (IsJobAvailable("Chief Engineer",chiefMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=21'>Chief Engineer</a><br>"

		if (IsJobAvailable("Station Engineer",engineerMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=4'>Station Engineer</a><br>"

		if (IsJobAvailable("Scientist",scientistMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=6'>Scientist</a><br>"

		if (IsJobAvailable("Chemist",chemistMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=7'>Chemist</a><br>"

		if (IsJobAvailable("Geneticist",geneticistMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=8'>Geneticist</a><br>"

		if (IsJobAvailable("Security Officer",securityMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=9'>Security Officer</a><br>"

		if (IsJobAvailable("Medical Doctor",doctorMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=10'>Medical Doctor</a><br>"

		if (IsJobAvailable("Atmospheric Technician",atmosMax))
			dat += "<a href='byond://?src=\ref[src];SelectedJob=11'>Atmospheric Technician</a><br>"



		dat += "<a href='byond://?src=\ref[src];SelectedJob=18'>Assistant</a><br>"

		src << browse(cssStyleSheetDab13 + dat, "window=latechoices;size=300x640;can_close=0")

	proc/create_character()
		var/mob/living/carbon/human/new_character = new(src.loc)

		close_spawn_windows()

		preferences.copy_to(new_character)
		new_character.dna.ready_dna(new_character)

		mind.transfer_to(new_character)


		return new_character

	Move()
		return 0


	proc/close_spawn_windows()
		src << browse(null, "window=latechoices") //closes late choices window
		src << browse(null, "window=playersetup") //closes the player setup window

/*
/obj/begin/verb/enter()
	log_game("[usr.key] entered as [usr.real_name]")

	if (ticker)
		for (var/mob/living/silicon/ai/A in world)
			if (!A.stat)
				A.say("[usr.real_name] has arrived on the station!")
				break

		usr << "<B>Game mode is [master_mode].</B>"

	var/mob/living/carbon/human/H = usr

//find spawn points for normal game modes

	if(!(ticker && ticker.mode.name == "ctf"))
		var/list/L = list()
		var/area/A = locate(/area/arrival/start)
		for(var/turf/T in A)
			L += T

		while(!L.len)
			usr << "\blue <B>You were unable to enter because the arrival shuttle has been destroyed! The game will reattempt to spawn you in 30 seconds!</B>"
			sleep(300)
			for(var/turf/T in A)
				L += T
		H << "\blue Now teleporting."
		H.loc = pick(L)

//for capture the flag

	else if(ticker && ticker.mode.name == "ctf")
		if(H.client.team == "Red")
			var/obj/R = locate("landmark*Red-Spawn")
			H << "\blue Now teleporting."
			H.loc = R.loc
		else if(H.client.team == "Green")
			var/obj/G = locate("landmark*Green-Spawn")
			H << "\blue Now teleporting."
			H.loc = G.loc

//error check

	else
		usr << "Invalid start please report this to the admins"

//add to manifest

	if(ticker)
		//add to manifest
		var/datum/data/record/G = new /datum/data/record(  )
		var/datum/data/record/M = new /datum/data/record(  )
		var/datum/data/record/S = new /datum/data/record(  )
		var/obj/item/weapon/card/id/C = H.wear_id
		if (C)
			G.fields["rank"] = C.assignment
		else
			G.fields["rank"] = "Unassigned"
		G.fields["name"] = H.real_name
		G.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7)), 6))
		M.fields["name"] = G.fields["name"]
		M.fields["id"] = G.fields["id"]
		S.fields["name"] = G.fields["name"]
		S.fields["id"] = G.fields["id"]
		if (H.gender == "female")
			G.fields["sex"] = "Female"
		else
			G.fields["sex"] = "Male"
		G.fields["age"] = text("[]", H.age)
		G.fields["fingerprint"] = text("[]", md5(H.dna.uni_identity))
		G.fields["p_stat"] = "Active"
		G.fields["m_stat"] = "Stable"
		M.fields["b_type"] = text("[]", H.b_type)
		M.fields["mi_dis"] = "None"
		M.fields["mi_dis_d"] = "No minor disabilities have been declared."
		M.fields["ma_dis"] = "None"
		M.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
		M.fields["alg"] = "None"
		M.fields["alg_d"] = "No allergies have been detected in this patient."
		M.fields["cdi"] = "None"
		M.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
		M.fields["notes"] = "No notes."
		S.fields["criminal"] = "None"
		S.fields["mi_crim"] = "None"
		S.fields["mi_crim_d"] = "No minor crime convictions."
		S.fields["ma_crim"] = "None"
		S.fields["ma_crim_d"] = "No minor crime convictions."
		S.fields["notes"] = "No notes."
		for(var/obj/datacore/D in world)
			D.general += G
			D.medical += M
			D.security += S
//DNA!
		reg_dna[H.dna.unique_enzymes] = H.real_name
//Other Stuff
		if(ticker.mode.name == "sandbox")
			H.CanBuild()

*/
/*
	say(var/message)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

		if (!message)
			return

		log_say("[src.key] : [message]")

		if (src.muted)
			return

		. = src.say_dead(message)
*/