-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules --
local TweenFactory = require("../TweenFactory")
local TransitionButton = require("../Wrappers/TransitionButton")
local LocationButton = require("../Wrappers/LocationButton")
local WarningButton = require("../Wrappers/WarningButton")
local MouseEvents = require("../../../Modules/MouseEvents")
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local BaseState = require(ReplicatedStorage.Modules.StateMachineService.BaseState)
local GuiEnums = require(ReplicatedStorage.Data.Enums.GuiEnums)
local GuiTypes = require(ReplicatedStorage.Data.Types.GuiTypes)
local GuiConfig = require(ReplicatedStorage.Data.Configs.GuiConfig)

-- References --
local LocalPlayer = Players.LocalPlayer

local MainMenuSounds = ReplicatedStorage.Assets.Sounds.MainMenu
local MainMenu = ReplicatedStorage.Assets.Gui.MainMenu
local HumanSpawn = MainMenu.HumanSpawn
local BlackScreen = MainMenu.BlackScreen

local CharacterConfigs = ReplicatedStorage.Data.Configs.CharacterConfigs

local SpawnRequest = ReplicatedStorage.Remotes.MenuRemotes.SpawnRequest

local StartEH = setmetatable({}, BaseState)
StartEH.__index = StartEH

function StartEH.new(Parent, Dependencies, Shared)
	-- nil is enum
	local self: GuiTypes.State = BaseState.new(GuiEnums.States.StartEH, Parent, Dependencies, Shared)
	setmetatable(self, StartEH)

	HumanSpawn.Locations.Player.Text = (LocalPlayer.Name:gsub("^%l", string.upper))

	return self
end

function StartEH:HandleInput(Input: string | InputObject | Enum.HumanoidStateType)
	local self: GuiTypes.State = self

end

function StartEH:Update(DeltaTime: number)
	local self: GuiTypes.State = self
end

function StartEH:Enter(OldState: GuiTypes.State)
	local self: GuiTypes.State = self
	
	local Shared = self.Shared
	local Parent = self.Parent
	HumanSpawn.Parent = LocalPlayer.PlayerGui

	self.Janitor = Janitor.new()

	local FadeToTransparent = TweenFactory:CreateTween(BlackScreen.Frame, GuiConfig.Tweens.FadeToTransparent)
	FadeToTransparent:Play()

	local ContinueButtonCallbacks = {}
	function ContinueButtonCallbacks:OnActivated()
		if not Shared.Spawn then
			for _, GuiObject in HumanSpawn.Warning:GetChildren() do
				GuiObject.Visible = true
			end

			task.spawn(function()
				task.wait(3)
				for _, GuiObject in HumanSpawn.Warning:GetChildren() do
					GuiObject.Visible = false
				end
			end)

			return
		end

		Parent:SetState(GuiEnums.States.Inactive)
		SpawnRequest:FireServer(Shared.CharacterConfig.Id)
	end

	local SpawnButton = TransitionButton.new(HumanSpawn.Spawn, ContinueButtonCallbacks)
	self.Janitor:Add(SpawnButton, "TransitionButtonDestroy")

	local BackButtonCallbacks = {}
	function BackButtonCallbacks:OnActivated()
		Parent:SetState(GuiEnums.States.SelectTeam)
	end
	local BackButton = TransitionButton.new(HumanSpawn.Back, BackButtonCallbacks)
	self.Janitor:Add(BackButton, "TransitionButtonDestroy")

	local WarningButtonConfig = {
		Button = HumanSpawn.Warning.WarningButton,
		Screen = HumanSpawn,
		Callbacks = {}
	}
	self.Janitor:Add(WarningButton.new(WarningButtonConfig, self.Shared), "WarningButtonDestroy")

	for _, GuiObject in HumanSpawn.Locations:GetChildren() do
		if not GuiObject:IsA("ImageButton") then
			continue
		end

		local LocationConfig = {
			Button = GuiObject,
			Callbacks = {},
			Screen = HumanSpawn
		}

		self.Janitor:Add(LocationButton.new(LocationConfig, self.Shared), "LocationButtonDestroy")
	end

	-- Set tools sometime --
	return true
end

function StartEH:Exit(NewState: GuiTypes.State)
	local self: GuiTypes.State = self
	
	local FadeToOpaque = TweenFactory:CreateTween(BlackScreen.Frame, GuiConfig.Tweens.FadeToOpaque)
	FadeToOpaque:Play()
	
	self.Janitor:Cleanup()
	
	FadeToOpaque.Completed:Wait()

	HumanSpawn.Parent = game.ReplicatedStorage.Assets.Gui.MainMenu

	return true
end

return StartEH
