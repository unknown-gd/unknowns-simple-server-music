local GetGlobal2Var = GetGlobal2Var

module( "ussm" )

function GetFilePath()
	return GetGlobal2Var( "ussm-file-path" )
end

function GetStartTime()
	return GetGlobal2Var( "ussm-start-time", 0 )
end

function GetVolume()
	return GetGlobal2Var( "ussm-volume", 1 )
end
