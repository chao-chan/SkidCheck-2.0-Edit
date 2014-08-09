/*
	=== SkidCheck - 2.0 ===
	--By HeX
*/

include("sh_SK.lua")

//Message
function Skid.Msg()
	local self 	 = net.ReadEntity()
	local Reason = net.ReadString()
	
	//Message
	chat.AddText(
		Skid.GREY, "[",
		Skid.WHITE, "Skid",
		Skid.BLUE, "Check",
		Skid.GREY, "] ",
		(self.Team and team.GetColor( self:Team() ) or Skid.RED), self:Nick(),
		Skid.GREY, " (",
		Skid.GREEN, self:SteamID(),
		Skid.GREY, ")",
		Skid.GREY, " <",
		Skid.RED, Reason,
		Skid.GREY, "> ",
		Skid.GREY, "is a ",
		Skid.PINK, "KNOWN CHEATER"
	)
	
	
	//Log
	if self == LocalPlayer() then return end
	local Log = Format(
		"\r\n[%s]: %s - %s (%s) - %s",
		os.date(), GetHostName(), self:Nick(), self:SteamID(), Reason
	)
	file.Append("cl_sk_encounters.txt", Log)
end
net.Receive("Skid.Msg", Skid.Msg)



















