-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- Modules --
local TransitionButton = require("../Wrappers/TransitionButton")
local DefaultButton = require("../Wrappers/DefaultButton")
local TweenFactory = require("../TweenFactory")
local MouseEvents = require("../../../Modules/MouseEvents")
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local BaseState = require(ReplicatedStorage.Modules.StateMachineService.BaseState)
local GuiEnums = require(ReplicatedStorage.Data.Enums.GuiEnums)
local GuiTypes = require(ReplicatedStorage.Data.Types.GuiTypes)
local GuiConfig = require(ReplicatedStorage.Data.Configs.GuiConfig)

-- References --
local LocalPlayer = Players.LocalPlayer

local MainMenu = ReplicatedStorage.Assets.Gui.MainMenu
local MainMenuSounds = ReplicatedStorage.Assets.Sounds.MainMenu
local ShopScreen = MainMenu.ShopScreen
local BlackScreen = MainMenu.BlackScreen

local RequestCheckout = ReplicatedStorage.Remotes.ShopRemotes.RequestCheckout

local Shop = setmetatable({}, BaseState)
Shop.__index = Shop

function Shop.new(Parent, Dependencies, Shared)
	-- nil is enum
	local self: GuiTypes.State = BaseState.new(GuiEnums.States.Shop, Parent, Dependencies, Shared)
	setmetatable(self, Shop)
	
	-- RequestCheckoutRemote --> (ItemEnum)
	RequestCheckout:FireServer()

	return self
end

function Shop:HandleInput(Input: string | InputObject | Enum.HumanoidStateType)
	local self: GuiTypes.State = self
end

function Shop:Update(DeltaTime: number)
	local self: GuiTypes.State = self
end

function Shop:Enter(OldState: GuiTypes.State)
	local self: GuiTypes.State = self
	ShopScreen.Parent = LocalPlayer.PlayerGui
	-- TODO: abstract button stuff when bored and have time
	self.Janitor = Janitor.new()

	local FadeToTransparent = TweenFactory:CreateTween(BlackScreen.Frame, GuiConfig.Tweens.FadeToTransparent)
	FadeToTransparent:Play()
	
	local Parent = self.Parent
	local BackButtonCallbacks = {}
	function BackButtonCallbacks:OnActivated()
		Parent:SetState(GuiEnums.States.Home)
	end
	local BackButton = TransitionButton.new(ShopScreen.Back, BackButtonCallbacks)
	self.Janitor:Add(BackButton, "TransitionButtonDestroy")

	for _, DonationProduct in ShopScreen.Donations:GetChildren() do
		local ItemButton = DefaultButton.new(DonationProduct.Price)
		self.Janitor:Add(ItemButton, "DefaultButtonDestroy")
		
		ItemButton.Button.Activated:Connect(function()
			ItemButton:DefaultButtonOnActivated()
			RequestCheckout:FireServer(DonationProduct:GetAttribute("PassEnum"))
			TweenFactory:CreateTween(ItemButton.Button, GuiConfig.Tweens.YellowTextUnhighlight):Play()
			TweenFactory:CreateTween(DonationProduct.Highlight, GuiConfig.Tweens.IconShrink):Play()
		end)

		self.Janitor:Add(ItemButton.MouseEnter:Connect(function()
			ItemButton:DefaultButtonOnEnter()
			TweenFactory:CreateTween(ItemButton.Button, GuiConfig.Tweens.YellowTextHighlight):Play()
			TweenFactory:CreateTween(DonationProduct.Highlight, GuiConfig.Tweens.IconExpand):Play()
		end), "Disconnect")

		self.Janitor:Add(ItemButton.MouseLeave:Connect(function()
			TweenFactory:CreateTween(ItemButton.Button, GuiConfig.Tweens.YellowTextUnhighlight):Play()
			TweenFactory:CreateTween(DonationProduct.Highlight, GuiConfig.Tweens.IconShrink):Play()
		end), "Disconnect")
	end
	
	local function CreatePriceButtons(Table)
		for _, Item in Table do
			if not Item:IsA("Folder") then
				continue
			end
			local ItemButton = DefaultButton.new(Item.Price)
			self.Janitor:Add(ItemButton, "DefaultButtonDestroy")

			ItemButton.Button.Activated:Connect(function()
				ItemButton:DefaultButtonOnActivated()
				RequestCheckout:FireServer(Item:GetAttribute("PassEnum"))
				TweenFactory:CreateTween(ItemButton.Button, GuiConfig.Tweens.YellowTextUnhighlight):Play()
			end)

			self.Janitor:Add(ItemButton.MouseEnter:Connect(function()
				ItemButton:DefaultButtonOnEnter()
				TweenFactory:CreateTween(ItemButton.Button, GuiConfig.Tweens.YellowTextHighlight):Play()
			end), "Disconnect")

			self.Janitor:Add(ItemButton.MouseLeave:Connect(function()
				TweenFactory:CreateTween(ItemButton.Button, GuiConfig.Tweens.YellowTextUnhighlight):Play()
			end), "Disconnect")
		end
	end
	
	CreatePriceButtons(ShopScreen.Humans:GetChildren())
	CreatePriceButtons(ShopScreen.Dinosaurs:GetChildren())

	
	return true
end

function Shop:Exit(NewState: GuiTypes.State)
	local self: GuiTypes.State = self

	local FadeToOpaque = TweenFactory:CreateTween(BlackScreen.Frame, GuiConfig.Tweens.FadeToOpaque)
	FadeToOpaque:Play()

	self.Janitor:Cleanup()

	FadeToOpaque.Completed:Wait()
	
	ShopScreen.Parent = game.ReplicatedStorage.Assets.Gui.MainMenu
	
	return true
end

return Shop
