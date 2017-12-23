local ply = FindMetaTable( "Player" )

function ply:CheckAdmin()
	if ReportConfig.SuperAdmin and self:IsSuperAdmin() then return true end
	if ReportConfig.Admin and self:IsAdmin() then return true end
	local usergroup = self:GetUserGroup()
	local useulx = self.CheckGroup
	for k, v in pairs( ReportConfig.CustomGroups ) do
		if useulx and self:CheckGroup( v ) then return true end
		if usergroup == v then return true end
	end
end

function GetAdmins()
	local admins = {}
	for k, v in pairs( player.GetAll() ) do
		if v:CheckAdmin() then
			table.insert( admins, v )
		end
	end
	return admins
end

function PlayerCanCheckReport( ply, rep )
	/*if ReportConfig.HighProtectionMode and #ReportConfig.HighProtectionModeList > 0 then
		local id64 = ply:SteamID64()
		for k, v in pairs( ReportConfig.HighProtectionModeList ) do
			if v == id64 then
				return true
			end
		end
	else*/if ReportConfig.ProtectionMode then
		if rep != ply:SteamID64() then
			return true
		end
	else
		return true
	end
end