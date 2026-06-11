-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules --
local TweenFactory = require("../TweenFactory")
local CharacterButton = require("../Wrappers/CharacterButton")
local TransitionButton = require("../Wrappers/TransitionButton")
local WarningButton = require("../Wrappers/WarningButton")
local SkinButton = require("../Wrappers/SkinButton")
local MouseEvents = require("../../../Modules/MouseEvents")
local PlayerState = require(ReplicatedStorage.Modules.PlayerState.PlayerStateClient)
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local BaseState = require(ReplicatedStorage.Modules.StateMachineService.BaseState)
local GuiEnums = require(ReplicatedStorage.Data.Enums.GuiEnums)
local GuiTypes = require(ReplicatedStorage.Data.Types.GuiTypes)
local GuiConfig = require(ReplicatedStorage.Data.Configs.GuiConfig)

-- References --
local LocalPlayer = Players.LocalPlayer

local BootupScreen = LocalPlayer.PlayerGui.BootupScreen
local MainMenuSounds = ReplicatedStorage.Assets.Sounds.MainMenu
local MainMenu = ReplicatedStorage.Assets.Gui.MainMenu
local DinosaurSelection = MainMenu.DinosaurSelection
local BlackScreen = MainMenu.BlackScreen

local CharacterConfigs = ReplicatedStorage.Data.Configs.CharacterConfigs

local HerbivorsFrame = DinosaurSelection.Herbivores.ScrollingFrame
local CarnivoresFrame = DinosaurSelection.Carnivores.ScrollingFrame

-- State --

local ED = setmetatable({}, BaseState)
ED.__index = ED

local DefaultTextSize = 23

local function CalculateSuitableTextSize(mainObject: ScrollingFrame)
	-- Set max size to default text size
	local Size = DefaultTextSize

	-- Loop through each object
	for _, object in pairs(mainObject:GetDescendants()) do
		local Success, Error, MS = pcall(function()
			if not object["TextSize"] then return end
			local AbsoluteSize = mainObject.Size.X.Scale * workspace.Camera.ViewportSize.X

			object.TextSize = DefaultTextSize * AbsoluteSize / 200
		end)
	end
end

function ED.new(Parent, Dependencies, Shared)
	-- nil is enum
	local self: GuiTypes.State = BaseState.new(GuiEnums.States.SelectED, Parent, Dependencies, Shared)
	setmetatable(self, ED)
	
	HerbivoresFrame = DinosaurSelection.Herbivores.ScrollingFrame
	CarnivoresFrame = DinosaurSelection.Carnivores.ScrollingFrame
	
	local Characters = PlayerState.GetShared("Characters")
	
	for CharacterId, Character in Characters do
		PlayerState.OnSharedChanged("Characters."..CharacterId, function()
			if HerbivoresFrame:FindFirstChild(CharacterId) then
				HerbivoresFrame[CharacterId].Count.Text = Character.Count.."/"..require(CharacterConfigs[CharacterId]).MaxCount

			elseif CarnivoresFrame:FindFirstChild(CharacterId) then
				CarnivoresFrame[CharacterId].Count.Text = Character.Count.."/"..require(CharacterConfigs[CharacterId]).MaxCount
			end
		end)
	end

	return self
end

function ED:HandleInput(Input: string | InputObject | Enum.HumanoidStateType)
	local self: GuiTypes.State = self
end

function ED:Update(DeltaTime: number)
	local self: GuiTypes.State = self

	CalculateSuitableTextSize(HerbivoresFrame)

	CalculateSuitableTextSize(CarnivoresFrame)
end

function ED:Enter(OldState: GuiTypes.State)
	local self: GuiTypes.State = self
	self.Janitor = Janitor.new()

	DinosaurSelection.Parent = LocalPlayer.PlayerGui

	CalculateSuitableTextSize(HerbivoresFrame)

	CalculateSuitableTextSize(CarnivoresFrame)

	local FadeToTransparent = TweenFactory:CreateTween(BlackScreen.Frame, GuiConfig.Tweens.FadeToTransparent)
	FadeToTransparent:Play()

	task.wait(GuiConfig.ConnectionDelayTime)

	for _, Child in CarnivoresFrame:GetChildren() do
		if not Child:IsA("Frame") then
			continue
		end
		
		local Config = {
			Button = Child.Label,
			ButtonFrame = Child,
			Screen = DinosaurSelection,
			Callbacks = {}
		}

		self.Janitor:Add(CharacterButton.new(Config, self.Shared), "CharacterButtonDestroy")
	end
	

	for _, Child in HerbivoresFrame:GetChildren() do
		if not Child:IsA("Frame") then
			continue
		end

		local Config = {
			Button = Child.Label,
			ButtonFrame = Child,
			Screen = DinosaurSelection,
			Callbacks = {}
		}

		self.Janitor:Add(CharacterButton.new(Config, self.Shared), "CharacterButtonDestroy")
	end
	
	local Parent = self.Parent
	local Shared = self.Shared
	
	local BackButtonCallbacks = {}
	local BackButton = TransitionButton.new(DinosaurSelection.Back, BackButtonCallbacks)
	self.Janitor:Add(BackButton, "TransitionButtonDestroy")
	function BackButtonCallbacks:OnActivated()
		Parent:SetState(GuiEnums.States.SelectTeam)
	end
	
	local ContinueButtonCallbacks = {}
	local ContinueButton = TransitionButton.new(DinosaurSelection.Continue, ContinueButtonCallbacks)
	self.Janitor:Add(ContinueButton, "TransitionButtonDestroy")
	
	function ContinueButtonCallbacks:OnActivated()
		if not Shared.CharacterConfig then
			for _, v in DinosaurSelection.Warning:GetChildren() do
				v.Visible = true
			end

			ContinueButton:SetCanTransition(false)
			return
		end
		ContinueButton:SetCanTransition(true)

		Parent:SetState(GuiEnums.States.StartED)
	end
	
	local ForwardsSkinButtonConfig = {
		Button = DinosaurSelection.Skin.Forwards,
		Screen = DinosaurSelection,
		IsForwards = true,
		Callbacks = {}
	}
	
	local BackwardsSkinButtonConfig = {
		Button = DinosaurSelection.Skin.Backwards,
		Screen = DinosaurSelection,
		IsForwards = false,
		Callbacks = {}
	}
	
	self.Janitor:Add(SkinButton.new(ForwardsSkinButtonConfig, self.Shared), "SkinButtonDestroy")
	
	self.Janitor:Add(SkinButton.new(BackwardsSkinButtonConfig, self.Shared), "SkinButtonDestroy")
	
	local WarningConfig = {
		Button = DinosaurSelection.Warning.WarningButton,
		Screen = DinosaurSelection,
	}
	
	self.Janitor:Add(WarningButton.new(WarningConfig, self.Shared), "WarningButtonDestroy")
	
	return true
end

function ED:Exit(NewState: GuiTypes.State)
	local self: GuiTypes.State = self

	local FadeToOpaque = TweenFactory:CreateTween(BlackScreen.Frame, GuiConfig.Tweens.FadeToOpaque)
	FadeToOpaque:Play()

	self.Janitor:Cleanup()

	FadeToOpaque.Completed:Wait()
	
	DinosaurSelection.Parent = game.ReplicatedStorage.Assets.Gui.MainMenu
	return true
end

return ED
