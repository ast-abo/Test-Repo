local CustomMouse = require("../Internal/CustomMouse")

local GuiAPI = {}

function GuiAPI:Init(Shared, Dependencies)
	self.Shared = Shared
	self.Dependencies = Dependencies
end

function GuiAPI:SetState(StateEnum)
	self.Dependencies.StateMachine:SetState(StateEnum)
end

function GuiAPI:Update(DeltaTime)
	self.Dependencies.StateMachine:Update(DeltaTime)
end


function GuiAPI:DisableMenuCam()
	--self.MenuCam:Disconnect()
end


return GuiAPI