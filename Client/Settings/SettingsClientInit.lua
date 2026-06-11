local SettingsClientAPI = require("./Public/SettingsClientAPI")
local PlayerState = require(game.ReplicatedStorage.Modules.PlayerState.PlayerStateClient)

local RequestSettings = game.ReplicatedStorage.Remotes.DataRemotes.RequestSettingsData
local RequestSettingChange = game.ReplicatedStorage.Remotes.DataRemotes.RequestSettingChange


local Shared = {}
local Dependencies = {
	RequestSettings = RequestSettings,
	RequestSettingChange = RequestSettingChange,
	PlayerState = PlayerState
}

SettingsClientAPI:Init(Shared, Dependencies)