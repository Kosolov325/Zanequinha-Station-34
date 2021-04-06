#define MAX_MOOD 10
#define MIN_MOOD -10

/mob/living/carbon/human
	proc/handleMood()
		spawn
			mood_handler.processMoodValues()
		spawn(4)
		return

datum
	mood_handler
		var/mob/living/carbon/human/owner

		New(mob/living/carbon/human/_owner)
			owner = _owner

		proc
			currentMoodDescs()
				var/text = ""
				for(var/datum/mood/m in owner.moods)
					if(m.meetConditions())
						text += m.desc
					else
						owner.moods -= m
				return text

			clearMoods()
				for(var/datum/mood/m in owner.moods)
					owner.moods -= m

			removeMood(datum/mood/m)
				owner.moods -= m

			processMoodValues()
				for(var/datum/mood/m in owner.moods)
					owner.mood += m.getMoodAdditive()
					if(owner.mood <= MIN_MOOD)
						owner.mood = MIN_MOOD
					if(owner.mood >= MAX_MOOD)
						owner.mood = MAX_MOOD

			clampOwnerMood()
				owner.mood = max(min(owner.mood, MAX_MOOD),MIN_MOOD)

datum
	mood
		var/moodAdditive = 0
		var/mob/owner
		var/_icon
		var/_icon_state = ""
		var/val

		var/desc = "ok mula"

		New(mob/_owner)
			owner = _owner

		proc/getMoodAdditive()
			var/num = max(min(moodAdditive, MAX_MOOD),MIN_MOOD)
			return num

		proc/adjustMood(nVal)
			moodAdditive = max(nVal,MIN_MOOD)
			owner:mood_handler?.clampOwnerMood()

		proc/addMoodToOwner()
			owner:mood = max(moodAdditive,MIN_MOOD)

		proc/changeIcon(newIcon)
			_icon = newIcon

		proc/changeIconState(newIconState)
			_icon_state = newIconState || "default"


		proc/meetConditions()
			return TRUE