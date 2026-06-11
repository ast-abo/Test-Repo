-- Modules --
local MouseEvents = require("../../../Modules/MouseEvents")
local DefaultButton = require("./DefaultButton")
local TweenFactory = require("../TweenFactory")
local GuiConfig = require(game.ReplicatedStorage.Data.Configs.GuiConfig)
local Janitor = require(game.ReplicatedStorage.Modules.Janitor)

-- References --
local MainMenuSounds = game.ReplicatedStorage.Assets.Sounds.MainMenu

local LocationButton = setmetatable({}, DefaultButton)
LocationButton.__index = LocationButton

function LocationButton.new(Config, Shared)
	local self = setmetatable(DefaultButton.new(Config.Button), LocationButton)
	
	self.Shared = Shared
	self.Screen = Config.Screen

	self.LocationButtonJanitor = Janitor.new()
	self.LocationButtonJanitor:Add(self, "LocationButtonDestroy")

	self.LocationButtonJanitor:Add(self.Button.Activated:Connect(function()
		self:LocationButtonOnActivated()
		if Config.Callbacks and Config.Callbacks.OnActivated then
			Config.Callbacks:OnActivated()
		end
	end), "Disconnect")

	self.LocationButtonJanitor:Add(self.MouseEnter:Connect(function()
		self:LocationButtonOnEnter()
	end), "Disconnect")
	self.LocationButtonJanitor:Add(self.MouseLeave:Connect(function()
		self:LocationButtonOnLeave()
	end), "Disconnect")
	
	return self
end

function LocationButton:LocationButtonOnActivated()
	self.Shared.Spawn = self.Button.Name
	self.Screen.Locations.Spawn.Text = "Spawn: "..self.Button.Name

	MainMenuSounds.Button_Confirm:Play()

	for _, v in self.Screen.Warning:GetChildren() do
		v.Visible = false
	end
	self:LocationButtonOnLeave()
	self:DefaultButtonOnActivated()
end

function LocationButton:LocationButtonOnEnter()
	TweenFactory:CreateTween(self.Button.TextLabel,GuiConfig.Tweens.TextHighlight):Play()
	self:DefaultButtonOnEnter()
end

function LocationButton:LocationButtonOnLeave()
	TweenFactory:CreateTween(self.Button.TextLabel,GuiConfig.Tweens.TextUnhighlight):Play()
end


function LocationButton:LocationButtonDestroy()
	-- Without this, animation effects would linger on view change
	self:LocationButtonOnLeave()
	self.DefaultButtonJanitor:Cleanup()
	self.LocationButtonJanitor:Cleanup()
end

return LocationButton