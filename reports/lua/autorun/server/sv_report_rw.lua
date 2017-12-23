function LoadReports()
	local path = "RepotSystem/"
	local filename = path..ReportConfig.FileName..".txt"
	if !file.Exists( path, "DATA" ) then
		file.CreateDir( path )
	elseif file.Exists( filename, "DATA" ) then
		print( "Loading reports..." )
		local data = file.Read( filename, "DATA" )
		local tab = util.JSONToTable( data )
		if !tab then
			print( "REPORTS LOADING FAILED!" )
			return
		end
		for k, v in pairs( tab ) do
			local rep = Report()
			rep:ParseNetInstance( v )
			table.insert( REPORTS, rep )
		end
	end
end

function SaveReports()
	local path = "RepotSystem/"
	print( "Saving reports..." )
	if !file.Exists( path, "DATA" ) then
		file.CreateDir( path )
	end
	local tab = {}
	for k, v in pairs( REPORTS ) do
		local instance = v:GetNetInstance()
		table.insert( tab, instance )
	end
	local data = util.TableToJSON( tab )
	if !data then
		print( "REPORTS SAVE FAILED!" )
		return
	end
	file.Write( path..ReportConfig.FileName..".txt", data )
end

timer.Create( "ReportsSaveSchedule", ReportConfig.AutoSave, 0, function()
	SaveReports()
end )

hook.Add( "ShutDown", "ReportsSaveOnShutDown", function()
	SaveReports()
end )

timer.Simple( 3, function()
	LoadReports()
end )

--TODO