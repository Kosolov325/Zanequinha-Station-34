datum
	mood
		normal
			desc = "ok mula"
			moodAdditive = 10

			meetConditions()
				if(owner.health >= owner.maxhealth/2)
					return TRUE
				else
					return FALSE

