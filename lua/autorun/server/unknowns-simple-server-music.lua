local GetGlobal2Var = GetGlobal2Var
local SetGlobal2Var = SetGlobal2Var
local CurTime = CurTime

module( "ussm" )

function GetFilePath()
	return GetGlobal2Var( "simple-server-music-file-path" )
end

function GetStartTime()
	return GetGlobal2Var( "simple-server-music-start-time", 0 )
end

function SetFilePath( filePath )
	SetGlobal2Var( "simple-server-music-start-time", CurTime() )
	SetGlobal2Var( "simple-server-music-file-path", filePath )
end
