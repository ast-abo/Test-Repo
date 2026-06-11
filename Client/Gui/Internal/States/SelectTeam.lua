-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules --
local ScreenButton = require("../Wrappers/ScreenButton")
local TransitionButton = require("../Wrappers/TransitionButton")
local TweenFactory = require("../TweenFactory")
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local BaseState = require(ReplicatedStorage.Modules.StateMachineService.BaseState)
local GuiEnums = require(ReplicatedStorage.Data.Enums.GuiEnums)
local GuiTypes = require(ReplicatedStorage.Data.Types.GuiTypes)
local GuiConfig = require(ReplicatedStorage.Data.Configs.GuiConfig)

-- References --
local LocalPlayer = Players.LocalPlayer

local MainMenu = ReplicatedStorage.Assets.Gui.MainMenu
local SelectTeamScreen = MainMenu.TeamScreen
local BlackScreen = MainMenu.BlackScreen

-- State --

local SelectTeam = setmetatable({}, BaseState)
SelectTeam.__index = SelectTeam

function SelectTeam.new(Parent, Dependencies, Shared)
	-- nil is enum
	local self: GuiTypes.State = BaseState.new(GuiEnums.States.SelectTeam, Parent, Dependencies, Shared)
	setmetatable(self, SelectTeam)
	
	return self
end

function SelectTeam:HandleInput(Input: string | InputObject | Enum.HumanoidStateType)
	local self: GuiTypes.State = self
end

function SelectTeam:Update(DeltaTime: number)
	local self: GuiTypes.State = self
end

function SelectTeam:Enter(OldState: GuiTypes.State)
	local self: GuiTypes.State = self
	SelectTeamScreen.Parent = LocalPlayer.PlayerGui
	
	self.Janitor = Janitor.new()

	local FadeToTransparent = TweenFactory:CreateTween(BlackScreen.Frame, GuiConfig.Tweens.FadeToTransparent)
	FadeToTransparent:Play()

	task.wait(GuiConfig.ConnectionDelayTime)
	
	local Parent = self.Parent
	local BackButtonCallbacks = {}
	function BackButtonCallbacks:OnActivated()
		Parent:SetState(GuiEnums.States.Home)
	end
	local BackButton = TransitionButton.new(SelectTeamScreen.Back,  BackButtonCallbacks)
	self.Janitor:Add(BackButton, "TransitionButtonDestroy")
		
	local Callbacks = {
		ED = {},
		EP = {},
		EH = {},
	}
	-- Without setting parent as an upvalue, self refers to Callbacks.button.
	local Parent = self.Parent
	function Callbacks.EP:OnActivated()
	end
	function Callbacks.ED:OnActivated()
		Parent:SetState(GuiEnums.States.SelectED)
	end
	function Callbacks.EH:OnActivated()
		Parent:SetState(GuiEnums.States.StartEH)
	end
	
	local EPButton = ScreenButton.new(SelectTeamScreen.ED.Select, Callbacks.ED)
	EPButton:SetCanTransition(false)
	self.Janitor:Add(EPButton, "ScreenButtonDestroy")
	
	local EHButton = ScreenButton.new(SelectTeamScreen.EH.Select, Callbacks.EH)
	self.Janitor:Add(EHButton, "ScreenButtonDestroy")
	
	local EPButton = ScreenButton.new(SelectTeamScreen.EP.Select, Callbacks.EP)
	self.Janitor:Add(EPButton, "ScreenButtonDestroy")
	return true
end

function SelectTeam:Exit(NewState: GuiTypes.State)
	local self: GuiTypes.State = self

	local FadeToOpaque = TweenFactory:CreateTween(BlackScreen.Frame, GuiConfig.Tweens.FadeToOpaque)
	FadeToOpaque:Play()

	self.Janitor:Cleanup()

	FadeToOpaque.Completed:Wait()
	SelectTeamScreen.Parent = MainMenu

	return true
end

return SelectTeam
