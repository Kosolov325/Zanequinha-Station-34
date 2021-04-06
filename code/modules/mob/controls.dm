/mob/verb/dropitem()
	set hidden = 1
	set name = "dropitem"
	drop_item()

/mob/verb/swaphand()
	set hidden = 1
	set name = "swaphand"
	if(istype(src,/mob/living/carbon))
		src:swap_hand()