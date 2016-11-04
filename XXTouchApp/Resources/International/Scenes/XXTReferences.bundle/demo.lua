--[[

	XXTouch天天爱消除经典模式.lua

	Created by 苏泽 on 16-08-13.
	Copyright (c) 2016年 苏泽. All rights reserved.

--]]

local topLeftX, topLeftY, iconWidth, iconHeight
local rowCount = 7
local colCount = 7

do
	local w, h = screen.size()
	if (w == 640 and h == 1136) then
		topLeftX = 8
		topLeftY = 302
		iconWidth = 90
		iconHeight = 90
	elseif (w == 750 and h == 1334) then
		topLeftX = 10
		topLeftY = 356
		iconWidth = 105
		iconHeight = 105
	elseif (w == 1242 and h == 2208) then
		topLeftX = 16
		topLeftY = 588
		iconWidth = 175
		iconHeight = 175
	elseif (w == 1536 and h == 2048) then
		topLeftX = 145
		topLeftY = 493
		iconWidth = 180
		iconHeight = 180
	elseif (w == 768 and h == 1024) then
		topLeftX = 72
		topLeftY = 246
		iconWidth = 90
		iconHeight = 90
	elseif (w == 640 and h == 960) then
		topLeftX = 8
		topLeftY = 214
		iconWidth = 90
		iconHeight = 90
	else
		error("不支持这个分辨率，可以尝试禁用放大模式使用。")
	end
end

local colorSim = 98

-- 要极限速度将下面几个数字全部改成 0 即可
local loopDelayRange = {1, 3}
local tapDelayRange = {0, 30}
local operationDelayRange = {30, 70}
local tapOffsetRange = {-15, 15}
-- --------------------------------

local keep = screen.keep
local get_color = screen.get_color
local msleep = sys.msleep
local toast = sys.toast
local touch_on = touch.on
local touch_off = touch.off


for i=1, 3 do
	toast("版权所有：XXTouch\n脚本开发讨论Q群：40898074")
	msleep(1000)
end

for i=1, 3 do
	toast((4-i).. "\n脚本不会自动停止")
	msleep(1000)
end

toast("开始！")

local iconPoints = {}
do
	local topLeftCX = topLeftX + iconWidth/2
	local topLeftCY = topLeftY + iconHeight/3
	for x=1, colCount do
		for y=1, rowCount do
			iconPoints[(y - 1)*colCount + x] = {
				math.floor(topLeftCX + iconWidth*(x - 1)),
				math.floor(topLeftCY + iconHeight*(y - 1)),
			}
		end
	end
end

local function getPoint(x, y)
	return iconPoints[(y - 1)*colCount + x]
end

local function getColorOfPoint(point)
	return get_color(point[1], point[2])
end

local function getColorOfIcon(x, y)
	return getColorOfPoint(getPoint(x, y))
end

local function isThreeColor(color1, color2, color3)
	if (cmpColor(color1, color2) >= colorSim and cmpColor(color1, color3) >= colorSim) then
		return true
	else
		return false
	end
end

do
	local abs			= math.abs
	local sqrt			= math.sqrt
	local ceil			= math.ceil
	function cmpColor(c0, c1)
		local x0, y0, z0 	= ( c0 / 0x10000 ), ( ( c0 % 0x10000 ) / 0x100 ), ( c0 % 0x100 )
		local x1, y1, z1 	= ( c1 / 0x10000 ), ( ( c1 % 0x10000 ) / 0x100 ), ( c1 % 0x100 )
		local xd 			= abs( x0 - x1 )
		local yd 			= abs( y0 - y1 )
		local zd 			= abs( z0 - z1 )
		local nd 			= sqrt( xd * xd + yd * yd )
		local r 			= sqrt( nd * nd + zd * zd )
		return ceil( ( 0xff - r ) / 0xff * 100 )
	end
end

function needUp(x, y, color)
	if (y > 1) then
		if (x > 2) then
			local UL1Color = getColorOfIcon(x - 1, y - 1)
			local UL2Color = getColorOfIcon(x - 2, y - 1)
			if (isThreeColor(color, UL1Color, UL2Color)) then
				return true
			end
		end
		if (x <= (colCount - 2)) then
			local UR1Color = getColorOfIcon(x + 1, y - 1)
			local UR2Color = getColorOfIcon(x + 2, y - 1)
			if (isThreeColor(color, UR1Color, UR2Color)) then
				return true
			end
		end
		if (x > 1 and x <= (colCount - 1)) then
			local UL1Color = getColorOfIcon(x - 1, y - 1)
			local UR1Color = getColorOfIcon(x + 1, y - 1)
			if (isThreeColor(color, UL1Color, UR1Color)) then
				return true
			end
		end
	end
	if (y > 3) then
		local U2Color = getColorOfIcon(x, y - 2)
		local U3Color = getColorOfIcon(x, y - 3)
		if (isThreeColor(color, U2Color, U3Color)) then
			return true
		end
	end
	return false
end

function needDown(x, y, color)
	if (y <= (rowCount - 1)) then
		if (x > 2) then
			local DL1Color = getColorOfIcon(x - 1, y + 1)
			local DL2Color = getColorOfIcon(x - 2, y + 1)
			if (isThreeColor(color, DL1Color, DL2Color)) then
				return true
			end
		end
		if (x <= (colCount - 2)) then
			local DR1Color = getColorOfIcon(x + 1, y + 1)
			local DR2Color = getColorOfIcon(x + 2, y + 1)
			if (isThreeColor(color, DR1Color, DR2Color)) then
				return true
			end
		end
		if (x > 1 and x <= (colCount - 1)) then
			local DL1Color = getColorOfIcon(x - 1, y + 1)
			local DR1Color = getColorOfIcon(x + 1, y + 1)
			if (isThreeColor(color, DL1Color, DR1Color)) then
				return true
			end
		end
	end
	if (y <= (rowCount - 3)) then
		local D2Color = getColorOfIcon(x, y + 2)
		local D3Color = getColorOfIcon(x, y + 3)
		if (isThreeColor(color, D2Color, D3Color)) then
			return true
		end
	end
	return false
end

function needLeft(x, y, color)
	if (x > 1) then
		if (y > 2) then
			local LU1Color = getColorOfIcon(x - 1, y - 1)
			local LU2Color = getColorOfIcon(x - 1, y - 2)
			if (isThreeColor(color, LU1Color, LU2Color)) then
				return true
			end
		end
		if (y <= (rowCount - 2)) then
			local LD1Color = getColorOfIcon(x - 1, y + 1)
			local LD2Color = getColorOfIcon(x - 1, y + 2)
			if (isThreeColor(color, LD1Color, LD2Color)) then
				return true
			end
		end
		if (y > 1 and y <= (rowCount - 1)) then
			local LD1Color = getColorOfIcon(x - 1, y + 1)
			local LU1Color = getColorOfIcon(x - 1, y - 1)
			if (isThreeColor(color, LD1Color, LU1Color)) then
				return true
			end
		end
	end
	if (x > 3) then
		local L2Color = getColorOfIcon(x - 2, y)
		local L3Color = getColorOfIcon(x - 3, y)
		if (isThreeColor(color, L2Color, L3Color)) then
			return true
		end
	end
	return false
end

function needRight(x, y, color)
	if (x <= (colCount - 1)) then
		if (y > 2) then
			local RU1Color = getColorOfIcon(x + 1, y - 1)
			local RU2Color = getColorOfIcon(x + 1, y - 2)
			if (isThreeColor(color, RU1Color, RU2Color)) then
				return true
			end
		end
		if (y <= (rowCount - 2)) then
			local RD1Color = getColorOfIcon(x + 1, y + 1)
			local RD2Color = getColorOfIcon(x + 1, y + 2)
			if (isThreeColor(color, RD1Color, RD2Color)) then
				return true
			end
		end
		if (y > 1 and y <= (rowCount - 1)) then
			local RD1Color = getColorOfIcon(x + 1, y + 1)
			local RU1Color = getColorOfIcon(x + 1, y - 1)
			if (isThreeColor(color, RD1Color, RU1Color)) then
				return true
			end
		end
	end
	if (x <= (colCount - 3)) then
		local R2Color = getColorOfIcon(x + 2, y)
		local R3Color = getColorOfIcon(x + 3, y)
		if (isThreeColor(color, R2Color, R3Color)) then
			return true
		end
	end
	return false
end

local function tapPoint(point)
	local random = math.random
	touch_on(
		1,
		point[1] + random(tapOffsetRange[1], tapOffsetRange[2]),
		point[2] + random(tapOffsetRange[1], tapOffsetRange[2])
	)
	msleep(random(tapDelayRange[1], tapDelayRange[2]))
	touch_off(
		1,
		point[1] + random(tapOffsetRange[1], tapOffsetRange[2]),
		point[2] + random(tapOffsetRange[1], tapOffsetRange[2])
	)
	msleep(random(tapDelayRange[1], tapDelayRange[2]))
end

local function moveUp(x, y)
	tapPoint(getPoint(x, y))
	tapPoint(getPoint(x, y - 1))
end

local function moveDown(x, y)
	tapPoint(getPoint(x, y))
	tapPoint(getPoint(x, y + 1))
end

local function moveLeft(x, y)
	tapPoint(getPoint(x, y))
	tapPoint(getPoint(x - 1, y))
end

local function moveRight(x, y)
	tapPoint(getPoint(x, y))
	tapPoint(getPoint(x + 1, y))
end

local scanners = {
	needUp,
	needDown,
	needLeft,
	needRight,
}

local delegates = {
	moveUp,
	moveDown,
	moveLeft,
	moveRight,
}

local hybridScanOrders = {
	{
		{1, colCount, 1},
		{1, rowCount, 1},
	},
	{
		{1, colCount, 1},
		{rowCount, 1, -1},
	},
	{
		{colCount, 1, -1},
		{1, rowCount, 1},
	},
	{
		{colCount, 1, -1},
		{rowCount, 1, -1},
	},
}

local function scan(...)
	local mode = math.random(1, #hybridScanOrders)
	for x=hybridScanOrders[mode][1][1], hybridScanOrders[mode][1][2], hybridScanOrders[mode][1][3] do
		for y=hybridScanOrders[mode][2][1], hybridScanOrders[mode][2][2], hybridScanOrders[mode][2][3] do
			local color = getColorOfIcon(x, y)
			for id, scanner in ipairs(scanners) do
				if (scanner(x, y, color)) then
					return id, x, y
				end
			end
		end
	end
	return 0
end

local function play(id, x, y)
	if (delegates[id]) then
		delegates[id](x, y)
		msleep(math.random(operationDelayRange[1], operationDelayRange[2]))
	else
		msleep(math.random(loopDelayRange[1], loopDelayRange[2]))
	end
end

while (true) do
	keep()
	play(scan())
end
