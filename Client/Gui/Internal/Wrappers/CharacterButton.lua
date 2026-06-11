-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules --
local TweenFactory = require("../TweenFactory")
local TransitionButton = require("../Wrappers/TransitionButton")
local MouseEvents = require("../../../Modules/MouseEvents")
local PlayerState = require(ReplicatedStorage.Modules.PlayerState.PlayerStateClient)
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local BaseState = require(ReplicatedStorage.Modules.StateMachineService.BaseState)
local GuiEnums = require(ReplicatedStorage.Data.Enums.GuiEnums)
local GuiTypes = require(ReplicatedStorage.Data.Types.GuiTypes)
local GuiConfig = require(ReplicatedStorage.Data.Configs.GuiConfig)
local DefaultButton = require("./DefaultButton")

-- References --
local LocalPlayer = Players.LocalPlayer

local BootupScreen = LocalPlayer.PlayerGui.BootupScreen
local MainMenuSounds = ReplicatedStorage.Assets.Sounds.MainMenu
local MainMenu = ReplicatedStorage.Assets.Gui.MainMenu
local BlackScreen = MainMenu.BlackScreen
local MainMenuSounds = game.ReplicatedStorage.Assets.Sounds.MainMenu

local CharacterConfigs = ReplicatedStorage.Data.Configs.CharacterConfigs

local UpdateCharacterCount = ReplicatedStorage.Remotes.MenuRemotes.UpdateCharacterCount

-- State --

local CharacterButton = setmetatable({}, DefaultButton)
CharacterButton.__index = CharacterButton

function CharacterButton.new(Config, Shared)
	local self = setmetatable(DefaultButton.new(Config.Button), CharacterButton)

	self.CharacterButtonJanitor = Janitor.new()
	self.CharacterButtonJanitor:Add(self, "CharacterButtonDestroy")
	self.Frame = Config.ButtonFrame	
	self.Screen = Config.Screen
	self.Shared = Shared

	self.CharacterButtonJanitor:Add(self.Button.Activated:Connect(function()
		self:CharacterButtonOnActivated()
		if Config.Callbacks and Config.Callbacks.OnActivated then
			Config.Callbacks:OnActivated()
		end
	end), "Disconnect")

	self.CharacterButtonJanitor:Add(self.MouseEnter:Connect(function()
		self:CharacterButtonOnEnter()
	end), "Disconnect")
	self.CharacterButtonJanitor:Add(self.MouseLeave:Connect(function()
		self:CharacterButtonOnLeave()
	end), "Disconnect")
	return self
end

function CharacterButton:CharacterButtonOnActivated()
	
	-- Points to the name of the frame containing the button
	local CharacterId = self.Button.Parent.Name

	if not PlayerState.Get("Characters")[CharacterId] then
		-- checking if player owns dinosaur
		return
	end

	if PlayerState.GetShared("Characters")[CharacterId].Count == require(CharacterConfigs[CharacterId]).MaxCount then
		MainMenuSounds.Button_Reject:Play()
		return
	end

	if self.Shared.CharacterConfig and CharacterId ~= self.Shared.CharacterConfig.Id then
		local CharacterCount = PlayerState.GetShared("Characters")[self.Shared.CharacterConfig.Id].Count
		local NewCharacterCount = CharacterCount - 1

		if self.Frame:FindFirstChild(self.Shared.CharacterConfig.Id) then
			HerbivoresFrame[self.Shared.CharacterConfig.Id].Count.Text = NewCharacterCount.."/"..self.Shared.CharacterConfig.MaxCount
		end
	end

	if self.Shared.CharacterConfig and CharacterId == self.Shared.CharacterConfig.Id then
		return
	end

	self.Shared.CharacterConfig = require(CharacterConfigs[CharacterId])

	UpdateCharacterCount:FireServer(self.Shared.CharacterConfig.Id)

	local CharacterCount = PlayerState.GetShared("Characters")[CharacterId].Count
	local NewCharacterCount = CharacterCount + 1

	if self.Frame:FindFirstChild(self.Shared.CharacterConfig.Id) then
		HerbivoresFrame[self.Shared.CharacterConfig.Id].Count.Text = NewCharacterCount.."/"..self.Shared.CharacterConfig.MaxCount
	end

	MainMenuSounds.Button_Confirm:Play()

	if self.Shared.CharacterConfig.IsGamepass then
		for _, GuiObject in self.Screen.CharacterDisplay.Gamepass:GetChildren() do
			GuiObject.Visible = true
		end
	else
		for _, GuiObject in self.Screen.CharacterDisplay.Gamepass:GetChildren() do
			GuiObject.Visible = false
		end
	end

	for _, GuiObject in self.Screen.CharacterDisplay.New:GetChildren() do
		if self.Shared.CharacterConfig.IsNew then
			GuiObject.Visible = true
		else
			GuiObject.Visible = false
		end
	end

	for _, GuiObject in self.Screen.Warning:GetChildren() do
		GuiObject.Visible = false
	end

	--TweenFactory:TextUnhighlight(self.Button.Label)
	--TweenFactory:TextUnhighlight(self.Button.Count)

	self.Screen.CharacterDisplay.DinoName.Text = "Name : "..self.Shared.CharacterConfig.Id.."//"
	self.Screen.CharacterDisplay.Skin.Text = "Skin : "..self.Shared.CharacterConfig.Skins[1].Id
	self.Screen.CharacterDisplay.Illustration.Image = self.Shared.CharacterConfig.Skins[1].Image
	self.Screen.CharacterDisplay.Class.Text = "Class // "..self.Shared.CharacterConfig.Class
	self.Screen.CharacterDisplay.Description.Text = self.Shared.CharacterConfig.Description

	self.Shared.Skin = self.Shared.CharacterConfig.Skins[1]
	self:CharacterButtonOnLeave()
	self:DefaultButtonOnActivated()
end

function CharacterButton:CharacterButtonOnEnter()
	local ButtonFolder = self.Button.Parent
	TweenFactory:CreateTween(self.Button, GuiConfig.Tweens.TextHighlight):Play()
	TweenFactory:CreateTween(self.Frame.Count, GuiConfig.Tweens.TextHighlight):Play()
	TweenFactory:CreateTween(self.Button.Highlight, GuiConfig.Tweens.DinosaurIconExpand):Play()
	self:DefaultButtonOnEnter()
end

function CharacterButton:CharacterButtonOnLeave()
	local ButtonFolder = self.Button.Parent
	TweenFactory:CreateTween(self.Button, GuiConfig.Tweens.TextUnhighlight):Play()
	TweenFactory:CreateTween(self.Frame.Count, GuiConfig.Tweens.TextUnhighlight):Play()
	TweenFactory:CreateTween(self.Button.Highlight, GuiConfig.Tweens.DinosaurIconShrink):Play()
end

function CharacterButton:CharacterButtonDestroy()
	-- Without this, animation effects would linger on view change
	self:CharacterButtonOnLeave()
	self.DefaultButtonJanitor:Cleanup()
	self.CharacterButtonJanitor:Cleanup()
end

return CharacterButton