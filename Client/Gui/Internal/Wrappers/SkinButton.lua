-- Modules --
local DefaultButton = require("./DefaultButton")
local TweenFactory = require("../TweenFactory")
local GuiConfig = require(game.ReplicatedStorage.Data.Configs.GuiConfig)
local Janitor = require(game.ReplicatedStorage.Modules.Janitor)

-- References --
local MainMenuSounds = game.ReplicatedStorage.Assets.Sounds.MainMenu

local SkinButton = setmetatable({}, DefaultButton)
SkinButton.__index = SkinButton

function SkinButton.new(Config, Shared)
	local self = setmetatable(DefaultButton.new(Config.Button), SkinButton)
	
	self.Shared = Shared
	self.Screen = Config.Screen
	self.IsForwards = Config.IsForwards
	self.SkinButtonJanitor = Janitor.new()
	self.SkinButtonJanitor:Add(self, "SkinButtonDestroy")

	self.SkinButtonJanitor:Add(self.Button.Activated:Connect(function()
		self:SkinButtonOnActivated()
		if Config.Callbacks and Config.Callbacks.OnActivated then
			Config.Callbacks:OnActivated()
		end
	end), "Disconnect")

	self.SkinButtonJanitor:Add(self.MouseEnter:Connect(function()
		self:SkinButtonOnEnter()
	end), "Disconnect")
	self.SkinButtonJanitor:Add(self.MouseLeave:Connect(function()
		self:SkinButtonOnLeave()
	end), "Disconnect")
	
	return self
end

function SkinButton:SkinButtonOnActivated()
	if self.IsForwards then
		
		if not self.Shared.CharacterConfig then
			MainMenuSounds.Button_Reject:Play()
			return
		end
		MainMenuSounds.Button_Confirm:Play()

		local Index = table.find(self.Shared.CharacterConfig.Skins, self.Shared.Skin)

		if Index < #self.Shared.CharacterConfig.Skins then
			self.Shared.Skin = self.Shared.CharacterConfig.Skins[Index + 1]
			self.Screen.CharacterDisplay.Skin.Text = "Skin : "..self.Shared.Skin.Id
			self.Screen.CharacterDisplay.Illustration.Image = self.Shared.Skin.Image
		end
		
	elseif not self.IsForwards then
		
		if not self.Shared.CharacterConfig then
			MainMenuSounds.Button_Reject:Play()
			return
		end
		MainMenuSounds.Button_Confirm:Play()

		local Index = table.find(self.Shared.CharacterConfig.Skins, self.Shared.Skin)

		if Index > 1 then
			self.Shared.Skin = self.Shared.CharacterConfig.Skins[Index - 1]
			self.Screen.CharacterDisplay.Skin.Text = "Skin : "..self.Shared.Skin.Id
			self.Screen.CharacterDisplay.Illustration.Image = self.Shared.Skin.Image
		end
	end
	
	self:SkinButtonOnLeave()
	self:DefaultButtonOnActivated()
end

function SkinButton:SkinButtonOnEnter()
	self:DefaultButtonOnEnter()
end

function SkinButton:SkinButtonOnLeave()
	
end


function SkinButton:SkinButtonDestroy()
	-- Without this, animation effects would linger on view change
	self:SkinButtonOnLeave()
	self.DefaultButtonJanitor:Cleanup()
	self.SkinButtonJanitor:Cleanup()
end

return SkinButton