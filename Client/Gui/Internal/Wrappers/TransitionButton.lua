-- Modules --
local MouseEvents = require("../../../Modules/MouseEvents")
local DefaultButton = require("./DefaultButton")
local TweenFactory = require("../../Internal/TweenFactory")
local Janitor = require(game.ReplicatedStorage.Modules.Janitor)
local GuiConfig = require(game.ReplicatedStorage.Data.Configs.GuiConfig)

-- References --
local MainMenuSounds = game.ReplicatedStorage.Assets.Sounds.MainMenu

local TransitionButton = setmetatable({}, DefaultButton)
TransitionButton.__index = TransitionButton

function TransitionButton.new(Button: GuiButton, Callbacks: {[string]: () -> ()})
	local self = setmetatable(DefaultButton.new(Button), TransitionButton)
	
	self.TransitionButtonJanitor = Janitor.new()
	
	self.TransitionButtonJanitor:Add(self, "TransitionButtonDestroy")
	
	self.TransitionButtonJanitor:Add(self.MouseEnter:Connect(function()
		TweenFactory:CreateTween(self.Button, GuiConfig.Tweens.TransitionButtonExpand):Play()
		TweenFactory:CreateTween(self.Button.Label, GuiConfig.Tweens.TextHighlight):Play()
		self:DefaultButtonOnEnter()
	end), "Disconnect")
	
	self.TransitionButtonJanitor:Add(self.MouseLeave:Connect(function()
		TweenFactory:CreateTween(self.Button, GuiConfig.Tweens.TransitionButtonShrink):Play()
		TweenFactory:CreateTween(self.Button.Label, GuiConfig.Tweens.TextUnhighlight):Play()
	end), "Disconnect")
	
	self.TransitionButtonJanitor:Add(self.Button.Activated:Connect(function()
		TweenFactory:CreateTween(self.Button, GuiConfig.Tweens.TransitionButtonActivated):Play()
		TweenFactory:CreateTween(self.Button.Label, GuiConfig.Tweens.TransitionButtonTextActivated):Play()
		if Callbacks.OnActivated then
			Callbacks:OnActivated()
		end
		self:DefaultButtonOnActivated()
	end), "Disconnect")

	return self
end
function TransitionButton:SetCanTransition(Value)
	self.CanTransition = Value
end

function TransitionButton:TransitionButtonDestroy()
	TweenFactory:CreateTween(self.Button, GuiConfig.Tweens.TransitionButtonShrink):Play()
	TweenFactory:CreateTween(self.Button.Label, GuiConfig.Tweens.TextUnhighlight):Play()
	self.TransitionButtonJanitor:Cleanup()
	self.DefaultButtonJanitor:Cleanup()
	return
end

return TransitionButton