AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

local SetGlobal2Var = SetGlobal2Var
local hook_Run = hook.Run
local CurTime = CurTime

--- Sets the music start time.
---
---@param startTime number Start time in seconds .
function ussm.SetStartTime( startTime )
	SetGlobal2Var( "ussm-start-time", startTime )
end

do

	local wrong_paths = {
		[ "unknown" ] = true,
		[ "false" ] = true,
		[ "none" ] = true,
		[ "nil" ] = true,
		[ "" ] = true
	}

	--- Sets the music file path/url.
	---
	--- Accept urls and local file paths.
	---
	---@param file_path string | nil URL or local file path.
	function ussm.SetFilePath( file_path )
		SetGlobal2Var( "ussm-pause", false )
		hook_Run( "USSM::Pause", false )
		ussm.PauseStart = nil

		file_path = hook_Run( "USSM::Play", file_path ) or file_path

		if not file_path or wrong_paths[ file_path ] then
			SetGlobal2Var( "ussm-start-time", 0 )
			SetGlobal2Var( "ussm-file-path", nil )
			hook_Run( "USSM::Stop" )
		else
			SetGlobal2Var( "ussm-start-time", CurTime() )
			SetGlobal2Var( "ussm-file-path", file_path )
		end
	end

end

--- Sets the music volume from 0 to 2, default is 1 (100%).
---
---@param volume number | nil Volume value must be 0 - 2.
function ussm.SetVolume( volume )
	if isnumber( volume ) then
		---@cast volume number
		volume = math.Clamp( volume, 0, 2 )
	else
		volume = 1
	end

	SetGlobal2Var( "ussm-volume", hook_Run( "USSM::Volume", volume ) or volume )
end

--- Sets the music repeat state.
---
---@param state boolean | nil `true` if repeat is enabled, `false` otherwise.
function ussm.SetRepeat( state )
	state = state == true
	SetGlobal2Var( "ussm-repeat", hook_Run( "USSM::Repeat", state ) or state )
end

--- Sets the music playback rate.
---
---@param rate number | nil Rate value must be 0 - 2
function ussm.SetPlaybackRate( rate )
	if isnumber( rate ) then
		---@cast rate number
		rate = math.Clamp( rate, 0, 2 )
	else
		rate = 1
	end

	SetGlobal2Var( "ussm-playback-rate", hook_Run( "USSM::PlaybackRate", rate ) or rate )
end

--- Pauses playback or resumes playback.
---
---@param paused boolean | nil `true` if playback is paused, `false` otherwise.
function ussm.SetPause( paused )
	paused = paused == true

	if paused ~= ussm.GetPause() then
		local curtime = CurTime()

		if paused then
			ussm.PauseStart = curtime
		else
			local offset = ( curtime - ( ussm.PauseStart or curtime ) )
			ussm.SetStartTime( ussm.GetStartTime() + offset )
			ussm.PauseStart = nil
		end

		SetGlobal2Var( "ussm-pause", hook_Run( "USSM::Pause", paused ) or paused )
	end
end

local function build_autocomplete( fn )
	return function( cmd, arg_str, args )
		local result = fn( string.sub( arg_str, 2 ), args )
		if result == nil then
			return nil
		end

		for i = 1, #result, 1 do
			result[ i ] = cmd .. " " .. result[ i ]
		end

		return result
	end
end
-- https://alium.p1ka.eu/files/mod.flip.ogg
concommand.Add( "ussm_set_path", function( pl, __, args )
	---@cast pl Player | nil
	if pl == nil or ( pl:IsSuperAdmin() or pl:IsListenServerHost() ) then
		ussm.SetFilePath( args[ 1 ] )
	elseif pl ~= nil then
		pl:ChatPrint( "[USSM] You don't have permission to run this command." )
	end
end, build_autocomplete( function( str_href )
	if str_href == "" then
		return { "\"http://\"", "\"https://\"" }
	end

	if string.match( str_href, "^\"[^\"]+" ) ~= nil then
		-- str_href = "\"" .. str_href
		str_href = string.sub( str_href, 2 )
	end

	if string.match( str_href, "[^\"]+\"$" ) == nil then
		str_href = str_href .. "\""
	end

	if string.find( str_href, "^https?://.+\"$" ) == nil then
		return { "\"http://" .. str_href, "\"https://" .. str_href }
	elseif string.match( str_href, "^\"[^\"]+\"$" ) == nil then
		return { "\"" .. str_href }
	else
		return { str_href }
	end
end ), "Sets the music file path/url. Use empty value to stop current audio." )

local bool_autocomplete = build_autocomplete( function( str_state )
	if str_state ~= "" then return end
	return { "0", "1" }
end )

local frac_autocomplete = build_autocomplete( function( str_rate )
	if string.len( str_rate ) > 3 then
		return
	end

	local lst = { "0" }

	local b1, b2 = string.byte( str_rate, 1, 2 )
	if b1 == nil then
		str_rate = "0" .. str_rate
	end

	if b2 == nil then
		str_rate = str_rate .. "."
		b2 = 0x2E --[[ . ]]
	end

	if ( b1 == 0x30 --[[ 0 ]] or b1 == 0x31 --[[ 1 ]] ) and b2 == 0x2E --[[ . ]] then
		for i = 0, 9, 1 do
			lst[ #lst + 1 ] = str_rate .. i
		end
	end

	lst[ #lst + 1 ] = "1"
	lst[ #lst + 1 ] = "2"

	return lst
end )

concommand.Add( "ussm_set_volume", function( pl, __, ___, str_volume )
	---@cast pl Player | nil
	if pl == nil or ( pl:IsSuperAdmin() or pl:IsListenServerHost() ) then
		ussm.SetVolume( tonumber( str_volume, 10 ) or 0.5 )

		if pl ~= nil then
			pl:ChatPrint( "[USSM] The music volume has been set to " .. ussm.GetVolume() )
		end
	elseif pl ~= nil then
		pl:ChatPrint( "[USSM] You don't have permission to run this command." )
	end
end, frac_autocomplete, "Sets the music volume. Default is 0.5" )

concommand.Add( "ussm_set_repeat", function( pl, __, ___, str_state )
	---@cast pl Player | nil
	if pl == nil or ( pl:IsSuperAdmin() or pl:IsListenServerHost() ) then
		ussm.SetRepeat( str_state == "1" )

		if pl ~= nil then
			if ussm.GetRepeat() then
				pl:ChatPrint( "[USSM] The music will repeat." )
			else
				pl:ChatPrint( "[USSM] The music will not repeat." )
			end
		end
	elseif pl ~= nil then
		pl:ChatPrint( "[USSM] You don't have permission to run this command." )
	end
end, bool_autocomplete, "Sets the music repeat state. 0 = false, 1 = true" )

concommand.Add( "ussm_set_playback_rate", function( pl, __, ___, str_rate )
	---@cast pl Player | nil
	if pl == nil or ( pl:IsSuperAdmin() or pl:IsListenServerHost() ) then
		ussm.SetPlaybackRate( tonumber( str_rate, 10 ) or 1 )

		if pl ~= nil then
			pl:ChatPrint( string.format( "[USSM] The music playback rate has been set to %f", ussm.GetPlaybackRate() ) )
		end
	elseif pl ~= nil then
		pl:ChatPrint( "[USSM] You don't have permission to run this command." )
	end
end, frac_autocomplete, "Sets the music playback rate. Default is 1" )

concommand.Add( "ussm_change_position", function( pl, __, ___, str_time )
	---@cast pl Player | nil
	if pl == nil or ( pl:IsSuperAdmin() or pl:IsListenServerHost() ) then
		local seconds = tonumber( str_time, 10 ) or 0
		if seconds == 0 then
			return
		end

		ussm.SetStartTime( ussm.GetStartTime() - seconds )

		if pl ~= nil then
			if seconds < 0 then
				pl:ChatPrint( string.format( "[USSM] The music start time has been moved back %d seconds.", -seconds ) )
			else
				pl:ChatPrint( string.format( "[USSM] The music start time has been moved forward %d seconds.", seconds ) )
			end
		end
	elseif pl ~= nil then
		pl:ChatPrint( "[USSM] You don't have permission to run this command." )
	end
end, nil, "Allows you to change the current music position, for exmaple -10 moves the music back 10 seconds, +10 moves the music forward 10 seconds." )

concommand.Add( "ussm_set_pause", function( pl, __, ___, str_state )
	---@cast pl Player | nil
	if pl == nil or ( pl:IsSuperAdmin() or pl:IsListenServerHost() ) then
		ussm.SetPause( str_state == "1" )

		if pl ~= nil then
			if ussm.GetPause() then
				pl:ChatPrint( "[USSM] Pausing playback..." )
			else
				pl:ChatPrint( "[USSM] Resuming playback..." )
			end
		elseif pl ~= nil then
			pl:ChatPrint( "[USSM] The music is already " .. ( ussm.GetPause() and "paused" or "playing" ) .. "." )
		end
	elseif pl ~= nil then
		pl:ChatPrint( "[USSM] You don't have permission to run this command." )
	end
end, bool_autocomplete, "Sets the music pause state. 0 = false, 1 = true" )
