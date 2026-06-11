local BaseState = require(game.ReplicatedStorage.Modules.StateMachineService.BaseState)
local GuiEnums = require(game.ReplicatedStorage.Data.Enums.GuiEnums)
local GuiTypes = require(game.ReplicatedStorage.Data.Types.GuiTypes)

local Loading = setmetatable({}, BaseState)
Loading.__index = Loading

local function randomExcept(min, max, excluded)
	local result
	repeat
		result = math.random(min, max)
	until result ~= excluded
	return result
end

function Loading.new(Parent, Dependencies, Shared)
	-- nil is enum
	local self: GuiTypes.State = BaseState.new(GuiEnums.States.Loading, Parent, Dependencies, Shared)
	setmetatable(self, Loading)
	
	self.Tweens = {}
	self.Loading = true
	
	return self
end

function Loading:HandleInput(Input: string | InputObject | Enum.HumanoidStateType)
	local self: GuiTypes.State = self
end

function Loading:Update(DeltaTime: number)
	local self: GuiTypes.State = self
end

function Loading:Enter(OldState: GuiTypes.State)
	local self: GuiTypes.State = self
	
	self.Dependencies.BlackScreen.Parent = self.Dependencies.LocalPlayer.PlayerGui
	self.Dependencies.LoadingScreen.Parent = self.Dependencies.LocalPlayer.PlayerGui
	local TweenInformation = TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	
	task.spawn(function()
		local RandomNumber = randomExcept(self.Dependencies.Config.BackgroundMin, self.Dependencies.Config.BackgroundMax, 0)
		local OldBackground = self.Dependencies.LoadingScreen.Backgrounds["Background"..RandomNumber]
		
		OldBackground.ImageTransparency = 0
		
		while self.Loading do
			task.wait()
			RandomNumber = randomExcept(1, 5, RandomNumber)
			local NewBackground = self.Dependencies.LoadingScreen.Backgrounds["Background"..RandomNumber]
			local OldTween: Tween = self.Dependencies.TweenService:Create(OldBackground, TweenInformation, {ImageTransparency = 1})
			local NewTween: Tween = self.Dependencies.TweenService:Create(NewBackground, TweenInformation, {ImageTransparency = 0})
			
			task.wait(self.Dependencies.Config.LoadingBackgroundDuration)
			OldTween:Play()
			OldTween.Completed:Wait()
			task.wait(self.Dependencies.Config.LoadingBackgroundDelay)
			NewTween:Play()
			NewTween.Completed:Wait()
			task.wait(self.Dependencies.Config.LoadingBackgroundDuration)
			
			OldBackground = NewBackground
		end
	end)
	
	task.spawn(function()
		while self.Loading do
			task.wait()
			for _, Bar in self.Dependencies.LoadingScreen.BarContainer:GetChildren() do
				if self.Tweens[Bar] then
					continue
				end

				local TweenInformation = TweenInfo.new(math.random(self.Dependencies.Config.AudioEffectDurationMin, self.Dependencies.Config.AudioEffectDurationMax),
					Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true)

				local Tween: Tween = self.Dependencies.TweenService:Create(Bar, TweenInformation,
					{Size = UDim2.new(Bar.Size.X.Scale, 0, math.random(self.Dependencies.Config.AudioEffectMin, self.Dependencies.Config.AudioEffectMax)/1000, 0)})

				Tween:Play()
				self.Tweens[Bar] = Tween

				Tween.Completed:Once(function()
					self.Tweens[Bar] = nil
				end)
			end
		end
	end)
	
	local Tween = self.Dependencies.TweenService:Create(self.Dependencies.BlackScreen.Frame, TweenInformation, {BackgroundTransparency = 1})
	Tween:Play()
	
	self.Dependencies.ContentProvider:PreloadAsync(self.Shared.Assets, function(Content)
		--print("✅ Asset With Id "..Content.." Loaded.")
		self.Shared.AssetsLoaded += 1

		if self.Shared.AssetsLoaded == self.Shared.AssetCount and self.Dependencies.LoadingScreen then
			self.Dependencies.LocalPlayer:SetAttribute("Loaded", true)
			Tween.Completed:Wait()
			--self.Parent:SetState(GuiEnums.States.Home)
		end
	end)
	
	task.delay(0.1, function()
		self.Parent:SetState(GuiEnums.States.Home)
	end)
	
	return true
end

function Loading:Exit(NewState: GuiTypes.State)
	local self: GuiTypes.State = self
	
	local TweenInformation = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local Tween: Tween = self.Dependencies.TweenService:Create(self.Dependencies.BlackScreen.Frame, TweenInformation, 
		{BackgroundTransparency = 0})

	Tween:Play()
	
	Tween.Completed:Wait()
	self.Loading = false
	self.Dependencies.LoadingScreen.Parent = game.ReplicatedStorage.Assets.Gui.MainMenu

	return true
end

return Loading
