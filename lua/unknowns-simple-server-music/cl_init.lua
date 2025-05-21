if ussm ~= nil then
	RunConsoleCommand( "stopsound" )
end

include( "shared.lua" )

local ussm_GetPlaybackRate = ussm.GetPlaybackRate
local ussm_GetStartTime = ussm.GetStartTime
local ussm_GetFilePath = ussm.GetFilePath
local ussm_GetRepeat = ussm.GetRepeat
local ussm_GetVolume = ussm.GetVolume
local ussm_GetPause = ussm.GetPause
local printf = ussm.printf
local math_abs = math.abs
local CurTime = CurTime

local music_volume = GetConVar( "snd_musicvolume" ):GetFloat()

cvars.AddChangeCallback( "snd_musicvolume", function( _, __, str )
	music_volume = tonumber( str, 10 ) or 0.5
end, "Unknown's Simple Server Music" )

local audio_meta = FindMetaTable( "IGModAudioChannel" )
---@cast audio_meta IGModAudioChannel

local audio_IsValid, audio_getState = audio_meta.IsValid, audio_meta.GetState
local audio_getLength, audio_getTime = audio_meta.GetLength, audio_meta.GetTime
local audio_getPlaybackRate = audio_meta.GetPlaybackRate
local audio_getVolume = audio_meta.GetVolume

---@type boolean
local is_downloading = false

---@type boolean
local is_failed = false

---@type IGModAudioChannel | nil
local channel

---@type string | nil
local file_path

---@param new_channel IGModAudioChannel
---@param error_id integer
---@param error_name string
local function bass_callback( new_channel, error_id, error_name )
	is_downloading = false

	if new_channel and audio_IsValid( new_channel ) then
		printf( "[USSM/Info] The new audio channel '%s' [%s] has been created.", file_path or "unknown", new_channel:GetTagsVendor() or "MPEG" )
		channel = new_channel
	else
		printf( "[USSM/Error] Audio channel creation failed with error code %d ( %s )", error_id, error_name )
		is_failed = true
	end
end

timer.Create( "Unknown's Simple Server Music", 0.25, 0, function()
	if is_downloading then return end

	local server_file_path = ussm_GetFilePath()
	if not server_file_path or #server_file_path == 0 then
		if channel and audio_IsValid( channel ) then
			printf( "[USSM] Current audio channel '%s' has been stopped.", file_path or "unknown" )
			file_path = server_file_path
			channel:Stop()
			channel = nil
		end

		return
	end

	if file_path == server_file_path then
		if channel and audio_IsValid( channel ) then
			local state = audio_getState( channel )
			if state == 3 then
				return
			end

			if ussm_GetPause() then
				if state ~= 2 then
					printf( "[USSM/Warn] Audio channel '%s' paused.", file_path or "unknown" )
					channel:Pause()
				end

				return
			end

			local volume = music_volume * ussm_GetVolume()
			if audio_getVolume( channel ) ~= volume then
				channel:SetVolume( volume )
			end

			local playback_rate = ussm_GetPlaybackRate()
			if audio_getPlaybackRate( channel ) ~= playback_rate then
				channel:SetPlaybackRate( playback_rate )
			end

			local lenght = audio_getLength( channel )
			if lenght > 0 then
				local server_time = ( ( CurTime() - ussm_GetStartTime() ) * playback_rate )
				if ussm_GetRepeat() then
					server_time = server_time % lenght
				elseif server_time > lenght then
					if state ~= 0 then
						printf( "[USSM/Info] Audio channel '%s' has ended.", file_path or "unknown" )
						channel:Stop()
					end

					return
				end

				if math_abs( audio_getTime( channel ) - server_time ) > 0.5 then
					printf( "[USSM/Warn] Audio channel '%s' syncing... ( %0.2f / %0.2f seconds )", file_path or "unknown", server_time, lenght )
					channel:SetTime( server_time )
				end
			end

			if state ~= 1 then
				printf( "[USSM/Warn] Audio channel '%s' not playing, resuming...", file_path or "unknown" )
				channel:Play()
			end

			return
		end
	else
		is_failed = false
	end

	if channel and audio_IsValid( channel ) then
		printf( "[USSM/Info] Audio channel '%s' has been stopped.", file_path or "unknown" )
		file_path = nil
		channel:Stop()
		channel = nil
	end

	if is_failed then
		return
	end

	if string.find( server_file_path, "^https?://.+$" ) ~= nil then
		printf( "[USSM/Info] Establishing a connection with '%s'...", server_file_path )
		file_path = server_file_path
		is_downloading = true

		sound.PlayURL( server_file_path, "mono noblock noplay", bass_callback )
	elseif file.Exists( server_file_path, "GAME" ) then
		printf( "[USSM/Info] Reading file '%s' from disk...", server_file_path )
		file_path = server_file_path
		is_downloading = true

		sound.PlayFile( server_file_path, "mono noplay", bass_callback )
	else
		printf( "[USSM/Error] Invalid local audio file path '%s'", server_file_path or "unknown" )
		is_failed = true
	end
end )
