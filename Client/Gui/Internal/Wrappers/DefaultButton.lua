-- Services --
local SoundService = game:GetService("SoundService")

-- Modules --
local MouseEvents = require("../../../Modules/MouseEvents")
local Janitor = require(game.ReplicatedStorage.Modules.Janitor)

-- References --
local MainMenuSounds = game.ReplicatedStorage.Assets.Sounds.MainMenu

local DefaultButton = {}
DefaultButton.__index = DefaultButton

function DefaultButton.new(Button: GuiButton)
	local self = setmetatable({}, DefaultButton)
	
	self.Button = Button
	self.MouseEnter, self.MouseLeave = MouseEvents.new(Button)
	
	self.DefaultButtonJanitor = Janitor.new()
	
	self.DefaultButtonJanitor:Add(self, "DefaultButtonDestroy")
	self.DefaultButtonJanitor:Add(self.MouseEnter, "Destroy")
	self.DefaultButtonJanitor:Add(self.MouseLeave, "Destroy")
	
	self.CanTransition = true
	return self
end

function DefaultButton:DefaultButtonOnActivated()
	if self.CanTransition then
		MainMenuSounds.Button_Confirm:Play()
	elseif not self.CanTransition then
		MainMenuSounds.Button_Reject:Play()
	end
end

function DefaultButton:DefaultButtonOnEnter()
	SoundService:PlayLocalSound(MainMenuSounds.Button_Hover)
end

function DefaultButton:SetCanTransition(Value: boolean)
	self.CanTransition = Value
end

function DefaultButton:DefaultButtonDestroy()
	self.DefaultButtonJanitor:Cleanup()
end

return DefaultButton