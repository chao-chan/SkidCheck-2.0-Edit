/*
	=== SkidCheck - 2.0 ===
	--By HeX
*/

include("sh_SK.lua")
include("sv_SkidList.lua")
AddCSLuaFile("sh_SK.lua")
AddCSLuaFile("autorun/client/cl_SK.lua")

util.AddNetworkString("Skid.Msg")

Skid.WaitFor = 25 --Seconds to wait before message
Skid.sk_kick = CreateConVar("sk_kick", 0, FCVAR_ARCHIVE, "Prevent players on the HAC DB from joining")


//Check
function Skid.Check(server_only)
	for k,v in pairs( player.GetHumans() ) do
		local Reason = Skid.HAC_DB[ v:SteamID() ]
		if not Reason then continue end
		
		//Hook
		if hook.Run("OnSkid", v, Reason, (not server_only) ) then return end
		
		//Log
		local Log = Format("\r\n[%s]: %s (%s) - %s", os.date(), v:Nick(), v:SteamID(), Reason)
		file.Append("sk_encounters.txt", Log)
		
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
			net.Broadcast()
			
			//Sound
			for k,v in pairs( player.GetHumans() ) do
				v:EmitSound("ambient/machines/thumper_shutdown1.wav")
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
	
	//Message
	MsgC(Skid.GREY, "\n[")
	MsgC(Skid.WHITE2, "Skid")
	MsgC(Skid.BLUE, "Check-")
	MsgC(Skid.ORANGE, "Connect")
	MsgC(Skid.GREY, "] ")
	MsgC(Skid.RED, user)
	MsgC(Skid.GREY, " (")
	MsgC(Skid.GREEN, SID)
	MsgC(Skid.GREY, ")")
	MsgC(Skid.GREY, " <")
	MsgC(Skid.RED, Reason)
	MsgC(Skid.GREY, ">")
	
	//Log
	local Log = Format("\r\n[%s]: %s (%s) - %s", os.date(), user, SID, Reason)
	file.Append("sk_blocked.txt", Log)
	
	//Block if enabled
	if Skid.sk_kick:GetBool() then
		return false, "[SkidCheck] Connection blocked. <"..Reason..">"
	end
end
hook.Add("CheckPassword", "Skid.CheckPassword", Skid.CheckPassword)


MsgC(Skid.GREEN, "[SkidCheck] Loaded. Will notify of ")
MsgC(Skid.RED, tostring( table.Count(Skid.HAC_DB) ) )
MsgC(Skid.GREEN, " skiddies!\n")















