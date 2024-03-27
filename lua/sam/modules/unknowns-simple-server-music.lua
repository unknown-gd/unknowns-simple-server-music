local Exists = file.Exists
local find = string.find

sam.command.new( "setaudio" )
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
		ussm.SetFilePath( value )
	end )
:End()
