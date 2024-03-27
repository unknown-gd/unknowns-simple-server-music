local cmd = ulx.command( "Fun", "ulx setaudio", function( ply, value )
	ulx.fancyLogAdmin( ply, "#A setted a URL audio to play. Use empty !setaudio to stop current audio." )
	ussm.SetFilePath( value )
end, "!setaudio" )

cmd:addParam( {
	["type"] = ULib.cmds.StringArg,
	["hint"] = "URL/FilePath",
	["autocomplete_fn"] = ulx.soundComplete
} )

cmd:defaultAccess( ULib.ACCESS_ADMIN )
cmd:help( "Sets a URL/FilePath to play on server. Use empty !setaudio to stop current audio." )
