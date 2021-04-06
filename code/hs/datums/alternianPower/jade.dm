datum
	alternians
		jade
			var/storedBlood = 0
			var/killedFaggots = 0
			verb
				CheckBlood()
					set name = "Check Stored Blood"
					set category = "Alternian"

					usr << "\blue The number of stored blood is [storedBlood]"