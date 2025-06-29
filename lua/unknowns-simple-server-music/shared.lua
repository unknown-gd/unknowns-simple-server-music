local GetGlobal2Var = GetGlobal2Var
local CurTime = CurTime

---@diagnostic disable-next-line: lowercase-global
---@class ussm
ussm = ussm or {}

ussm.SyncFactor = CreateConVar( "ussm_sync_factor", "0.5", { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "The sync factor used for syncing the music.", 0.1, 300 )

--- Prints a formatted string.
---
---@param fmt string
---@param ... any
function ussm.printf( fmt, ... )
	return print( string.format( fmt, ... ) )
end

--- Returns the music file path/url.
---
---@return string | nil
function ussm.GetFilePath()
	return GetGlobal2Var( "ussm-file-path" )
end

--- Returns the music start time.
---
---@return number
function ussm.GetStartTime()
	return GetGlobal2Var( "ussm-start-time", CurTime() )
end

--- Returns the music volume, default is 1.
---
---@return number
function ussm.GetVolume()
	return GetGlobal2Var( "ussm-volume", 1 )
end

--- Returns the music repeat state.
---
---@return boolean
function ussm.GetRepeat()
	return GetGlobal2Var( "ussm-repeat", true )
end

--- Returns the music playback rate.
---
---@return number
function ussm.GetPlaybackRate()
	return GetGlobal2Var( "ussm-playback-rate", 1 )
end

--- Returns the music pause state.
---
---@return boolean
function ussm.GetPause()
	return GetGlobal2Var( "ussm-pause", false )
end
