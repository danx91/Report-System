----------------------------PASSWORD----------------------------

ReportConfig.AdminPassword = "Admin" --Password which allows admins to run global actions. If you want to disable password go to 'sh_report_utils.lua' file - recommended: password should be hard to guess, but easy to remember

----------------------------------------------------------------

util.AddNetworkString( "OpenReport" )
util.AddNetworkString( "ReportLog" )
util.AddNetworkString( "OpenReportWindow" )
util.AddNetworkString( "ReportAdminPort" )

local function CommandHandler( ply, cmd, args )
	if cmd == "load" then
		local ammount = math.min( args[1], #REPORTS )
		local reports = {}
		if ammount == -1 and #REPORTS > 0 and args[2] and args[3] then
			local mode = args[2]
			local id = args[3]
			if mode == "REP" then
				for k, v in pairs( REPORTS ) do
					if v:GetReportedPlayer().ID == id and PlayerCanCheckReport( ply, v:GetReportedPlayer().ID ) then
						table.insert( reports, v:GetNetInstance() )
					end
				end
			elseif mode == "ING" then
				for k, v in pairs( REPORTS ) do
					if v:GetReportingPlayer().ID == id and PlayerCanCheckReport( ply, v:GetReportedPlayer().ID ) then
						table.insert( reports, v:GetNetInstance() )
					end
				end
			end
		elseif ammount > 0 then
			local loaded = 0
			local index = 0
			repeat
				local rep = REPORTS[ #REPORTS - index ]
				if PlayerCanCheckReport( ply, rep:GetReportedPlayer().ID ) then
					table.insert( reports, rep:GetNetInstance() )
					loaded = loaded + 1
				end
				index = index + 1
			until loaded >= ammount or index >= #REPORTS
			/*for i = 0, ammount - 1 do
				table.insert( reports, REPORTS[ #REPORTS - i ]:GetNetInstance() )
			end*/
		end
		local command = {
			cmd = "loadok",
			args = reports
		}
		net.Start( "ReportAdminPort" )
			net.WriteTable( command )
		net.Send( ply )
	elseif cmd == "close" then
		local id = args[1]
		local text = args[2]
		local result = CloseID( ply, id, text )

		local txt = result and "You successfully closed this case!" or "You failed to close this case!"

		local command = {
			cmd = "cmdran",
			args = { txt }
		}
		net.Start( "ReportAdminPort" )
			net.WriteTable( command )
		net.Send( ply )
	elseif cmd == "closerep" then
		local id = args[1]
		local text = args[2]
		local result = CloseReported( ply, id, text )

		local txt = result and "You successfully closed these cases!" or "You failed to close these cases!"

		local command = {
			cmd = "cmdran",
			args = { txt }
		}
		net.Start( "ReportAdminPort" )
			net.WriteTable( command )
		net.Send( ply )
	elseif cmd == "closeing" then
		local id = args[1]
		local text = args[2]
		local result = CloseReporting( ply, id, text )

		local txt = result and "You successfully closed these cases!" or "You failed to close these cases!"

		local command = {
			cmd = "cmdran",
			args = { txt }
		}
		net.Start( "ReportAdminPort" )
			net.WriteTable( command )
		net.Send( ply )
	elseif cmd == "delete" then
		local id = args[1]
		local reason = args[2]
		local result = DeleteID( ply, id, reason )

		local txt = result and "You successfully deleted this case!" or "You failed to delete this case!"

		local command = {
			cmd = "cmdran",
			args = { txt }
		}
		net.Start( "ReportAdminPort" )
			net.WriteTable( command )
		net.Send( ply )
	elseif cmd == "deleterep" then
		local id = args[1]
		local reason = args[2]
		local result = DeleteReported( ply, id, reason )

		local txt = result and "You successfully deleted these cases!" or "You failed to delete these cases!"

		local command = {
			cmd = "cmdran",
			args = { txt }
		}
		net.Start( "ReportAdminPort" )
			net.WriteTable( command )
		net.Send( ply )
	elseif cmd == "deleteing" then
		local id = args[1]
		local reason = args[2]
		local result = DeleteReporting( ply, id, reason )

		local txt = result and "You successfully deleted these cases!" or "You failed to delete these cases!"

		local command = {
			cmd = "cmdran",
			args = { txt }
		}
		net.Start( "ReportAdminPort" )
			net.WriteTable( command )
		net.Send( ply )
	elseif cmd == "closeall" then
		local reason = args[1]
		local password = args[2]

		local result = false
		if ReportConfig.PasswordRequired and ReportConfig.AdminPassword == password then
			result = CloseAll( ply, reason )
		end

		local txt = result and "You successfully closed all cases!" or "You failed to close all cases!"

		local command = {
			cmd = "cmdran",
			args = { txt }
		}
		net.Start( "ReportAdminPort" )
			net.WriteTable( command )
		net.Send( ply )
	elseif cmd == "deleteall" then
		local reason = args[1]
		local password = args[2]

		local result = false
		if ReportConfig.PasswordRequired and ReportConfig.AdminPassword == password then
			result = DeleteAll( ply, reason )
		end

		local txt = result and "You successfully deleted all cases!" or "You failed to delete all cases!"

		local command = {
			cmd = "cmdran",
			args = { txt }
		}
		net.Start( "ReportAdminPort" )
			net.WriteTable( command )
		net.Send( ply )
	elseif cmd == "deleteclosed" then
		local reason = args[1]
		local password = args[2]

		local result = false
		if ReportConfig.PasswordRequired and ReportConfig.AdminPassword == password then
			result = DeleteClosed( ply, reason )
		end

		local txt = result and "You successfully deleted these cases!" or "You failed to delete these cases!"

		local command = {
			cmd = "cmdran",
			args = { txt }
		}
		net.Start( "ReportAdminPort" )
			net.WriteTable( command )
		net.Send( ply )
	elseif cmd == "closetime" then
		local reason = args[1]
		local password = args[2]
		local time = args[3]

		local result = false
		if ReportConfig.PasswordRequired and ReportConfig.AdminPassword == password then
			result = CloseTime( ply, time, reason )
		end

		local txt = result and "You successfully closed these cases!" or "You failed to close these cases!"

		local command = {
			cmd = "cmdran",
			args = { txt }
		}
		net.Start( "ReportAdminPort" )
			net.WriteTable( command )
		net.Send( ply )
	elseif cmd == "deletetime" then
		local reason = args[1]
		local password = args[2]
		local time = args[3]

		local result = false
		if ReportConfig.PasswordRequired and ReportConfig.AdminPassword == password then
			result = DeleteTime( ply, time, reason )
		end

		local txt = result and "You successfully deleted these cases!" or "You failed to delete these cases!"

		local command = {
			cmd = "cmdran",
			args = { txt }
		}
		net.Start( "ReportAdminPort" )
			net.WriteTable( command )
		net.Send( ply )
	end
end

local function SortReports()
	local ntab = {}
	for k, v in pairs( REPORTS ) do
		table.insert( ntab, v )
	end
	REPORTS = ntab
	/*table.sort( REPORTS, function( a, b )
		return a:GetTime() < b:GetTime()
	end )*/
end

net.Receive( "ReportAdminPort", function( len, ply )
	if !ply:CheckAdmin() then return end
	local command = net.ReadTable()
	if istable( command ) then
		CommandHandler( ply, command.cmd, command.args )
	end
end )

net.Receive( "OpenReport", function( len, ply )
		if ply.lreptime and ply.lreptime > RealTime() then
			net.Start( "OpenReport" )
				net.WriteString( "s" )
				net.WriteString( string.ToMinutesSeconds( ply.lreptime - RealTime() ) )
			net.Send( ply )
		else
			local tab = net.ReadTable()
			local rep = Report( ply, tab.reported, tab.data )
			table.insert( REPORTS, rep )

			net.Start( "OpenReport" )
				net.WriteString( tab.reported )
			net.Send( ply )

			ply.lreptime = RealTime() + ReportConfig.ReportDelay or 60
			ReportLogChat( "Your report has been successfully accepted! Case ID: "..rep:GetID(), ply )
			ReportMsg( "New report recived! "..( ReportConfig.UseCommands and "Type '"..ReportConfig.AdminCommand.."' to open reports menu." or "Press "..input.GetKeyName( ReportConfig.AdminKey ).."' to open reports menu." ), GetAdmins() )
		end
end )

REPORTS = REPORTS or {}
ReportsAutoID = ReportsAutoID or 0

function GetAutoID()
	local r = ReportsAutoID
	ReportsAutoID = ReportsAutoID + 1
	return r
end

--PrintTable( REPORTS )
--print( "--------" )

function GetTime()
	time = time or 0
	if string.upper( ReportConfig.Time ) == "SV" then
		return RealTime()
	else
		return os.time()
	end
end

function CloseAll( ply, txt )
	if !IsValid( ply ) then return end
	txt = txt or ""
	local num = 0
	for k, v in pairs( REPORTS ) do
		if v:Close( ply, txt.."\n\nClosed by action: 'CLOSE ALL'" ) then
			num = num + 1
		end
	end
	if num > 0 then
		ReportLogAdmin( "Player "..ply:GetName().." closed all ("..num..") reports" )
		return true
	end
end

function CloseID( ply, id, txt )
	if !IsValid( ply ) then return end
	txt = txt or ""
	for k, v in pairs( REPORTS ) do
		if v:GetID() == id then
			if v:Close( ply, txt ) then
				SilentReportLog( "Player "..ply:GetName().." closed report with ID: "..id )
				return true
			end
		end
	end
end

function CloseReported( ply, reported, txt )
	if !IsValid( ply ) then return end
	txt = txt or ""
	local num = 0
	for k, v in pairs( REPORTS ) do
		if v:GetReportedPlayer().ID == reported then
			if v:Close( ply, txt.."\n\nClosed by action: 'CLOSE BY REPORTED PLAYER'" ) then
				num = num + 1
			end
		end
	end
	if num > 0 then
		ReportLogAdmin( "Player "..ply:GetName().." closed all ("..num..") reports against: "..reported )
		return true
	end
end

function CloseReporting( ply, reporting, txt )
	if !IsValid( ply ) then return end
	txt = txt or ""
	local num = 0
	for k, v in pairs( REPORTS ) do
		if v:GetReportingPlayer().ID == reporting then
			if v:Close( ply, txt.."\n\nClosed by action: 'CLOSE BY REPORTING PLAYER'" ) then
				num = num + 1
			end
		end
	end
	if num > 0 then
		ReportLogAdmin( "Player "..ply:GetName().." closed all ("..num..") reports created by: "..reporting )
		return true
	end
end

function CloseTime( ply, time, txt )
	if !IsValid( ply ) then return end
	txt = txt or ""
	local num = 0
	for k, v in pairs( REPORTS ) do
		if v:GetTime() + time * 3600 < GetTime() then
			if v:Close( ply, txt.."\n\nClosed by action: 'CLOSE BEFORE TIME'" ) then
				num = num + 1
			end
		end
	end
	if num > 0 then
		ReportLogAdmin( "Player "..ply:GetName().." closed all ("..num..") reports created before last"..time.." hours" )
		return true
	end
end

function DeleteAll( ply, reason )
	if !IsValid( ply ) then return end
	reason = reason or "No reason"
	local num = 0
	for k, v in pairs( REPORTS ) do
		REPORTS[k] = nil
		num = num + 1
	end
	REPORTS = {}
	--collectgarbage() ???
	if num > 0 then
		ReportLogAdmin( "Player "..ply:GetName().." deleted all ("..num..") reports. Reason: "..reason )
		return true
	end
end

function DeleteClosed( ply, reason )
	if !IsValid( ply ) then return end
	reason = reason or "No reason"
	local num = 0
	for k, v in pairs( REPORTS ) do
		if v:IsClosed() then
			REPORTS[k] = nil
			num = num + 1
		end
	end
	if num > 0 then
		SortReports()
		ReportLogAdmin( "Player "..ply:GetName().." deleted all ("..num..") closed reports. Reason: "..reason )
		return true
	end
end

function DeleteID( ply, id, reason )
	if !IsValid( ply ) then return end
	reason = reason or "No reason"
	for k, v in pairs( REPORTS ) do
		if v:GetID() == id then
			REPORTS[k] = nil
			SortReports()
			SilentReportLog( "Player "..ply:GetName().." deleted report with ID: "..id.." Reason: "..reason )
			return true
		end
	end
end

function DeleteReported( ply, reported, reason )
	if !IsValid( ply ) then return end
	reason = reason or "No reason"
	local num = 0
	for k, v in pairs( REPORTS ) do
		if v:GetReportedPlayer().ID == reported then
			REPORTS[k] = nil
			num = num + 1
		end
	end
	if num > 0 then
		SortReports()
		ReportLogAdmin( "Player "..ply:GetName().." deleted all ("..num..") reports against "..reported..". Reason: "..reason )
		return true
	end
end

function DeleteReporting( ply, reporting, reason )
	if !IsValid( ply ) then return end
	reason = reason or "No reason"
	local num = 0
	for k, v in pairs( REPORTS ) do
		if v:GetReportingPlayer().ID == reporting then
			REPORTS[k] = nil
			num = num + 1
		end
	end
	if num > 0 then
		SortReports()
		ReportLogAdmin( "Player "..ply:GetName().." deleted all ("..num..") reports created by "..reporting..". Reason: "..reason )
		return true
	end
end

function DeleteTime( ply, time, reason )
	if !IsValid( ply ) then return end
	reason = reason or "No reason"
	local num = 0
	for k, v in pairs( REPORTS ) do
		if v:GetTime() + time * 3600 < GetTime() then
			REPORTS[k] = nil
			num = num + 1
		end
	end
	if num > 0 then
		SortReports()
		ReportLogAdmin( "Player "..ply:GetName().." deleted all ("..num..") reports created before last "..time.." hours. Reason: "..reason )
		return true
	end
end

function ReportMsg( txt, plys )
	if !plys then
		plys = player.GetAll()
	end
	local chat = {
		{ color = Color( 255, 75, 75, 255 ), text = "[REPORTS SYSTEM] " },
		{ color = Color( 255, 255, 255, 255 ), text = txt },
	}
	net.Start( "ReportLog" )
		net.WriteTable( chat )
	net.Send( plys )
end

function ReportLogChat( txt, plys )
	if !plys then
		plys = player.GetAll()
	end
	local chat = {
		{ color = Color( 255, 75, 75, 255 ), text = "[REPORTS SYSTEM]" },
		{ color = Color( 100, 200, 75, 255 ), text = "[LOG] " },
		{ color = Color( 255, 255, 255, 255 ), text = txt },
	}
	net.Start( "ReportLog" )
		net.WriteTable( chat )
	net.Send( plys )
end

function ReportLogAdmin( txt )
	local plys = GetAdmins()
	local chat = {
		{ color = Color( 255, 75, 75, 255 ), text = "[REPORTS SYSTEM]" },
		{ color = Color( 150, 100, 200, 255 ), text = "[ADMIN LOG] " },
		{ color = Color( 255, 255, 255, 255 ), text = txt },
	}
	ServerLog( txt )
	net.Start( "ReportLog" )
		net.WriteTable( chat )
	net.Send( plys )
end

function SilentReportLog( txt )
	local plys = GetAdmins()
	local chat = {
		{ color = Color( 255, 75, 75, 255 ), text = "[REPORTS SYSTEM]" },
		{ color = Color( 150, 100, 200, 255 ), text = "[ADMIN LOG] " },
		{ color = Color( 255, 255, 255, 255 ), text = txt },
		silent = true,
	}
	ServerLog( txt )
	net.Start( "ReportLog" )
		net.WriteTable( chat )
	net.Send( plys )
end

local function OpenReportWindow( ply, admin )
	admin = admin and true or false
	net.Start( "OpenReportWindow" )
	net.WriteBool( admin )
	net.Send( ply )
end

timer.Create( "ReportsSchedule", 300, 0, function()
	local reps = 0
	for k, v in pairs( REPORTS ) do
		if !v:IsClosed() then
			reps = reps + 1
		end
	end
	if reps < 1 then return end
	ReportMsg( "Pending reports: "..reps..". Total reports: "..#REPORTS, GetAdmins() )
end )

hook.Add( "PlayerButtonDown", "OpenReportGUIKeys", function( ply, key )
	if !ReportConfig.UseKeys then return end
	if ply:CheckAdmin() and key == ReportConfig.AdminKey then
		OpenReportWindow( ply, true )
	elseif key == ReportConfig.ReportKey then
		OpenReportWindow( ply )
	end
end )

hook.Add( "PlayerSay", "OpenReportGUICommands", function( ply, text, team )
	if !ReportConfig.UseCommands then return end
	text = string.lower( text )
	if ply:CheckAdmin() and text == string.lower( ReportConfig.AdminCommand ) then
		OpenReportWindow( ply, true )
		return ""
	elseif	text == string.lower( ReportConfig.ReportCommand ) then
		OpenReportWindow( ply )
		return ""
	end
end )