local GuiConfig = require(game.ReplicatedStorage.Data.Configs.GuiConfig)
local TweenService = game:GetService("TweenService")

local TweenFactory = {}

function TweenFactory:CreateTween(Target, Config)
	local FadeToOpaque = TweenService:Create(Target, Config.TweenInformation, Config.PropertyTable)

	return FadeToOpaque
end

return TweenFactory
