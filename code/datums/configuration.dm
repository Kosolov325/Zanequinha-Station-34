/datum/configuration
	var/server_name = null				// server name (for world name / status)
	var/server_suffix = 0				// generate numeric suffix based on server port

	var/medal_hub = null				// medal hub name
	var/medal_password = null			// medal hub password

	var/log_ooc = 1						// log OOC channek
	var/log_access = 1					// log login/logout
	var/log_say = 1						// log client say
	var/log_admin = 1					// log admin actions
	var/log_game = 1					// log game events
	var/log_vote = 1					// log voting
	var/log_whisper = 1					// log client whisper
	var/allow_vote_restart = 0 			// allow votes to restart
	var/allow_vote_mode = 0				// allow votes to change mode
	var/allow_admin_jump = 1			// allows admin jumping
	var/allow_admin_spawning = 1		// allows admin item spawning
	var/allow_admin_rev = 1				// allows admin revives
	var/vote_delay = 600				// minimum time between voting sessions (seconds, 10 minute default)
	var/vote_period = 60				// length of voting period (seconds, default 1 minute)
	var/vote_no_default = 0				// vote does not default to nochange/norestart (tbi)
	var/vote_no_dead = 0				// dead people can't vote (tbi)

	var/list/mode_names = list()
	var/list/modes = list()				// allowed modes
	var/list/votable_modes = list()		// votable modes
	var/list/probabilities = list()		// relative probability of each mode
	var/allow_ai = 1					// allow ai job
	var/hostedby = null
	var/respawn = 1

/datum/configuration/New()
	..()