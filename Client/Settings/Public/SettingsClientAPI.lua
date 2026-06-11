local Settings = script.Parent.Parent.Internal.SettingsModules

local SettingsClientAPI = {}

function SettingsClientAPI:Init(Shared, Dependencies)
	self.Shared = Shared
	self.Dependencies = Dependencies
end

function SettingsClientAPI:SetSetting(SettingId, Value)
	if Value then
		require(Settings[SettingId]):On()
	elseif not Value then
		require(Settings[SettingId]):Off()
	end
end

return SettingsClientAPI