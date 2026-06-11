local MouseEvents = {}

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Signal = require(game.ReplicatedStorage.Modules.Signal)

local player = Players.LocalPlayer
local PlayerGui: PlayerGui = player.PlayerGui
local camera = Workspace.CurrentCamera

local cachedGUIDs = {}

local isFingerOnScreen = false

type Enter = RBXScriptSignal
type Leave = RBXScriptSignal

--[[
SMALL ISSUE: If position or size is not positive then MouseEvents will not work as intended you must set
the position and size to be positive or MouseEvents will not fire.

]]--



local function canFireEnter()
	if UserInputService.TouchEnabled and not isFingerOnScreen then
		return false
	end

	return true
end

UserInputService.TouchStarted:Connect(function()
	isFingerOnScreen = true
end)

UserInputService.TouchEnded:Connect(function()
	isFingerOnScreen = false
end)

local function areAncestorsVisible(guiObject: GuiObject): boolean
	local current = guiObject
	while current do
		if current:IsA("GuiObject") and current.Visible == false then
			return false
		elseif current:IsA("ScreenGui") and current.Enabled == false then
			return false
		end
		current = current.Parent
	end
	return true
end

local function isPointVisibleInHierarchy(guiObject: GuiObject, point: Vector2): boolean
	local ancestor = guiObject
	while ancestor and ancestor:IsA("GuiObject") do
		if not ancestor.Visible then
			return false
		end

		if ancestor.ClipsDescendants then
			local pos, size = ancestor.AbsolutePosition, ancestor.AbsoluteSize
			if point.X < pos.X or point.X > pos.X + size.X
				or point.Y < pos.Y or point.Y > pos.Y + size.Y then
				return false
			end
		end

		ancestor = ancestor.Parent
	end
	return true
end

local function isTopmost(guiObject: GuiObject, mousePos: Vector2): boolean
	if not isPointVisibleInHierarchy(guiObject, mousePos) then
		return false
	end

	local objectsAtPos = player.PlayerGui:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)
	for _, obj in ipairs(objectsAtPos) do
		if obj == guiObject or guiObject:IsDescendantOf(obj) then
			return true
		end
	end
	return true
end

function MouseEvents:IsMouseOverGuiObject(guiObject: GuiObject): boolean
	if UserInputService.TouchEnabled and not isFingerOnScreen then return false end

	local gui = guiObject:FindFirstAncestorWhichIsA("ScreenGui")
	if not gui then return false end
	if not areAncestorsVisible(guiObject) then return end

	local mousePos = UserInputService:GetMouseLocation()
	
	mousePos = Vector2.new(mousePos.X, mousePos.Y - GuiService:GetGuiInset().Y)
		
	if not isTopmost(guiObject, mousePos) then return end

	local topLeft = guiObject.AbsolutePosition
	local bottomRight = topLeft + guiObject.AbsoluteSize

	return mousePos.X >= topLeft.X and mousePos.X <= bottomRight.X
		and mousePos.Y >= topLeft.Y and mousePos.Y <= bottomRight.Y
end

function MouseEvents.new(guiObject: GuiObject): (RBXScriptSignal, RBXScriptSignal, string)
	local mouseEnter = Signal()
	local mouseLeave = Signal()
	-- signal needs to be destroyed
	local mouseIsOver = false

	local connectionGUID = HttpService:GenerateGUID(false)
	
	local function update()
		-- no signal destroyed event so we check if it can still be fired
		if not mouseEnter["Fire"] then
			RunService:UnbindFromRenderStep(connectionGUID)
			return
		end

		local isOver = MouseEvents:IsMouseOverGuiObject(guiObject)
		if isOver and not mouseIsOver and canFireEnter() then
			mouseIsOver = true
			mouseEnter:Fire()
		elseif not isOver and mouseIsOver then
			mouseIsOver = false
			mouseLeave:Fire()
		end
	end

	RunService:BindToRenderStep(connectionGUID, Enum.RenderPriority.First.Value, update)

	guiObject.AncestryChanged:Connect(function(_, parent)
		if not parent then
			RunService:UnbindFromRenderStep(connectionGUID)
		end
	end)

	return mouseEnter, mouseLeave
end

return MouseEvents