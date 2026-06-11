-- Modules --
local MouseEvents = require("../../../Modules/MouseEvents")
local DefaultButton = require("./DefaultButton")
local TweenFactory = require("../TweenFactory")
local GuiConfig = require(game.ReplicatedStorage.Data.Configs.GuiConfig)
local Janitor = require(game.ReplicatedStorage.Modules.Janitor)

-- References --
local MainMenuSounds = game.ReplicatedStorage.Assets.Sounds.MainMenu

local WarningButton = setmetatable({}, DefaultButton)
WarningButton.__index = WarningButton

function WarningButton.new(Config, Shared)
	local self = setmetatable(DefaultButton.new(Config.Button), WarningButton)
	
	self.Screen = Config.Screen

	self.WarningButtonJanitor = Janitor.new()
	self.WarningButtonJanitor:Add(self, "WarningButtonDestroy")

	self.WarningButtonJanitor:Add(self.Button.Activated:Connect(function()
		self:WarningButtonOnActivated()
		if Config.Callbacks and Config.Callbacks.OnActivated then
			Config.Callbacks:OnActivated()
		end
	end), "Disconnect")

	self.WarningButtonJanitor:Add(self.MouseEnter:Connect(function()
		self:WarningButtonOnEnter()
	end), "Disconnect")
	self.WarningButtonJanitor:Add(self.MouseLeave:Connect(function()
		self:WarningButtonOnLeave()
	end), "Disconnect")
	return self
end

function WarningButton:WarningButtonOnActivated()
	MainMenuSounds.Button_Confirm:Play()

	local WarningButtonActivated = TweenFactory:CreateTween(self.Button, GuiConfig.Tweens.WarningButtonActivated)
	WarningButtonActivated:Play()

	local WarningButtonTextActivated = TweenFactory:CreateTween(self.Button.Label, GuiConfig.Tweens.WarningButtonTextActivated)
	WarningButtonTextActivated:Play()
	
	for _, v in self.Screen.Warning:GetChildren() do
		v.Visible = false
	end
	
	self:WarningButtonOnLeave()
	self:DefaultButtonOnActivated()
end

function WarningButton:WarningButtonOnEnter()
	local WarningButtonExpand = TweenFactory:CreateTween(self.Button, GuiConfig.Tweens.WarningButtonExpand)
	WarningButtonExpand:Play()

	TweenFactory:CreateTween(self.Button.Label, GuiConfig.Tweens.TextHighlight):Play()

	self:DefaultButtonOnEnter()
end

function WarningButton:WarningButtonOnLeave()
	local WarningButtonShrink = TweenFactory:CreateTween(self.Button, GuiConfig.Tweens.WarningButtonShrink)
	WarningButtonShrink:Play()

	TweenFactory:CreateTween(self.Button.Label, GuiConfig.Tweens.TextUnhighlight):Play()
end


function WarningButton:WarningButtonDestroy()
	-- Without this, animation effects would linger on view change
	self:WarningButtonOnLeave()
	self.DefaultButtonJanitor:Cleanup()
	self.WarningButtonJanitor:Cleanup()
end

return WarningButton