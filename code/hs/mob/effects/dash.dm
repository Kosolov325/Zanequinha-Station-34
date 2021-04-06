obj/d1
	New()
		special_processing += src
		..()

	special_process()
		src.alpha -= 5
mob
	proc
		Dash_Effect(location)
			var/obj/d1 = new(/**/)
			d1.name = "[src] Dashed"
			d1.overlays = src.overlays
			d1.underlays = src.underlays
			d1.icon = src.icon
			d1.icon_state = src.icon_state
			d1.dir = src.dir
			d1.loc = location
			d1.alpha=100
			spawn(7) del(d1)