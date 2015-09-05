/*
	=== SkidCheck - 2.0 ===
	--By HeX
*/

if HAC then
	ErrorNoHalt("\n[SkidCheck] Disabled. Please remove HAC and restart the server\n")
	return
end

Skid.WaitFor 	= 35 --Seconds to wait before message
Skid.sk_kick 	= CreateConVar("sk_kick",	0, FCVAR_ARCHIVE, "Prevent players who are in the DB from joining")
Skid.sk_omit 	= CreateConVar("sk_omit",	1, FCVAR_ARCHIVE, "Don't send the SK message to the cheater in question (Useless if sk_kick or sk_admin is 1)")
Skid.sk_admin	= CreateConVar("sk_admin",	0, FCVAR_ARCHIVE, "Only send SK messages to admins (Useless if sk_kick or sk_omit is 1)")
Skid.sk_sync	= CreateConVar("sk_sync",	6, FCVAR_ARCHIVE, "Allow list sync from GitHub? value == hours to check for updates (0 to disable)")


AddCSLuaFile("autorun/sh_SK.lua")
AddCSLuaFile("autorun/client/cl_SK.lua")

util.AddNetworkString("Skid.Msg")


//Load lists
function table.MergeEx(from,dest)
	for k,v in pairs(from) do
		dest[k] = v
	end
	from = nil
end

Skid.Lists = file.Find("lua/SkidCheck/sv_SkidList*.lua", "GAME", "nameasc")

HAC = { Skiddies = {} }
	//Must load in reverse order! 9 > 1
	for k,v in pairs(Skid.Lists) do
		include("SkidCheck/"..v)
	end
	
	Skid.HAC_DB = HAC.Skiddies
HAC = nil



//Check
function Skid.Check(server_only)
	//Get admins, used for sk_admin
	local Admins = {}
	for k,v in pairs( player.GetHumans() ) do
		if v:IsAdmin() then
			table.insert(Admins, v)
		end
	end
	
	//Go!
	for k,v in pairs( player.GetHumans() ) do
		local Reason = Skid.HAC_DB[ v:SteamID() ]
		if not Reason then continue end
		
		//Hook
		if hook.Run("OnSkid", v, Reason, (not server_only) ) then return end
		
		//Log
		file.Append("sk_encounters.txt", Format("\r\n[%s]: %s (%s) - %s", os.date(), v:Nick(), v:SteamID(), Reason) )
		
		//Tell server
		MsgC(Skid.GREY, "\n[")
		MsgC(Skid.WHITE2, "Skid")
		MsgC(Skid.BLUE, "Check")
		MsgC(Skid.GREY, "] ")
		MsgC(Skid.RED, v:Nick() )
		MsgC(Skid.GREY, " (")
		MsgC(Skid.GREEN, v:SteamID() )
		MsgC(Skid.GREY, ")")
		MsgC(Skid.GREY, " <")
		MsgC(Skid.RED, Reason)
		MsgC(Skid.GREY, "> ")
		MsgC(Skid.GREY, "is on the ")
		MsgC(Skid.ORANGE, "HAC database\n\n")
		
		if not server_only then
			//Tell clients
			net.Start("Skid.Msg")
				net.WriteEntity(v)
				net.WriteString(Reason)
				
			//Send to everyone BUT cheater
			if Skid.sk_omit:GetBool() then
				net.SendOmit(v)
			else
				//Admins
				if Skid.sk_admin:GetBool() and #Admins > 0 then
					net.Send(Admins) --Don't send if no admins and sk_admin is 1, OTHERWISE WILL SEND TO EVERYONE.
				else
					//Everyone
					net.Broadcast()
				end
			end
		end
	end
end

function Skid.Command()
	Skid.Check()
end
concommand.Add("sk", Skid.Command)

//Spawn
function Skid.Spawn(self)
	//Server
	Skid.Check(true)
	
	//Clients
	timer.Simple(Skid.WaitFor, function()
		Skid.Check()
	end)
end
hook.Add("PlayerInitialSpawn", "Skid.Spawn", Skid.Spawn)



//Auth check
function Skid.CheckPassword(SID64, ipaddr, sv_pass, pass, user)
	//Invalid
	local SID = util.SteamIDFrom64(SID64)
	if not SID or SID == "" then
		return false, "Invalid SteamID"
	end
	
	//Lookup
	local Reason = Skid.HAC_DB[ SID ]
	if not Reason then return end
	
	//Log
	file.Append("sk_connect.txt", Format("\r\n[%s]: %s (%s) - %s", os.date(), user, SID, Reason) )
	
	//Message
	MsgC(Skid.GREY, "\n[")
	MsgC(Skid.WHITE2, "Skid")
	MsgC(Skid.BLUE, "Check")
	MsgC(Skid.ORANGE, "Connect")
	MsgC(Skid.GREY, "] ")
	MsgC(Skid.RED, user)
	MsgC(Skid.GREY, " (")
	MsgC(Skid.GREEN, SID)
	MsgC(Skid.GREY, ")")
	MsgC(Skid.GREY, " <")
	MsgC(Skid.RED, Reason)
	MsgC(Skid.GREY, ">")
	
	//Block if enabled
	if Skid.sk_kick:GetBool() then
		return false, "[SkidCheck] You're on the naughty list: "..SID.."\n<"..Reason..">"
	end
end
hook.Add("CheckPassword", "Skid.CheckPassword", Skid.CheckPassword)



//List sync from GitHub
Skid.CanSync = ""
if Skid.sk_sync:GetBool() then
	Skid.CanSync = " (Will sync on map change)"
	
	include("sk_Sync.lua")
end

//Loaded
function Skid.Ready()
	MsgC(Skid.GREY, 	"\n[")
	MsgC(Skid.WHITE2, 	"Skid")
	MsgC(Skid.BLUE, 	"Check")
	MsgC(Skid.GREY, 	"] ")
	MsgC(Skid.GREEN, 	"Ready. ")
	MsgC(Skid.RED,		 tostring( table.Count(Skid.HAC_DB) ):Comma() )
	MsgC(Skid.GREEN, 	" bad players in local lists!"..Skid.CanSync.."\n\n")
end
timer.Simple(1, Skid.Ready)





--[[
	Falco, it's up to server owners to choose who joins their server (and whether or not to run this addon)
	
	SkidCheck is the list of people who I don't want playing on my server. Not "malicious code".
	It was originally the HAC database, and was released here for anyone to use for any reason. Not to cause drama.
	
	I'm not going to bypass your disabling of SkidCheck in DarkRP, all that will now happen is the following messages.
]]
local Check = Skid.Check
timer.Simple(6, function()
	if Skid.Check == Check then return end
	
	MsgC(Skid.GREY, 	"\n\n  [")
	MsgC(Skid.WHITE2, 	"Skid")
	MsgC(Skid.BLUE, 	"Check")
	MsgC(Skid.GREY, 	"] ")
	MsgC(Skid.RED, 		"Disabled due to DarkRP update.\n\n")
	
	MsgC(Skid.BLUE, 	"  SkidCheck is now ")
	MsgC(Skid.PINK, 	"no longer protecting ")
	MsgC(Skid.BLUE, 	"this server.\n")
	
	MsgC(Skid.BLUE, 	"  Falco has chosen to disable SkidCheck in current versions of DarkRP.\n")
	MsgC(Skid.BLUE, 	"  Please delete this addon.\n\n")
	
	MsgC(Skid.BLUE, 	"  If you want to continue to use SkidCheck, ")
	MsgC(Skid.RED, 		"blame falco.\n\n")
end)













