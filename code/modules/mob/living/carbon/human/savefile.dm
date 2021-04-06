#define SAVEFILE_VERSION_MIN	4
#define SAVEFILE_VERSION_MAX	4

datum/preferences/proc/savefile_path(mob/user)
	return "data/player_saves/[copytext(user.ckey, 1, 2)]/[user.ckey]/preferences.sav"

datum/preferences/proc/savefile_save(mob/user)

	var/savefile/F = new /savefile(src.savefile_path(user))

	F["version"] << SAVEFILE_VERSION_MAX

	F["real_name"] << src.real_name
	F["gender"] << src.gender
	F["age"] << src.age
	F["hair_red"] << src.r_hair
	F["hair_green"] << src.g_hair
	F["hair_blue"] << src.b_hair
	F["facial_red"] << src.r_facial
	F["facial_green"] << src.g_facial
	F["facial_blue"] << src.b_facial
	F["skin_tone"] << src.s_tone
	F["hair_style_name"] << src.h_style
	F["facial_style_name"] << src.f_style
	F["eyes_red"] << src.r_eyes
	F["eyes_green"] << src.g_eyes
	F["eyes_blue"] << src.b_eyes
	F["blood_type"] << src.b_type
	F["be_syndicate"] << src.be_syndicate
	F["tts_extra_pitch"] << src.tts_extra_pitch

	//var/species = "human"
	//var/species_color = null

	F["species"] << src.species
	F["species_color"] << src.species_color

	F["tail"] << src.tail
	F["tail_color"] << src.tail_color

	F["horn_icon"] << src.horn_icon
	F["alternian_blood_type"] << src.alternian_blood_type
	F["sign"] << src.sign

	return 1

// loads the savefile corresponding to the mob's ckey
// if silent=true, report incompatible savefiles
// returns 1 if loaded (or file was incompatible)
// returns 0 if savefile did not exist

datum/preferences/proc/savefile_load(mob/user, var/silent = 1)
	if (IsGuestKey(user.key))
		return 0

	var/path = savefile_path(user)

	if (!fexists(path))
		return 0

	var/savefile/F = new /savefile(path)

	var/version = null
	F["version"] >> version

	if (isnull(version) || version < SAVEFILE_VERSION_MIN || version > SAVEFILE_VERSION_MAX)
		fdel(path)

		alert(user, "Your savefile was incompatible with this version and was deleted. Please create your character again.")

		return 0

	F["real_name"] >> src.real_name
	F["gender"] >> src.gender
	F["age"] >> src.age
	F["hair_red"] >> src.r_hair
	F["hair_green"] >> src.g_hair
	F["hair_blue"] >> src.b_hair
	F["facial_red"] >> src.r_facial
	F["facial_green"] >> src.g_facial
	F["facial_blue"] >> src.b_facial
	F["skin_tone"] >> src.s_tone
	F["hair_style_name"] >> src.h_style
	F["facial_style_name"] >> src.f_style
	F["eyes_red"] >> src.r_eyes
	F["eyes_green"] >> src.g_eyes
	F["eyes_blue"] >> src.b_eyes
	F["blood_type"] >> src.b_type
	F["be_syndicate"] >> src.be_syndicate
	F["species"] >> src.species
	F["species_color"] >> src.species_color
	F["tail"] >> src.tail
	F["tail_color"] >> src.tail_color
	F["tts_extra_pitch"] >> src.tts_extra_pitch

	F["horn_icon"] >> src.horn_icon
	F["alternian_blood_type"] >> src.alternian_blood_type
	F["sign"] >> src.sign
	return 1

#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN
