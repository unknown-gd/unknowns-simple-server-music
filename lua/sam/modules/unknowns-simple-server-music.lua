local command = sam.command
local Exists = file.Exists
local find = string.find

command.new( "setaudio" )
	:Help( "Sets a URL/FilePath to play on server. Use empty value to stop current audio." )
	:SetPermission( "setaudio", "admin" )
	:SetCategory( "Fun" )
	:AddArg( "text", {
		optional = true,
		hint = "URL/FilePath",
		check = function( value )
			if not value or #value == 0 then return true end
			return find( value, "^https?://.+$" ) ~= nil or Exists( value, "GAME" )
		end
	} )
	:OnExecute( function( ply, value )
		SetGlobal2Float( "simple-server-music-start-time", CurTime() )
		SetGlobal2String( "simple-server-music-file-path", value )
	end )
:End()
