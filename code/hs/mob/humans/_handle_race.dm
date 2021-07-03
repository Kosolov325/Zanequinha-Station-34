var/list/retard = list("Roberto_candi","Nopm")

/mob/living/carbon/human
	var/gooze = 0
	var/sans
	proc/handle_race()
		spawn
			if(src.health > 0)
				// Mood nigga
				handleMood()
				if(health >= maxhealth/2)
					stat = 0
				var/_prob = rand(1,10)
				if(key in retard)
					src.brainloss += min(max(round(world.time/10)))
				if(species == "alternian")
					switch(alternian_blood_type)
						if("Purple")
							if(_prob/2 == 1)
								if(prob(20))
									for(var/mob/M in view(src))
										if(M.client)
											M << "\blue [src] honks!"
											M << sound('sound/items/bikehorn.ogg')
						if("Fuchsia")
							gooze *= rand(1,world.time/10)
			//else if(health <= 0)
			//	contents = null
		spawn(8)
		return