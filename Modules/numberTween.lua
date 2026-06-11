local NumberTween = {}
NumberTween.__index = NumberTween

function NumberTween.new(Parent)
	local self = {}
	self.Parent = Parent

	self.Direction = (self.Parent.Target - self.Parent.Initial) >= 0 and 1 or -1
	return setmetatable(self, NumberTween)
end

function NumberTween:Update(DeltaTime: number): never
	self.Direction = (self.Parent.Target - self.Parent.Value) >= 0 and 1 or -1

	if self.Parent.Value == self.Parent.Target or DeltaTime == 0 then
		return self.Parent.Value
	end

	local Distance = math.abs(self.Parent.Target - self.Parent.Value)
	local Step = self.Parent.Speed * DeltaTime

	if Step >= Distance then
		self.Parent.Value = self.Parent.Target
	else
		self.Parent.Value = self.Parent.Value + Step * self.Direction
	end
end

return NumberTween