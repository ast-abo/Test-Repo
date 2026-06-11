local BaseState = require(game.ReplicatedStorage.Modules.StateMachineService.BaseState)
local GuiEnums = require(game.ReplicatedStorage.Data.Enums.GuiEnums)
local GuiTypes = require(game.ReplicatedStorage.Data.Types.GuiTypes)

local SelectEP = setmetatable({}, BaseState)
SelectEP.__index = SelectEP

function SelectEP.new(Parent, Dependencies, Shared)
	-- nil is enum
	local self: GuiTypes.State = BaseState.new(GuiEnums.States.SelectEP, Parent, Dependencies, Shared)
	setmetatable(self, SelectEP)

	return self
end

function SelectEP:HandleInput(Input: string | InputObject | Enum.HumanoidStateType)
	local self: GuiTypes.State = self
	
end

function SelectEP:Update(DeltaTime: number)
	local self: GuiTypes.State = self
	
end

function SelectEP:Enter(OldState: GuiTypes.State)
	local self: GuiTypes.State = self
	
	return true
end

function SelectEP:Exit(NewState: GuiTypes.State)
	local self: GuiTypes.State = self

	return true
end

return SelectEP
