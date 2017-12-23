CURRENT_ADMIN_WINDOW = CURRENT_ADMIN_WINDOW

local function SetChildrenEnabled( wn, enable, child )
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
	elseif IsValid( child ) then
		child:SetEnabled( enable )
	end
end

local function ClearData()
	for k, v in pairs( CURRENT_ADMIN_WINDOW.data ) do
		v:Clear()
	end
end

local function RunCMD( cmd )
	if !cmd then return end
	net.Start( "ReportAdminPort" )
		net.WriteTable( cmd )
	net.SendToServer()
	for k, v in pairs( CURRENT_ADMIN_WINDOW.caction ) do
		v:SetEnabled( false )
	end
	for k, v in pairs( CURRENT_ADMIN_WINDOW.daction ) do
		v:SetEnabled( false )
	end
	timer.Create( "CMDDELAY", 3, 1, function()
		Derma_Message( "An error has occurred! Client did not receive answer from server. Try again", "Report Admin", "OK" )
		for k, v in pairs( CURRENT_ADMIN_WINDOW.caction ) do
			v:SetEnabled( true )
		end
		for k, v in pairs( CURRENT_ADMIN_WINDOW.daction ) do
			v:SetEnabled( true )
		end
	end )
end

local function GlobalActionCMD( cmd, arg )
	if ReportConfig.PasswordRequired then
		Derma_StringRequest( "Report Admin", "Enter password", "", function( password )
			Derma_StringRequest( "Report Admin", "Enter reason", CURRENT_ADMIN_WINDOW.ldreason or "", function( reason )
				reason = reason or ""
				password = password or ""
				local command = {
					cmd = cmd,
					args = { reason, password, arg }
				}
				RunCMD( command )
			end, nil, "Send", "Cancel" )
		end, nil, "Confirm", "Cancel" )
	else
		Derma_StringRequest( "Report Admin", "Enter reason", CURRENT_ADMIN_WINDOW.ldreason or "", function( reason )
			reason = reason or ""
			local command = {
				cmd = cmd,
				args = { reason, [3] = arg }
			}
			RunCMD( command )
		end, nil, "Send", "Cancel" )
	end
end

local function Load( id )
	local data = CURRENT_ADMIN_WINDOW.data
	local report = CURRENT_ADMIN_WINDOW.loaded_reports[id]
	if !report then return end
	data.did:SetText( report.ID )
	data.ddate:SetText( report.Date )
	data.dreportedid:SetText( report.Reported.ID )
	data.dreportedname:SetText( report.Reported.Name or "-" )
	data.dingid:SetText( report.Reporting.ID )
	data.dingname:SetText( report.Reporting.Name or "-" )
	data.dtopic:SetText( report.Topic )
	data.ddesc:SetText( report.Desc )
	data.dstatus:SetText( report.Closed and "Closed" or "Open" )
	data.dclosedby:SetText( report.Closed and ( report.ClosedBy.Name.."; "..report.ClosedBy.ID ) or "-" )
	data.dclosedate:SetText( report.Closed and report.CloseDate or "-" )
	if report.Closed then
		data.dclosenote:SetEditable( false )
		data.dclosenote:SetText( report.CloseNote or "-" )
		for k, v in pairs( CURRENT_ADMIN_WINDOW.caction ) do
			v:SetEnabled( false )
		end
	else
		data.dclosenote:SetEditable( true )
		data.dclosenote:SetText( "" )
		for k, v in pairs( CURRENT_ADMIN_WINDOW.caction ) do
			v:SetEnabled( true )
		end
	end

	for k, v in pairs( CURRENT_ADMIN_WINDOW.daction ) do
		v:SetEnabled( true )
	end

end

local function LoadReports( x, group, select, mode, id )
	CURRENT_ADMIN_WINDOW.lammount = x
	CURRENT_ADMIN_WINDOW.select = select
	CURRENT_ADMIN_WINDOW.lmode = mode
	CURRENT_ADMIN_WINDOW.lid = id
	local command = {
		cmd = "load",
		args = { x, mode, id }
	}
	net.Start( "ReportAdminPort" )
		net.WriteTable( command )
	net.SendToServer()
	SetChildrenEnabled( group, false )
	timer.Create( "LOADDELAY", 3, 1, function()
		Derma_Message( "An error has occurred! Client did not receive answer from server. Try again", "Report Admin", "OK" )
	end )
	timer.Create( "LOADCND", 2, 1, function()
		SetChildrenEnabled( group, true )
	end )
end

local function CreateWindow()
	local w, h = ScrW(), ScrH()

	local admin_window, dscroll, dlabel
	local dloadgroup, dload10, dload25, dload50, dloadentry, dloadcustom, dreportslist
	local dbigpanel1, dpanel1, dpanel2, did, dreportedid, dreportedname, ddate, dingid, dingname, dtopic, ddesc
	local dbigpanel2, dpanel3, dpanel4, dstatus, dclosedby, dclosedate, dclosenote
	local dbigpanel3, dbpanel0, dbpanel1, dbpanel2, dclose, dcrep, dcing, ddel, ddrep, dding
	local dbigpanel4, dbpanel3, dbpanel4, dbpanel5, dctime, dcall, ddall, dtimeentry, ddtime, ddelclosed

	admin_window = vgui.Create( "DFrame" )
	admin_window:SetTitle( "Report Admin" )
	admin_window:SetSizable( false )
	admin_window:SetSize( w * 0.45, h * 0.9 )
	admin_window:Center()
	admin_window:MakePopup()
	--admin_window:ShowCloseButton( false )
	admin_window:SetDeleteOnClose( true )
	admin_window.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 25, 25, 25, 175 ) )
		surface.DrawRect( 0, 0, w, h )
	end

	dscroll = vgui.Create( "DScrollPanel", admin_window )
	dscroll:Dock( FILL )
	dscroll.Paint = function( self, w, h )
	end

	----------------------------------------------------------------------------

	dloadgroup = vgui.Create( "DPanel", dscroll )
	dloadgroup:Dock( TOP )
	dloadgroup:DockMargin( 15, 10, 15, 5 )

	dloadgroup.Paint = function( self, w, h ) end

	dload10 = vgui.Create( "DButton", dloadgroup )
	dload10:Dock( LEFT )
	dload10:DockMargin( 0, 0, 7, 0 )
	dload10:SetWide( w * 0.05 )

	dload10:SetText( "Load 10" )
	dload10.DoClick = function( self )
		LoadReports( 10, dloadgroup )
	end

	dload25 = vgui.Create( "DButton", dloadgroup )
	dload25:Dock( LEFT )
	dload25:DockMargin( 0, 0, 7, 0 )
	dload25:SetWide( w * 0.05 )

	dload25:SetText( "Load 25" )
	dload25.DoClick = function( self )
		LoadReports( 25, dloadgroup )
	end

	dload50 = vgui.Create( "DButton", dloadgroup )
	dload50:Dock( LEFT )
	dload50:DockMargin( 0, 0, 75, 0 )
	dload50:SetWide( w * 0.05 )

	dload50:SetText( "Load 50" )
	dload50.DoClick = function( self )
		LoadReports( 50, dloadgroup )
	end

	dloadentry = vgui.Create( "DTextEntry", dloadgroup )
	dloadentry:Dock( LEFT )
	dloadentry:DockMargin( 0, 0, 5, 0 )
	dloadentry:SetWide( w * 0.15 )

	dloadentry:SetText( "ID" )

	dloadcustom = vgui.Create( "DButton", dloadgroup )
	dloadcustom:Dock( TOP )
	dloadcustom:DockMargin( 0, 0, 0, 0 )

	dloadcustom:SetText( "Load ID" )
	dloadcustom:SetTooltip( "Load all reports:\n   Left click - created against player with given ID\n   Right click - created by player with given ID" )
	dloadcustom.DoClick = function( self )
		local id = dloadentry:GetValue()
		if id == "ID" then return end
		LoadReports( -1, dloadgroup, nil, "REP", id )
	end
	dloadcustom.DoRightClick = function( self )
		local id = dloadentry:GetValue()
		if id == "ID" then return end
		LoadReports( -1, dloadgroup, nil, "ING", id )
	end

	dreportslist = vgui.Create( "DListView", dscroll )
	dreportslist:Dock( TOP )
	dreportslist:DockMargin( 10, 5, 10, 10 )
	dreportslist:SetTall( h * 0.275 )
	dreportslist:SetEnabled( false )

	dreportslist:SetTooltip( "Click any mouse button to load report,\nevery button also puts specified text to 'Load ID':\n   Left click - 'Against' ID\n   Right click - 'Creator' ID" )

	dreportslist:SetMultiSelect( false )
	dreportslist:AddColumn( "ID" )
	dreportslist:AddColumn( "Against" )
	dreportslist:AddColumn( "Creator" )
	dreportslist:AddColumn( "Date" )
	dreportslist:AddColumn( "Status" )

	dreportslist.OnRowSelected = function ( self, index, row )
		dloadentry:SetText( row:GetValue( 2 ) )
		Load( index )
	end

	dreportslist.OnRowRightClick = function( self, index, row )
		dloadentry:SetText( row:GetValue( 3 ) )
	end

	admin_window.dreportslist = dreportslist

	----------------------------------------------------------------------------

	dlabel = vgui.Create( "DLabel", dscroll )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 0, 0, 0 )
	dlabel:SetText( "Informations" )

	dbigpanel1 = vgui.Create( "DPanel", dscroll )
	dbigpanel1:Dock( TOP )
	dbigpanel1:DockMargin( 10, 0, 10, 10 )
	dbigpanel1:SetTall( 375 )

	dbigpanel1.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 200, 200, 200, 200 ) )
		surface.DrawOutlinedRect( 0, 0, w, h )
		surface.DrawOutlinedRect( 1, 1, w - 2, h - 2 )
	end

	dpanel1 = vgui.Create( "DPanel", dbigpanel1 )
	dpanel1:Dock( LEFT )
	dpanel1:DockMargin( 0, 5, 0, 5 )
	dpanel1:SetWide( w * 0.175 )

	dpanel1.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 200, 200, 200, 200 ) )
		surface.DrawRect( w - 2, 5, 2, h - 10 )
	end

	dlabel = vgui.Create( "DLabel", dpanel1 )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 5, 0, 5 )
	dlabel:SetText( "Case Date:" )

	ddate = vgui.Create( "DTextEntry", dpanel1 )
	ddate:Dock( TOP )
	ddate:DockMargin( 20, 0, 20, 10 )
	ddate:SetEditable( false )

	dlabel = vgui.Create( "DLabel", dpanel1 )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 5, 0, 5 )
	dlabel:SetText( "Case ID:" )

	did = vgui.Create( "DTextEntry", dpanel1 )
	did:Dock( TOP )
	did:DockMargin( 20, 0, 20, 10 )
	did:SetEditable( false )

	dlabel = vgui.Create( "DLabel", dpanel1 )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 5, 0, 5 )
	dlabel:SetText( "Suspect ID:" )

	dreportedid = vgui.Create( "DTextEntry", dpanel1 )
	dreportedid:Dock( TOP )
	dreportedid:DockMargin( 20, 0, 20, 10 )
	dreportedid:SetEditable( false )

	dlabel = vgui.Create( "DLabel", dpanel1 )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 5, 0, 5 )
	dlabel:SetText( "Suspect Name:" )

	dreportedname = vgui.Create( "DTextEntry", dpanel1 )
	dreportedname:Dock( TOP )
	dreportedname:DockMargin( 20, 0, 20, 10 )
	dreportedname:SetEditable( false )

	dlabel = vgui.Create( "DLabel", dpanel1 )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 5, 0, 5 )
	dlabel:SetText( "Cretor ID:" )

	dingid = vgui.Create( "DTextEntry", dpanel1 )
	dingid:Dock( TOP )
	dingid:DockMargin( 20, 0, 20, 10 )
	dingid:SetEditable( false )

	dlabel = vgui.Create( "DLabel", dpanel1 )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 5, 0, 5 )
	dlabel:SetText( "Cretor Name:" )

	dingname = vgui.Create( "DTextEntry", dpanel1 )
	dingname:Dock( TOP )
	dingname:DockMargin( 20, 0, 20, 10 )
	dingname:SetEditable( false )

	---------------------------------------------

	dpanel2 = vgui.Create( "DPanel", dbigpanel1 )
	dpanel2:Dock( FILL )
	dpanel2:DockMargin( 0, 5, 0, 5 )
	dpanel2:SetWide( w * 0.11 )

	dpanel2.Paint = function( self, w, h ) end

	dlabel = vgui.Create( "DLabel", dpanel2 )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 5, 0, 5 )
	dlabel:SetText( "Topic:" )

	dtopic = vgui.Create( "DTextEntry", dpanel2 )
	dtopic:Dock( TOP )
	dtopic:DockMargin( 20, 0, 20, 10 )
	dtopic:SetEditable( false )
	dtopic:SetHeight( 30 )

	dlabel = vgui.Create( "DLabel", dpanel2 )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 5, 0, 5 )
	dlabel:SetText( "Description:" )

	ddesc = vgui.Create( "DTextEntry", dpanel2 )
	ddesc:Dock( FILL )
	ddesc:DockMargin( 20, 0, 20, 20 )
	ddesc:SetEditable( false )
	ddesc:SetMultiline( true )

	----------------------------------------------------------------------------

	dlabel = vgui.Create( "DLabel", dscroll )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 0, 0, 0 )
	dlabel:SetText( "Status" )

	dbigpanel2 = vgui.Create( "DPanel", dscroll )
	dbigpanel2:Dock( TOP )
	dbigpanel2:DockMargin( 10, 0, 10, 5 )
	dbigpanel2:SetTall( 190 )

	dbigpanel2.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 200, 200, 200, 200 ) )
		surface.DrawOutlinedRect( 0, 0, w, h )
		surface.DrawOutlinedRect( 1, 1, w - 2, h - 2 )
	end

	dpanel3 = vgui.Create( "DPanel", dbigpanel2 )
	dpanel3:Dock( LEFT )
	dpanel3:DockMargin( 0, 5, 0, 5 )
	dpanel3:SetWide( w * 0.175 )

	dpanel3.Paint = function( self, w, h )	
		surface.SetDrawColor( Color( 200, 200, 200, 200 ) )
		surface.DrawRect( w - 2, 5, 2, h - 10 )
	end

	dlabel = vgui.Create( "DLabel", dpanel3 )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 5, 0, 5 )
	dlabel:SetText( "Status:" )

	dstatus = vgui.Create( "DTextEntry", dpanel3 )
	dstatus:Dock( TOP )
	dstatus:DockMargin( 20, 0, 20, 10 )
	dstatus:SetEditable( false )

	dlabel = vgui.Create( "DLabel", dpanel3 )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 5, 0, 5 )
	dlabel:SetText( "Closed By:" )

	dclosedby = vgui.Create( "DTextEntry", dpanel3 )
	dclosedby:Dock( TOP )
	dclosedby:DockMargin( 20, 0, 20, 10 )
	dclosedby:SetEditable( false )

	dlabel = vgui.Create( "DLabel", dpanel3 )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 5, 0, 5 )
	dlabel:SetText( "Close Date:" )

	dclosedate = vgui.Create( "DTextEntry", dpanel3 )
	dclosedate:Dock( TOP )
	dclosedate:DockMargin( 20, 0, 20, 10 )
	dclosedate:SetEditable( false )

	---------------------------------------------

	dpanel4 = vgui.Create( "DPanel", dbigpanel2 )
	dpanel4:Dock( FILL )
	dpanel4:DockMargin( 0, 5, 0, 5 )
	dpanel4:SetWide( w * 0.11 )

	dpanel4.Paint = function( self, w, h ) end

	dlabel = vgui.Create( "DLabel", dpanel4 )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 5, 0, 5 )
	dlabel:SetText( "Close Note:" )

	dclosenote = vgui.Create( "DTextEntry", dpanel4 )
	dclosenote:Dock( FILL )
	dclosenote:DockMargin( 20, 0, 20, 20 )
	dclosenote:SetEditable( false )
	dclosenote:SetMultiline( true )

	----------------------------------------------------------------------------

	dlabel = vgui.Create( "DLabel", dscroll )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 0, 0, 0 )
	dlabel:SetText( "Report Actions" )

	dbigpanel3 = vgui.Create( "DPanel", dscroll )
	dbigpanel3:Dock( TOP )
	dbigpanel3:DockMargin( 10, 0, 10, 30 )
	dbigpanel3:SetTall( 140 )

	dbigpanel3.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 200, 200, 200, 200 ) )
		surface.DrawOutlinedRect( 0, 0, w, h )
		surface.DrawOutlinedRect( 1, 1, w - 2, h - 2 )
	end

	dbpanel0 = vgui.Create( "DPanel", dbigpanel3 )
	dbpanel0:Dock( LEFT )
	dbpanel0:DockMargin( 0, 5, 0, 5 )
	dbpanel0:SetWide( w * 0.15 - 10 )

	dbpanel0.Paint = function( self, w, h )	end

	dclose = vgui.Create( "DButton", dbpanel0 )
	dclose:Dock( TOP )
	dclose:DockMargin( 10, 10, 10, 15 )
	dclose:SetTall( 40 )

	dclose:SetText( "Close case" )
	dclose:SetTooltip( "Closes case" )

	ddel = vgui.Create( "DButton", dbpanel0 )
	ddel:Dock( TOP )
	ddel:DockMargin( 10, 15, 10, 10 )
	ddel:SetTall( 40 )

	ddel:SetText( "Delete case" )
	ddel:SetTooltip( "Deletes case" )

	-------------------------------------

	dbpanel1 = vgui.Create( "DPanel", dbigpanel3 )
	dbpanel1:Dock( FILL )
	dbpanel1:DockMargin( 0, 5, 0, 5 )

	dbpanel1.Paint = function( self, w, h )	end

	dcrep = vgui.Create( "DButton", dbpanel1 )
	dcrep:Dock( TOP )
	dcrep:DockMargin( 10, 10, 10, 15 )
	dcrep:SetTall( 40 )

	dcrep:SetText( "Close REP" )
	dcrep:SetTooltip( "Closes all cases against reported player" )

	ddrep = vgui.Create( "DButton", dbpanel1 )
	ddrep:Dock( TOP )
	ddrep:DockMargin( 10, 15, 10, 10 )
	ddrep:SetTall( 40 )

	ddrep:SetText( "Delete REP" )
	ddrep:SetTooltip( "Deletes all cases against reported player" )

	-------------------------------------

	dbpanel2 = vgui.Create( "DPanel", dbigpanel3 )
	dbpanel2:Dock( RIGHT )
	dbpanel2:DockMargin( 0, 5, 0, 5 )
	dbpanel2:SetWide( w * 0.15 - 10 )

	dbpanel2.Paint = function( self, w, h )	end

	dcing = vgui.Create( "DButton", dbpanel2 )
	dcing:Dock( TOP )
	dcing:DockMargin( 10, 10, 10, 15 )
	dcing:SetTall( 40 )

	dcing:SetText( "Close ING" )
	dcing:SetTooltip( "Closes all cases created by reporting player" )

	dding = vgui.Create( "DButton", dbpanel2 )
	dding:Dock( TOP )
	dding:DockMargin( 10, 15, 10, 10 )
	dding:SetTall( 40 )

	dding:SetText( "Delete ING" )
	dding:SetTooltip( "Deletes all cases created by reporting player" )

	----------------------------------------------------------------------------

	dlabel = vgui.Create( "DLabel", dscroll )
	dlabel:Dock( TOP )
	dlabel:DockMargin( 5, 0, 0, 0 )
	dlabel:SetText( "Global Actions" )

	dbigpanel4 = vgui.Create( "DPanel", dscroll )
	dbigpanel4:Dock( TOP )
	dbigpanel4:DockMargin( 10, 0, 10, 5 )
	dbigpanel4:SetTall( 140 )

	dbigpanel4.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 200, 200, 200, 200 ) )
		surface.DrawOutlinedRect( 0, 0, w, h )
		surface.DrawOutlinedRect( 1, 1, w - 2, h - 2 )
	end

	dbpanel3 = vgui.Create( "DPanel", dbigpanel4 )
	dbpanel3:Dock( LEFT )
	dbpanel3:DockMargin( 0, 5, 0, 5 )
	dbpanel3:SetWide( w * 0.15 - 10 )

	dbpanel3.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 200, 200, 200, 200 ) )
		surface.DrawRect( 30, 64, w - 30, 2 )
	end

	dtimeentry = vgui.Create( "DNumberWang", dbpanel3 )
	dtimeentry:Dock( TOP )
	dtimeentry:DockMargin( 10, 10, 10, 15 )
	dtimeentry:SetTall( 40 )

	dtimeentry:SetValue( 1 )
	dtimeentry:SetTooltip( "Time in hours" )

	ddelclosed = vgui.Create( "DButton", dbpanel3 )
	ddelclosed:Dock( TOP )
	ddelclosed:DockMargin( 10, 15, 10, 10 )
	ddelclosed:SetTall( 40 )

	ddelclosed:SetText( "Delete closed cases" )
	ddelclosed:SetTooltip( "Deletes all closed cases" )

	-------------------------------------

	dbpanel4 = vgui.Create( "DPanel", dbigpanel4 )
	dbpanel4:Dock( FILL )
	dbpanel4:DockMargin( 0, 5, 0, 5 )

	dbpanel4.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 200, 200, 200, 200 ) )
		surface.DrawRect( 0, 64, w, 2 )
	end

	dctime = vgui.Create( "DButton", dbpanel4 )
	dctime:Dock( TOP )
	dctime:DockMargin( 10, 15, 10, 10 )
	dctime:SetTall( 40 )

	dctime:SetText( "Close TIME" )
	dctime:SetTooltip( "Closes all cases created before the last x hours" )

	dcall = vgui.Create( "DButton", dbpanel4 )
	dcall:Dock( TOP )
	dcall:DockMargin( 10, 15, 10, 10 )
	dcall:SetTall( 40 )

	-------------------------------------

	dbpanel5 = vgui.Create( "DPanel", dbigpanel4 )
	dbpanel5:Dock( RIGHT )
	dbpanel5:DockMargin( 0, 5, 0, 5 )
	dbpanel5:SetWide( w * 0.15 - 10 )

	dbpanel5.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 200, 200, 200, 200 ) )
		surface.DrawRect( 0, 64, w - 30, 2 )
	end

	ddtime = vgui.Create( "DButton", dbpanel5 )
	ddtime:Dock( TOP )
	ddtime:DockMargin( 10, 15, 10, 10 )
	ddtime:SetTall( 40 )

	ddtime:SetText( "Delete TIME" )
	ddtime:SetTooltip( "Deletes all cases created before the last x hours" )

	dcall:SetText( "Close all cases" )
	dcall:SetTooltip( "Closes all cases" )

	ddall = vgui.Create( "DButton", dbpanel5 )
	ddall:Dock( TOP )
	ddall:DockMargin( 10, 15, 10, 10 )
	ddall:SetTall( 40 )

	ddall:SetText( "Delete all cases" )
	ddall:SetTooltip( "Delete all cases" )

	----------------------------------------------------------------------------
	--Actions

	dclose.DoClick = function( self )
		if dclosenote:GetText() == "" then
			Derma_Message( "You have to write close note!", "Report Admin", "OK" )
			return
		end
		local command = {
			cmd = "close",
			args = { did:GetText(), dclosenote:GetText() }
		}
		RunCMD( command )
	end

	dcrep.DoClick = function( self )
		if dclosenote:GetText() == "" then
			Derma_Message( "You have to write close note!", "Report Admin", "OK" )
			return
		end
		local command = {
			cmd = "closerep",
			args = { dreportedid:GetText(), dclosenote:GetText() }
		}
		RunCMD( command )
	end

	dcing.DoClick = function( self )
		if dclosenote:GetText() == "" then
			Derma_Message( "You have to write close note!", "Report Admin", "OK" )
			return
		end
		local command = {
			cmd = "closeing",
			args = { dingid:GetText(), dclosenote:GetText() }
		}
		RunCMD( command )
	end

	ddel.DoClick = function( self )
		Derma_StringRequest( "Report Admin", "Enter delete reason", admin_window.ldreason or "", function( text )
			text = text or ""
			admin_window.ldreason = text
			local command = {
				cmd = "delete",
				args = { did:GetText(), text }
			}
			RunCMD( command )
		end, nil, "Send", "Cancle" )
	end

	ddrep.DoClick = function( self )
		Derma_StringRequest( "Report Admin", "Enter delete reason", admin_window.ldreason or "", function( text )
			text = text or ""
			admin_window.ldreason = text
			local command = {
				cmd = "deleterep",
				args = { dreportedid:GetText(), text }
			}
			RunCMD( command )
		end, nil, "Send", "Cancle" )
	end

	dding.DoClick = function( self )
		Derma_StringRequest( "Report Admin", "Enter delete reason", admin_window.ldreason or "", function( text )
			text = text or ""
			admin_window.ldreason = text
			local command = {
				cmd = "deleteing",
				args = { dingid:GetText(), text }
			}
			RunCMD( command )
		end, nil, "Send", "Cancel" )
	end

	dcall.DoClick = function( self )
		GlobalActionCMD( "closeall" )
	end

	ddall.DoClick = function( self )
		GlobalActionCMD( "deleteall" )
	end

	ddelclosed.DoClick = function( self )
		GlobalActionCMD( "deleteclosed" )
	end

	dctime.DoClick = function( self )
		local time = dtimeentry:GetValue()
		if time < 1 then time = 1 end
		GlobalActionCMD( "closetime", time )
	end

	ddtime.DoClick = function( self )
		local time = dtimeentry:GetValue()
		if time < 1 then time = 1 end
		GlobalActionCMD( "deletetime", time )
	end

	----------------------------------------------------------------------------

	admin_window.data = { did = did, dreportedid = dreportedid, dreportedname = dreportedname, ddate = ddate, dingid = dingid, dingname = dingname, dtopic = dtopic, ddesc = ddesc, dstatus = dstatus, dclosedby = dclosedby, dclosedate = dclosedate, dclosenote = dclosenote }
	admin_window.caction = { dclose = dclose, dcrep = dcrep, dcing = dcing }
	admin_window.daction = { ddel = ddel, ddrep = ddrep, dding = dding }
	--admin_window.dloadgroup = dloadgroup


	for k, v in pairs( admin_window.caction ) do
		v:SetEnabled( false )
	end

	for k, v in pairs( admin_window.daction ) do
		v:SetEnabled( false )
	end

	return admin_window
end

function OpenAdminWindow()
	if !IsValid( CURRENT_ADMIN_WINDOW ) then
		CURRENT_ADMIN_WINDOW = CreateWindow()
	end
end
if IsValid( CURRENT_ADMIN_WINDOW ) then
	CURRENT_ADMIN_WINDOW:Close()
end
--OpenAdminWindow()

local function CommandHandler( cmd, args )
	if cmd == "loadok" then
		timer.Remove( "LOADDELAY" )
		local reports = args
		CURRENT_ADMIN_WINDOW.dreportslist:Clear()
		if #reports > 0 then
			CURRENT_ADMIN_WINDOW.loaded_reports = table.Copy( reports )
			for k, v in ipairs( reports ) do
				CURRENT_ADMIN_WINDOW.dreportslist:AddLine( v.ID, v.Reported.ID, v.Reporting.ID, v.Date, v.Closed and "Closed" or "Open" )
				CURRENT_ADMIN_WINDOW.dreportslist:SetEnabled( true )
			end
			if CURRENT_ADMIN_WINDOW.select then
				CURRENT_ADMIN_WINDOW.dreportslist:SelectItem( CURRENT_ADMIN_WINDOW.dreportslist:GetLine( CURRENT_ADMIN_WINDOW.select ) )
			end
		else
			Derma_Message( "Server was unable to load reports!", "Report Admin", "OK" )
		end
	elseif cmd == "cmdran" then
		timer.Remove( "CMDDELAY" )
		for k, v in pairs( CURRENT_ADMIN_WINDOW.caction ) do
			v:SetEnabled( true )
		end
		for k, v in pairs( CURRENT_ADMIN_WINDOW.daction ) do
			v:SetEnabled( true )
		end
		local txt = args[1] or ""
		Derma_Query( "If you want to continue, you have to refresh reports list!", "Report Admin", "Refresh", function()
			LoadReports( CURRENT_ADMIN_WINDOW.lammount or "10", nil, CURRENT_ADMIN_WINDOW.dreportslist:GetSelectedLine(), CURRENT_ADMIN_WINDOW.lmode, CURRENT_ADMIN_WINDOW.lid )
			ClearData()
		end, "Exit", function()
			CURRENT_ADMIN_WINDOW:Close()
		end )
		Derma_Message( txt, "Report Admin", "OK" )
	end
end

net.Receive( "ReportAdminPort", function( len )
	local command = net.ReadTable()
	if istable( command ) then
		CommandHandler( command.cmd, command.args )
	end
end )