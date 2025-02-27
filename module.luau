--// @RebornEnder 2025

type deg = number

local HttpService = game:GetService("HttpService")

local Config = {
	ToastSize = UDim.new(250, 56),
	ToastOffsetScreen = UDim.new(18, 28),
	ToastOffsetLayout = UDim.new(0, 5),
	TweenSpeed = 0.25
}

local function Color3ToGradient(Rotation: deg, Color: Color3)
	local UIGradient = Instance.new("UIGradient")
	UIGradient.Rotation = Rotation
	UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color),
		ColorSequenceKeypoint.new(0.01, Color3.new(Color.R / 2, Color.G / 2, Color.B / 2)),
		ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
	})
	UIGradient.Transparency = NumberSequence.new(0, 0.25)
	return UIGradient
end

local function SmoothListLayout(MainGuiBase: GuiBase, Padding: UDim): ()
	if not MainGuiBase then error("SmoothListLayout called but no GuiBase was provided.", 2) end
	if not Padding then Padding = UDim.new(0, 0) end

	local function UpdateLayout(): ()
		local GuiObjects: table = (function()
			local tmp = {}
			for _, obj in MainGuiBase:GetChildren() do
				if obj:IsA("GuiBase") then
					table.insert(tmp, obj)
				end
			end	
			table.sort(tmp, function(a: GuiBase, b: GuiBase)
				return a.LayoutOrder > b.LayoutOrder
			end)
			return tmp
		end)()

		for index: number, object: GuiBase in GuiObjects do
			index -= 1

			local ObjectPosition = UDim2.new(
				MainGuiBase.Size.X.Scale - object.Size.X.Scale,
				MainGuiBase.Size.X.Offset - object.Size.X.Offset,
				MainGuiBase.Size.Y.Scale - ((object.Size.Y.Scale + Padding.Scale) * index),
				MainGuiBase.Size.Y.Offset - ((object.Size.Y.Offset + Padding.Offset) * index)
			)

			if index == 0 then
				object.Position = ObjectPosition
			else
				object:TweenPosition(ObjectPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, Config.TweenSpeed, true)
			end
		end
	end

	local function TrackObject(GuiObject: GuiBase): ()
		if not GuiObject:IsA("GuiBase") then return end
		--[[local Connection = GuiObject.Changed:Connect(UpdateLayout)
		GuiObject.Destroying:Connect(function()
			Connection:Disconnect()
		end)]] --// Disabled due to buggy behavior when tracking changes.

		UpdateLayout()
	end

	MainGuiBase.ChildAdded:Connect(TrackObject)
	MainGuiBase.ChildRemoved:Connect(UpdateLayout)
end

local DynamicToasts = {
	ToastTypes = {
		Info = 1,
		Okay = 2,
		Warning = 3,
		Bad = 4
	},

	ToastGradients = {
		Color3ToGradient(30, Color3.fromRGB(0, 128, 255)),
		Color3ToGradient(30, Color3.fromRGB(0, 255, 128)),
		Color3ToGradient(30, Color3.fromRGB(255, 192, 0)),
		Color3ToGradient(30, Color3.fromRGB(255, 0, 64))
	},

	RawToast = function()
		local ToastElements = {
			Toast = Instance.new("Frame"),
			Container = Instance.new("Frame"),
			ToastTitle = Instance.new("TextLabel"),
			ToastDescription = Instance.new("TextLabel"),
			FlexItem = Instance.new("UIFlexItem"),
			Corner = Instance.new("UICorner"),
			ListLayout = Instance.new("UIListLayout"),
			Padding = Instance.new("UIPadding")
		}

		--// Toast
		ToastElements.Toast.Name = `Toast {HttpService:GenerateGUID(true)}`
		ToastElements.Toast.BackgroundTransparency = 1
		ToastElements.Toast.Size = UDim2.new(1, 0, 0, Config.ToastSize.Offset)

		--// Container
		ToastElements.Container.Name = "Container"
		ToastElements.Container.AnchorPoint = Vector2.new(1, 0.5)
		ToastElements.Container.BackgroundColor3 = Color3.new(1, 1, 1)
		ToastElements.Container.Position = UDim2.new(1, 0, 0.5, 0)
		ToastElements.Container.Size = UDim2.new(1, -Config.ToastOffsetScreen.Scale, 1, 0)
		ToastElements.Container.Parent = ToastElements.Toast

		--// ToastTitle
		local TTTextSize = 16
		ToastElements.ToastTitle.Name = "ToastTitle"
		ToastElements.ToastTitle.BackgroundTransparency = 1
		ToastElements.ToastTitle.LayoutOrder = 0
		ToastElements.ToastTitle.Size = UDim2.new(1, 0, 0, TTTextSize)
		ToastElements.ToastTitle.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold)
		ToastElements.ToastTitle.TextColor3 = Color3.new(1, 1, 1)
		ToastElements.ToastTitle.TextSize = TTTextSize
		ToastElements.ToastTitle.TextTruncate = Enum.TextTruncate.AtEnd
		ToastElements.ToastTitle.TextXAlignment = Enum.TextXAlignment.Right
		ToastElements.ToastTitle.Parent = ToastElements.Container

		--// ToastDescription
		local TDTextSize = 14
		ToastElements.ToastDescription.Name = "ToastDescription"
		ToastElements.ToastDescription.BackgroundTransparency = 1
		ToastElements.ToastDescription.LayoutOrder = 1
		ToastElements.ToastDescription.Size = UDim2.new(1, 0, 0, TDTextSize)
		ToastElements.ToastDescription.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium)
		ToastElements.ToastDescription.TextColor3 = Color3.new(1, 1, 1)
		ToastElements.ToastDescription.TextSize = TDTextSize
		ToastElements.ToastDescription.TextTruncate = Enum.TextTruncate.AtEnd
		ToastElements.ToastDescription.TextWrapped = true
		ToastElements.ToastDescription.TextXAlignment = Enum.TextXAlignment.Right
		ToastElements.ToastDescription.Parent = ToastElements.Container

		--// FlexItem
		ToastElements.FlexItem.FlexMode = Enum.UIFlexMode.Fill
		ToastElements.FlexItem.Parent = ToastElements.ToastDescription

		--// Corner
		ToastElements.Corner.CornerRadius = UDim.new(0, 6)
		ToastElements.Corner.Parent = ToastElements.Container

		--// ListLayout
		ToastElements.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ToastElements.ListLayout.Parent = ToastElements.Container

		--// Padding
		ToastElements.Padding.PaddingBottom = UDim.new(0, 5)
		ToastElements.Padding.PaddingLeft = UDim.new(0, 80)
		ToastElements.Padding.PaddingRight = UDim.new(0, 10)
		ToastElements.Padding.PaddingTop = UDim.new(0, 5)
		ToastElements.Padding.Parent = ToastElements.Container

		return ToastElements
	end,

	ContainerGui = (function()
		if gethui then
			return gethui()
		elseif pcall(function() return game:GetService("CoreGui").ClassName end) then
			return game:GetService("CoreGui")
		else
			return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
		end
	end)()
}

return function()
	local LayoutOrder = -999999999
	local UIElements = {
		ScreenUI = Instance.new("ScreenGui"),
		ToastContainer = Instance.new("Frame"),
		--// ListLayout = Instance.new("UIListLayout")
	}

	--// ScreenUI
	UIElements.ScreenUI.Name = "DynamicToasts"
	UIElements.ScreenUI.DisplayOrder = 999999999
	--// UIElements.ScreenUI.IgnoreGuiInset = true
	UIElements.ScreenUI.ResetOnSpawn = false
	UIElements.ScreenUI.Parent = DynamicToasts.ContainerGui

	--// ToastContainer
	UIElements.ToastContainer.Name = "ToastContainer"
	UIElements.ToastContainer.BackgroundTransparency = 1
	UIElements.ToastContainer.Position = UDim2.new(0, 0, 0, Config.ToastOffsetScreen.Offset)
	UIElements.ToastContainer.Size = UDim2.new(0, Config.ToastSize.Scale + Config.ToastOffsetScreen.Scale, 1, -(Config.ToastOffsetScreen.Offset * 2))
	UIElements.ToastContainer.ClipsDescendants = true
	UIElements.ToastContainer.Parent = UIElements.ScreenUI

	--// ListLayout
	SmoothListLayout(UIElements.ToastContainer, Config.ToastOffsetLayout)
	--UIElements.ListLayout.Padding = Config.ToastOffsetLayout
	--UIElements.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	--UIElements.ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	--UIElements.ListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	--UIElements.ListLayout.Parent = UIElements.ToastContainer

	return {
		ToastType = DynamicToasts.ToastTypes,
		NewToast = function(self, ToastType: number?, ToastTitle: string?, ToastDescription: string?, Duration: number?): ()
			if not self then error("Expected ':' not '.' calling member function NewToast", 2) end
			local Toast = DynamicToasts.RawToast()
			DynamicToasts.ToastGradients[ToastType or 1]:Clone().Parent = Toast.Container
			Toast.ToastTitle.Text = ToastTitle or "DynamicToasts"
			Toast.ToastDescription.Text = ToastDescription or "?"
			Toast.Toast.LayoutOrder = LayoutOrder
			LayoutOrder += 1
			Toast.Toast.Parent = UIElements.ToastContainer
			task.spawn(function()
				local Basic = {
					Position = Toast.Container.Position,
					Size = Toast.Container.Size
				}

				local Late = {
					Position = UDim2.new(-0.25, 0, 0.5, 0),
					Size = UDim2.new(Toast.Container.Size.X.Scale / 4, Toast.Container.Size.X.Offset, Toast.Container.Size.Y.Scale / 4, Toast.Container.Size.Y.Offset)
				}

				Toast.Container.Position = Late.Position
				Toast.Container.Size = Late.Size
				Toast.Container:TweenSizeAndPosition(Basic.Size, Basic.Position, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, Config.TweenSpeed, true, function()
					task.wait(Duration or 5)
					Toast.Container:TweenSizeAndPosition(Late.Size, Late.Position, Enum.EasingDirection.In, Enum.EasingStyle.Quart, Config.TweenSpeed, true, function()
						Toast.Toast:Destroy()
					end)
				end)
			end)
		end,
	}
end
