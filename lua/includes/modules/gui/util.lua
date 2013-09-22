function GwenColor(r, g, b, a)
	return Color(r, g, b, a)
end

-- TODO: Does using an FFI struct increase performance enough to justify using it?
function GwenRect(x, y, width, height)
	local rect = {}
	rect.x = x
	rect.y = y
	rect.w = width
	rect.h = height
	return rect
end

function GwenMargin(left, top, right, bottom)
	local margin = {}
	margin.left = left
	margin.top = top
	margin.right = right
	margin.bottom = bottom
	return margin
end
