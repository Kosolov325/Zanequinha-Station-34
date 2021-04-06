/*
	Gives clients a Mouse Position datum and updates it when the mouse moves.

	Credit to Kaiochao for this lib.
*/

client
	var
		tmp
			mouse_position/mouse_position
	/*
		When the mouse moves from one object to the next,
			with no mouse buttons pressed,
			only MouseEntered is called, not MouseMove.
		So, update the mouse position here.
	*/
	MouseEntered(object, location, control, params)
		..()
		/*
			Only do this if the mouse position is initialized.
			The screen-loc of the mouse is contained in the params argument,
				so parse the params to extract it and pass it to the mouse datum.
			This is repeated for MouseMove and MouseDrag.
		*/
		if(mouse_position)
			mouse_position.is_over_map = TRUE
			mouse_position.SetScreenLoc(params2list(params)["screen-loc"])

	MouseExited(object, location, control, params)
		..()
		if(mouse_position)
			mouse_position.is_over_map = FALSE

	/*
		When the mouse moves from one screen-pixel to the next,
			with no mouse buttons pressed,
			MouseMove is called.
		So, update the mouse position here.
	*/
	MouseMove(object, location, control, params)
		..()
		if(mouse_position)
			mouse_position.SetScreenLoc(params2list(params)["screen-loc"])

	/*
		When the mouse moves from one screen-pixel to the next,
			with any mouse button pressed,
			MouseDrag is called.
		So, update the mouse position here.
	*/
	MouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params)
		..()
		if(mouse_position)
			mouse_position.SetScreenLoc(params2list(params)["screen-loc"])

/*
	Defines the Mouse Position datum.

	The following procs are provided:
		* X()
		* Y()
			Coordinates of the mouse in the client's screen.

		* WorldX()
		* WorldY()
			Coordinates of the mouse in the world.

		* ScreenLoc()
			The screen_loc of the mouse.

		* IsOverMap()
			Is the mouse currently over the map?

	Conventions:
		* The coordinates and ScreenLoc() are "last-known" values obtained
		 when the mouse was last on the map.
		* (1, 1) is the bottom-left.
		* Coordinates are in pixels.
		* X increases from west to east.
		* Y increases from south to north.

	The position of the mouse is provided by the client mouse proc
	 overrides in ClientMousePosition.dm.

	Since the client mouse procs can be called at any time,
	 parsing of the screen-loc string happens only when necessary.
*/
mouse_position
	var
		tmp
			// Client whose mouse is being tracked.
			client/client

			// Last-known screen_loc of the mouse.
			screen_loc

			// Is the mouse currently over the map?
			is_over_map = FALSE


			// Don't touch these vars below!

			// Whether to parse screen_loc to get up-to-date coordinates.
			_parse = FALSE

			// Last-known coordinates of the mouse in the screen.
			// Updated when necessary.
			_x
			_y

		global
			// See the definition below about this.
			mouse_position/catcher/MouseCatcher = new

			/*
				This regex expects a screen-loc string, which is of the form

					"[tile_x]:[step_x],[tile_y]:[step_y]"

				given by the "params" argument of the mouse events.
			*/
			regex/MouseRegex = regex("(\\d+):(\\d+),(\\d+):(\\d+)")

	/*
		The mouse position must be initialized with a client,
		because the world-position of the mouse requires
		knowledge of the client's position in the world.
	*/
	New(client/client)
		src.client = client
	proc
		/*
			Returns the screen_loc of the mouse.
		*/
		ScreenLoc()
			return screen_loc

		/*
			Returns whether the mouse is currently over the map.
		*/
		IsOverMap()
			return is_over_map

		/*
			Returns the x-coordinate of the mouse in the screen.
		*/
		X()
			return _x

		/*
			Returns the y-coordinate of the mouse in the screen.
		*/
		Y()
			return _y

		/*
			Returns the x-coordinate of the mouse in the world.
		*/
		WorldX()
			return X() + client.bound_x - 1

		/*
			Returns the y-coordinate of the mouse in the world.
		*/
		WorldY()
			return Y() + client.bound_y - 1

		/*
			Sets the screen_loc of the mouse,
				which is used to get the mouse's position in the screen.
		*/
		SetScreenLoc(screen_loc)
			if(src.screen_loc != screen_loc)
				src.screen_loc = screen_loc
				_parse = TRUE
				Moved()

		/*
			Parses the screen_loc of the mouse into screen pixel coordinates.

			This only happens as often as it needs to, which is important
			because SetScreenLoc() can be called arbitrarily often by the
			client mouse procs.
		*/
		ParseScreenLoc()
			if(MouseRegex.Find(screen_loc))
				var list/data = MouseRegex.group
				_x = text2num(data[2]) + (text2num(data[1]) - 1) * 32
				_y = text2num(data[4]) + (text2num(data[3]) - 1) * 32
				_parse = FALSE

		/*
			Called when the mouse moves.
		*/
		Moved()
			ParseScreenLoc()
	/*
		The mouse catcher is required so that mouse movements are detected
			on pixels where there are no atoms drawn, such as in opacity
			and past the edge of the world, where the map's background color is shown.

		This still only fills the HUD space, though, so the mouse won't be tracked
			outside of that space.
	*/
	catcher
		parent_type = /obj
		icon = null
		screen_loc = "SOUTHWEST to NORTHEAST"
		mouse_opacity = 2
		name = ""
		plane = -100
		layer = BACKGROUND_LAYER
