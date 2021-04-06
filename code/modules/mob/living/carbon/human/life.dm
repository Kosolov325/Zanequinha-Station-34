/mob/living/carbon/human
	var
		oxygen_alert = 0
		toxins_alert = 0
		fire_alert = 0

		temperature_alert = 0


/mob/living/carbon/human/Life()
	set invisibility = 0
	set background = 1

	if (src.transforming)
		return

	var/datum/gas_mixture/environment = loc.return_air()

	if (src.stat == 2) //still breathing
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	src.blinded = null

	//Disease Check
	handle_virus_updates()

	//Handle temperature/pressure differences between body and environment
	handle_environment(environment)

	//Mutations and radiation
	handle_mutations_and_radiation()

	//Chemicals in the body
	handle_chemicals_in_body()


	//stuff in the stomach
	handle_stomach()

	//Disabilities
	handle_disabilities()

	// Update clothing
	update_clothing()

	//Being buckled to a chair or bed
	check_if_buckled()

	// Yup.
	update_canmove()

	//race or alternians :3 LOOOOOOOl
	handle_race()


	clamp_values()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()


/mob/living/carbon/human
	proc
		clamp_values()

			stunned = max(min(stunned, 20),0)
			paralysis = max(min(paralysis, 20), 0)
			weakened = max(min(weakened, 20), 0)
			sleeping = max(min(sleeping, 20), 0)
			bruteloss = max(bruteloss, 0)
			toxloss = max(toxloss, 0)
			oxyloss = max(oxyloss, 0)
			fireloss = max(fireloss, 0)


		handle_disabilities()

			if (src.disabilities & 2)
				if ((prob(1) && src.paralysis < 1 && src.r_epil < 1))
					src << "\red You have a seizure!"
					for(var/mob/O in viewers(src, null))
						if(O == src)
							continue
						O.show_message(text("\red <B>[src] starts having a seizure!"), 1)
					src.paralysis = max(10, src.paralysis)
					src.make_jittery(1000)
			if (src.disabilities & 4)
				if ((prob(5) && src.paralysis <= 1 && src.r_ch_cou < 1))
					src.drop_item()
					spawn( 0 )
						emote("cough")
						return
			if (src.disabilities & 8)
				if ((prob(10) && src.paralysis <= 1 && src.r_Tourette < 1))
					src.stunned = max(10, src.stunned)
					spawn( 0 )
						switch(rand(1, 3))
							if(1)
								emote("twitch")
							if(2 to 3)
								say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")
						var/old_x = src.pixel_x
						var/old_y = src.pixel_y
						src.pixel_x += rand(-2,2)
						src.pixel_y += rand(-1,1)
						sleep(2)
						src.pixel_x = old_x
						src.pixel_y = old_y
						return
			if (src.disabilities & 16)
				if (prob(10))
					src.stuttering = max(10, src.stuttering)
			if (src.brainloss >= 60 && src.stat != 2)
				if (prob(7))
					switch(pick(1,2,3))
						if(1)
							say(pick("I... I just really like your penis, okay?",
							";g",
							"this game sucks",
							"krifra eat poo?",
							"without oxigen blob don't evoluate?",
							"CAPTAINS A COMDOM",
							"wjy is niger cemsored?",
							";ADMIN REVIVE ME CLANCE KILLED ME NOT VALID!!!",
							";CLANCE KILLING ME!!",
							"[pick("", "that faggot traitor")] [pick("joerge", "george", "gorge", "gdoruge")] [pick("mellens", "melons", "mwrlins")] is grifing me HAL;P!!!",
							"can u give me [pick("telikesis","halk","eppilapse")]?",
							"THe saiyans screwed",
							"im trangsegeder!!!!",
							"I WANNA PET TEH MONKIES",
							"PLEASE TURN ME INTO A SENTIENT LOAF AS A JOKE IT WOULD BE FUNNY!",
							"By the way CHANCE KILLED ME. I didn't just walk onto it accidentally. Chance PULLED me onto it. (And he couldn't of known I was an antagonist so it is not valid)"
							"stop grifing me!!!!",
							"SOTP IT#"))
						if(2)
							emote("drool")
						if(3)
							T_Pose()

		handle_mutations_and_radiation()

			if(src.fireloss)
				if(src.mutations & 2 || prob(50))
					switch(src.fireloss)
						if(1 to 50)
							src.fireloss--
						if(51 to 100)
							src.fireloss -= 5

			if (src.mutations & 8 && src.health <= 25)
				src.mutations &= ~8
				src << "\red You suddenly feel very weak."
				src.weakened = 3
				emote("collapse")

			if (src.radiation)
				if (src.radiation > 100)
					src.radiation = 100
					src.weakened = 10
					src << "\red You feel weak."
					emote("collapse")

				if (src.radiation < 0)
					src.radiation = 0

				switch(src.radiation)
					if(1 to 49)
						src.radiation--
						if(prob(25))
							src.toxloss++
							src.updatehealth()

					if(50 to 74)
						src.radiation -= 2
						src.toxloss++
						if(prob(5))
							src.radiation -= 5
							src.weakened = 3
							src << "\red You feel weak."
							emote("collapse")
						src.updatehealth()

					if(75 to 100)
						src.radiation -= 3
						src.toxloss += 3
						if(prob(1))
							src << "\red You mutate!"
							randmutb(src)
							domutcheck(src,null)
							emote("gasp")
						src.updatehealth()


		breathe()

			if(src.reagents.has_reagent(/datum/reagent/lexorin)) return
			if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) return

			var/datum/gas_mixture/environment = loc.return_air()
			var/datum/air_group/breath
			// HACK NEED CHANGING LATER
			if(src.health < 0)
				src.losebreath++

			if(losebreath>0) //Suffocating so do not take a breath
				air-=tick_lag_original*4
				if(istype(loc, /obj/))
					var/obj/location_as_object = loc
					location_as_object.handle_internal_lifeform(src, 0)
			else
				//First, check for air from internal atmosphere (using an air tank and mask generally)
				breath = get_breath_from_internal(BREATH_VOLUME)

				//No breath from internal atmosphere so get breath from location
				if(!breath)
					if(istype(loc, /obj/))
						var/obj/location_as_object = loc
						breath = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME)
					else if(istype(loc, /turf/))
						var/breath_moles = 0
						/*if(environment.return_pressure() > ONE_ATMOSPHERE)
							// Loads of air around (pressure effects will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
							breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
						else*/
							// Not enough air around, take a percentage of what's there to model this properly
						breath_moles = environment.total_moles()*BREATH_PERCENTAGE

						breath = loc.remove_air(breath_moles)

				else //Still give containing object the chance to interact
					if(istype(loc, /obj/))
						var/obj/location_as_object = loc
						location_as_object.handle_internal_lifeform(src, 0)

			handle_breath(breath)

			if(breath)
				loc.assume_air(breath)


		get_breath_from_internal(volume_needed)
			if(internal)
				if (!contents.Find(src.internal))
					internal = null
				if (!wear_mask || !(wear_mask.flags & MASKINTERNALS) )
					internal = null
				if(internal)
					if (src.internals)
						src.internals.icon_state = "internal1"
					return internal.remove_air_volume(volume_needed)
				else
					if(src.internals)
						src.internals.icon_state = "internal0"
			else
				if(src.internals)
					src.internals.icon_state = "internal0"
			return null

		update_canmove()
			if(paralysis || stunned || weakened || buckled || changeling_fakedeath) canmove = 0
			else canmove = 1

		handle_breath(datum/gas_mixture/breath)
			if(src.nodamage)
				return

			if(!breath || (breath.total_moles() == 0))
				air-=tick_lag_original

				oxygen_alert = max(oxygen_alert, 1)

				return 0

			var/safe_oxygen_min = 20 // Minimum safe partial pressure of O2, in kPa
			//var/safe_oxygen_max = 140 // Maximum safe partial pressure of O2, in kPa (Not used for now)
			var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
			var/safe_toxins_max = 0.5
			var/SA_para_min = 1
			var/SA_sleep_min = 5
			var/oxygen_used = 0
			var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

			//Partial pressure of the O2 in our breath
			var/O2_pp = (breath.oxygen/breath.total_moles())*breath_pressure
			// Same, but for the toxins
			var/Toxins_pp = (breath.toxins/breath.total_moles())*breath_pressure
			// And CO2, lets say a PP of more than 10 will be bad (It's a little less really, but eh, being passed out all round aint no fun)
			var/CO2_pp = (breath.carbon_dioxide/breath.total_moles())*breath_pressure

			if(O2_pp < safe_oxygen_min) 			// Too little oxygen
				if(O2_pp > 0)
					var/ratio = safe_oxygen_min/O2_pp
					air-=tick_lag_original*7
					oxygen_used = breath.oxygen*ratio/6
				else
					air-=tick_lag_original*7
				oxygen_alert = max(oxygen_alert, 1)
			/*else if (O2_pp > safe_oxygen_max) 		// Too much oxygen (commented this out for now, I'll deal with pressure damage elsewhere I suppose)
				spawn(0) emote("cough")
				var/ratio = O2_pp/safe_oxygen_max
				oxyloss += 5*ratio
				oxygen_used = breath.oxygen*ratio/6
				oxygen_alert = max(oxygen_alert, 1)*/
			else 									// We're in safe limits
				air += tick_lag_original*12
				oxygen_used = breath.oxygen/6
				oxygen_alert = 0

			breath.oxygen -= oxygen_used
			breath.carbon_dioxide += oxygen_used

			if(CO2_pp > safe_co2_max)
				if(!co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
					co2overloadtime = world.time
				else if(world.time - co2overloadtime > 120)
					src.paralysis = max(src.paralysis, 3)
					air -= tick_lag_original*7
					if(world.time - co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
						air -= tick_lag_original*7
				if(prob(1)) // Lets give them some chance to know somethings not right though I guess.
					spawn(0) emote("cough")

			else
				co2overloadtime = 0

			if(Toxins_pp > safe_toxins_max) // Too much toxins
				var/ratio = breath.toxins/safe_toxins_max
				air -= tick_lag_original*7
				toxloss += min(ratio, 10)	//Limit amount of damage toxin exposure can do per second
				toxins_alert = max(toxins_alert, 1)
			else
				toxins_alert = 0

			if(breath.trace_gases.len)	// If there's some other shit in the air lets deal with it here.
				for(var/datum/gas/sleeping_agent/SA in breath.trace_gases)
					var/SA_pp = (SA.moles/breath.total_moles())*breath_pressure
					if(SA_pp > SA_para_min) // Enough to make us paralysed for a bit
						src.paralysis = max(src.paralysis, 3) // 3 gives them one second to wake up and run away a bit!
						if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
							src.sleeping = max(src.sleeping, 2)
					else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
						if(prob(1))
							spawn(0) emote(pick("giggle", "laugh"))


			if(breath.temperature > (T0C+66) && !(src.mutations & 2)) // Hot air hurts :(
				if(prob(1))
					src << "\red You feel a searing heat in your lungs!"
				fire_alert = 1
			else
				fire_alert = 0


			//Temporary fixes to the alerts.

			return 1

		handle_environment(datum/gas_mixture/environment)
			if(!environment)
				return
			var/environment_heat_capacity = environment.heat_capacity()
			var/loc_temp = T0C
			if(istype(loc, /turf/space))
				environment_heat_capacity = loc:heat_capacity
				loc_temp = 2.7
			else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
				loc_temp = loc:air_contents.temperature
			else
				loc_temp = environment.temperature

			var/thermal_protection = get_thermal_protection()
			if(stat != 2 && abs(src.bodytemperature - 310.15) < 50)
				src.bodytemperature += adjust_body_temperature(src.bodytemperature, 310.15, thermal_protection)
			if(loc_temp < 310.15) // a cold place -> add in cold protection
				src.bodytemperature += adjust_body_temperature(src.bodytemperature, loc_temp, 1/thermal_protection)
			else // a hot place -> add in heat protection
				thermal_protection += add_fire_protection(loc_temp)
				src.bodytemperature += adjust_body_temperature(src.bodytemperature, loc_temp, 1/thermal_protection)


			// lets give them a fair bit of leeway so they don't just start dying
			//as that may be realistic but it's no fun
			if((src.bodytemperature > (T0C + 50)) || (src.bodytemperature < (T0C + 10)) && (!istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))) // Last bit is just disgusting, i know
				if(environment.temperature > (T0C + 50) || (environment.temperature < (T0C + 10)))
					var/transfer_coefficient

					transfer_coefficient = 1
					if(head && (head.body_parts_covered & HEAD) && (environment.temperature < head.protective_temperature))
						transfer_coefficient *= head.heat_transfer_coefficient
					if(wear_mask && (wear_mask.body_parts_covered & HEAD) && (environment.temperature < wear_mask.protective_temperature))
						transfer_coefficient *= wear_mask.heat_transfer_coefficient
					if(wear_suit && (wear_suit.body_parts_covered & HEAD) && (environment.temperature < wear_suit.protective_temperature))
						transfer_coefficient *= wear_suit.heat_transfer_coefficient

					handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*transfer_coefficient)

					transfer_coefficient = 1
					if(wear_suit && (wear_suit.body_parts_covered & UPPER_TORSO) && (environment.temperature < wear_suit.protective_temperature))
						transfer_coefficient *= wear_suit.heat_transfer_coefficient
					if(w_uniform && (w_uniform.body_parts_covered & UPPER_TORSO) && (environment.temperature < w_uniform.protective_temperature))
						transfer_coefficient *= w_uniform.heat_transfer_coefficient

					handle_temperature_damage(UPPER_TORSO, environment.temperature, environment_heat_capacity*transfer_coefficient)

					transfer_coefficient = 1
					if(wear_suit && (wear_suit.body_parts_covered & LOWER_TORSO) && (environment.temperature < wear_suit.protective_temperature))
						transfer_coefficient *= wear_suit.heat_transfer_coefficient
					if(w_uniform && (w_uniform.body_parts_covered & LOWER_TORSO) && (environment.temperature < w_uniform.protective_temperature))
						transfer_coefficient *= w_uniform.heat_transfer_coefficient

					handle_temperature_damage(LOWER_TORSO, environment.temperature, environment_heat_capacity*transfer_coefficient)

					transfer_coefficient = 1
					if(wear_suit && (wear_suit.body_parts_covered & LEGS) && (environment.temperature < wear_suit.protective_temperature))
						transfer_coefficient *= wear_suit.heat_transfer_coefficient
					if(w_uniform && (w_uniform.body_parts_covered & LEGS) && (environment.temperature < w_uniform.protective_temperature))
						transfer_coefficient *= w_uniform.heat_transfer_coefficient

					handle_temperature_damage(LEGS, environment.temperature, environment_heat_capacity*transfer_coefficient)

					transfer_coefficient = 1
					if(wear_suit && (wear_suit.body_parts_covered & ARMS) && (environment.temperature < wear_suit.protective_temperature))
						transfer_coefficient *= wear_suit.heat_transfer_coefficient
					if(w_uniform && (w_uniform.body_parts_covered & ARMS) && (environment.temperature < w_uniform.protective_temperature))
						transfer_coefficient *= w_uniform.heat_transfer_coefficient

					handle_temperature_damage(ARMS, environment.temperature, environment_heat_capacity*transfer_coefficient)

					transfer_coefficient = 1
					if(wear_suit && (wear_suit.body_parts_covered & HANDS) && (environment.temperature < wear_suit.protective_temperature))
						transfer_coefficient *= wear_suit.heat_transfer_coefficient
					if(gloves && (gloves.body_parts_covered & HANDS) && (environment.temperature < gloves.protective_temperature))
						transfer_coefficient *= gloves.heat_transfer_coefficient

					handle_temperature_damage(HANDS, environment.temperature, environment_heat_capacity*transfer_coefficient)

					transfer_coefficient = 1
					if(wear_suit && (wear_suit.body_parts_covered & FEET) && (environment.temperature < wear_suit.protective_temperature))
						transfer_coefficient *= wear_suit.heat_transfer_coefficient
					if(shoes && (shoes.body_parts_covered & FEET) && (environment.temperature < shoes.protective_temperature))
						transfer_coefficient *= shoes.heat_transfer_coefficient

					handle_temperature_damage(FEET, environment.temperature, environment_heat_capacity*transfer_coefficient)

			/*if(stat==2) //Why only change body temp when they're dead? That makes no sense!!!!!!
				bodytemperature += 0.8*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)
			*/

			//Account for massive pressure differences
			return //TODO: DEFERRED

		adjust_body_temperature(current, loc_temp, boost)
			var/temperature = current
			var/difference = abs(current-loc_temp)	//get difference
			var/increments// = difference/10			//find how many increments apart they are
			if(difference > 50)
				increments = difference/5
			else
				increments = difference/10
			var/change = increments*boost	// Get the amount to change by (x per increment)
			var/temp_change
			if(current < loc_temp)
				temperature = min(loc_temp, temperature+change)
			else if(current > loc_temp)
				temperature = max(loc_temp, temperature-change)
			temp_change = (temperature - current)
			return temp_change

		get_thermal_protection()
			var/thermal_protection = 1.0
			//Handle normal clothing
			if(head && (head.body_parts_covered & HEAD))
				thermal_protection += 0.5
			if(wear_suit && (wear_suit.body_parts_covered & UPPER_TORSO))
				thermal_protection += 0.5
			if(w_uniform && (w_uniform.body_parts_covered & UPPER_TORSO))
				thermal_protection += 0.5
			if(wear_suit && (wear_suit.body_parts_covered & LEGS))
				thermal_protection += 0.2
			if(wear_suit && (wear_suit.body_parts_covered & ARMS))
				thermal_protection += 0.2
			if(wear_suit && (wear_suit.body_parts_covered & HANDS))
				thermal_protection += 0.2
			if(shoes && (shoes.body_parts_covered & FEET))
				thermal_protection += 0.2
			if(wear_suit && (wear_suit.flags & SUITSPACE))
				thermal_protection += 3
			if(head && (head.flags & HEADSPACE))
				thermal_protection += 1
			if(src.mutations & 2)
				thermal_protection += 5

			return thermal_protection

		add_fire_protection(var/temp)
			var/fire_prot = 0
			if(head)
				if(head.protective_temperature > temp)
					fire_prot += (head.protective_temperature/10)
			if(wear_mask)
				if(wear_mask.protective_temperature > temp)
					fire_prot += (wear_mask.protective_temperature/10)
			if(glasses)
				if(glasses.protective_temperature > temp)
					fire_prot += (glasses.protective_temperature/10)
			if(ears)
				if(ears.protective_temperature > temp)
					fire_prot += (ears.protective_temperature/10)
			if(wear_suit)
				if(wear_suit.protective_temperature > temp)
					fire_prot += (wear_suit.protective_temperature/10)
			if(w_uniform)
				if(w_uniform.protective_temperature > temp)
					fire_prot += (w_uniform.protective_temperature/10)
			if(gloves)
				if(gloves.protective_temperature > temp)
					fire_prot += (gloves.protective_temperature/10)
			if(shoes)
				if(shoes.protective_temperature > temp)
					fire_prot += (shoes.protective_temperature/10)

			return fire_prot

		handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
			if(src.nodamage)
				return
			var/discomfort = min(abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)

			switch(body_part)
				if(HEAD)
					TakeDamage("head", 0, 2.5*discomfort)
				if(UPPER_TORSO)
					TakeDamage("chest", 0, 2.5*discomfort)
				if(LOWER_TORSO)
					TakeDamage("groin", 0, 2.0*discomfort)
				if(LEGS)
					TakeDamage("l_leg", 0, 0.6*discomfort)
					TakeDamage("r_leg", 0, 0.6*discomfort)
				if(ARMS)
					TakeDamage("l_arm", 0, 0.4*discomfort)
					TakeDamage("r_arm", 0, 0.4*discomfort)
				if(FEET)
					TakeDamage("l_foot", 0, 0.25*discomfort)
					TakeDamage("r_foot", 0, 0.25*discomfort)
				if(HANDS)
					TakeDamage("l_hand", 0, 0.25*discomfort)
					TakeDamage("r_hand", 0, 0.25*discomfort)

		handle_chemicals_in_body()

			if(reagents) reagents.metabolize(src)

			if(src.weight > 95 && !(src.mutations & 32))
				src << "\red You suddenly feel blubbery!"
				src.mutations |= 32
				update_body()
			if (src.weight < 95 && src.mutations & 32)
				src << "\blue You feel fit again!"
				src.mutations &= ~32
				update_body()
			if (src.nutrition > 0)
				src.nutrition -= tick_lag_original/10
				if(nutrition < 35)
					weight -= tick_lag_original/70
				if(nutrition > 100)
					weight += tick_lag_original/70
					if(nutrition > 150)
						nutrition = 150
			else
				bruteloss += tick_lag_original //Starving
			if(src.thirst > 0)
				src.thirst -= tick_lag_original/5
				if(thirst > 150)
					thirst = 150
			else
				bruteloss += tick_lag_original*3 //Dying of thirst
			if(weight < 30)
				bruteloss -= weight-30
			if (src.drowsyness)
				src.drowsyness--
				src.eye_blurry = max(2, src.eye_blurry)
				if (prob(5))
					src.sleeping = 1
					src.paralysis = 5

			confused = max(0, confused - 1)
			// decrement dizziness counter, clamped to 0
			if(resting)
				dizziness = max(0, dizziness - 5)
				jitteriness = max(0, jitteriness - 5)
			else
				dizziness = max(0, dizziness - 1)
				jitteriness = max(0, jitteriness - 1)

			src.updatehealth()

			return //TODO: DEFERRED
		handle_regular_hud_updates()

			if (src.stat == 2 || src.mutations & 4)
				src.see_in_dark = 8
				src.see_invisible = 2
			else if (istype(src.glasses, /obj/item/clothing/glasses/meson))

				src.see_in_dark = 3
				src.see_invisible = 0
			else if (istype(src.glasses, /obj/item/clothing/glasses/thermal))

				src.see_in_dark = 4
				src.see_invisible = 2
			else if (src.stat != 2)
				src.see_in_dark = 2
				src.see_invisible = 0

			if (src.sleep) src.sleep.icon_state = text("sleep[]", src.sleeping)


			if(src.pullin)	src.pullin.icon_state = "pull[src.pulling ? 1 : 0]"


			if (src.toxin)	src.toxin.icon_state = "tox[src.toxins_alert ? 1 : 0]"
			if (src.oxygen) src.oxygen.icon_state = "oxy[src.oxygen_alert ? 1 : 0]"
			if (src.fire) src.fire.icon_state = "fire[src.fire_alert ? 1 : 0]"
			//NOTE: the alerts dont reset when youre out of danger. dont blame me,
			//blame the person who coded them. Temporary fix added.

			switch(src.bodytemperature) //310.055 optimal body temp

				if(370 to INFINITY)
					src.bodytemp.icon_state = "temp4"
				if(350 to 370)
					src.bodytemp.icon_state = "temp3"
				if(335 to 350)
					src.bodytemp.icon_state = "temp2"
				if(320 to 335)
					src.bodytemp.icon_state = "temp1"
				if(300 to 320)
					src.bodytemp.icon_state = "temp0"
				if(295 to 300)
					src.bodytemp.icon_state = "temp-1"
				if(280 to 295)
					src.bodytemp.icon_state = "temp-2"
				if(260 to 280)
					src.bodytemp.icon_state = "temp-3"
				else
					src.bodytemp.icon_state = "temp-4"

			src.client.screen -= src.hud_used.blurry
			src.client.screen -= src.hud_used.druggy
			src.client.screen -= src.hud_used.vimpaired

			if ((src.blind && src.stat != 2))
				if ((src.blinded))
					src.blind.layer = 18
				else
					src.blind.layer = 0

					if (src.disabilities & 1 && !istype(src.glasses, /obj/item/clothing/glasses/regular) )
						src.client.screen += src.hud_used.vimpaired

					if (src.eye_blurry)
						src.client.screen += src.hud_used.blurry

					if (src.druggy)
						src.client.screen += src.hud_used.druggy

			if (src.stat != 2)
				if (src.machine)
					if (!( src.machine.check_eye(src) ))
						src.reset_view(null)
				else
					if(!client.adminobs)
						reset_view(null)

			return 1

		handle_random_events()
			if (prob(1) && prob(2))
				spawn(0)
					emote("sneeze")
					return

		handle_virus_updates()
			if(src.bodytemperature > 406)
				src.resistances += src.virus
				src.virus = null

			if(!src.virus)
				if(prob(40))
					for(var/mob/living/carbon/M in oviewers(4, src))
						if(M.virus && M.virus.spread == "Airborne")
							if(M.virus.affected_species.Find("Human"))
								if(src.resistances.Find(M.virus.type))
									continue
								var/datum/disease/D = new M.virus.type //Making sure strain_data is preserved
								D.strain_data = M.virus.strain_data
								src.contract_disease(D)
					for(var/obj/decal/cleanable/blood/B in view(4, src))
						if(B.virus && B.virus.spread == "Airborne")
							if(B.virus.affected_species.Find("Human"))
								if(src.resistances.Find(B.virus.type))
									continue
								var/datum/disease/D = new B.virus.type
								D.strain_data = B.virus.strain_data
								src.contract_disease(D)
			else
				src.virus.stage_act()

		check_if_buckled()
			if (src.buckled)
				src.lying = istype(src.buckled, /obj/stool/bed) || istype(src.buckled, /obj/machinery/conveyor)
				if(src.lying)
					src.drop_item()
				src.density = 1
			else
				src.density = !src.lying

		handle_stomach()
			spawn(0)
				for(var/mob/M in stomach_contents)
					if(M.loc != src)
						stomach_contents.Remove(M)
						continue
					if(istype(M, /mob/living/carbon) && src.stat != 2)
						if(M.stat == 2)
							M.death(1)
							stomach_contents.Remove(M)
							if(M.client)
								var/mob/dead/observer/newmob = new(M)
								M:client:mob = newmob
								M.mind.transfer_to(newmob)
								newmob.reset_view(null)
							del(M)
							continue
						if(air_master.current_cycle%3==1)
							if(!M.nodamage)
								M.bruteloss += 5
							src.nutrition += 10
/*
snippets

	if (src.mach)
		if (src.machine)
			src.mach.icon_state = "mach1"
		else
			src.mach.icon_state = null

	if (!src.m_flag)
		src.moved_recently = 0
	src.m_flag = null



		if ((istype(src.loc, /turf/space) && !( locate(/obj/movable, src.loc) )))
			var/layers = 20
			// ******* Check
			if (((istype(src.head, /obj/item/clothing/head) && src.head.flags & 4) || (istype(src.wear_mask, /obj/item/clothing/mask) && (!( src.wear_mask.flags & 4 ) && src.wear_mask.flags & 8))))
				layers -= 5
			if (istype(src.w_uniform, /obj/item/clothing/under))
				layers -= 5
			if ((istype(src.wear_suit, /obj/item/clothing/suit) && src.wear_suit.flags & 8))
				layers -= 10
			if (layers > oxcheck)
				oxcheck = layers


				if(src.bodytemperature < 282.591 && (!src.firemut))
					if(src.bodytemperature < 250)
						src.fireloss += 4
						src.updatehealth()
						if(src.paralysis <= 2)	src.paralysis += 2
					else if(prob(1) && !src.paralysis)
						if(src.paralysis <= 5)	src.paralysis += 5
						emote("collapse")
						src << "\red You collapse from the cold!"
				if(src.bodytemperature > 327.444  && (!src.firemut))
					if(src.bodytemperature > 345.444)
						if(!src.eye_blurry)	src << "\red The heat blurs your vision!"
						src.eye_blurry = max(4, src.eye_blurry)
						if(prob(3))	src.fireloss += rand(1,2)
					else if(prob(3) && !src.paralysis)
						src.paralysis += 2
						emote("collapse")
						src << "\red You collapse from heat exaustion!"
				plcheck = src.t_plasma
				oxcheck = src.t_oxygen
				G.turf_add(T, G.total_moles())
*/