---Blackjack version 0.8---

---Remade from the ground up but thanks to blood muffin for the original that got me started on this project---

---Settings---
local buttons = {
    --{number, xPos, yPos}--
        {"1", 20, 20},
        {"2", 25, 20},
        {"3", 30, 20},
        {"4", 20, 22},
        {"5", 25, 22},
        {"6", 30, 22},
        {"7", 20, 24},
        {"8", 25, 24},
        {"9", 30, 24},
        {"0", 25, 26},
        {"10", 20, 26}, --clear
        {"11", 30, 26}  --enter
    }
    
    local pressed = ""
    
    ---Functions---
    
    --Checks to see if x and y cords click match with button--
    function checkButton(xPressed, yPressed)
        for k, v in pairs(buttons) do
            if yPressed == v[3] then
                if xPressed >= v[2] and xPressed <= (v[2] + 2) then
                    return true, v[1]
                end
            end
        end
        return false
    end
    
    --Main program--
    
    function runPinpad(x, y)
        --Resets everything--
        pressed = ""
        term.setBackgroundColor(colors.brown)
        term.setTextColor(1)
        --Draws the button as the number or a letter for the controls--
        for k, v in pairs(buttons) do
            term.setCursorPos(v[2], v[3])
            if v[1] == "10" then
                term.setBackgroundColor(colors.red)
                term.write(" " .. "C" .. " ")
            elseif v[1] == "11" then
                term.setBackgroundColor(colors.green)
                term.write(" " .. "E" .. " ")
            else
                term.setBackgroundColor(colors.brown)
                term.write(" " .. v[1] .. " ")
            end
        end
        term.setBackgroundColor(colors.green)
        term.setTextColor(1)
        term.setCursorPos(x, y)
        --Checks click until clear or enter pressed--
        while true do
            --Sets up event listener for a press on the screen--
            local event, button, xp, yp = os.pullEvent("monitor_touch")
            --Uses checkButton to check the x and y against buttons--
            local isClick, numClicked = checkButton(xp, yp)
            --Run if a button was clicked--
            if (isClick) then
                if numClicked == "10" then
                    --If clicked clear return false--
                    return false
                elseif numClicked == "11" then
                    --If clicked enter return true and the string of numbers entered--
                    return true, pressed
                else
                    --If a number pressed add that number to the string of numbers pressed--
                    pressed = pressed.. numClicked
                    --Write the number to the screen so the player knows what they pressed--
                    term.write(numClicked)
                end
            end
        end
    end
