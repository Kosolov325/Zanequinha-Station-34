/proc/log_admin(text)
	admin_log.Add(text)
	if (config.log_admin)
		diary << "ADMIN: [text]"
	discord_relay("**ADMIN: [text]**",AdminhelpWebhook)

/proc/log_game(text)
	if (config.log_game)
		diary << "GAME: [text]"
	discord_relay("**GAME: [text]**",AdminhelpWebhook)

/proc/log_vote(text)
	if (config.log_vote)
		diary << "VOTE: [text]"
	discord_relay("**VOTE: [text]**",AdminhelpWebhook)

/proc/log_access(text)
	if (config.log_access)
		diary << "ACCESS: [text]"
	discord_relay("**ACCESS: [text]**",AdminhelpWebhook)

/proc/log_say(text)
	if (config.log_say)
		diary << "SAY: [text]"
	discord_relay("**SAY: [text]**",AdminhelpWebhook)

/proc/log_ooc(text)
	if (config.log_ooc)
		diary << "OOC: [text]"
	discord_relay("**OOC: [text]**",AdminhelpWebhook)

/proc/log_whisper(text)
	if (config.log_whisper)
		diary << "WHISPER: [text]"
	discord_relay("**WHISPER: [text]**",AdminhelpWebhook)