ReportConfig = {}

--CORE CONFIG - Do NOT touch unless you know what are you doing!

--If you don't know what are you doing you can cause script errors and give access to unauthorized players!
--Here you can customize reports system

ReportConfig.Time = "OS" --'OS' or 'SV' ('OS' - system time, 'SV' - server time) - default: 'OS', recommended: 'OS'
ReportConfig.TimeFormat = "%H:%M - %d/%m/%Y (%A)" --http://wiki.garrysmod.com/page/os/date - default: '%H:%M - %d/%m/%Y (%A)'

ReportConfig.SuperAdmin = true --Is superadmins allowed to check reports? - default: 'true', recommended: 'true'
ReportConfig.Admin = true --Is admins allowed to check reports? - default: 'true', recommended: 'true'
ReportConfig.CustomGroups = { --Custom groups of players who can access reports. ULX compatible - default: '{}'
	--Put here group names surrounded by " and separete them by , ( Example: "KidAdmin", "Moderator", "ReportGuy" )

}

ReportConfig.ProtectionMode = true --If set to 'true' reported admins can't see reports against them. It's highly recommended to set this var to 'true' - default: 'true'

ReportConfig.PasswordRequired = true --Does global actions need password authentication? - default: 'true', recommended: 'true'
--You can change password on top of sv_report_utils.lua file

ReportConfig.UseKeys = true --Shoud players be able to open report menu by pressing buttons? - default: 'true', recommended: 'true'
ReportConfig.ReportKey = KEY_F4 --Key which opens report window - default: 'KEY_F4'
ReportConfig.AdminKey = KEY_PAD_5 --Key which opens admin window - default: 'KEY_PAD_5'

ReportConfig.UseCommands = true --Shoud players be able to open report menu by chat commands? - default: 'true', recommended: 'true'
ReportConfig.ReportCommand = "!report" --Command which opens report window - default: '!report'
ReportConfig.AdminCommand = "!reportadmin" --Command which opens admin window - default: '!reportadmin'

ReportConfig.ReportDelay = 90 --After sending report player has to wiat this ammount of time before sending next report - default: '60'

ReportConfig.FileName = "save" --Name of file where reports are saved - default: 'Save'
ReportConfig.AutoSave = 300 --This var means delay in seconds between reports auto saves - default: '300'

--Languages --TODO
