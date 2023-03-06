--Blackjack version 0.0.6--

vers = "0.0.6"
local color = colors.black

--Made by Mavric on YouTube--
local buttons = {
    {"Stand", 16, colors.black, 15, 21},
    {"Hit", 22, colors.gray, 21, 25},
    {"Double", 26, colors.red, 25, 32}
}

local button = {
    {"Stand", 19, colors.black, 18, 24},
    {"Hit", 25, colors.gray, 24, 28}
}

local loop = true

os.loadAPI("/blackjack/pinapi.lua")

function clear()
    term.setBackgroundColor(8192)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.black)
    term.write("Blackjack OS ".. vers)
    term.setCursorPos(1, 2)
    term.setTextColor(colors.yellow)
    term.write("Made By Mavric, Please Report Bugs")
end

function drawCard(x, y, char, suit)
	if (suit == "\5" or suit == "\6") then
		color = colors.black
    else
        color = colors.red
    end
    local pic = paintutils.loadImage("/blackjack/card.nfp")
    paintutils.drawImage(pic, x, y)
    term.setCursorPos(x + 1, y + 1)
    term.setBackgroundColor(1)
    term.setTextColor(color)
    print(char)
    term.setCursorPos(x + 3, y + 3)
    print(suit)
	if char == 10 then
		term.setCursorPos(x + 4, y + 5)
	else
    	term.setCursorPos(x + 5, y + 5)
	end
    print(char)
end

function drawBack(x, y)
    local pic = paintutils.loadImage("/blackjack/cardBack.nfp")
    paintutils.drawImage(pic, x, y)
end

function drawBet(x, y, bal)
    local bet = 0
    while true do
        clear()
        local pic = paintutils.loadImage("/blackjack/logo.nfp")
        paintutils.drawImage(pic, x, y)
        term.setBackgroundColor(colors.green)
        term.setTextColor(colors.lime)
        term.setCursorPos(1, 3)
        term.write("$")
        term.write(tostring(bal))
        term.setCursorPos(x, y + 9)
        term.setTextColor(1)
        term.write("Bet: ")
        isbettt, bettt = pinapi.pinpad(x + 5, y + 9)
        bettt = tonumber(bettt)
        if (isbettt) then
            if bettt ~= nil then
                if bettt > 0 then
                    if bettt < bal or bettt == bal then
                        return bettt
                    end
                end
            end
        end
    end
end

function drawButton(dub)
    term.setTextColor(1)
    if (dub) then
        for k, v in pairs(buttons) do
            term.setBackgroundColor(buttons[k][3])
            term.setCursorPos(buttons[k][2], 30)
            term.write(buttons[k][1])
        end
    else
        for k, v in pairs(button) do
            term.setBackgroundColor(button[k][3])
            term.setCursorPos(button[k][2], 30)
            term.write(button[k][1])
        end
    end
end

function checkPress(xx, yy, dubb)
    if (dubb) then
        if yy == 30 then
            if xx > buttons[1][4] and xx < buttons[1][5] then
                return true, 1
            elseif xx > buttons[2][4] and xx < buttons[2][5] then
                return true, 2
            elseif xx > buttons[3][4] and xx < buttons[3][5] then
                return true, 3
            else
                return false
            end
        end
    else
        if yy == 30 then
            if xx > button[1][4] and xx < button[1][5] then
                return true, 1
            elseif xx > button[2][4] and xx < button[2][5] then
                return true, 2
            else
                return false
            end
        end
    end
end
