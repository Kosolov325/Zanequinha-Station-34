/mob/living/carbon/enemy
	name = "Enemy"
	desc = "It hates you."
	Life() //haha whats its like to override a thing
		EnemyProcess()
		..()
	proc
		EnemyProcess()
			..()