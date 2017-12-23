local function GetPlayerData( ply, id )
	if ply then
		if !isstring( ply ) then
			if ply.IsPlayer and ply:IsPlayer() then
				return { Name = ply:GetName(), ID = ply:SteamID64() }
			else
				return { Name = "", ID = "", Empty = true }
			end
		else
			local fply = player.GetBySteamID64( ply ) 
			if fply then
				return GetPlayerData( fply )
			else
				return GetPlayerData( nil, ply )
			end
		end
	else
		return { ID = id }
	end
end

Report = {}
Report.__index = Report

Report.ID = "0"
Report.Time = 0
Report.Date = ""
Report.Reporting = { Name = "", ID = "", Empty = true }
Report.Reported = { Name = "", ID = "", Empty = true }
Report.ClosedBy = { Name = "", ID = "", Empty = true }
Report.Closed = false
Report.CloseDate = ""
Report.Topic = ""
Report.Desc = ""
Report.CloseNote = ""

function Report:New( ply, reported, data )
	local report = {}
	setmetatable( report, Report )
	if ply then
		local time = GetTime()
		report.ID = tostring( math.Round( time ) )..GetAutoID()
		report.Time = time
		
		local format = ReportConfig.TimeFormat or "%H:%M - %d/%m/%Y (%A)"
		report.Date = os.date( format, os.time() )

		report.Reporting = GetPlayerData( ply )
		report.Reported = GetPlayerData( reported )
		report.Topic = data.topic or ""
		report.Desc = data.desc or ""
	end
	return report
end

function Report:Close( ply, note )
	if self.Closed then return end
	self.Closed = true
	self.ClosedBy = GetPlayerData( ply )
	self.CloseNote = note or ""

	local format = ReportConfig.TimeFormat or "%H:%M - %d/%m/%Y (%A)"
	self.CloseDate = os.date( format, os.time() )
	return true
end

function Report:GetReportingPlayer()
	return table.Copy( self.Reporting )
end

function Report:GetReportedPlayer()
	return table.Copy( self.Reported )
end

function Report:GetClosedByPlayer()
	return table.Copy( self.ClosedBy )
end

function Report:GetTopic()
	return self.Topic
end

function Report:GetText()
	return self.Desc
end

function Report:GetCloseNote()
	return self.CloseNote
end

function Report:GetTime()
	return self.Time
end

function Report:GetDate()
	return self.Date
end

function Report:GetID()
	return self.ID
end

function Report:IsClosed()
	return self.Closed
end

function Report:GetNetInstance()
	local instance = {
		ID = self.ID,
		Time = self.Time,
		Date = self.Date,
		Reporting = self.Reporting,
		Reported = self.Reported,
		ClosedBy = self.ClosedBy,
		Closed = self.Closed,
		CloseDate = self.CloseDate,
		Topic = self.Topic,
		Desc = self.Desc,
		CloseNote = self.CloseNote
	}
	return instance
end

function Report:ParseNetInstance( instance )
		self.ID = instance.ID
		self.Time = instance.Time
		self.Date = instance.Date
		self.Reporting = instance.Reporting
		self.Reported = instance.Reported
		self.ClosedBy = instance.ClosedBy
		self.Closed = instance.Closed
		self.CloseDate = instance.CloseDate
		self.Topic = instance.Topic
		self.Desc = instance.Desc
		self.CloseNote = instance.CloseNote
end

setmetatable( Report, { __call = Report.New } )