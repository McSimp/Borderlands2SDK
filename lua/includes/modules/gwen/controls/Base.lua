local oo = oo
local table = table

local BaseControl = oo.CreateClass("Gwen.Control.Base")

function BaseControl:Init(parent)
	self.parent = nil
	self.actualParent = nil
	self.innerPanel = nil
	self.skin = nil
	self:SetParent(parent)
	self.hidden = false
	self.bounds = GwenRect(0, 0, 10, 10)
	self.padding = GwenPadding(0, 0, 0, 0)
	self.margin = GwenMargin(0, 0, 0, 0)
	self.iDock = 0
	self:RestrictToParent(false)
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(false)
	self:Invalidate()
	self:SetCursor("normal")
	self:SetToolTip(nil)
	self:SetTabable(false)
	self:SetShouldDrawBackground(true)
	self.disabled = false
	self.includeInSize = true

	self.children = {}
	self.innerBounds = GwenRect(0, 0, 0, 0)
	self.renderBounds = GwenRect(0, 0, 0, 0)
end

function BaseControl:Delete()
	-- Traverse backwards so we can delete as we go through
	for i=#self.children,1,-1 do
		self.children[i]:Delete()
		table.remove(self.children, i)
	end

	-- TODO
end

function BaseControl:DelayedDelete()
	self:GetCanvas():AddDelayedDelete(self)
end

function BaseControl:SetParent(parent)
	if self.parent == parent then return end

	-- If this control already has a parent, remove this control from it
	-- and add it to the new one.
	if self.parent then
		self.parent:RemoveChild(self)
	end

	self.parent = parent
	self.actualParent = nil

	if parent then
		parent:AddChild(self)
	end
end

function BaseControl:GetParent()
	return self.parent
end

function BaseControl:GetCanvas()
	if not self.parent then return nil end

	return self.parent:GetCanvas()
end

function BaseControl:GetChildren()
	if self.innerPanel then
		return self.innerPanel:GetChildren()
	else
		return self.children
	end
end

function BaseControl:IsChild(control)
	return table.contains(self.children, control)
end

function BaseControl:NumChildren()
	return #self.children
end

function BaseControl:GetChild(i)
	return self.children[i]
end

function BaseControl:SizeToChildren(w, h)
	if w == nil then w = true end
	if h == nil then h = true end

	local size = self:ChildrenSize()
	size.x = size.x + self:GetPadding().right
	size.y = size.y + self:GetPadding().bottom

	return self:SetSize(w and size.x or self:Width(), h and size.y or self:Height())
end

function BaseControl:ChildrenSize()
	local size = GwenPoint()

	for _,child in self.children do
		if not child:Hidden() and child:ShouldIncludeInSize() then
			size.x = math.max(size.x, child:Right())
			size.y = math.max(size.y, child:Bottom())
		end
	end

	return size
end

function BaseControl:Think()
	return
end

function BaseControl:AddChild(child)
	if self.innerPanel then
		self.innerPanel:AddChild(child)
		return
	end

	table.insert(self.children, child)
	child.actualParent = self
end

function BaseControl:RemoveChild(child)
	if self.innerPanel == child then
		self.innerPanel = nil
	end

	if self.innerPanel then
		self.innerPanel:RemoveChild(child)
	end

	table.removeValue(self.children, child)
end

function BaseControl:RemoveAllChildren()
	self.innerPanel = nil
	self.children = {}
end

function BaseControl:SendToBack()
	if not self.actualParent then return end
	if self.actualParent.children[1] == self then return end

	table.removeValue(self.actualParent.children, self)
	table.insert(self.actualParent.children, self)

	self:InvalidateParent()
	self:Redraw()
end

function BaseControl:BringToFront()
	if not self.actualParent then return end
	if self.actualParent.children[self.actualParent:NumChildren()] == self then return end

	table.removeValue(self.actualParent.children, self)
	table.insert(self.actualParent.children, self)

	self:InvalidateParent()
	self:Redraw()
end

function BaseControl:BringNextToControl(child, behind)
	error("NYI: BaseControl:BringNextToControl")
end

function BaseControl:LocalPosToCanvas(localPos)
	if not self.parent then return localPos end

	local x = localPos.x + self:X()
	local y = localPos.y + self:Y()

	-- If the parent has an innerPanel and we're a child of it, add its offset
	-- onto our position.
	if self.parent.innerPanel and self.parent.innerPanel:IsChild(self) then
		x = x + self.parent.innerPanel:X()
		y = y + self.parent.innerPanel:Y()
	end

	return self.parent:LocalPosToCanvas(GwenPoint(x, y))
end

function BaseControl:CanvasPosToLocal(canvasPos)
	if not self.parent then return canvasPos end

	local x = canvasPos.x - self:X()
	local y = canvasPos.y - self:Y()

	if self.parent.innerPanel and self.parent.innerPanel:IsChild(self) then
		x = x - self.parent.innerPanel:X()
		y = y - self.parent.innerPanel:Y()
	end

	return self.parent:CanvasPosToLocal(GwenPoint(x, y))
end

function BaseControl:Dock(iDock)
	if self.iDock == iDock then return end

	self.iDock = iDock
	self:Invalidate()
	self:InvalidateParent()
end

function BaseControl:GetDock()
	return self.iDock
end

function BaseControl:RestrictToParent(restrict)
	self.restrictToParent = restrict
end

function BaseControl:ShouldRestrictToParent()
	return self.restrictToParent
end

function BaseControl:X()
	return self.bounds.x
end

function BaseControl:Y()
	return self.bounds.y
end

function BaseControl:Width()
	return self.bounds.w
end

function BaseControl:Height()
	return self.bounds.h
end

function BaseControl:Bottom()
	return self.bounds.y + self.bounds.h + self.margin.bottom
end

function BaseControl:Right()
	return self.bounds.x + self.bounds.w + self.margin.right
end

function BaseControl:GetMargin()
	return self.margin
end

function BaseControl:GetPadding()
	return self.padding
end

-- Two functions - either call it with a point or call it with x and y
function BaseControl:SetPos(x, y)
	if y == nil then
		-- x is a point
		y = x.y
		x = x.x
	end

	self:SetBounds(x, y, self:Width(), self:Height())
end

function BaseControl:GetPos()
	return GwenPoint(self:X(), self:Y())
end

function BaseControl:SetWidth(w)
	self:SetSize(w, self:Height())
end

function BaseControl:SetHeight(h)
	self:SetSize(self:Width(), h)
end

-- Two functions - either call with a point or call it with w and h
function BaseControl:SetSize(w, h)
	if h == nil then
		-- w is a point
		h = w.y
		w = w.x
	end

	self:SetBounds(self:X(), self:Y(), w, h)
end

function BaseControl:GetSize()
	return GwenPoint(self:Width(), self:Height())
end

-- Two functions - either call with GwenRect or with x,y,w,h
function BaseControl:SetBounds(x, y, w, h)
	if y == nil then
		-- x is a GwenRect
		y = x.y
		w = x.w
		h = x.h
		x = x.x
	end

	local oldBounds = table.copy(self:GetBounds())
	self.bounds = GwenRect(x, y, w, h)
	self:OnBoundsChanged(oldBounds)
end

function BaseControl:SetPadding(padding)
	self.padding = table.copy(padding)
	self:Invalidate()
	self:InvalidateParent()
end

function BaseControl:SetMargin(margin)
	self.margin = table.copy(margin)
	self:Invalidate()
	self:InvalidateParent()
end

