local cmd = ulx.command( "Fun", "ulx setaudio", function( ply, value )
	ulx.fancyLogAdmin( ply, "#A setted a URL audio to play. Use empty !setaudio to stop current audio." )
	SetGlobal2Float( "simple-server-music-start-time", CurTime() )
	SetGlobal2String( "simple-server-music-file-path", value )
end, "!setaudio" )

cmd:addParam( {
	["type"] = ULib.cmds.StringArg,
	["hint"] = "URL/FilePath",
	["autocomplete_fn"] = ulx.soundComplete
} )

cmd:defaultAccess( ULib.ACCESS_ADMIN )
cmd:help( "Sets a URL/FilePath to play on server. Use empty !setaudio to stop current audio." )
