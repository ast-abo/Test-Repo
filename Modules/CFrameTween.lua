local TweenService = game:GetService("TweenService")

local function AngleDifference(A, B): number
	-- Shortest difference in degrees between angles A and B
	local Diff = (B - A + 180) % 360 - 180
	return Diff
end

local function ToOrientationDeg(Cf)
	local X, Y, Z = Cf:ToOrientation()
	return math.deg(X), math.deg(Y), math.deg(Z)
end

local function LerpAngle(A, B, T): number
	local Diff = AngleDifference(A, B)
	return A + Diff * T
end

local CFrameTween: CFrameTween = {}
CFrameTween.__index = CFrameTween

function CFrameTween.new(Parent)
	local self = {}
	self.Parent = Parent
	
	return setmetatable(self, CFrameTween)
end

function CFrameTween:Update(DeltaTime: number): never
	local self: self = self

	local CurX, CurY, CurZ = ToOrientationDeg(self.Parent.Value)
	local TarX, TarY, TarZ = ToOrientationDeg(self.Parent.Target)

	local DiffX = AngleDifference(CurX, TarX)
	local DiffY = AngleDifference(CurY, TarY)
	local DiffZ = AngleDifference(CurZ, TarZ)
	local TotalDiff = math.sqrt(DiffX^2 + DiffY^2 + DiffZ^2)

	--if TotalDiff == 0 or DeltaTime == 0 then
	--	self.Parent.Value = CFrame.new(self.Parent.Value.Position) * CFrame.fromOrientation(math.rad(TarX), math.rad(TarY), math.rad(TarZ))
	--	return self.Parent.Value
	--end

	local MaxStep = self.Parent.Speed * DeltaTime
	local T = math.clamp(MaxStep / TotalDiff, 0, 1)
--	local NewT = TweenService:GetValue(T, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	
	local NewX = LerpAngle(CurX, TarX, T)
	local NewY = LerpAngle(CurY, TarY, T)
	local NewZ = LerpAngle(CurZ, TarZ, T)
	
	if NewX ~= NewX then
		return
	end
	
	if NewY ~= NewY then
		return
	end
	
	if NewZ ~= NewZ then
		return
	end

	self.Parent.Value = CFrame.new(self.Parent.Value.Position) * CFrame.fromOrientation(math.rad(NewX), math.rad(NewY), math.rad(NewZ))
end

return CFrameTween