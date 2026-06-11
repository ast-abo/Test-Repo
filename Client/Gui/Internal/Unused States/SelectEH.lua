local BaseState = require(game.ReplicatedStorage.Modules.StateMachineService.BaseState)
local GuiEnums = require(game.ReplicatedStorage.Data.Enums.GuiEnums)
local GuiTypes = require(game.ReplicatedStorage.Data.Types.GuiTypes)

local TemplateState = setmetatable({}, BaseState)
TemplateState.__index = TemplateState

function TemplateState.new(Parent, Dependencies, Shared)
	-- nil is enum
	local self: GuiTypes.State = BaseState.new(GuiEnums.States.SelectEH, Parent, Dependencies, Shared)
	setmetatable(self, TemplateState)
	
	return self
end

function TemplateState:HandleInput(Input: string | InputObject | Enum.HumanoidStateType)
	local self: GuiTypes.State = self
end

function TemplateState:Update(DeltaTime: number)
	local self: GuiTypes.State = self
end

function TemplateState:Enter(OldState: GuiTypes.State)
	local self: GuiTypes.State = self

	self.Dependencies.SpawnRequest:FireServer(nil, "Human")

	local TweenInformation = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local Tween: Tween = self.Dependencies.TweenService:Create(self.Dependencies.BlackScreen.Frame, TweenInformation, 
		{BackgroundTransparency = 1})

	Tween:Play()
	
	return true
end

function TemplateState:Exit(NewState: GuiTypes.State)
	local self: GuiTypes.State = self
	
	
	return true
end

return TemplateState
