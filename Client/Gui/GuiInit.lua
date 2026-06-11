-- Services --
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

-- Modules --
local GuiAPI = require("./Public/GuiAPI")
local GuiConfig = require(game.ReplicatedStorage.Data.Configs.GuiConfig)
local Janitor = require("@game/ReplicatedStorage/Modules/Janitor")
local GuiEnums = require("@game/ReplicatedStorage/Data/Enums/GuiEnums")
local StateMachineService = require(game.ReplicatedStorage.Modules.StateMachineService)

-- References --
local LocalPlayer = Players.LocalPlayer

local StateFolder = LocalPlayer.PlayerScripts["Gui"].Internal.States

-- State --

local StateMachineShared = {
	Spawn = nil
}

local StateMachineDependencies = {
	
}

local GuiStateMachine = StateMachineService.new({
	Id = "MainMenu",
	Initial = GuiEnums.States.Bootup,
	StateFolder = StateFolder,
	Dependencies = StateMachineDependencies,
	Shared = StateMachineShared
})
GuiStateMachine:Init()

local GuiShared = {
	
}

local GuiDependencies = {
	StateMachine = GuiStateMachine
}

-- Instantiations/Initializations --
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

GuiAPI:Init(GuiShared, GuiDependencies)

-- Connections --

RunService.Heartbeat:Connect(function(DeltaTime)
	GuiAPI:Update(DeltaTime)
end)

if GuiConfig.Skip.States and RunService:IsStudio() then
	task.wait(0.6)
	GuiAPI:SetState(GuiEnums.States.Home)
end