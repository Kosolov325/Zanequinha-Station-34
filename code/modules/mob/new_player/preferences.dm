/proc/iscool(mob/M) //epic way to know if your a furry
	if(world.port in PORTS_NOT_ALLOWED)
		return 1
	else
		if(M.client)
			if(M.client.key in AdministrationTeam || M.client.key == world.host || M.client.key == "Roberto_candi")
				return 1
			else
				return 0
		else
			return 0

datum/preferences
	var/real_name
	var/gender = MALE
	var/age = 11
	var/b_type = "A+"

	var/be_syndicate

	var/species = "human"
	var/species_color = rgb(127,127,127)

	/*
	var/species = "human"
	var/species_icon = 'human.dmi'
	var/species_color = null
	var/animating = 0
	*/
	var/tail = "none"
	var/tail_color = rgb(127,127,127)

	var/h_style = "Short Hair"
	var/f_style = "Shaved"

	var/r_hair = 0.0
	var/g_hair = 0.0
	var/b_hair = 0.0

	var/tts_extra_pitch = 0
	var/r_facial = 0.0
	var/g_facial = 0.0
	var/b_facial = 0.0

	var/s_tone = 0.0
	var/r_eyes = 0.0
	var/g_eyes = 0.0
	var/b_eyes = 0.0

	var/horn_icon
	var/alternian_blood_type
	var/sign

	var/icon/preview_icon = null

	New()
		randomize_name()

		..()
	proc/Get_Species_Icon()
		switch(species)
			if("human")
				return 'icons/mob/human.dmi'
			if("vulpine")
				return 'icons/mob/vulpine.dmi'
			if("alternian")
				return 'icons/mob/human.dmi'
			if("shark")
				return 'icons/mob/shark.dmi'

	proc/randomize_name()
		if (gender == MALE)
			real_name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
		else
			real_name = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))

	proc/update_preview_icon()
		del(src.preview_icon)

		var/g = "m"
		if (src.gender == MALE)
			g = "m"
		else if (src.gender == FEMALE)
			g = "f"
		var/list/speciesorganGENDER = list("chest","groin") //will eb converted to "chest_m_s"
		var/list/speciesorganNORMAL = list("head", "arm_left", "arm_right", "hand_left", "hand_right", "leg_left", "leg_right", "foot_left", "foot_right")
		src.preview_icon = new /icon(Get_Species_Icon(), "blank")
		for(var/ee in speciesorganNORMAL)
			src.preview_icon.Blend(new /icon(Get_Species_Icon(), "[ee]_s"), ICON_OVERLAY)
		for(var/eee in speciesorganGENDER)
			src.preview_icon.Blend(new /icon(Get_Species_Icon(), "[eee]_[g]_s"), ICON_OVERLAY)

		// Skin tone
		if (src.species_color != null && species != "human" && species != "alternian")
			src.preview_icon += species_color
		if(tail != "none")
			var/icon/tail_c = new /icon('icons/mob/mob_acc.dmi', "icon_state" = "[tail]") //i hate maintaining furry code
			tail_c += tail_color
			src.preview_icon.Blend(tail_c, ICON_OVERLAY)
		var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "eyes_s")
		eyes_s.Blend(rgb(src.r_eyes, src.g_eyes, src.b_eyes), ICON_ADD)

		if(horn_icon != "Mutant")
			var enum = pick(1,2,3)
			var picked_horn = ""
			switch(alternian_blood_type)
				if("Rust")
					picked_horn = "rust_horns[enum]"
					sign = pick("Arga","Arcer","Argo")
				if("Bronze")
					picked_horn = "bronze_horns[enum]"
					sign = pick("Taura","Taurittanius","Taurga")
				if("Gold")
					picked_horn = "gold_horns[enum]"
					sign = pick("Gemnius","Gemsci","Gemza")
				if("Lime")
					picked_horn = "lime_horns[enum]"
					sign = pick("Canrus","Cansci","Canrist")
				if("Olive")
					picked_horn = "olive_horns[enum]"
					sign = pick("Lesces","Leiborn","Lerius")
				if("Jade")
					picked_horn = "jade_horns[enum]"
					sign = pick("Virrus","Virnius","Virpia")
				if("Teal")
					picked_horn = "teal_horns[enum]"
					sign = pick("Libun","Ligo","Limino")
				if("Cerulean")
					picked_horn = "cerulean_horns[enum]"
					sign = pick("Scorittarius","Scorun","Scorza")
				if("Indigo")
					picked_horn = "indigo_horns[enum]"
					sign = pick("Sagio","Sagimino","Sagicen")
				if("Purple")
					picked_horn = "purple_horns[enum]"
					sign = pick("Capriza","Capries","Capriborn")
				if("Violet")
					picked_horn = "violet_horns[enum]"
					sign = pick("Aquapio","Aquaries","Aquapia")
				if("Fuchsia")
					picked_horn = "fuchsia_horns[enum]" //Temp
					sign = pick("Pirius","Pittarius","Picen") //Pintius kkkk
			var/icon/horns = new /icon('icons/mob/alternian_horns.dmi', "icon_state" = "[picked_horn]") //i hate maintaining furry code
			src.horn_icon = picked_horn
			src.preview_icon.Blend(horns, ICON_OVERLAY)

		var/h_style_r = null
		switch(h_style)
			if("Short Hair")
				h_style_r = "hair_a"
			if("Long Hair")
				h_style_r = "hair_b"
			if("Cut Hair")
				h_style_r = "hair_c"
			if("Mohawk")
				h_style_r = "hair_d"
			if("Balding")
				h_style_r = "hair_e"
			if("")
				h_style_r = "hair_f"
			if("Bedhead")
				h_style_r = "hair_bedhead"
			if("Dreadlocks")
				h_style_r = "hair_dreads"
			if("Kleeia")
				h_style_r = "hair_kleeia"
			if("Long Alt")
				h_style_r = "hair_long_alt"
			if("Pigtails")
				h_style_r = "hair_pigtails2"
			else
				h_style_r = "bald"

		var/f_style_r = null
		switch(f_style)
			if ("Watson")
				f_style_r = "facial_watson"
			if ("Chaplin")
				f_style_r = "facial_chaplin"
			if ("Selleck")
				f_style_r = "facial_selleck"
			if ("Neckbeard")
				f_style_r = "facial_neckbeard"
			if ("Full Beard")
				f_style_r = "facial_fullbeard"
			if ("Long Beard")
				f_style_r = "facial_longbeard"
			if ("Van Dyke")
				f_style_r = "facial_vandyke"
			if ("Elvis")
				f_style_r = "facial_elvis"
			if ("Abe")
				f_style_r = "facial_abe"
			if ("Chinstrap")
				f_style_r = "facial_chin"
			if ("Hipster")
				f_style_r = "facial_hip"
			if ("Goatee")
				f_style_r = "facial_gt"
			if ("Hogan")
				f_style_r = "facial_hogan"
			else
				f_style_r = "bald"

		var/icon/hair_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[h_style_r]_s")
		hair_s.Blend(rgb(src.r_hair, src.g_hair, src.b_hair), ICON_ADD)

		var/icon/facial_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[f_style_r]_s")
		facial_s.Blend(rgb(src.r_facial, src.g_facial, src.b_facial), ICON_ADD)

		var/icon/mouth_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "mouth_[g]_s")

		eyes_s.Blend(hair_s, ICON_OVERLAY)
		eyes_s.Blend(mouth_s, ICON_OVERLAY)
		eyes_s.Blend(facial_s, ICON_OVERLAY)

		src.preview_icon.Blend(eyes_s, ICON_OVERLAY)

		del(mouth_s)
		del(facial_s)
		del(hair_s)
		del(eyes_s)

	proc/ShowChoices(mob/user)
		update_preview_icon()
		user << browse_rsc(preview_icon, "previewicon.png")

		var/dat = "<html><body>"
		dat += "<a href=\"byond://?src=\ref[user];preferences=1;real_name=input\"><b>Name : [src.real_name]</b></a> "
		dat += "(<a href=\"byond://?src=\ref[user];preferences=1;real_name=random\">Randomize</A>)<br><br>"
		dat += "<br>"

		dat += "<b>Gender:</b> <a href=\"byond://?src=\ref[user];preferences=1;gender=input\"><b>[src.gender == MALE ? "Male" : "Female"][species == "human" && gender == FEMALE ? " (catgirl ears enabled)" : ""]</b></a><br>" //this is what you get for PLAYING TG NOOB
		dat += "<b>Age:</b> <a href='byond://?src=\ref[user];preferences=1;age=input'>[src.age]</a>"

		dat += "<hr><table><tr><td><b>Body</b><br>"
		dat += "Blood Type: <a href='byond://?src=\ref[user];preferences=1;b_type=input'>[src.b_type]</a><br>"
		dat += "Voice Pitch: <a href='byond://?src=\ref[user];preferences=1;tts_pitch=input'>Change</a><br>"

		dat += "<b>Species:</b> <a href='byond://?src=\ref[user];preferences=1;species_change=input'>[species] (Change)</a><br>"
		dat += "<b>Species Color:</b> <a href='byond://?src=\ref[user];preferences=1;s_tone=input'>Change</a><br>"
		dat += "<b>Tail:</b> <a href='byond://?src=\ref[user];preferences=1;tail=input'>[tail] (Change)</a><br>"
		dat += "<b>Tail Color:</b> <a href='byond://?src=\ref[user];preferences=1;t_tone=input'>Change</a><br>"
		if(src.species == "alternian")
			dat += "<b>Blood Type:</b> <a href='byond://?src=\ref[user];preferences=1;alternian_blood_type=input'>[alternian_blood_type] (Change)</a><br>"

		dat += "</td><td><b>Preview</b><br><img src=previewicon.png height=64 width=64></td></tr></table>"

		dat += "<hr><b>Hair</b><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;hair=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(src.r_hair, 2)][num2hex(src.g_hair, 2)][num2hex(src.b_hair, 2)]\"><table bgcolor=\"#[num2hex(src.r_hair, 2)][num2hex(src.g_hair, 2)][num2hex(src.b_hair)]\"><tr><td>IM</td></tr></table></font>"
		dat += "Style: <a href='byond://?src=\ref[user];preferences=1;h_style=input'>[src.h_style]</a>"

		dat += "<hr><b>Facial</b><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;facial=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(src.r_facial, 2)][num2hex(src.g_facial, 2)][num2hex(src.b_facial, 2)]\"><table bgcolor=\"#[num2hex(src.r_facial, 2)][num2hex(src.g_facial, 2)][num2hex(src.b_facial)]\"><tr><td>GO</td></tr></table></font>"
		dat += "Style: <a href='byond://?src=\ref[user];preferences=1;f_style=input'>[src.f_style]</a>"

		dat += "<hr><b>Eyes</b><br>"
		dat += "<a href='byond://?src=\ref[user];preferences=1;eyes=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(src.r_eyes, 2)][num2hex(src.g_eyes, 2)][num2hex(src.b_eyes, 2)]\"><table bgcolor=\"#[num2hex(src.r_eyes, 2)][num2hex(src.g_eyes, 2)][num2hex(src.b_eyes)]\"><tr><td>KU</td></tr></table></font>"
		dat += "<hr>"

		if (!IsGuestKey(user.key))
			dat += "<a href='byond://?src=\ref[user];preferences=1;load=1'>Load Setup</a><br>"
			dat += "<a href='byond://?src=\ref[user];preferences=1;save=1'>Save Setup</a><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;reset_all=1'>Reset Setup</a><br>"
		dat += "</body></html>"

		user << browse(cssStyleSheetDab13 + dat, "window=preferences;size=300x640")
	proc/process_link(mob/user, list/link_tags)
		//BLOOD TYPE
		if (link_tags["alternian_blood_type"])
			if(iscool(user))
				alternian_blood_type = input(user, "Blood Type","Character Generation") in allBloodTypes
			else
				alternian_blood_type = input(user, "Blood Type","Character Generation") in normalBloodTypes //normalBloodTypes

		if (link_tags["tts_pitch"])
			tts_extra_pitch = input(user,"TTS voice pitch ( -50 to 50 )","Character Generation") as num
			tts_extra_pitch = tts_extra_pitch/10
			if(tts_extra_pitch > 0.5)
				tts_extra_pitch = 0.5
			if(tts_extra_pitch < -0.5)
				tts_extra_pitch = -0.5
		if (link_tags["species_change"])																	//Desgurpe furrys
			species = input(user, "Please select a species:", "Character Generation") in list("human",/*"vulpine","shark",*/"alternian")

		if (link_tags["real_name"])
			var/new_name

			switch(link_tags["real_name"])
				if("input")
					new_name = input(user, "Please select a name:", "Character Generation")  as text
					var/list/bad_characters = list("_", "'", "\"", "<", ">", ";", "[", "]", "{", "}", "|", "\\")
					for(var/c in bad_characters)
						new_name = dd_replacetext(new_name, c, "")
					if(!new_name || (new_name == "Unknown"))
						alert("Don't do this")
						return

				if("random")
					if (src.gender == MALE)
						new_name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
					else
						new_name = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
			if(new_name)
				if(length(new_name) >= 26)
					new_name = copytext(new_name, 1, 26)
				src.real_name = new_name

		if (link_tags["age"])
			var/new_age = input(user, "Please select type in age: 9-20", "Character Generation")  as num

			if(new_age)
				src.age = max(min(round(text2num(new_age)), 20), 9)

		if (link_tags["b_type"])
			var/new_b_type = input(user, "Please select a blood type:", "Character Generation")  as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )

			if (new_b_type)
				src.b_type = new_b_type

		if (link_tags["hair"])
			var/new_hair = input(user, "Please select hair color.", "Character Generation") as color
			if(new_hair)
				src.r_hair = hex2num(copytext(new_hair, 2, 4))
				src.g_hair = hex2num(copytext(new_hair, 4, 6))
				src.b_hair = hex2num(copytext(new_hair, 6, 8))
/*
		if (link_tags["r_hair"])
			var/new_component = input(user, "Please select red hair component: 1-255", "Character Generation")  as text

			if (new_component)
				src.r_hair = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["g_hair"])
			var/new_component = input(user, "Please select green hair component: 1-255", "Character Generation")  as text

			if (new_component)
				src.g_hair = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["b_hair"])
			var/new_component = input(user, "Please select blue hair component: 1-255", "Character Generation")  as text

			if (new_component)
				src.b_hair = max(min(round(text2num(new_component)), 255), 1)
*/

		if (link_tags["facial"])
			var/new_facial = input(user, "Please select facial hair color.", "Character Generation") as color
			if(new_facial)
				src.r_facial = hex2num(copytext(new_facial, 2, 4))
				src.g_facial = hex2num(copytext(new_facial, 4, 6))
				src.b_facial = hex2num(copytext(new_facial, 6, 8))
/*
		if (link_tags["r_facial"])
			var/new_component = input(user, "Please select red facial component: 1-255", "Character Generation")  as text

			if (new_component)
				src.r_facial = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["g_facial"])
			var/new_component = input(user, "Please select green facial component: 1-255", "Character Generation")  as text

			if (new_component)
				src.g_facial = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["b_facial"])
			var/new_component = input(user, "Please select blue facial component: 1-255", "Character Generation")  as text

			if (new_component)
				src.b_facial = max(min(round(text2num(new_component)), 255), 1)
*/
		if (link_tags["eyes"])
			var/new_eyes = input(user, "Please select eye color.", "Character Generation") as color
			if(new_eyes)
				src.r_eyes = hex2num(copytext(new_eyes, 2, 4))
				src.g_eyes = hex2num(copytext(new_eyes, 4, 6))
				src.b_eyes = hex2num(copytext(new_eyes, 6, 8))
/*
		if (link_tags["r_eyes"])
			var/new_component = input(user, "Please select red eyes component: 1-255", "Character Generation")  as text

			if (new_component)
				src.r_eyes = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["g_eyes"])
			var/new_component = input(user, "Please select green eyes component: 1-255", "Character Generation")  as text

			if (new_component)
				src.g_eyes = max(min(round(text2num(new_component)), 255), 1)

		if (link_tags["b_eyes"])
			var/new_component = input(user, "Please select blue eyes component: 1-255", "Character Generation")  as text

			if (new_component)
				src.b_eyes = max(min(round(text2num(new_component)), 255), 1)
*/
		//tail_color

		if (link_tags["s_tone"])
			var/new_species_color = input(user, "Please select species color", "Character Generation")  as color
			species_color = new_species_color

		if (link_tags["t_tone"])
			var/new_species_tail_color = input(user, "Please select tail color", "Character Generation")  as color
			tail_color = new_species_tail_color

		if (link_tags["tail"])
			var/new_species_tail = input(user, "Please select new tail", "Character Generation")  in list("none","vulptail1","vulptail2","vulptail3","vulptail4","vulptail5","vulptail6","vulptail7","ligger","shark")
			tail = new_species_tail


		if (link_tags["h_style"])
			var/new_style = input(user, "Please select hair style", "Character Generation")  as null|anything in list( "Cut Hair", "Short Hair", "Long Hair", "Mohawk", "Balding", "Fag", "Bedhead", "Dreadlocks", "Bald","Kleeia")

			if (new_style)
				src.h_style = new_style

		if (link_tags["f_style"])
			var/new_style = input(user, "Please select facial style", "Character Generation")  as null|anything in list("Watson", "Chaplin", "Selleck", "Full Beard", "Long Beard", "Neckbeard", "Van Dyke", "Elvis", "Abe", "Chinstrap", "Hipster", "Goatee", "Hogan", "Shaved")

			if (new_style)
				src.f_style = new_style

		if (link_tags["gender"])
			if (src.gender == MALE)
				src.gender = FEMALE
			else
				src.gender = MALE


		if (link_tags["b_syndicate"])
			src.be_syndicate = !( src.be_syndicate )

		if(!IsGuestKey(user.key))
			if(link_tags["save"])
				src.savefile_save(user)

			else if(link_tags["load"])
				if (!src.savefile_load(user, 0))
					alert(user, "You do not have a savefile.")

		if (link_tags["reset_all"])
			gender = MALE
			randomize_name()

			age = 30

			be_syndicate = 0
			r_hair = 0.0
			g_hair = 0.0
			b_hair = 0.0
			r_facial = 0.0
			g_facial = 0.0
			b_facial = 0.0
			h_style = "Short Hair"
			f_style = "Shaved"
			r_eyes = 0.0
			g_eyes = 0.0
			b_eyes = 0.0
			s_tone = 0.0
			b_type = "A+"


		src.ShowChoices(user)

	proc/copy_to(mob/living/carbon/human/character)
		//BLOOD TYPE TROLL OK
		if(alternian_blood_type == "Mutant")
			character.alternian_blood_type = "Mutant"
			character.horn_icon = "Mutant"
			character.sign = "Mutant"
		else
			character.alternian_blood_type = alternian_blood_type
			character.horn_icon = horn_icon
			character.sign = sign

		character.gender = gender

		if(tail == "")
			tail = "none"
		character.species = species

		character.species_color = species_color

		character.tail = tail
		character.tail_color = tail_color

		character.species_icon = Get_Species_Icon()
		character.real_name = real_name

		character.gender = gender

		character.age = age
		character.b_type = b_type

		character.r_eyes = r_eyes
		character.g_eyes = g_eyes
		character.b_eyes = b_eyes

		character.r_hair = r_hair
		character.g_hair = g_hair
		character.b_hair = b_hair

		character.r_facial = r_facial
		character.g_facial = g_facial
		character.b_facial = b_facial

		character.tts_extra_pitch = tts_extra_pitch
		character.s_tone = s_tone

		character.h_style = h_style
		character.f_style = f_style

		switch(h_style)
			if("Short Hair")
				character.hair_icon_state = "hair_a"
			if("Long Hair")
				character.hair_icon_state = "hair_b"
			if("Cut Hair")
				character.hair_icon_state = "hair_c"
			if("Mohawk")
				character.hair_icon_state = "hair_d"
			if("Balding")
				character.hair_icon_state = "hair_e"
			if("Fag")
				character.hair_icon_state = "hair_f"
			if("Bedhead")
				character.hair_icon_state = "hair_bedhead"
			if("Dreadlocks")
				character.hair_icon_state = "hair_dreads"
			if("Kleeia")
				character.hair_icon_state = "hair_kleeia"
			else
				character.hair_icon_state = "bald"

		switch(f_style)
			if ("Watson")
				character.face_icon_state = "facial_watson"
			if ("Chaplin")
				character.face_icon_state = "facial_chaplin"
			if ("Selleck")
				character.face_icon_state = "facial_selleck"
			if ("Neckbeard")
				character.face_icon_state = "facial_neckbeard"
			if ("Full Beard")
				character.face_icon_state = "facial_fullbeard"
			if ("Long Beard")
				character.face_icon_state = "facial_longbeard"
			if ("Van Dyke")
				character.face_icon_state = "facial_vandyke"
			if ("Elvis")
				character.face_icon_state = "facial_elvis"
			if ("Abe")
				character.face_icon_state = "facial_abe"
			if ("Chinstrap")
				character.face_icon_state = "facial_chin"
			if ("Hipster")
				character.face_icon_state = "facial_hip"
			if ("Goatee")
				character.face_icon_state = "facial_gt"
			if ("Hogan")
				character.face_icon_state = "facial_hogan"
			else
				character.face_icon_state = "bald"


		character.update_face()
		character.update_body()

/*

	if (!M.real_name || M.be_random_name)
		if (M.gender == "male")
			M.real_name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
		else
			M.real_name = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
	for(var/mob/living/carbon/human/H in world)
		if(cmptext(H.real_name,M.real_name))
			usr << "You are using a name that is very similar to a currently used name, please choose another one using Character Setup."
			return
	if(cmptext("Unknown",M.real_name))
		usr << "This name is reserved for use by the game, please choose another one using Character Setup."
		return

*/