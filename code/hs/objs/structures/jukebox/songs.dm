datum
	song
		var
			name = "Thit"
			file = "music/karako.ogg"
			volume = 100
			playing = FALSE


		proc/Play()
			if(playing == FALSE)
				playing = TRUE
				playsound(src, file, volume, 0, 30, 0)

		proc/stopSound()
			playing = FALSE