local BaseState = require(game.ReplicatedStorage.Modules.StateMachineService.BaseState)
local GuiEnums = require(game.ReplicatedStorage.Data.Enums.GuiEnums)
local GuiTypes = require(game.ReplicatedStorage.Data.Types.GuiTypes)

local StartEP = setmetatable({}, BaseState)
StartEP.__index = StartEP

function StartEP.new(Parent, Dependencies, Shared)
	-- nil is enum
	local self: GuiTypes.State = BaseState.new(GuiEnums.States.StartEP, Parent, Dependencies, Shared)
	setmetatable(self, StartEP)

	return self
end

function StartEP:HandleInput(Input: string | InputObject | Enum.HumanoidStateType)
	local self: GuiTypes.State = self

end

function StartEP:Update(DeltaTime: number)
	local self: GuiTypes.State = self
end

function StartEP:Enter(OldState: GuiTypes.State)
	local self: GuiTypes.State = self

	return true
end

function StartEP:Exit(NewState: GuiTypes.State)
	local self: GuiTypes.State = self
	return true
end

return StartEP
