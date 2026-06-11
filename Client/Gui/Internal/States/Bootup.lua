-- Services --
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules --
local CameraEffectsService = require("../../../Modules/CameraEffectsService")
local BaseState = require(ReplicatedStorage.Modules.StateMachineService.BaseState)
local GuiEnums = require(ReplicatedStorage.Data.Enums.GuiEnums)
local GuiTypes = require(ReplicatedStorage.Data.Types.GuiTypes)
local GuiConfig = require(ReplicatedStorage.Data.Configs.GuiConfig)

-- References --
local LocalPlayer = Players.LocalPlayer

local BootupScreen = LocalPlayer.PlayerGui.BootupScreen
local MainMenu = ReplicatedStorage.Assets.Gui.MainMenu
local LoadingScreen = MainMenu.LoadingScreen
local BlackScreen = MainMenu.BlackScreen

-- State --
local AssetCount = #CollectionService:GetTagged("Preload")
local AssetsLoaded = 0
local Assets = CollectionService:GetTagged("Preload")

local CameraEffects = CameraEffectsService.getInstance()
CameraEffects:SetSubject(workspace:WaitForChild("Ambiance Menu"):WaitForChild("CameraPosition"))

local Bootup = setmetatable({}, BaseState)
Bootup.__index = Bootup

function Bootup.new(Parent, Dependencies, Shared)
	-- nil is enum
	local self: GuiTypes.State = BaseState.new(GuiEnums.States.Bootup, Parent, Dependencies, Shared)
	setmetatable(self, Bootup)
	

	ContentProvider:PreloadAsync(Assets, function(Content)
		--print("✅ Asset With Id "..Content.." Loaded.")
		AssetsLoaded += 1

		--if AssetsLoaded == AssetCount and LoadingScreen then
		--	-- TODO: Check if this is still needed?
		--	LocalPlayer:getatt("Loaded", true)
		--end
	end)
	
	-- Without this then we would get sent back to home when the video ends if states were skipped.
	if not GuiConfig.Skip.States or not RunService:IsStudio() then
		BootupScreen.Video.Ended:Connect(function()
			BlackScreen.Parent = LocalPlayer.PlayerGui
			self.Parent:SetState(GuiEnums.States.Home)
		end)
	end
	
	return self
end

function Bootup:HandleInput(Input: string | InputObject | Enum.HumanoidStateType)
	local self: GuiTypes.State = self

end

function Bootup:Update(DeltaTime: number)
	local self: GuiTypes.State = self
end

function Bootup:Enter(OldState: GuiTypes.State)
	local self: GuiTypes.State = self
	
	CameraEffects:EnableTiltToMouse()
	
	return true
end

function Bootup:Exit(NewState: GuiTypes.State)
	local self: GuiTypes.State = self
	BootupScreen.Parent = MainMenu
	
	if GuiConfig.Skip.States then
		BlackScreen.Parent = LocalPlayer.PlayerGui
	end
	return true
end

return Bootup
