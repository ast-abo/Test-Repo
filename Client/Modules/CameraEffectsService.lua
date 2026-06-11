-- Services --
local RunService = game:GetService("RunService")

-- Modules --

-- References --
local LocalPlayer = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- State --
local _Instance = nil
local Connections = {}

local CameraEffects = {}
CameraEffects.__index = CameraEffects

function CameraEffects.getInstance()
	if _Instance then
		return _Instance
	end
	
	local self = setmetatable({}, CameraEffects)

	self.Subject = nil
	
	_Instance = self
	
	return self
end

function CameraEffects:SetSubject(Subject)
	self.Subject = Subject
end

function CameraEffects:EnableTiltToMouse()
	repeat
		wait()
		Camera.CameraType = Enum.CameraType.Scriptable
	until
	Camera.CameraType == Enum.CameraType.Scriptable

	--// Move cam
	local maxTilt = 17
	local InitialCamCframe = Camera.CFrame
	local speed = 10 -- Adjust for snappiness

	workspace.CurrentCamera.CFrame = self.Subject.CFrame

	Connections.TiltToMouse = game:GetService("RunService").RenderStepped:Connect(function(Dt)
		local targetCFrame = self.Subject.CFrame * CFrame.Angles(
			math.rad((((LocalPlayer:GetMouse().Y - LocalPlayer:GetMouse().ViewSizeY / 2) / LocalPlayer:GetMouse().ViewSizeY)) * -maxTilt),
			math.rad((((LocalPlayer:GetMouse().X - LocalPlayer:GetMouse().ViewSizeX / 2) / LocalPlayer:GetMouse().ViewSizeX)) * -maxTilt),
			0
		)

		-- Use Dt to make the transition frame-rate independent
		Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 - math.exp(-speed * Dt))
	end)
end

function CameraEffects:DisableTiltToMouse()
	Connections.TiltToMouse:Disconnect()
end

function CameraEffects:SetCameraToCharacter()
	Camera.CameraSubject = self.Subject
	Camera.CameraType = Enum.CameraType.Follow
end
return CameraEffects
