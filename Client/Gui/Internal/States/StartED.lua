-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules --
local TweenFactory = require("../TweenFactory")
local CharacterButton = require("../Wrappers/CharacterButton")
local TransitionButton = require("../Wrappers/TransitionButton")
local LocationButton = require("../Wrappers/LocationButton")
local WarningButton = require("../Wrappers/WarningButton")
local SkinButton = require("../Wrappers/SkinButton")
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
local DinosaurSpawn = MainMenu.DinosaurSpawn
local BlackScreen = MainMenu.BlackScreen

local CharacterConfigs = ReplicatedStorage.Data.Configs.CharacterConfigs

local SpawnRequest = ReplicatedStorage.Remotes.MenuRemotes.SpawnRequest

local Start = setmetatable({}, BaseState)
Start.__index = Start

function Start.new(Parent, Dependencies, Shared)
	-- nil is enum
	local self: GuiTypes.State = BaseState.new(GuiEnums.States.StartED, Parent, Dependencies, Shared)
	setmetatable(self, Start)
	
	DinosaurSpawn.Locations.Player.Text = (LocalPlayer.Name:gsub("^%l", string.upper))
	
	return self
end

function Start:HandleInput(Input: string | InputObject | Enum.HumanoidStateType)

end

function Start:Update(DeltaTime: number)

end

function Start:Enter(OldState: GuiTypes.State)
	local self: GuiTypes.State = self
	local Shared = self.Shared
	local Parent = self.Parent
	DinosaurSpawn.Parent = LocalPlayer.PlayerGui
	
	self.Janitor = Janitor.new()

	local FadeToTransparent = TweenFactory:CreateTween(BlackScreen.Frame, GuiConfig.Tweens.FadeToTransparent)
	FadeToTransparent:Play()
	
	local ContinueButtonCallbacks = {}
	function ContinueButtonCallbacks:OnActivated()
		if not Shared.Spawn then
			for _, GuiObject in DinosaurSpawn.Warning:GetChildren() do
				GuiObject.Visible = true
			end

			task.spawn(function()
				task.wait(3)
				for _, GuiObject in DinosaurSpawn.Warning:GetChildren() do
					GuiObject.Visible = false
				end
			end)

			return
		end

		Parent:SetState(GuiEnums.States.Inactive)
		SpawnRequest:FireServer(Shared.CharacterConfig.Id)
	end

	local SpawnButton = TransitionButton.new(DinosaurSpawn.Spawn, ContinueButtonCallbacks)
	self.Janitor:Add(SpawnButton, "TransitionButtonDestroy")
	
	local BackButtonCallbacks = {}
	function BackButtonCallbacks:OnActivated()
		Parent:SetState(GuiEnums.States.SelectED)
	end
	local BackButton = TransitionButton.new(DinosaurSpawn.Back, BackButtonCallbacks)
	self.Janitor:Add(BackButton, "TransitionButtonDestroy")
	
	local WarningButtonConfig = {
		Button = DinosaurSpawn.Warning.WarningButton,
		Screen = DinosaurSpawn,
		Callbacks = {}
	}
	self.Janitor:Add(WarningButton.new(WarningButtonConfig, self.Shared), "WarningButtonDestroy")

	for _, GuiObject in DinosaurSpawn.Locations:GetChildren() do
		if not GuiObject:IsA("ImageButton") then
			continue
		end
		
		local LocationConfig = {
			Button = GuiObject,
			Callbacks = {},
			Screen = DinosaurSpawn
		}
		
		self.Janitor:Add(LocationButton.new(LocationConfig, self.Shared), "LocationButtonDestroy")
	end
	
	DinosaurSpawn.Locations.DinoName.Text = "Name: "..self.Shared.CharacterConfig.Id
	DinosaurSpawn.Locations.Skin.Text = "Skin: "..self.Shared.CharacterConfig.Skins[1].Id
	DinosaurSpawn.Locations.Class.Text = "Class: "..self.Shared.CharacterConfig.Class
	return true
end

function Start:Exit(NewState: GuiTypes.State)
	local self: GuiTypes.State = self
	
	local FadeToOpaque = TweenFactory:CreateTween(BlackScreen.Frame, GuiConfig.Tweens.FadeToOpaque)
	FadeToOpaque:Play()
	
	self.Janitor:Cleanup()
	
	FadeToOpaque.Completed:Wait()
	
	DinosaurSpawn.Parent = game.ReplicatedStorage.Assets.Gui.MainMenu
	return true
end

return Start
