local SettingsEnums = require(game.ReplicatedStorage.Data.Enums.SettingsEnums)

local RequestSettingChange = game.ReplicatedStorage.Remotes.DataRemotes.RequestSettingChange

local Shadows = {}

function Shadows:On()
	for _, Part in workspace:GetDescendants() do
		local CanCastShadow = pcall(function()
			local CastingShadow = Part.CastShadow
		end)

		if not CanCastShadow then
			continue
		end
		
		Part["CastShadow"] = true
	end
	
	RequestSettingChange:FireServer(SettingsEnums.Shadows, true)
end

function Shadows:Off()
	for _, Part in workspace:GetDescendants() do
		local CanCastShadow = pcall(function()
			local CastingShadow = Part.CastShadow
		end)
		
		if not CanCastShadow then
			continue
		end
		
		Part["CastShadow"] = false
	end
	
	RequestSettingChange:FireServer(SettingsEnums.Shadows, false)
end

return Shadows