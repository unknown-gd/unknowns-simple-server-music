local GetGlobal2Var = GetGlobal2Var
local CurTime = CurTime

---@diagnostic disable-next-line: lowercase-global
---@class ussm
ussm = ussm or {}

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
