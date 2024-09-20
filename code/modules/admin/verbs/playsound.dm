/client/proc/play_sound(S as sound)
	set category = "Server.Global Messages"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUNDS))
		return

	var/freq = 1
	var/vol = input(usr, "What volume would you like the sound to play at?",, 100) as null|num
	if(!vol)
		return
	vol = clamp(vol, 1, 100)

	var/sound/admin_sound = new()
	admin_sound.file = S
	admin_sound.priority = 250
	admin_sound.channel = CHANNEL_ADMIN
	admin_sound.frequency = freq
	admin_sound.wait = 1
	admin_sound.repeat = 0
	admin_sound.status = SOUND_STREAM
	admin_sound.volume = vol

	var/res = tgui_alert(usr, "Show the title of this song to the players?",, list("Yes","No", "Cancel"))
	switch(res)
		if("Yes")
			to_chat(world, span_boldannounce("An admin played: [S]"))
		if("Cancel")
			return

	//log_admin("[key_name(src)] played sound [S]") // Yogs comment-out
	//message_admins("[key_name_admin(src)] played sound [S]") // Yogs comment-out
	var/count = 0 //yogs

	for(var/mob/M in GLOB.player_list)
		if(M.client.prefs.toggles & SOUND_MIDI)
			admin_sound.volume = vol * M.client.admin_music_volume
			SEND_SOUND(M, admin_sound)
			admin_sound.volume = vol
			count++ //Yogs
	//yogs start -- informs admins of how much of the server actually heard their sound
	count = round(count / GLOB.player_list.len * 100,0.5)
	log_admin("[key_name(src)] played sound [S] to [count]% of the server.")
	message_admins("[key_name_admin(src)] played sound [S] to [count]% of the server.")
	//yogs end

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Global Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/play_local_sound(S as sound)
	set category = "Server.Global Messages"
	set name = "Play Local Sound"
	if(!check_rights(R_SOUNDS))
		return

	log_admin("[key_name(src)] played a local sound [S]")
	message_admins("[key_name_admin(src)] played a local sound [S]")
	playsound(get_turf(src.mob), S, 50, 0, 0)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Local Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/play_web_sound()
	set category = "Server.Global Messages"
	set name = "Play Internet Sound"
	if(!check_rights(R_SOUNDS))
		return

	var/web_sound_url
	var/stop_web_sounds = FALSE

	var/web_sound_input = input("Enter content URL (supported sites only, leave blank to stop playing)", "Play Internet Sound via youtube-dl") as text|null
	
	if(istext(web_sound_input))
		var/list/data = list()
		data["url"] = web_sound_input
		data["downloadMode"] = "audio"

		var/datum/http_request/request = new()
		request.prepare(RUSTG_HTTP_METHOD_POST, "https://api.cobalt.tools/", json_encode(data), list("Content-Type" = "application/json", "Accept" = "application/json"))
		request.execute_blocking()
		UNTIL(request.is_complete() || !usr)
		if (!usr)
			return

		var/datum/http_response/response = request.into_response()
		if(response.errored)
			to_chat(src, span_danger("Response Error: [response.error]"))
			return
		var/list/body = json_decode(response.body)
		if(body["status"] == "error")
			to_chat(src, span_danger("Errored"))
			return
		debug_variables(body)
		if(body["url"])
			web_sound_url = body["url"]
			to_chat(src, "Played [web_sound_input] successfully.")
	else
		stop_web_sounds = TRUE
	
	if(web_sound_url || stop_web_sounds)
		for(var/m in GLOB.player_list)
			var/mob/M = m
			var/client/C = M.client
			if(C.prefs.toggles & SOUND_MIDI)
				if(!stop_web_sounds)
					C.tgui_panel?.play_music(web_sound_url, list())
				else
					C.tgui_panel?.stop_music()

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Play Internet Sound")

/client/proc/set_round_end_sound(S as sound)
	set category = "Server.Global Messages"
	set name = "Set Round End Sound"
	if(!check_rights(R_SOUNDS))
		return

	//Yogs start -- Adds confirm for whenever an admin has already set the roundend sound.
	var/static/lastadmin
	var/static/lastsound

	if(lastadmin && src.ckey != lastadmin)
		if(alert("Warning: Another Admin, [lastadmin], already set the roundendsound to [lastsound]. Overwrite?",,"Yes","Cancel") != "Yes")
			return
	SSticker.SetRoundEndSound(S)
	lastadmin = src.ckey
	lastsound = "[S]"
	//Yogs end

	log_admin("[key_name(src)] set the round end sound to [S]")
	message_admins("[key_name_admin(src)] set the round end sound to [S]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set Round End Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/stop_sounds()
	set category = "Server.Global Messages"
	set name = "Stop All Playing Sounds"
	if(!src.holder)
		return

	log_admin("[key_name(src)] stopped all currently playing sounds.")
	message_admins("[key_name_admin(src)] stopped all currently playing sounds.")
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			SEND_SOUND(M, sound(null))
			var/client/C = M.client
			C?.tgui_panel?.stop_music()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stop All Playing Sounds") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
