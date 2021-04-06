#define SOLID 1
#define LIQUID 2
#define GAS 3

//The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
//so that it can continue working when the reagent is deleted while the proc is still active.

datum
	reagent
		var/name = "Reagent"
		var/description = ""
		var/datum/reagents/holder = null
		var/reagent_state = SOLID
		var/data = null
		var/volume = 0

		proc
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume) //By default we have a chance to transfer some
				var/datum/reagent/self = src
				src = null										  //of the reagent to the mob on TOUCHING it.
				if(method == TOUCH)

					var/chance = 1
					for(var/obj/item/clothing/C in M.get_equipped_items())
						if(C.permeability_coefficient < chance) chance = C.permeability_coefficient
					chance = chance * 100

					if(prob(chance))
						if(M.reagents)
							M.reagents.add_reagent(self.type,self.volume/2)
				return

			reaction_obj(var/obj/O, var/volume) //By default we transfer a small part of the reagent to the object
				src = null						//if it can hold reagents. nope!
				//if(O.reagents)
				//	O.reagents.add_reagent(//DEPRECATED id,volume/3)
				return

			reaction_turf(var/turf/T, var/volume)
				src = null
				return

			on_mob_life(var/mob/M)
				holder.remove_reagent(src.type, 0.4) //By default it slowly disappears.
				return

		milk
			name = "Milk"
			//DEPRECATED id = "milk"
			description = "An opaque white LIQUID produced by the mammary glands of mammals."
			reagent_state = LIQUID

		beer
			name = "Beer"
			//DEPRECATED id = "beer"
			description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!data) data = 1
				data++
				M.make_dizzy(3)
				M:jitteriness = max(M:jitteriness-3,0)
				if(data >= 25)
					if (!M:stuttering) M:stuttering = 1
					M:stuttering += 3
				if(data >= 40 && prob(33))
					if (!M:confused) M:confused = 1
					M:confused += 2
				..()

		water
			name = "Water"
			//DEPRECATED id = "water"
			description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
			reagent_state = LIQUID

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 3)
					T:water_height += volume
					water_changed += T //eh
				for(var/i in 1 to round(volume*5))
					var/obj/Particle/Water/A = new(T)
					A.x_pos = 16
					A.y_pos = 16
					A.x_spd = (rand(-30,30)/10)
					A.y_spd = (rand(-30,30)/10)

				var/hotspot = (locate(/obj/hotspot) in T)
				if(hotspot)
					var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
					lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
					lowertemp.react()
					T.assume_air(lowertemp)
					del(hotspot)
				return
			reaction_obj(var/obj/O, var/volume)
				src = null
				var/turf/T = get_turf(O)
				var/hotspot = (locate(/obj/hotspot) in T)
				if(hotspot)
					var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
					lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
					lowertemp.react()
					T.assume_air(lowertemp)
					del(hotspot)
				return

		lube
			name = "Space Lube"
			//DEPRECATED id = "lube"
			description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
			reagent_state = LIQUID

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(T:wet >= 2) return
				T:wet = 2
				spawn(800)
					T:wet = 0
					if(T:wet_overlay)
						T:overlays -= T:wet_overlay
						T:wet_overlay = null

				return

		bilk
			name = "Bilk"
			//DEPRECATED id = "bilk"
			description = "This appears to be beer mixed with milk. Disgusting."
			reagent_state = LIQUID

		anti_toxin
			name = "Anti-Toxin (Dylovene)"
			//DEPRECATED id = "anti_toxin"
			description = "Dylovene is a broad-spectrum antitoxin."
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:drowsyness = max(M:drowsyness-2, 0)
				if(holder.has_reagent(/datum/reagent/toxin))
					holder.remove_reagent(/datum/reagent/toxin, 2)
				if(holder.has_reagent(/datum/reagent/stoxin))
					holder.remove_reagent(/datum/reagent/stoxin, 2)
				if(holder.has_reagent(/datum/reagent/plasma))
					holder.remove_reagent(/datum/reagent/plasma, 1)
				if(holder.has_reagent(/datum/reagent/acid))
					holder.remove_reagent(/datum/reagent/acid, 1)
				M:toxloss = max(M:toxloss-2,0)
				..()
				return

		toxin
			name = "Toxin"
			//DEPRECATED id = "toxin"
			description = "A Toxic chemical."
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:toxloss += 1.5
				..()
				return

		cyan//DEPRECATED ide
			name = "Cyan//DEPRECATED ide"
			//DEPRECATED id = "cyan//DEPRECATED ide"
			description = "A highly toxic chemical."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:toxloss += 3
				M:oxyloss += 3
				..()
				return

		stoxin
			name = "Sleep Toxin"
			//DEPRECATED id = "stoxin"
			description = "An effective hypnotic used to treat insomnia."
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(!data) data = 1
				switch(data)
					if(1 to 15)
						M.eye_blurry = max(M.eye_blurry, 10)
					if(15 to 25)
						M:drowsyness  = max(M:drowsyness, 20)
					if(25 to INFINITY)
						M:paralysis = max(M:paralysis, 20)
						M:drowsyness  = max(M:drowsyness, 30)
				data++
				..()
				return

		inaprovaline
			name = "Inaprovaline"
			//DEPRECATED id = "inaprovaline"
			description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M.losebreath >= 10)
					M.losebreath = max(10, M.losebreath-5)
				holder.remove_reagent(src.type, 0.2)
				return

		space_drugs
			name = "Space drugs"
			//DEPRECATED id = "space_drugs"
			description = "An illegal chemical compound used as drug."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				if(M.canmove) step(M, pick(cardinal))
				if(prob(7)) M:emote(pick("twitch","drool","moan","giggle"))
				holder.remove_reagent(src.type, 0.2)
				return

		silicate
			name = "Silicate"
			//DEPRECATED id = "silicate"
			description = "A compound that can be used to reinforce glass."
			reagent_state = LIQUID
			reaction_obj(var/obj/O, var/volume)
				src = null
				if(istype(O,/obj/window))
					O:health = O:health * 2
					var/icon/I = icon(O.icon,O.icon_state,O.dir)
					I.SetIntensity(1.15,1.50,1.75)
					O.icon = I
				return

		oxygen
			name = "Oxygen"
			//DEPRECATED id = "oxygen"
			description = "A colorless, odorless gas."
			reagent_state = GAS

		nitrogen
			name = "Nitrogen"
			//DEPRECATED id = "nitrogen"
			description = "A colorless, odorless, tasteless gas."
			reagent_state = GAS

		hydrogen
			name = "Hydrogen"
			//DEPRECATED id = "hydrogen"
			description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
			reagent_state = GAS

		potassium
			name = "Potassium"
			//DEPRECATED id = "potassium"
			description = "A soft, low-melting SOLID that can easily be cut with a knife. Reacts violently with water."
			reagent_state = SOLID

		mercury
			name = "Mercury"
			//DEPRECATED id = "mercury"
			description = "A chemical element."
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M.canmove) step(M, pick(cardinal))
				if(prob(5)) M:emote(pick("twitch","drool","moan"))
				..()
				return

		sulfur
			name = "Sulfur"
			//DEPRECATED id = "sulfur"
			description = "A chemical element."
			reagent_state = SOLID

		carbon
			name = "Carbon"
			//DEPRECATED id = "carbon"
			description = "A chemical element."
			reagent_state = SOLID

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(!istype(T, /turf/space))
					new /obj/decal/cleanable/dirt(T)

		chlorine
			name = "Chlorine"
			//DEPRECATED id = "chlorine"
			description = "A chemical element."
			reagent_state = GAS
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:bruteloss++
				..()
				return

		fluorine
			name = "Fluorine"
			//DEPRECATED id = "fluorine"
			description = "A highly-reactive chemical element."
			reagent_state = GAS
			on_mob_life(var/mob.M)
				if(!M) M = holder.my_atom
				M:toxloss++
				..()
				return

		phosphorus
			name = "Phosphorus"
			//DEPRECATED id = "phosphorus"
			description = "A chemical element."
			reagent_state = SOLID

		lithium
			name = "Lithium"
			//DEPRECATED id = "lithium"
			description = "A chemical element."
			reagent_state = SOLID

			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M.canmove) step(M, pick(cardinal))
				if(prob(5)) M:emote(pick("twitch","drool","moan"))
				..()
				return

		sugar
			name = "Sugar"
			//DEPRECATED id = "sugar"
			description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
			reagent_state = SOLID

		acid
			name = "Sulphuric acid"
			//DEPRECATED id = "ac//DEPRECATED id"
			description = "A strong mineral acid with the molecular formula H2SO4."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:toxloss++
				M:fireloss++
				..()
				return
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if(method == TOUCH)
					if(istype(M, /mob/living/carbon/human))
						if(M:wear_mask)
							del (M:wear_mask)
							M << "\red Your mask melts away but protects you from the ac//DEPRECATED id!"
							return
						if(M:head)
							del (M:head)
							M << "\red Your helmet melts into uselessness but protects you from the ac//DEPRECATED id!"
							return

					if(prob(75))
						var/datum/organ/external/affecting = M:organs["head"]
						affecting.take_damage(25, 0)
						M:UpdateDamage()
						M:UpdateDamageIcon()
						M:emote("scream")
						M << "\red Your face has become disfigured!"
						M.real_name = "Unknown"
					else
						M:bruteloss += 15
				else
					M:bruteloss += 15

			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/item) && prob(40))
					var/obj/decal/cleanable/molten_item/I = new/obj/decal/cleanable/molten_item(O.loc)
					I.desc = "Looks like this was \an [O] some time ago."
					for(var/mob/M in viewers(5, O))
						M << "\red \the [O] melts."
					del(O)

		pacid
			name = "Polytrinic acid"
			//DEPRECATED id = "pac//DEPRECATED id"
			description = "Polytrinic ac//DEPRECATED id is a an extremely corrosive chemical substance."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:toxloss++
				M:fireloss++
				..()
				return
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if(method == TOUCH)
					if(istype(M, /mob/living/carbon/human))
						if(M:wear_mask)
							del (M:wear_mask)
							M << "\red Your mask melts away!"
							return
						if(M:head)
							del (M:head)
							M << "\red Your helmet melts into uselessness!"
							return
						var/datum/organ/external/affecting = M:organs["head"]
						affecting.take_damage(75, 0)
						M:UpdateDamage()
						M:UpdateDamageIcon()
						M:emote("scream")
						M << "\red Your face has become disfigured!"
						M.real_name = "Unknown"
					else
						M:bruteloss += 15
				else
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:organs["head"]
						affecting.take_damage(75, 0)
						M:UpdateDamage()
						M:UpdateDamageIcon()
						M:emote("scream")
						M << "\red Your face has become disfigured!"
						M.real_name = "Unknown"
					else
						M:bruteloss += 15

			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/item))
					var/obj/decal/cleanable/molten_item/I = new/obj/decal/cleanable/molten_item(O.loc)
					I.desc = "Looks like this was \an [O] some time ago."
					for(var/mob/M in viewers(5, O))
						M << "\red \the [O] melts."
					del(O)

		radium
			name = "Radium"
			//DEPRECATED id = "radium"
			description = "Radium is an alkaline earth metal. It is extremely radioactive."
			reagent_state = SOLID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M.radiation += 3
				..()
				return


			reaction_turf(var/turf/T, var/volume)
				src = null
				if(!istype(T, /turf/space))
					new /obj/decal/cleanable/greenglow(T)


		ryetalyn
			name = "Ryetalyn"
			//DEPRECATED id = "ryetalyn"
			description = "Ryetalyn can cure all genetic abnomalities."
			reagent_state = SOLID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M.mutations = 0
				M.disabilities = 0
				M.sdisabilities = 0
				..()
				return

		mutagen
			name = "Unstable mutagen"
			//DEPRECATED id = "mutagen"
			description = "Might cause unpredictable mutations. Keep away from children."
			reagent_state = LIQUID
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if ( (method==TOUCH && prob(33)) || method==INGEST)
					randmuti(M)
					if(prob(98))
						randmutb(M)
					else
						randmutg(M)
					domutcheck(M, null, 1)
					updateappearance(M,M.dna.uni_identity)
				return
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M.radiation += 3
				..()
				return

		iron
			name = "Iron"
			//DEPRECATED id = "iron"
			description = "Pure iron is a metal."
			reagent_state = SOLID

		aluminium
			name = "Aluminium"
			//DEPRECATED id = "aluminium"
			description = "A silvery white and ductile member of the boron group of chemical elements."
			reagent_state = SOLID

		silicon
			name = "Silicon"
			//DEPRECATED id = "silicon"
			description = "A tetravalent metallo//DEPRECATED id, silicon is less reactive than its chemical analog carbon."
			reagent_state = SOLID

		fuel
			name = "Welding fuel"
			//DEPRECATED id = "fuel"
			description = "Required for welders. Flamable."
			reagent_state = LIQUID
			reaction_obj(var/obj/O, var/volume)
				src = null
				var/turf/the_turf = get_turf(O)
				var/datum/gas_mixture/napalm = new
				var/datum/gas/volatile_fuel/fuel = new
				fuel.moles = 15
				napalm.trace_gases += fuel
				the_turf.assume_air(napalm)
			reaction_turf(var/turf/T, var/volume)
				src = null
				var/datum/gas_mixture/napalm = new
				var/datum/gas/volatile_fuel/fuel = new
				fuel.moles = 15
				napalm.trace_gases += fuel
				T.assume_air(napalm)
				return

		coffee
			name = "Coffee"
			//DEPRECATED id = "coffee"
			description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				..()
				M.dizziness = max(0,M.dizziness-5)
				M:drowsyness = max(0,M:drowsyness-3)
				M:sleeping = 0
				M.bodytemperature = min(310, M.bodytemperature+5) //310 is the normal bodytemp. 310.055
				M.make_jittery(5)

		space_cleaner
			name = "Space cleaner"
			//DEPRECATED id = "cleaner"
			description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
			reagent_state = LIQUID
			reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/decal/cleanable))
					del(O)
				else
					O.clean_blood()
			reaction_turf(var/turf/T, var/volume)
				T.overlays = null
				T.clean_blood()
				for(var/obj/decal/cleanable/C in src)
					del(C)
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				M.clean_blood()
				if(istype(M, /mob/living/carbon))
					var/mob/living/carbon/C = M
					if(C.r_hand)
						C.r_hand.clean_blood()
					if(C.l_hand)
						C.l_hand.clean_blood()
					if(C.wear_mask)
						C.wear_mask.clean_blood()
					if(istype(M, /mob/living/carbon/human))
						if(C:w_uniform)
							C:w_uniform.clean_blood()
						if(C:wear_suit)
							C:wear_suit.clean_blood()
						if(C:shoes)
							C:shoes.clean_blood()
						if(C:gloves)
							C:gloves.clean_blood()
						if(C:head)
							C:head.clean_blood()


		space_cola
			name = "Cola"
			//DEPRECATED id = "cola"
			description = "A refreshing beverage."
			reagent_state = LIQUID
			var/F = 0
			var/ag = 0
			on_mob_life(var/mob/M)
				F = F + 1
				if(F > 1)
					F = 0
					ag = ag + 45
					var/obj/Particle/Spark/Alternate/da1 = new(locate(M.x,M.y,M.z))
					da1.owner = M
					da1.ang = 0 + ag
					var/obj/Particle/Spark/Alternate/da2 = new(locate(M.x,M.y,M.z))
					da2.owner = M
					da2.ang = 180 + ag

				M:shield = max(0,min(100,M:shield + 5))
				..()

		slurp_juice
			name = "Slurp Juice"
			//DEPRECATED id = "slurpjuice"
			description = "A refreshing beverage."
			reagent_state = LIQUID
			var/F = 0
			var/ag = 0
			on_mob_life(var/mob/M)
				M:shield = max(0,min(100,M:shield + 5))
				M.oxyloss = max(0,M.oxyloss-1)
				M.toxloss = max(0,M.toxloss-1)
				M.fireloss = max(0,M.fireloss-1)
				M.bruteloss = max(0,M.bruteloss-1)
				M.specialloss = max(0,M.specialloss-1)
				..()

		plasma
			name = "Plasma"
			//DEPRECATED id = "plasma"
			description = "Plasma in its LIQUID form."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(holder.has_reagent(/datum/reagent/inaprovaline))
					holder.remove_reagent(/datum/reagent/inaprovaline, 2)
				M:toxloss++
				..()
				return
			reaction_obj(var/obj/O, var/volume)
				src = null
				var/turf/the_turf = get_turf(O)
				var/datum/gas_mixture/napalm = new
				var/datum/gas/volatile_fuel/fuel = new
				fuel.moles = 5
				napalm.trace_gases += fuel
				the_turf.assume_air(napalm)
			reaction_turf(var/turf/T, var/volume)
				src = null
				var/datum/gas_mixture/napalm = new
				var/datum/gas/volatile_fuel/fuel = new
				fuel.moles = 5
				napalm.trace_gases += fuel
				T.assume_air(napalm)
				return

		leporazine
			name = "Leporazine"
			//DEPRECATED id = "leporazine"
			description = "Leporazine can be use to stabilize an indiv//DEPRECATED iduals body temperature."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < 310)
					M.bodytemperature = max(310, M.bodytemperature-10)
				else if(M.bodytemperature > 311)
					M.bodytemperature = min(310, M.bodytemperature+10)
				..()
				return

		cryptobiolin
			name = "Cryptobiolin"
			//DEPRECATED id = "cryptobiolin"
			description = "Cryptobiolin causes confusion and dizzyness."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M.make_dizzy(1)
				if(!M.confused) M.confused = 1
				M.confused = max(M.confused, 20)
				holder.remove_reagent(src.type, 0.2)
				return

		lexorin
			name = "Lexorin"
			//DEPRECATED id = "lexorin"
			description = "Lexorin temporarily stops respiration. Causes tissue damage."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(prob(33)) M.bruteloss++
				holder.remove_reagent(src.type, 0.3)
				return

		kelotane
			name = "Kelotane"
			//DEPRECATED id = "kelotane"
			description = "Kelotane is a drug used to treat burns."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:fireloss = max(M:fireloss-2,0)
				..()
				return

		dexalin
			name = "Dexalin"
			//DEPRECATED id = "dexalin"
			description = "Dexalin is used in the treatment of oxygen deprivation."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:oxyloss = max(M:oxyloss-2, 0)
				..()
				return

		dexalinp
			name = "Dexalin Plus"
			//DEPRECATED id = "dexalinp"
			description = "Dexalin Plus is used in the treatment of oxygen deprivation. Its highly effective."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:oxyloss = 0
				..()
				return

		tricordrazine
			name = "Tricordrazine"
			//DEPRECATED id = "tricordrazine"
			description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a w//DEPRECATED ide range of injuries."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M:oxyloss && prob(40)) M:oxyloss--
				if(M:bruteloss && prob(40)) M:bruteloss--
				if(M:fireloss && prob(40)) M:fireloss--
				if(M:toxloss && prob(40)) M:toxloss--
				..()
				return

		synaptizine
			name = "Synaptizine"
			//DEPRECATED id = "synaptizine"
			description = "Synaptizine is used to treat neuroleptic shock. Can be used to help remove disabling symptoms such as paralysis."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:drowsyness = max(M:drowsyness-5, 0)
				if(M:paralysis) M:paralysis--
				if(M:stunned) M:stunned--
				if(M:weakened) M:weakened--
				..()
				return

		impedrezene
			name = "Impedrezene"
			//DEPRECATED id = "impedrezene"
			description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:jitteriness = max(M:jitteriness-5,0)
				if(prob(80)) M:brainloss++
				if(prob(50)) M:drowsyness = max(M:drowsyness, 3)
				if(prob(10)) M:emote("drool")
				..()
				return

		hyronalin
			name = "Hyronalin"
			//DEPRECATED id = "hyronalin"
			description = "Hyronalin is a medicinal drug used to counter the effects of radiation poisoning."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M:radiation && prob(80)) M:radiation--
				..()
				return

		alkysine
			name = "Alkysine"
			//DEPRECATED id = "alkysine"
			description = "Alkysine is a drug used to lessen the damage to neurological tissue after a catastrophic injury. Can heal brain tissue."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:brainloss = max(M:brainloss-3 , 0)
				..()
				return

		arithrazine
			name = "Arithrazine"
			//DEPRECATED id = "arithrazine"
			description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				M:radiation = max(M:radiation-3,0)
				if(M:toxloss && prob(50)) M:toxloss--
				if(prob(15)) M:bruteloss++
				..()
				return

		bicaridine
			name = "Bicar//DEPRECATED idine"
			//DEPRECATED id = "bicar//DEPRECATED idine"
			description = "Bicar//DEPRECATED idine is an analgesic medication and can be used to treat blunt trauma."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M:bruteloss && prob(40)) M:bruteloss--
				..()
				return

		hyperzine
			name = "Hyperzine"
			//DEPRECATED id = "hyperzine"
			description = "Hyperzine is a highly effective, long lasting, muscle stimulant."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(prob(5)) M:emote(pick("twitch","blink_r","shiver"))
				holder.remove_reagent(src.type, 0.2)
				return

		cryoxadone
			name = "Cryoxadone"
			//DEPRECATED id = "cryoxadone"
			description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < 170)
					if(M:oxyloss) M:oxyloss = max(0, M:oxyloss-3)
					if(M:bruteloss) M:bruteloss = max(0, M:bruteloss-3)
					if(M:fireloss) M:fireloss = max(0, M:fireloss-3)
					if(M:toxloss) M:toxloss = max(0, M:toxloss-3)

				return

		spaceacillin
			name = "Spaceacillin"
			//DEPRECATED id = "spaceacillin"
			description = "An all-purpose antiviral agent."
			reagent_state = LIQUID

			on_mob_life(var/mob/M)
				if(!M) M = holder.my_atom
				if((M.virus) && (prob(8)))
					if(M.virus.spread == "Airborne")
						M.virus.spread = "Remissive"
					M.virus.stage--
					if(M.virus.stage <= 0)
						M.resistances += M.virus.type
						M.virus = null
				holder.remove_reagent(src.type, 0.2)
				return

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

		nanites
			name = "Nanomachines"
			//DEPRECATED id = "nanites"
			description = "Microscopic construction robots."
			reagent_state = LIQUID
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if( (prob(10) && method==TOUCH) || method==INGEST)
					if(!M.virus)
						M.virus = new /datum/disease/robotic_transformation
						M.virus.affected_mob = M

//foam precursor

		fluorosurfactant
			name = "Fluorosurfactant"
			//DEPRECATED id = "fluorosurfactant"
			description = "A perfluoronated sulfonic ac//DEPRECATED id that forms a foam when mixed with water."
			reagent_state = LIQUID


// metal foaming agent
// this is lithium hydr//DEPRECATED ide. Add other recipies (e.g. LiH + H2O -> LiOH + H2) eventually

		foaming_agent
			name = "Foaming agent"
			//DEPRECATED id = "foaming_agent"
			description = "A agent that yields metallic foam when mixed with light metal and a strong ac//DEPRECATED id."
			reagent_state = SOLID

		nicotine
			name = "Nicotine"
			//DEPRECATED id = "nicotine"
			description = "A highly addictive stimulant extracted from the tobacco plant."
			reagent_state = LIQUID

		ethanol
			name = "Ethanol"
			//DEPRECATED id = "ethanol"
			description = "A well-known alcohol with a variety of applications."
			reagent_state = LIQUID
			on_mob_life(var/mob/M)
				if(!data) data = 1
				data++
				M.make_dizzy(5)
				M:jitteriness = max(M:jitteriness-5,0)
				if(data >= 25)
					if (!M:stuttering) M:stuttering = 1
					M:stuttering += 4
				if(data >= 40 && prob(33))
					if (!M:confused) M:confused = 1
					M:confused += 3
				..()

		ammonia
			name = "Ammonia"
			//DEPRECATED id = "ammonia"
			description = "A caustic substance commonly used in fertilizer or household cleaners."
			reagent_state = GAS

		diethylamine
			name = "Diethylamine"
			//DEPRECATED id = "diethylamine"
			description = "A secondary amine, mildly corrosive."
			reagent_state = LIQUID