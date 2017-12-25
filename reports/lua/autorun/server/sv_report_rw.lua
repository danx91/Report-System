function LoadReports()
	local path = "RepotSystem/"
	local filename = path..ReportConfig.SaveFileName..".txt"
	if !file.Exists( path, "DATA" ) then
		file.CreateDir( path )
	elseif file.Exists( filename, "DATA" ) then
		if !WriteReportLog( "Loading reports..." ) then
			print( "Loading reports..." )
		end
		local data = file.Read( filename, "DATA" )
		local tab = util.JSONToTable( data )
		if !tab then
			if !WriteReportLog( "REPORTS LOADING FAILED!" ) then
				print( "REPORTS LOADING FAILED!" )
			end
			return
		end
		REPORTS = {}
		for k, v in pairs( tab ) do
			if k == "AutoID" then
				ReportsAutoID = tonumber( v ) or 0
				continue
			end
			local rep = Report()
			rep:ParseNetInstance( v )
			table.insert( REPORTS, rep )
		end
	end
end

function SaveReports()
	local path = "RepotSystem/"
	if !WriteReportLog( "Saving reports..." ) then
		print( "Saving reports..." )
	end	
	print( "Saving reports..." )
	if !file.Exists( path, "DATA" ) then
		file.CreateDir( path )
	end
	local tab = {}
	for k, v in pairs( REPORTS ) do
		local instance = v:GetNetInstance()
		table.insert( tab, instance )
	end
	tab.AutoID = ReportsAutoID or 0
	local data = util.TableToJSON( tab )
	if !data then
		if !WriteReportLog( "REPORTS SAVE FAILED!" ) then
			print( "REPORTS SAVE FAILED!" )
		end
		return
	end
	file.Write( path..ReportConfig.SaveFileName..".txt", data )
end

function WriteReportLog( text )
	if !ReportConfig.EnableLogs then return end
	local path = "RepotSystem/"
	local filename = path..ReportConfig.LogFileName..".txt"
	if !file.Exists( path, "DATA" ) then
		file.CreateDir( path )
	end

	local date = os.date( "%d/%m/%Y %H:%M:%S", os.time() )

	local txt = "[LOG "..date.."] "..text
	print( txt )
	file.Append( filename, txt.."\n" )
	return true
end

timer.Create( "ReportsSaveSchedule", ReportConfig.AutoSave, 0, function()
	SaveReports()
end )

hook.Add( "ShutDown", "ReportsSaveOnShutDown", function()
	WriteReportLog( "Server shutting down..." )
	SaveReports()
	WriteReportLog( "[SESSION ENDED]" )
end )

timer.Simple( 3, function()
	WriteReportLog( "[SESSION STARTED]" )
	LoadReports()
end )

--TODO