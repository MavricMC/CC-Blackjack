---Blackjack version 0.6---

--Edited by Mavric on YouTube--

--Made by Bloodmuffin on YoutTube--

---Settings---
local keypad = {
--{num,xpos,ypos}--
    {1, 20, 20},
    {2, 25, 20},
    {3, 30, 20},
    {4, 20, 22},
    {5, 25, 22},
    {6, 30, 22},
    {7, 20, 24},
    {8, 25, 24},
    {9, 30, 24},
    {10, 20, 26}, --clear
    {0, 25, 26},
    {11, 30, 26} --enter
}

local input = ""

---Functions---

--Checks to see if the x and y click is a button--
function checkClick(t, x, y)
    for i,v in pairs(t) do
        local num, cx, cy = unpack(v)
        if (x >= cx) and (x <= cx + 2) and (y == cy) then
	        return true, num
	    end
    end
  return false
end

--Draws the number pressed--
function numClick(num)
    if num ==  11 then
        return true, 0
    elseif num == 10 then
        return true, 1
    else
        input = input .. num
        term.write(tostring(num))
        return false
    end
end

--Main program--

function pinpad(xx, yy)
    input = ""
    term.setBackgroundColor(colors.brown)
    term.setTextColor(1)
    for i, v in pairs(keypad) do
        local num, x, y = unpack(v)
        term.setCursorPos(x, y)
        if num == 10 then
            term.setBackgroundColor(colors.red)
            term.write(" " .. "C" .. " ")
        elseif num == 11 then
            term.setBackgroundColor(colors.green)
            term.write(" " .. "E" .. " ")
        else
            term.setBackgroundColor(colors.brown)
            term.write(" " .. num .. " ")
        end
    end
    term.setBackgroundColor(colors.green)
    term.setTextColor(1)
    term.setCursorPos(xx, yy)
    while true do
        --Checks to see if player has clicked on the screen--
        local event, button, x, y = os.pullEvent("monitor_touch")
        --Checks if x and y pressed are a button--
        local validClick, num = checkClick(keypad, x, y)
        if (validClick) then
            local triger, but = numClick(num)
            if (triger) then
                if but == 0 then
                    local tig = input
                    input = ""
                    return true, tig
                elseif but == 1 then
                    return false
                end
            end
        end
    end
end
