-- Services --
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- Modules --
local TweenFactory = require("./TweenFactory")
local GuiConfig = require(game.ReplicatedStorage.Data.Configs.GuiConfig)

-- References --
local LocalPlayer = Players.LocalPlayer
local CursorGui = game.ReplicatedStorage.Assets.Gui.CursorGui
local Cursor = CursorGui.Cursor
local Mouse = LocalPlayer:GetMouse()

-- State --
CursorGui.Parent = LocalPlayer.PlayerGui
UserInputService.MouseIconEnabled = false

-- Connections --
RunService.PreRender:Connect(function()
	UserInputService.MouseIconEnabled = false
	Cursor.Position = UDim2.new(0, Mouse.X - 17, 0, Mouse.Y + GuiService:GetGuiInset().Y - 11.5)
end)

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	-- Check if the click is a left mouse button press
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		-- Get the current mouse position on the screen
		local mousePos = UserInputService:GetMouseLocation()

		-- Fetch all GUI objects at the mouse coordinates
		local objectsAtPosition = PlayerGui:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y - GuiService:GetGuiInset().Y)

		-- Loop through the returned objects
		for _, guiObject in ipairs(objectsAtPosition) do
			if not guiObject.Interactable then
				continue
			end
			print("You clicked on:", guiObject:GetFullName())
			-- Animate mouse
			--local MedTween = TweenFactory:CreateTween(Cursor.SecondLayer, GuiConfig.Tweens.MouseMediumSizeTween)
			--MedTween:Play()
			--MedTween.Completed:Wait()
			
			--local LargeTween = TweenFactory:CreateTween(Cursor.ThirdLayer, GuiConfig.Tweens.MouseLargeSizeTween)
			--LargeTween:Play()
			--LargeTween.Completed:Wait()
			
			--task.wait(0.05)
			
			--Cursor.SecondLayer.Size = UDim2.new(0, 0, 0, 0)
			--Cursor.ThirdLayer.Size = UDim2.new(0, 0, 0, 0)
			
			local MouseActivatedTween = TweenFactory:CreateTween(Cursor.FirstLayer, GuiConfig.Tweens.MouseActivated)
			MouseActivatedTween:Play()
			break
		end
	end
end)


return {}
