AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

local SetGlobal2Var = SetGlobal2Var
local CurTime = CurTime

---@diagnostic disable-next-line: lowercase-global
ussm = ussm or {}

--- Sets the music start time.
---@param startTime number
function ussm.SetStartTime( startTime )
	SetGlobal2Var( "ussm-start-time", startTime )
end

--- Sets the music file path/url.
---
--- Accept urls and local file paths.
---@param filePath string | nil
function ussm.SetFilePath( filePath )
	if not filePath or filePath == "none" or filePath == "nil" then
		SetGlobal2Var( "ussm-start-time", nil )
		SetGlobal2Var( "ussm-file-path", nil )
		return
	end

	SetGlobal2Var( "ussm-start-time", CurTime() )
	SetGlobal2Var( "ussm-file-path", filePath )
end

--- Sets the music volume from 0 to 1, default is 1 (100%).
---@param volume number
function ussm.SetVolume( volume )
	if not volume then
		SetGlobal2Var( "ussm-volume", nil )
		return
	end

	if volume > 1 then
		volume = 1
	elseif volume < 0 then
		volume = 0
	end

	SetGlobal2Var( "ussm-volume", volume )
end

local url_cvar = CreateConVar( "sv_ussm_url", "", FCVAR_NOTIFY, "URL/FilePath to play on server." )
ussm.SetFilePath( url_cvar:GetString() )

cvars.AddChangeCallback( url_cvar:GetName(), function( _, __, value )
	ussm.SetFilePath( value )
end, "Unknown's Simple Server Music" )
