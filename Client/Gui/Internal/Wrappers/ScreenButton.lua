-- Modules --
local MouseEvents = require("../../../Modules/MouseEvents")
local DefaultButton = require("./DefaultButton")
local TweenFactory = require("../TweenFactory")
local GuiConfig = require(game.ReplicatedStorage.Data.Configs.GuiConfig)
local Janitor = require(game.ReplicatedStorage.Modules.Janitor)

-- References --
local MainMenuSounds = game.ReplicatedStorage.Assets.Sounds.MainMenu

local ScreenButton = setmetatable({}, DefaultButton)
ScreenButton.__index = ScreenButton

function ScreenButton.new(Button: GuiButton, Callbacks: {[string]: () -> ()})
	local self = setmetatable(DefaultButton.new(Button), ScreenButton)

	self.ScreenButtonJanitor = Janitor.new()
	self.ScreenButtonJanitor:Add(self, "ScreenButtonDestroy")

	self.ScreenButtonJanitor:Add(self.Button.Activated:Connect(function()
		self:ScreenButtonOnActivated()
		if Callbacks and Callbacks.OnActivated then
			Callbacks:OnActivated()
		end
	end), "Disconnect")

	self.ScreenButtonJanitor:Add(self.MouseEnter:Connect(function()
		self:ScreenButtonOnEnter()
	end), "Disconnect")
	self.ScreenButtonJanitor:Add(self.MouseLeave:Connect(function()
		self:ScreenButtonOnLeave()
	end), "Disconnect")
	return self
end

function ScreenButton:ScreenButtonOnActivated()
	self:ScreenButtonOnLeave()
	self:DefaultButtonOnActivated()
end

function ScreenButton:ScreenButtonOnEnter()
	local ButtonFolder = self.Button.Parent
	for _, Object in ButtonFolder:GetChildren() do
		if Object:IsA("TextLabel") then
			TweenFactory:CreateTween(Object, GuiConfig.Tweens.TextHighlight):Play()
		end

		if Object:IsA("Frame") then
			TweenFactory:CreateTween(Object, GuiConfig.Tweens.IconExpand):Play()
		end
	end

	self:DefaultButtonOnEnter()
end

function ScreenButton:ScreenButtonOnLeave()
	local ButtonFolder = self.Button.Parent
	for _, Object in ButtonFolder:GetChildren() do
		if Object:IsA("TextLabel") then
			TweenFactory:CreateTween(Object, GuiConfig.Tweens.TextUnhighlight):Play()
		end

		if Object:IsA("Frame") then
			TweenFactory:CreateTween(Object, GuiConfig.Tweens.IconShrink):Play()
		end
	end
end


function ScreenButton:ScreenButtonDestroy()
	-- Without this, animation effects would linger on view change
	self:ScreenButtonOnLeave()
	self.DefaultButtonJanitor:Cleanup()
	self.ScreenButtonJanitor:Cleanup()
end

return ScreenButton