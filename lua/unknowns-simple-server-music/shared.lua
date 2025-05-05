local GetGlobal2Var = GetGlobal2Var

---@diagnostic disable-next-line: lowercase-global
ussm = ussm or {}

--- Returns the music file path/url.
---@return string | nil
function ussm.GetFilePath()
	return GetGlobal2Var( "ussm-file-path" )
end

--- Returns the music start time.
---@return number
function ussm.GetStartTime()
	return GetGlobal2Var( "ussm-start-time", 0 )
end

--- Returns the music volume. Default is 1.
---@return number
function ussm.GetVolume()
	return GetGlobal2Var( "ussm-volume", 1 )
end
