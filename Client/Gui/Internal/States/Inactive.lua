-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules --
local TweenFactory = require("../TweenFactory")
local CameraEffectsService = require("../../../Modules/CameraEffectsService")
local BaseState = require(ReplicatedStorage.Modules.StateMachineService.BaseState)
local GuiEnums = require(ReplicatedStorage.Data.Enums.GuiEnums)
local GuiTypes = require(ReplicatedStorage.Data.Types.GuiTypes)
local GuiConfig = require(ReplicatedStorage.Data.Configs.GuiConfig)

-- References --
local LocalPlayer = Players.LocalPlayer

local MainMenu = ReplicatedStorage.Assets.Gui.MainMenu
local BlackScreen = MainMenu.BlackScreen

-- State --
local CameraEffects = CameraEffectsService.getInstance()

local Inactive = setmetatable({}, BaseState)
Inactive.__index = Inactive

function Inactive.new(Parent, Dependencies, Shared)
	-- nil is enum
	local self: GuiTypes.State = BaseState.new(GuiEnums.States.Inactive, Parent, Dependencies, Shared)
	setmetatable(self, Inactive)

	return self
end

function Inactive:HandleInput(Input: string | InputObject | Enum.HumanoidStateType)
	local self: GuiTypes.State = self
	
end

function Inactive:Update(DeltaTime: number)
	local self: GuiTypes.State = self
end

function Inactive:Enter(OldState: GuiTypes.State)
	local self: GuiTypes.State = self
	
	CameraEffects:DisableTiltToMouse()
	CameraEffects.Subject = LocalPlayer.Character.CameraPart
	CameraEffects:SetCameraToCharacter()
	
	local DinoSystem = game.ReplicatedStorage.Assets.Systems.DinosaurSystem:Clone()
	DinoSystem.Parent = LocalPlayer.PlayerScripts
	
	local FadeToTransparent = TweenFactory:CreateTween(BlackScreen.Frame, GuiConfig.Tweens.FadeToTransparent)
	FadeToTransparent:Play()
	
	return true
end

function Inactive:Exit(NewState: GuiTypes.State)
	local self: GuiTypes.State = self
	return true
end

return Inactive
