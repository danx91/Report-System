local CURRENT_REPORT_WINDOW

local function SetChildrenEnabled( wn, enable )
	if IsValid( wn ) then
		local children = wn:GetChildren()
		for k, v in pairs( children ) do
			if !v.mdf and !enable and v:IsEnabled() then
				v.mdf = true
			end
			if v.mdf then
				v:SetEnabled( enable )
			end
		end
	end
end

local function CreateWindow()
	local w, h = ScrW(), ScrH()

	local report_window, dplayer, dlabel, selectbox, dsearch, dtopic, dcancle, dsend, dscroll, dbpanel

	report_window = vgui.Create( "DFrame" )
	report_window:SetTitle( "Report Player" )
	report_window:SetSizable( false )
	report_window:SetSize( w * 0.22, h * 0.7 )
	report_window:Center()
	report_window:MakePopup()
	--report_window:ShowCloseButton( false )
	report_window:SetDeleteOnClose( true )
	report_window.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 25, 25, 25, 175 ) )
		surface.DrawRect( 0, 0, w, h )
	end

	dscroll = vgui.Create( "DScrollPanel", report_window )
	dscroll:Dock( FILL )
	dscroll:DockMargin( 5, 5, 5, 5 )

	dlabel = vgui.Create( "DLabel", dscroll )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 0, 0, 0 )
	dlabel:SetText( "Select Player" )

	dsearch = vgui.Create( "DTextEntry", dscroll )
	dsearch:Dock( TOP )
	dsearch:DockMargin( 10, 0, 10, 0 )
	dsearch:SetText( "Search - type player name" )
	dsearch.OnChange = function( self )
		selectbox:Clear()
		for k, v in pairs( player.GetAll() ) do
			local name = v:GetName()
			local id = v:SteamID64()
			local text = string.lower( self:GetText() )
			if  text == "" or string.find( string.lower( name ), text ) or ( id and string.find( id, text ) ) then
				selectbox:AddLine( name, id )
			end
		end
	end

	selectbox = vgui.Create( "DListView", dscroll )
	selectbox:Dock( TOP )
	selectbox:DockMargin( 10, 2, 10, 0 )
	selectbox:SetHeight( h * 0.2 )

	selectbox:SetMultiSelect( false )
	selectbox:AddColumn( "Name" )
	selectbox:AddColumn( "ID" )

	for k, v in pairs( player.GetAll() ) do
		selectbox:AddLine( v:GetName(), v:SteamID64() )
	end

	selectbox.OnRowSelected = function( self, index, panel )
		local id = panel:GetColumnText( 2 )
		if id == "" then id = "BOT" end
		dplayer:SetText( id )
	end

	dlabel = vgui.Create( "DLabel", dscroll )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 5, 0, 0 )
	dlabel:SetText( "ID" )

	dplayer = vgui.Create( "DTextEntry", dscroll )
	dplayer:Dock( TOP )
	dplayer:DockMargin( 10, 0, 10, 0 )
	dplayer:SetEnabled( false )

	dlabel = vgui.Create( "DLabel", dscroll )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 35, 0, 0 )
	dlabel:SetText( "Write Report" )

	dtopic = vgui.Create( "DTextEntry", dscroll )
	dtopic:Dock( TOP )
	dtopic:DockMargin( 10, 15, 10, 0 )
	dtopic:SetText( "Topic" )

	ddesc = vgui.Create( "DTextEntry", dscroll )
	ddesc:Dock( TOP )
	ddesc:DockMargin( 10, 5, 10, 0 )
	ddesc:SetText( "Description" )
	ddesc:SetHeight( 200 )
	ddesc:SetMultiline( true )

	dbpanel = vgui.Create( "DPanel", dscroll )
	dbpanel:Dock( TOP )
	dbpanel.Paint = function() end
	dbpanel:SetTall( 100 )

	dcancle = vgui.Create( "DButton", dbpanel )
	dcancle:Dock( LEFT )
	dcancle:DockMargin( 10, 25, 5, 25 )
	dcancle:SetWide( w * 0.05 )
	dcancle:SetText( "Cancel" )
	dcancle.DoClick = function( self )
		report_window:Close()
	end

	dsend = vgui.Create( "DButton", dbpanel )
	dsend:Dock( FILL )
	dsend:DockMargin( 5, 25, 10, 25 )
	dsend:SetWide( w * 0.1 )
	dsend:SetText( "Send" )
	dsend.DoClick = function( self )
		if dplayer:GetText() == "" then
			Derma_Message( "You have to select player!", "Report Player", "OK" )
			return
		end
		if string.lower( dtopic:GetText() ) == "topic" then
			Derma_Message( "You have to write topic!", "Report Player", "OK" )
			return
		end
		if string.lower( ddesc:GetText() ) == "description" then
			Derma_Message( "You have to write description!", "Report Player", "OK" )
			return
		end
		
		report_window.rep = dplayer:GetText()
		SetChildrenEnabled( report_window, false )

		local tab = {
			reported = dplayer:GetText(),
			data = {
				topic = dtopic:GetText(),
				desc = ddesc:GetText()
			}
		}

		net.Start( "OpenReport" )
			net.WriteTable( tab )
		net.SendToServer()

		timer.Create( "ReportTimer", 3, 1, function()
			Derma_Message( "An error has occurred! Client did not receive answer from server. Try again", "Report Player", "OK" )
			SetChildrenEnabled( report_window, true )
		end )
	end

	return report_window
end

function OpenReportWindow()
	if !IsValid( CURRENT_REPORT_WINDOW ) then
		CURRENT_REPORT_WINDOW = CreateWindow()
	end
end

net.Receive( "OpenReport", function( len )
	local str = net.ReadString()
	if CURRENT_REPORT_WINDOW.rep == str then
		timer.Remove( "ReportTimer" )
		Derma_Message( "Thank you for reporting this player! Administration will investigate this report as soon as possible.", "Report Player", "OK" )
		CURRENT_REPORT_WINDOW:Close()	
	elseif str == "s" then
		local time = net.ReadString()
		timer.Remove( "ReportTimer" )
		Derma_Message( "You have to wait "..time.." before next report!", "Report Player", "OK" )
		SetChildrenEnabled( CURRENT_REPORT_WINDOW, true )
	end
end )