/*

A clock is useful for when you want events to fire periodically.

An example is a global update loop that drives physics and AI.
You can even pause it the clock to halt all physics and AI behavior.

e.g.
	```
	var clock/update_loop = new

	object
		New()
			EVENT_ADD(update_loop.OnTick, src, .proc/Update)

		proc
			Update()
	```

If you rely on world.time, you should use clock.time instead.
This allows for the pausing of stuff like cooldowns, which work by
comparing the current time with a stored end time.


clock
	Variables
		tick_lag
			Time between ticks, in deciseconds.
			Automatically maximizes to world.tick_lag.

	Read-only variables
		time
			Time passed in deciseconds, BYOND's standard unit of time
			used by sleep, spawn, world.time, etc.
			Reflects milliseconds.

		ticks
			The number of ticks passed.

		milliseconds
			Time passed in milliseconds.

		seconds
			Time passed in seconds.
			Reflects milliseconds.

		delta_time
			Time between ticks, in seconds.
			Reflects tick_lag.

		paused
			Ticks don't occur while the clock is paused.

	Methods
		Pause()
			Pauses ticking. Timing values stay where they are.

		Resume()
			Resumes ticking. Timing values continue from
			where they left off.

		Reset()
			Resets all timing values.

		Stop()
			Stops the clock.

		Start()
			Resets, then starts the clock.
			Starts the clock.
			This is called automatically when the clock is created.

*/

clock
	var
		time = 0
		tick_lag = 0

		ticks = 0
		milliseconds = 0
		seconds = 0
		delta_time = 0

		paused = FALSE
		running = FALSE
		start_id

		tmp/event/OnTick // (clock/Clock)

	New(TickLag, StartPaused = FALSE)
		tick_lag = TickLag
		paused = StartPaused
		Start()

	proc
		Pause()
			paused = TRUE

		Resume()
			paused = FALSE

		Reset()
			ticks = 0
			milliseconds = 0
			seconds = 0
			time = 0

		Stop()
			running = FALSE

		Start()
			set waitfor = FALSE, background = TRUE

			Reset()

			running = TRUE

			var _start_id = ++start_id
			while(running && start_id == _start_id)
				tick_lag = max(tick_lag, world.tick_lag)
				if(!paused) OnTick && OnTick.Fire(src)
				sleep tick_lag
				if(!paused)
					ticks++
					delta_time = tick_lag / 10
					milliseconds += tick_lag * 1e2
					seconds = milliseconds * 1e-3
					time = milliseconds * 1e-2
