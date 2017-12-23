local function WriteLog( silent, ... )
	if !silent then
		chat.AddText( ... )
	end
	MsgC( ... )
	Msg( "\n" )
end

net.Receive( "ReportLog", function( len )
	local tab = net.ReadTable()
	local finaltable = {}
	for k, v in pairs( tab ) do
		if istable( v ) then
			if !v.text or v.text == "" then continue end
			table.insert( finaltable, v.color or Color( 255, 255, 255, 255 ) )
			table.insert( finaltable, v.text )
		end
	end
	WriteLog( tab.silent, unpack( finaltable ) )
end )

net.Receive( "OpenReportWindow", function( len )
	local admin = net.ReadBool()
	if admin then
		OpenAdminWindow()
	else
		OpenReportWindow()
	end
end )