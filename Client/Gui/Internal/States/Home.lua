-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules --
local TweenFactory = require("../TweenFactory")
local ScreenButton = require("../Wrappers/ScreenButton")
local SlidingTween = require("../Wrappers/SlidingTween")
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
local HomeScreen = MainMenu.HomeScreen
local BlackScreen = MainMenu.BlackScreen

-- State --

local Home = setmetatable({}, BaseState)
Home.__index = Home

function Home.new(Parent, Dependencies, Shared)
	-- nil is enum
	local self: GuiTypes.State = BaseState.new(GuiEnums.States.Home, Parent, Dependencies, Shared)
	setmetatable(self, Home)
	
	HomeScreen.SlidingText.ImageLabel.Frame:WaitForChild("UserName").Text = `USER: {LocalPlayer.Name}`
	self.SlidingFrameJanitor = Janitor.new()

	return self
end

function Home:HandleInput(Input: string | InputObject | Enum.HumanoidStateType)
	local self: GuiTypes.State = self

end

function Home:Update(DeltaTime: number)
	local self: GuiTypes.State = self

end

function Home:Enter(OldState: GuiTypes.State)
	local self: GuiTypes.State = self
	HomeScreen.Parent = LocalPlayer.PlayerGui
	
	self.Janitor = Janitor.new()

	local FadeToTransparent = TweenFactory:CreateTween(BlackScreen.Frame, GuiConfig.Tweens.FadeToTransparent)
	FadeToTransparent:Play()

	task.wait(GuiConfig.ConnectionDelayTime)
	
	local Callbacks = {
		Play = {},
		Shop = {},
		Settings = {},
		Guide = {}
	}
	-- Without setting parent as an upvalue, self refers to Callbacks.button.
	local Parent = self.Parent
	function Callbacks.Play:OnActivated()
		Parent:SetState(GuiEnums.States.SelectTeam)
	end
	function Callbacks.Shop:OnActivated()
		Parent:SetState(GuiEnums.States.Shop)
	end
	function Callbacks.Settings:OnActivated()
		Parent:SetState(GuiEnums.States.Settings)
	end
	self.Janitor:Add(ScreenButton.new(HomeScreen.Play.ImageButton, Callbacks.Play), "ScreenButtonDestroy")
	self.Janitor:Add(ScreenButton.new(HomeScreen.Settings.ImageButton, Callbacks.Settings), "ScreenButtonDestroy")
	self.Janitor:Add(ScreenButton.new(HomeScreen.Shop.ImageButton, Callbacks.Shop), "ScreenButtonDestroy")
	local GuideButton = ScreenButton.new(HomeScreen.Guide.ImageButton)
	self.Janitor:Add(GuideButton, "ScreenButtonDestroy")
	
	-- No screen for guide yet so I set can transition to false.
	GuideButton:SetCanTransition(false)
	
	local SlidingFrame = SlidingTween.new(HomeScreen.SlidingText.ImageLabel.Frame, GuiConfig.Tweens.TextSlidingTween)
	self.SlidingFrameJanitor:Add(SlidingFrame, "Destroy")
	SlidingFrame:Start()
	
	local SlidingMonitor = SlidingTween.new(HomeScreen.MonitorAnimation.ImageLabel.Scroll, GuiConfig.Tweens.TextSlidingTween)
	self.SlidingFrameJanitor:Add(SlidingMonitor, "Destroy")
	SlidingMonitor:Start()
	return true
end

function Home:Exit(NewState: GuiTypes.State)
	local self: GuiTypes.State = self

	local FadeToOpaque = TweenFactory:CreateTween(BlackScreen.Frame, GuiConfig.Tweens.FadeToOpaque)
	FadeToOpaque:Play()
	
	self.Janitor:Cleanup()
	
	FadeToOpaque.Completed:Wait()
	
	self.SlidingFrameJanitor:Cleanup()
	HomeScreen.Parent = MainMenu

	return true
end

return Home
