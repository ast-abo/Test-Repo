local SettingsEnums = require(game.ReplicatedStorage.Data.Enums.SettingsEnums)

local RequestSettingChange = game.ReplicatedStorage.Remotes.DataRemotes.RequestSettingChange

local Music = {}

function Music:On()
	
	RequestSettingChange:FireServer(SettingsEnums.Music, true)
	-- set music obj on
end

function Music:Off()
	-- set music obj off
	RequestSettingChange:FireServer(SettingsEnums.Music, true)
end

return Music