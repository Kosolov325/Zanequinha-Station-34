/mob/living/carbon/human
	var/list/overlayList = list()

	proc/addOverlay(var/image/ov)
		src.overlayList[ov] += ov

	proc/clearOverlay(var/image/ov)
		src.overlayList[ov] -= ov