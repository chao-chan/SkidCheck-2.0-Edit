/*
	=== SkidCheck - 3.2 ===
	Update module idea & some code by GGG KILLER
*/

Skid.Sync = {
	//List of files to download
	Index 			= {},

	//Run the list files here
	HAC 			= {
		Skiddies	= {},
	},

	table 			= {
		MergeEx 	= table.MergeEx,
	},
}



//Messages
local function MsgN(str, err)
	MsgC(Skid.GREY, 	"[")
	MsgC(Skid.WHITE2, 	"Skid")
	MsgC(Skid.BLUE, 	"Check")
	MsgC(Skid.PINK, 	"Sync")
	MsgC(Skid.GREY, 	"] ")
	if err then
		MsgC(Skid.RED,	"ERROR: ")
	end
	MsgC(Skid.ORANGE, 	str.."\n")
end

local function Error(str)
	MsgN(str, true)
end


//Selector
local selector = {}
selector.__index = selector

function selector:Select()
	local Idx  	= nil
	local This 	= nil
	for k,v in pairs(self.Tab) do
		Idx  = k
		This = v

		self._Upto = self._Upto + 1
		break
	end

	if Idx then
		self.Tab[ Idx ] = nil
		self.OnSelect(self, This)
	end

	if self._Upto == self._Size then
		self.Tab = nil
		self	 = nil
	end
end



//Download this list
function Skid.Sync.Download(self, v)
	MsgN("Downloading list "..self._Upto.."/"..self._Size)

	local Name = v.Name

	http.Fetch(v.URL, function(body)
		//body
		if not ( isstring(body) and #body > 9 ) then
			Error("GitHub download body error (Got "..tostring(body)..")")
			return
		end


		//Compile
		local List = CompileString(body, Name)
		if not List then
			Error("GitHub download, Can't compile "..Name)
			return
		end

		//Call
		setfenv(List, Skid.Sync)
		local ret,err = pcall(List)
		if err or not ret then
			Error("GitHub download, Can't load "..Name..": ["..tostring(err).."]\n")
			return
		end


		//Select next
		timer.Simple(1, function()
			//Finish
			if self._Upto == self._Size then
				//Too small
				local Size = table.Count(Skid.Sync.HAC.Skiddies)
				if Size < 48000 then
					Error("GitHub download, List size mismatch! (Only got "..tostring(Size):Comma()..", way less than local lists!)")
					return
				end

				//Override local lists
				local New				= table.Count(Skid.Sync.HAC.Skiddies)
				local Old				= table.Count(Skid.HAC_DB)
				Skid.HAC_DB 			= Skid.Sync.HAC.Skiddies
				Skid.Sync.HAC.Skiddies 	= {}

				local Diff	= New - Old
				local sDiff	= tostring(Diff):Comma()
				MsgN("Download complete, lists up to date."..(Diff > 0 and " "..sDiff.." new IDs :)" or "") )

				if Diff > 500 then
					MsgN("\n\nLocal lists differ by more than "..sDiff.." IDs.\nRe-download the addon from GitHub to be sure of updates!\n")
				end

				Skid.CanSync = " Sync complete :)"
				Skid.Ready()
			else
				self:Select()
			end
		end)

	end, function(err)
		Error("GitHub download error "..(err == "unsuccessful" and "http.Fetch not functioning, blame Garry" or err)..")")
	end)
end



//Download index
function Skid.Sync.GetIndex()
	MsgN("GitHub download, getting index..")

	local Index = {}

	http.Fetch("https://api.github.com/repositories/22792657/contents/lua/SkidCheck", function(body)
		//body
		if not ( isstring(body) and #body > 9 ) then
			Error("GitHub body error (Got "..tostring(body)..")")
			return
		end

		//JSON
		body = util.JSONToTable(body)
		if not ( istable(body) and #body >= 9 ) then
			Error("GitHub JSON decode error (Got "..type(body)..")")
			return
		end


		//Files
		for k,v in pairs(body) do
			if not v.name then continue end

			if v.name:StartWith("sv_SkidList") then
				table.insert(Index,
					{
						URL		= v.download_url,
						Name 	= v.name,
					}
				)
			end
		end
		//Sort
		table.sort(Index, function(k,v)
			return v.Name < k.Name
		end)

		//Make sure they're all there
		local Have	= #Skid.Lists
		local Got	= #Index
		if Got < Have then
			Error("GitHub list count error (Got "..Got..", Have "..Have..")")
			return
		end

		//Start the download
		local This = setmetatable(
			{
				OnSelect	= Skid.Sync.Download,
				Tab			= Index,
				_Size		= #Index,
				_Upto		= 0,
			},
			selector
		)

		//Go!
		This:Select()

	end, function(err)
		Error("GitHub GetIndex error "..(err == "unsuccessful" and "http.Fetch not functioning, blame Garry" or err)..")")
	end)
end


//Slight delay, to wait for everything to become ready
timer.Simple(3, Skid.Sync.GetIndex)

//Update every 6 hours
timer.Create("Skid.Sync.GetIndex", (Skid.sk_sync:GetInt() * 60 * 60), 0, Skid.Sync.GetIndex)

//Manual sync
function Skid.Sync.Command()
	Skid.Sync.GetIndex()
end
concommand.Add("sk_update", Skid.Sync.Command)
