-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules --
local TransitionButton = require("../Wrappers/TransitionButton")
local TweenFactory = require("../TweenFactory")
local SettingsAPI = require("../../../Settings/Public/SettingsClientAPI")
local MouseEvents = require("../../../Modules/MouseEvents")
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local BaseState = require(ReplicatedStorage.Modules.StateMachineService.BaseState)
local GuiEnums = require(ReplicatedStorage.Data.Enums.GuiEnums)
local GuiTypes = require(ReplicatedStorage.Data.Types.GuiTypes)
local GuiConfig = require(ReplicatedStorage.Data.Configs.GuiConfig)

-- References --
local LocalPlayer = Players.LocalPlayer

local MainMenu = ReplicatedStorage.Assets.Gui.MainMenu
local MainMenuSounds = ReplicatedStorage.Assets.Sounds.MainMenu
local SettingsScreen = MainMenu.SettingsScreen
local BlackScreen = MainMenu.BlackScreen

local RequestSettingsData = ReplicatedStorage.Remotes.DataRemotes.RequestSettingsData

local Settings = setmetatable({}, BaseState)
Settings.__index = Settings

function Settings.new(Parent, Dependencies, Shared)
	-- nil is enum
	local self: GuiTypes.State = BaseState.new(GuiEnums.States.Settings, Parent, Dependencies, Shared)
	setmetatable(self, Settings)
	
	local SettingsData = RequestSettingsData:InvokeServer()
	
	for SettingId, SettingValue in SettingsData do
		SettingsAPI:SetSetting(SettingId, SettingValue)
		
		local OnTween
		local OffTween
		
		if SettingValue then
			OnTween = TweenFactory:CreateTween(SettingsScreen.Settings[SettingId].Off, GuiConfig.Tweens.RedTextUnhighlight)
			OffTween = TweenFactory:CreateTween(SettingsScreen.Settings[SettingId].On, GuiConfig.Tweens.GreenTextHighlight)
		elseif not SettingValue then
			OnTween = TweenFactory:CreateTween(SettingsScreen.Settings[SettingId].Off, GuiConfig.Tweens.RedTextHighlight)
			OffTween = TweenFactory:CreateTween(SettingsScreen.Settings[SettingId].On, GuiConfig.Tweens.GreenTextUnhighlight)
		end
		
		OnTween:Play()
		OffTween:Play()
	end
	
	return self
end

function Settings:HandleInput(Input: string | InputObject | Enum.HumanoidStateType)
	local self: GuiTypes.State = self
end

function Settings:Update(DeltaTime: number)
	local self: GuiTypes.State = self
end

function Settings:Enter(OldState: GuiTypes.State)
	local self: GuiTypes.State = self
	SettingsScreen.Parent = LocalPlayer.PlayerGui
	
	self.Janitor = Janitor.new()
	
	local FadeToTransparent = TweenFactory:CreateTween(BlackScreen.Frame, GuiConfig.Tweens.FadeToTransparent)
	FadeToTransparent:Play()
	
	local Parent = self.Parent
	local BackButtonCallbacks = {}
	function BackButtonCallbacks:OnActivated()
		Parent:SetState(GuiEnums.States.Home)
	end
	local BackButton = TransitionButton.new(SettingsScreen.Back,  BackButtonCallbacks)
	self.Janitor:Add(BackButton, "TransitionButtonDestroy")
	
	-- No wrapper because settingsbuttons are only used in this state
	for _, Setting in SettingsScreen.Settings:GetChildren() do
		local SettingId = Setting.Name
		
		local SettingEnter, SettingLeave = MouseEvents.new(Setting.Background)
		
		self.Janitor:Add(SettingEnter, "Destroy")
		self.Janitor:Add(SettingLeave, "Destroy")
		
		SettingEnter:Connect(function()
			game:GetService("SoundService"):PlayLocalSound(MainMenuSounds.Button_Hover)
			TweenFactory:CreateTween(Setting.Label, GuiConfig.Tweens.TextHighlight):Play()
			TweenFactory:CreateTween(Setting.Slash, GuiConfig.Tweens.TextHighlight):Play()
			TweenFactory:CreateTween(Setting.Highlight, GuiConfig.Tweens.IconExpand):Play()
		end)
		
		SettingLeave:Connect(function()
			TweenFactory:CreateTween(Setting.Label, GuiConfig.Tweens.TextUnhighlight):Play()
			TweenFactory:CreateTween(Setting.Slash, GuiConfig.Tweens.TextUnhighlight):Play()
			TweenFactory:CreateTween(Setting.Highlight, GuiConfig.Tweens.IconShrink):Play()
		end)
		

		self.Janitor:Add(Setting.On.Activated:Connect(function()
			SettingsAPI:SetSetting(SettingId, true)
			MainMenuSounds.Button_Confirm:Play()
			
			local OnTween = TweenFactory:CreateTween(Setting.Off, GuiConfig.Tweens.RedTextUnhighlight)
			local OffTween = TweenFactory:CreateTween(Setting.On, GuiConfig.Tweens.GreenTextHighlight)
			OnTween:Play()
			OffTween:Play()
		end), "Disconnect")
		
		self.Janitor:Add(Setting.Off.Activated:Connect(function()
			SettingsAPI:SetSetting(SettingId, false)
			MainMenuSounds.Button_Confirm:Play()

			local OnTween = TweenFactory:CreateTween(Setting.Off, GuiConfig.Tweens.RedTextHighlight)
			local OffTween = TweenFactory:CreateTween(Setting.On, GuiConfig.Tweens.GreenTextUnhighlight)
			OnTween:Play()
			OffTween:Play()
		end), "Disconnect")
	end
	
	return true
end

function Settings:Exit(NewState: GuiTypes.State)
	local self: GuiTypes.State = self

	local FadeToOpaque = TweenFactory:CreateTween(BlackScreen.Frame, GuiConfig.Tweens.FadeToOpaque)
	FadeToOpaque:Play()
	
	self.Janitor:Cleanup()
	FadeToOpaque.Completed:Wait()
	
	SettingsScreen.Parent = game.ReplicatedStorage.Assets.Gui.MainMenu
	return true
end

return Settings
