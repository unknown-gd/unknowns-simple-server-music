include( "shared.lua" )

local GetGlobal2Var = GetGlobal2Var
local Exists = file.Exists
local find = string.find
local CurTime = CurTime
local abs = math.abs
local sound = sound
local print = print

local snd_musicvolume = GetConVar( "snd_musicvolume" )
local filePath, isURL = "", false

local metadata = _G[ "Unknown's Simple Server Music" ]
if not istable( metadata ) then
	metadata = {}
	_G[ "Unknown's Simple Server Music" ] = metadata
end

local playingStated = {
	[ GMOD_CHANNEL_PLAYING ] = true,
	[ GMOD_CHANNEL_STALLED ] = true
}

local IGModAudioChannel = FindMetaTable( "IGModAudioChannel" )
local IsValid, GetLength, GetTime, GetState, GetVolume, SetVolume = IGModAudioChannel.IsValid, IGModAudioChannel.GetLength, IGModAudioChannel.GetTime, IGModAudioChannel.GetState, IGModAudioChannel.GetVolume, IGModAudioChannel.SetVolume
local GetFloat = FindMetaTable( "ConVar" ).GetFloat
local time, lenght, startTime, volume = 0, 0, 0, 0

timer.Create( "Unknown's Simple Server Music", 0.25, 0, function()
	if metadata.IsDownloading then return end

	filePath, oldChannel = GetGlobal2Var( "ussm-file-path" ), metadata.m_ServerAudioChannel
	if not filePath or #filePath == 0 then
		if oldChannel and IsValid( oldChannel ) then
			print( "[USSM] Stoping audio:", metadata.m_ServerAudioFilePath or "none" )
			metadata.m_ServerAudioFilePath = filePath
			metadata.m_ServerAudioChannel = nil
			oldChannel:Stop()
		end

		return
	end

	if metadata.m_ServerAudioFilePath == filePath then
		if oldChannel and IsValid( oldChannel ) then
			volume = GetFloat( snd_musicvolume ) * GetGlobal2Var( "ussm-volume", 1 )
			if GetVolume( oldChannel ) ~= volume then
				SetVolume( oldChannel, volume )
			end

			startTime = GetGlobal2Var( "ussm-start-time" )
			if startTime then
				lenght = GetLength( oldChannel )
				if lenght > 0 then
					time = ( CurTime() - startTime ) % lenght
					if abs( GetTime( oldChannel ) - time ) > 0.5 then
						print( "[USSM] Audio syncing: " .. time .. " / " .. lenght )
						oldChannel:SetTime( time )
					end
				end
			end

			if not playingStated[ GetState( oldChannel ) ] then
				print( "[USSM] Replaying audio:", metadata.m_ServerAudioFilePath or "none" )
				oldChannel:Play()
			end

			return
		end
	else
		metadata.IsFailed = false
	end

	if oldChannel and IsValid( oldChannel ) then
		print( "[USSM] Stoping audio:", metadata.m_ServerAudioFilePath or "none" )
		metadata.m_ServerAudioChannel = nil
		oldChannel:Stop()
	end

	if metadata.IsFailed then return end

	isURL = find( filePath, "^https?://.+$" ) ~= nil
	if not isURL and not Exists( filePath, "GAME" ) then return end

	print( "[USSM] Downloading audio file:", filePath )
	metadata.m_ServerAudioFilePath = filePath
	metadata.IsDownloading = true

	sound[ isURL and "PlayURL" or "PlayFile" ]( filePath, "mono noblock noplay", function( newChannel, errorID, errorName )
		metadata.IsDownloading = false

		if not ( newChannel and IsValid( newChannel ) ) then
			ErrorNoHalt( "[USSM] Sound channel creation error: " .. errorName .. "(" .. errorID .. ")\n" )
			metadata.IsFailed = true
			return
		end

		metadata.m_ServerAudioChannel = newChannel
		print( "[USSM] New audio channel:", newChannel )
	end )
end )
