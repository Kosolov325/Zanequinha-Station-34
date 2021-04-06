#define SOLID 1
#define LIQUID 2
#define GAS 3

//drinks boi

datum
	reagent
		faygo
			name = "Faygo"
			//DEPRECATED id = "slurpjuice"
			description = "A refreshing beverage."
			reagent_state = LIQUID
			var/F = 0
			var/ag = 0
			on_mob_life(var/mob/M)
				if(prob(30) && M:alternian_blood_type)
					if(M:alternian_blood_type != "Purple")
						M:TakeBruteDamage(1)
						M:stuttering += min(4,M:stuttering)
						M:confused += min(3,M:confused)
						if(prob(5))
							if(prob(50))
								M:gib()
						if(prob(5)) M:emote(pick("shiver","blink_r"))
				else
					M.oxyloss = max(0,min(M.oxyloss-10,0))
					M.toxloss = max(0,min(M.toxloss-10,0))
					M.fireloss = max(0,min(M.fireloss-10,0))
					M.bruteloss = max(0,min(M.bruteloss-10,0))
					M.specialloss = max(0,min(M.specialloss-10,0))
				..()