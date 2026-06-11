local RunService = game:GetService("RunService")
local Janitor = require("@game/ReplicatedStorage/Modules/Janitor")

local SlidingTween = {}
SlidingTween.__index = SlidingTween

function SlidingTween.new(Target, Config)
	local self = setmetatable({}, SlidingTween)
	self._Janitor = Janitor.new()
	self._Direction = 1

	self.PrimaryObject = Target
	self.SecondaryObject = Target:Clone()
	self.Container = Target.Parent
	self.IsForwards = Config.IsForwards
	self.SlidingSpeed = Config.SlidingSpeed
	self.Padding = Config.Padding or 0
	self.Wrapped = Config.Wrapped or false

	self.PrimaryPosition = 0
	if self.IsForwards then
		self._Direction = 1
	elseif not self.IsForwards then
		self._Direction = -1
	end

	self.SecondaryPosition = -self._Direction
	self.SecondaryObject.Position = UDim2.fromScale(self.SecondaryPosition, self.SecondaryObject.Position.Y.Scale)
	self.SecondaryObject.Parent = self.Container
	self._Janitor:Add(self.SecondaryObject, "Destroy")

	return self
end

function SlidingTween:Start()
	self._Janitor:Add(RunService.PreRender:Connect(function(DeltaTime)
		local DeltaPosition = self._Direction * self.SlidingSpeed * DeltaTime
		local ResetPostion = -self._Direction + -self._Direction * self.Padding

		self.PrimaryPosition += DeltaPosition
		self.SecondaryPosition += DeltaPosition

		if self.IsForwards then
			self._Direction = 1
			self.PrimaryObjectClipped = self.PrimaryPosition >= 1 + self.Padding
			self.SecondaryObjectClipped = self.SecondaryPosition >= 1 + self.Padding
		elseif not self.IsForwards then
			self._Direction = -1
			self.PrimaryObjectClipped = self.PrimaryPosition <= -1 - self.Padding
			self.SecondaryObjectClipped = self.SecondaryPosition <= -1 - self.Padding
		end

		if self.PrimaryObjectClipped then
			self.PrimaryPosition = ResetPostion
			self.SecondaryPosition = 0
		end

		if self.SecondaryObjectClipped then
			self.SecondaryPosition = ResetPostion
			self.PrimaryPosition = 0
		end

		self.PrimaryObject.Position = UDim2.fromScale(self.PrimaryPosition, self.PrimaryObject.Position.Y.Scale)
		self.SecondaryObject.Position = UDim2.fromScale(self.SecondaryPosition, self.SecondaryObject.Position.Y.Scale)
	end), "Disconnect")
end

function SlidingTween:Destroy()
	self._Janitor:Cleanup()
end

return SlidingTween