/*
	=== SkidCheck - 2.0 ===
	--By HeX
*/

include("sh_SK.lua")
AddCSLuaFile("sh_SK.lua")
AddCSLuaFile("autorun/client/cl_SK.lua")

util.AddNetworkString("Skid.Msg")

Skid.sk_kick	= CreateConVar("sk_kick", 0, FCVAR_ARCHIVE, "Prevent players on the HAC DB from joining")
Skid.WaitFor	= 25 --Seconds to wait before message
Skid.URL		= "http://unitedhosts.org/bar/tmp/hac_db_all.json"
Skid.DB_File	= "hac_db_all.txt"
Skid.HAC_DB		= {}


//Update
local function Error(code)
	//This
	code = "\n[SkidCheck] "..code.."\n"
	MsgC(Skid.RED, code)
	
	//Check file
	local Cont 	= file.Read(Skid.DB_File, "DATA")
	local Col	= Skid.RED
	if isstring(Cont) and #Cont > 5000 then
		//Use local backup
		code 		 = "\n[SkidCheck] Using local backup\n"
		Col 		 = Skid.PINK
		Skid.DB_File = util.JSONToTable(Cont)
		
		MsgC(Col, code)
		MsgC(Skid.GREEN, "[SkidCheck] Could not update, but will check "..table.Count(Skid.DB_File).." skiddies!\n")
	else
		//Fail
		code = "\n[SkidCheck] Can't use local backup, try again or contact HeX\n"
		MsgC(Col, code)
	end
end

function Skid.UpdateDB()
	MsgC(Skid.BLUE, "[SkidCheck] Updating SkidCheck database..\n")
	
	http.Fetch(Skid.URL,
		//Ok
		function(body,len,head,code)
			//Decode
			local New = util.JSONToTable(body)
			if not istable(New) or table.Count(New) == 0 then
				Error("JSON decoding error")
				return
			end
			
			//Write backup
			file.Write(Skid.DB_File, body)
			Skid.HAC_DB = New
			
			MsgC(Skid.GREEN, "[SkidCheck] Updated. Will notify of "..table.Count(New).." skiddies!\n")
		end,
		
		//Fail
		function(code)
			Error("HTTP Error "..code)
		end
	)
end
timer.Simple(1, function()
	MsgC(Skid.PINK, "[SkidCheck] Loaded. Will update database in 8 seconds\n")
	timer.Simple(8, Skid.UpdateDB)
end)


//Check
function Skid.Check(self)
	for k,v in pairs( player.GetHumans() ) do
		local Reason = Skid.HAC_DB[ v:SteamID() ]
		if not Reason then continue end
		
		//Log
		local Log = Format("\r\n[%s]: %s (%s) - %s", os.date(), v:Nick(), v:SteamID(), Reason)
		file.Append("sk_encounters.txt", Log)
		
		//Tell server
		MsgC(Skid.BLUE, "\n[SkidCheck] ")
		MsgC(Skid.GREY, v:Nick().." ("..v:SteamID()..")")
		MsgC(Skid.BLUE, " is a on the HAC database for: ")
		MsgC(Skid.RED, 	Reason.."\n\n")
		
		//Tell clients
		net.Start("Skid.Msg")
			net.WriteEntity(v)
			net.WriteString(Reason)
		net.Broadcast()
		
		//Sound
		for k,v in pairs( player.GetHumans() ) do
			v:EmitSound("ambient/machines/thumper_shutdown1.wav")
		end
		
		//Hook
		if not v.Skid_DoneHook then
			v.Skid_DoneHook = true
			hook.Run("OnSkid", v, Reason)
		end
	end
end

//Manual
function Skid.ReCheck(self,cmd,args)
	if IsValid(self) and not self:IsAdmin() then return end
	
	//Force reload
	if args[1] == "f" then
		Skid.UpdateDB()
		
		timer.Simple(5,Skid.Check)
		return
	end
	
	//Check
	Skid.Check()
end
concommand.Add("sk", Skid.ReCheck)

//Spawn
function Skid.Spawn(self)
	timer.Simple(Skid.WaitFor, function()
		Skid.Check()
	end)
end
hook.Add("PlayerInitialSpawn", "Skid.Spawn", Skid.Spawn)



//Auth check
function Skid.CheckPassword(SID64, ipaddr, sv_pass, pass, user)
	if not Skid.sk_kick:GetBool() then return end
	
	//Invalid
	local SID = util.SteamIDFrom64(SID64)
	if not (SID and SID != "") then
		return false, "Invalid SteamID"
	end
	
	//Lookup
	local Reason = Skid.HAC_DB[ SID ]
	if not Reason then return end
	
	//Log
	local Log = Format("\r\n[%s]: %s (%s) - %s", os.date(), user, SID, Reason)
	file.Append("sk_blocked.txt", Log)
	
	//Message
	MsgC(Skid.RED, "\n[SkidCheck] ")
	MsgC(Skid.GREY, user.." ("..SID..")")
	MsgC(Skid.BLUE, " has been blocked from joining due to: ")
	MsgC(Skid.RED, 	Reason.."\n\n")
	
	return false, "[SkidCheck] Connection blocked. <"..Reason..">"
end
hook.Add("CheckPassword", "Skid.CheckPassword", Skid.CheckPassword)

















