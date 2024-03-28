AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

local SetGlobal2Var = SetGlobal2Var
local CurTime = CurTime

module( "ussm" )

function SetStartTime( startTime )
	SetGlobal2Var( "ussm-start-time", startTime )
end

-- accept urls and local file paths
function SetFilePath( filePath )
	if not filePath or filePath == "none" or filePath == "nil" then
		SetGlobal2Var( "ussm-start-time", nil )
		SetGlobal2Var( "ussm-file-path", nil )
		return
	end

	SetGlobal2Var( "ussm-start-time", CurTime() )
	SetGlobal2Var( "ussm-file-path", filePath )
end

-- from 0 to 1
function SetVolume( volume )
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
