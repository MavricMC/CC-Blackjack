---Blackjack version 0.9---
local version = "0.9"

--Made by Mavric--
--Code on https://github.com/MavricMC/CC-Blackjack--

os.pullEvent = os.pullEventRaw --Prevent program termination
settings.set("shell.allow_disk_startup", false)
settings.save()

---Settings---
local atm = "blackjack_1"
local bankSide = "top"
local server = 0
local screen = "left"
local drive = "bottom"
local background = colors.green
--Card X cords--
local xCords = {
    {23},
    {18, 26},
    {14, 22, 30},
    {10, 18, 26, 34},
    {6, 14, 22, 30, 38},
    {3, 11, 19, 27, 35, 43}
}
--Pinpad Button info--
local pinpad = {
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
--Game Buttons--
local buttons = {
--{text, xWritePos, color, x cord each side of the button}--
    {"Stand", 18, colors.black,},
    {"Hit", 24, colors.gray},
    {"Double", 28, colors.red}
}
--Without double--
local button = {
    {"Stand", 20, colors.black, 18, 24},
    {"Hit", 26, colors.gray, 24, 28}
}

local xOffset = 2
local xOffsetDealer = 2
local double = false
local doubled = false
local betting = {}
local text = {}
rednet.open(bankSide)
local m = peripheral.wrap(screen)

--Bank functions--
function balance(account, ATM, pin)
    local msg = {"bal", account, ATM, pin}
    rednet.send(server, msg, "banking")
    local send, mes, pro = rednet.receive("banking")
    if mes[1] == "balR" then
        return mes[2], mes[3]
    end
    return false, "oof"
end

function deposit(account, amount, ATM, pin)
    local msg = {"dep", account, amount, ATM, pin}
    rednet.send(server, msg, "banking")
    local send, mes, pro = rednet.receive("banking")
    if mes[1] == "depR" then
        return mes[2], mes[3]
    end
    return false, "oof"
end

function withdraw(account, amount, ATM, pin)
    local msg = {"wit", account, amount, ATM, pin}
    rednet.send(server, msg, "banking")
    local send, mes, pro = rednet.receive("banking")
    if mes[1] == "witR" then
        return mes[2], mes[3], amount
    end
    return false, "oof"
end

function transfer(account, account2, amount, ATM, pin)
    local msg = {"tra", account, account2, amount, ATM, pin}
    rednet.send(server, msg, "banking")
    local send, mes, pro = rednet.receive("banking")
    if mes[1] == "traR" then
        return mes[2], mes[3]
    end
    return false, "oof"
end

---Api functions---

--Resets the screen--
function clear(insert)
    --Clears the screen--
    term.setBackgroundColor(background)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.black)
    --Writes important infomation--
    term.write("Blackjack OS ".. version)
    term.setCursorPos(1, 2)
    term.setTextColor(colors.yellow)
    term.write("Made By Mavric, Please Report Bugs")
    if (insert) then
        local pic = paintutils.loadImage("/blackjack/logo.nfp")
        paintutils.drawImage(pic, 20, 14)
        term.setBackgroundColour(colours.green)
        term.setCursorPos(17, 23)
        term.write("Please insert card")
    end
end

--Draw a card--
function drawCard(x, y, char, suit)
    --Set color to red or black based on the suit--
    local color = colors.red
	if (suit == "\5" or suit == "\6") then
		color = colors.black
    end
    --Draw a blank card--
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

--Draw the back of a card--
function drawBack(x, y)
    local pic = paintutils.loadImage("/blackjack/cardBack.nfp")
    paintutils.drawImage(pic, x, y)
end

function drawButton(double)
    term.setTextColor(1)
    if (double) then
        --Loops through each button in buttons and draws it using the x cord, y cord, and text--
        for k, v in pairs(buttons) do
            term.setBackgroundColor(buttons[k][3])
            term.setCursorPos(buttons[k][2], 30)
            term.write(buttons[k][1])
        end
    else
        --Do the same with out the double button--
        for k, v in pairs(button) do
            term.setBackgroundColor(button[k][3])
            term.setCursorPos(button[k][2], 30)
            term.write(button[k][1])
        end
    end
end

function checkPress(x, y, double)
    if (double) then
        --Checks y cord, all buttons are the same--
        if y == 30 then
            --Checks stand against its min and max x cords in buttons--
            if x >= buttons[1][2] and x < (buttons[1][2] + string.len(buttons[1][1])) then
                return true, 1
            --Checks double against its min and max x cords in buttons--
            elseif x >= buttons[2][2] and x < (buttons[2][2] + string.len(buttons[2][1])) then
                return true, 2
            --Checks hit against its min and max x cords in buttons--
            elseif x >= buttons[3][2] and x < (buttons[3][2] + string.len(buttons[3][1])) then
                return true, 3
            else
                --Returns false because no match found--
                return false
            end
        end
    else
        --Do the same without the double button--
        if y == 30 then
            if x >= button[1][2] and x < (button[1][2] + string.len(button[1][1])) then
                return true, 1
            elseif x >= button[2][2] and x < (button[2][2] + string.len(button[2][1])) then
                return true, 2
            else
                return false
            end
        end
    end
end


--Betting functions from MP--
function checkX(x, y)
    if x == 49 and y == 17 then
        return true
    else
        return false
    end
end

function drawX()
    term.setTextColor(colors.white)
    term.setBackgroundColor(colours.red)
    term.setCursorPos(49, 17)
    term.write("X")
end

function pinpad(key)
    if (tonumber(key)) then
        if key == 259 then
            return true, 10
        elseif key == 257 or key == 335 then
            return true, 11
        elseif tonumber(key) >= 0 and tonumber(key) <= 9 then
            return true, tonumber(key)
        end
    end
    return false
end

function clearSmall(insert)
    clear(false)
    local pic = paintutils.loadImage("/blackjack/logo.nfp")
    paintutils.drawImage(pic, 20, 4)
    if (insert) then
        term.setBackgroundColor(colours.green)
        term.setCursorPos(17, 13)
        term.write("Please insert card")
    end
end

function drawBet(PIN, number)
    clearSmall(false)
    term.setBackgroundColor(colours.green)
    term.setTextColor(colours.lime)
    term.setCursorPos(1, 3)
    if (PIN) then
        term.write("ID:")
    else
        term.write("$")
    end
    term.write(number)
    term.setCursorPos(20, 13)
    term.setTextColor(1)
    if (PIN) then
        term.write("PIN:")
    else
        term.write("BET:")
    end
    drawX()
end


---GameFunctions---

--Check if a hand has a ace--
function isAce(dealer)
    if (dealer) then
        --Loops through all the dealers cards and returns true if it finds an ace--
        for k, v in pairs(cards.dealer) do
            if (cards.dealer[k][2] == "A") then
                return true
            end
        end
        --Returns false if it find nothing--
        return false
    else
        --Do the same for the player--
        for k, v in pairs(cards.player) do
            if (cards.player[k][2] == "A") then
                return true
            end
        end
        return false
    end
end

--Gets the total of the cards in a hand--
function getTotal(dealer)
    --For the dealer--
    if (dealer) then
        --Adds card values together--
        local dealerFuncTotal = 0
        for k, v in pairs(cards.dealer) do
            dealerFuncTotal = dealerFuncTotal + cards.dealer[k][1]
        end
        if (isAce(true)) then
            --If there is an ace and the total is less than 12 than offset score by 10--
            if (dealerFuncTotal > 11) then
                return dealerFuncTotal
            else
                return dealerFuncTotal + 10
            end
        else
            return dealerFuncTotal
        end
    --Do the same for the player--
    else
        local funcTotal = 0
        for k, v in pairs(cards.player) do
            funcTotal = funcTotal + cards.player[k][1]
        end
        if (isAce(false)) then
            if (funcTotal > 11) then
                return funcTotal
            else
                return funcTotal + 10
            end
        else
            return funcTotal
        end
    end
end

--Gets another card for the player--
function hit()
    if xOffset < 6 then
        xOffset = xOffset + 1
        --Preps screen--
        clear(false)
        drawButton(double)
        --Draws dealers cards--
        drawCard(xCords[2][1], 5, cards.dealer[1][2], cards.dealer[1][3])
        --Dealers second card is hidden untill the has finished--
        drawBack(xCords[2][2], 5)
        local success = true
        --look into this success var--
        
        --Picks a random card from the deck--
        local rand = math.random(1, table.maxn(cards.deck))
        local card = cards.deck[rand]
        --Moves card from the deck to the playes hand--
        table.remove(cards.deck, rand)
        table.insert(cards.player, card)
        
        --Draws players cards--
        local count = 1
        for k, v in pairs(cards.player) do
            drawCard(xCords[xOffset][count], 22, cards.player[k][2], cards.player[k][3])
            count = count + 1
        end
        return false
    else
        return true
    end
end

--Do the same for the dealer--
function dealerHit()
    if xOffsetDealer < 6 then
        --Preps screen--
        clear(false)
        xOffsetDealer = xOffsetDealer + 1
        --Picks a random card from the deck--
        local rand = math.random(1, table.maxn(cards.deck))
        local card = cards.deck[rand]
        --Moves card from the deck to the dealers hand--
        table.remove(cards.deck, rand)
        table.insert(cards.dealer, card)
        
        --Draws players cards--
        local count = 1
        for k, v in pairs(cards.player) do
            drawCard(xCords[xOffset][count], 22, cards.player[k][2], cards.player[k][3])
            count = count + 1
        end
        
        --Draws dealers cards--
        count = 1
        for k, v in pairs(cards.dealer) do
            drawCard(xCords[xOffsetDealer][count], 5, cards.dealer[k][2], cards.dealer[k][3])
            count = count + 1
        end
        return false
    else
        return true
    end
end

--Draws players and dealers cards without hiden card--
function endGame()
    clear(false)
    local count = 1
    for k, v in pairs(cards.dealer) do
        drawCard(xCords[xOffsetDealer][count], 5, cards.dealer[k][2], cards.dealer[k][3])
        count = count + 1
    end
    count = 1
    for k, v in pairs(cards.player) do
        drawCard(xCords[xOffset][count], 22, cards.player[k][2], cards.player[k][3])
        count = count + 1
    end
end

function runGame()
    ---Setup---
    os.loadAPI("/blackjack/cards.lua")
    xOffset = 2
    xOffsetDealer = 2
    double = false
    doubled = false
    term.redirect(m) --Connect and clear large screen--
    clear(true)
    term.redirect(term.native()) --Connect and clear small screen--
    clearSmall(true)

    --Betting setup--
    betting = {false, false, 0, 0} --is betting, is pin, id, balance--
    text = {"", ""} --bet amount, pin--

    --Betting--
    local loop = true
    while loop do
        local event = {os.pullEvent()}
        if event[1] == "terminate" then
            if (redstone.getInput("back")) then
                error("You found the lever didnt you")
            else
                print("Did you think Im that stupid?")
            end
        elseif event[1] == "disk" then
            local id = disk.getID(drive)
            disk.eject(drive)
            if id ~= nil then
                if betting[1] == false then
                    drawBet(true, id)
                    betting[1] = true
                    betting[3] = id
                end
            end
        elseif event[1] == "mouse_click" then
            if (betting[1]) then
                if (checkX(event[3], event[4])) then
                    betting[1] = false
                    betting[2] = false
                    betting[3] = 0
                    betting[4] = 0
                    text[1] = ""
                    text[2] = ""
                    clearSmall(true)
                end
            end
        elseif event[1] == "char" or event[1] == "key" then
            if (betting[1]) then
                if (betting[2]) then
                    local isKey, keyNum = pinpad(event[2])
                    if (isKey) then
                        if keyNum == 10 then
                            if string.len(text[1]) > 0 then
                                text[1] = string.sub(text[1], 1, string.len(text[1]) - 1)
                                term.setBackgroundColor(colours.green)
                                term.setTextColor(1)
                                term.clearLine(13)
                                term.setCursorPos(20, 13)
                                term.write("BET: ".. text[1])
                            end
                        elseif keyNum == 11 then
                            if string.len(text[1]) < 6 then
                                if text[1] ~= "" then
                                    if (betting[4] >= tonumber(text[1]) and tonumber(text[1]) ~= 0) then
                                        local suc, res = withdraw(betting[3], tonumber(text[1]), atm, text[2])
                                        clearSmall(false)
                                        term.setBackgroundColor(colours.green)
                                        term.setCursorPos(11, 13)
                                        if (suc) then
                                            term.write("Your bet of $".. text[1].. " has been set")
                                            loop = false
                                        else
                                            term.write("Error: ".. res)
                                        end
                                    else
                                        clearSmall(false)
                                        term.setBackgroundColor(colours.green)
                                        term.setCursorPos(11, 13)
                                        if (tonumber(text[1]) == 0) then
                                            term.write("Must be more than zero!")
                                        else
                                            term.write("Must be enough money in your account!")
                                        end
                                        betting[1] = false
                                        betting[2] = false
                                        betting[3] = 0
                                        betting[4] = 0
                                        text[1] = ""
                                        text[2] = ""
                                        sleep(3)
                                        clearSmall(true)
                                    end
                                end
                            end
                        elseif keyNum >= 0 and keyNum <= 9 then
                            if string.len(text[1]) < 5 then
                                text[1] = text[1].. keyNum
                                term.setBackgroundColor(colours.green)
                                term.setTextColor(1)
                                term.setCursorPos(24 + string.len(text[1]), 13)
                                term.write(keyNum)
                            end
                        end
                    end
                else
                    local isKey, keyNum = pinpad(event[2])
                    if (isKey) then
                        if keyNum == 10 then
                            if string.len(text[2]) > 0 then
                                text[2] = string.sub(text[2], 1, string.len(text[2]) - 1)
                                term.setBackgroundColor(colours.green)
                                term.setTextColor(1)
                                term.clearLine(13)
                                term.setCursorPos(20, 13)
                                term.write("PIN: ".. string.sub("****", 1, string.len(text[2])))
                            end
                        elseif keyNum == 11 then
                            if string.len(text[2]) == 5 then
                                local suc, res = balance(betting[3], atm, text[2])
                                if (suc) then
                                    betting[4] = tonumber(res)
                                    betting[2] = true
                                    drawBet(false, res)
                                else
                                    betting[1] = false
                                    betting[3] = 0
                                    text[2] = ""
                                    clearSmall(false)
                                    term.setBackgroundColor(colours.green)
                                    term.setCursorPos(11, 13)
                                    term.write(res)
                                    sleep(3)
                                    clearSmall(true)
                                end
                            end
                        elseif keyNum >= 0 and keyNum <= 9 then
                            if string.len(text[2]) < 5 then
                                text[2] = text[2].. keyNum
                                term.setBackgroundColor(colours.green)
                                term.setTextColor(1)
                                term.setCursorPos(24 + string.len(text[2]), 13)
                                term.write("*")
                            end
                        end
                    end
                end
            end
        end
    end

    term.redirect(m) --Connect large screen--
    clear(false)
    --Get players cards--
    local rand = math.random(1, table.maxn(cards.deck))
    local card = cards.deck[rand]
    table.remove(cards.deck, rand)
    table.insert(cards.player, card)
    
    rand = math.random(1, table.maxn(cards.deck))
    card = cards.deck[rand]
    table.remove(cards.deck, rand)
    table.insert(cards.player, card)

    --Draws players cards--
    local count = 1
    for k, v in pairs(cards.player) do
        drawCard(xCords[xOffset][count], 22, cards.player[k][2], cards.player[k][3])
        count = count + 1
    end
    
    --Get dealers cards--
    rand = math.random(1, table.maxn(cards.deck))
    card = cards.deck[rand]
    table.remove(cards.deck, rand)
    table.insert(cards.dealer, card)
    
    rand = math.random(1, table.maxn(cards.deck))
    card = cards.deck[rand]
    table.remove(cards.deck, rand)
    table.insert(cards.dealer, card)
    --Draws dealers cards--
    drawCard(xCords[2][1], 5, cards.dealer[1][2], cards.dealer[1][3])
    --Dealers second card is hidden untill the has finished--
    drawBack(xCords[2][2], 5)

    --Gets players and dealers totals--
    local dealerTotal = getTotal(true)
    local total = getTotal(false)

    --If the dealer of player has 21 they win--
    if (dealerTotal == 21) then
        drawCard(xCords[2][2], 5, cards.dealer[2][2], cards.dealer[2][3])
        return false, tonumber(text[1])
    elseif (total == 21) then
	local winnings = (2 * tonumber(text[1]))
        return true, winnings
    end
    
    if (2 * tonumber(text[1])) > betting[4] then
        drawButton(false)
        double = false
    else
        drawButton(true)
        double = true
    end
    
    ---Main code---
    local success = true
    while (success) do
        local event = {os.pullEvent()}
        if event[1] == "terminate" then
            if (redstone.getInput("back")) then
                error("You found the lever didnt you")
            else
                print("Did you think Im that stupid?")
            end
        elseif event[1] == "monitor_touch" then
            --Checks to see if player has clicked on the screen--
            --Checks if x and y pressed are a button--
            local pres, butt = checkPress(event[3], event[4], double)
            if (pres) then
                if butt == 1 then
                    --If they pressed stand it exits the loop--
                    success = false
                elseif butt == 2 then
                    --If they pressed hit they cant use double anymore--
                    double = false
                    --Gets they player another card
                    local full = hit()
                    if (full) then
                        --If the player had 6 cards when they, hit they get 1 more card--
                        total = getTotal(false)
                        local rand = math.random(1, table.maxn(cards.deck))
                        drawCard(xCords[1][1], 13, cards.deck[rand][2], cards.deck[rand][3])
                        total = total + cards.deck[rand][1]
                        --If they dont go bust they win--
                        if total > 21 then
                            return false, tonumber(text[1])
                        else
			    local winnings = (2 * tonumber(text[1]))
                            return true, winnings
                        end
                    else
                        --Check total with new card to see if they go bust--
                        total = getTotal(false)
                        if total > 21 then
                            --If they go bust they lose--
                            endGame()
                            return false, tonumber(text[1])
                        end
                    end
                elseif butt == 3 then
                    if (double) then
                        --If they pressed double and double is an option they get one more card--
                        local suc, res = withdraw(betting[3], tonumber(text[1]), atm, text[2])
                        if (suc) then
                            hit()
                            
                            --Check total with new card to see if they go bust--
                            total = getTotal(false)
                            if total > 21 then
                                --If they go bust they lose--
                                endGame()
                                local winnings = (2 * tonumber(text[1]))
                                return false, winnings
                            end
                            
                            --If they dont go bust it exits the loop and their bet is doubled--
                            doubled = true
                            success = false
                        else
                            term.write("Error: ".. res)
                        end
                    end
                end
            end
        end
    end


    --Stand--
    clear(false)
    count = 1
    for k, v in pairs(cards.dealer) do
        drawCard(xCords[2][count], 5, cards.dealer[k][2], cards.dealer[k][3])
        count = count + 1
    end

    --Keeps getting the dealer another card untill they go bust or their total is more than 16--
    dealerTotal = getTotal(true)
    while dealerTotal < 17 do
        local dfull = dealerHit()
        if (dfull) then
            --If the dealer had 6 cards when they hit, they get 1 more card--
            dealerTotal = getTotal(true)
            drawCard(xCords[1][1], 13, cards.deck[count][2], cards.deck[count][3])
            dealerTotal = dealerTotal + cards.deck[count][1]
            --If they dont go bust they win--
            if dealerTotal > 21 then
                --Returns true if the dealer goes bust--
                --It works out the winnings--
                if (doubled) then
                    --Doubles the bet if they doubled--
                    local winnings = (4 * tonumber(text[1]))
                    return true, winnings
                else
                    local winnings = (2 * tonumber(text[1]))
                    return true, winnings
                end
            else
                --Returns false if the dealer doesn't goes bust--
                --It works out the winnings--
                if (doubled) then
                    --Doubles the bet if they doubled--
                    local winnings = (2 * tonumber(text[1]))
                    return false, winnings
                else
                    return false, tonumber(text[1])
                end
            end
        else
            --Checks if the dealer went bust--
            dealerTotal = getTotal(true)
            if dealerTotal > 21 then
                endGame()
                --Returns true if the dealer goes bust--
                --It works out the winnings--
                if (doubled) then
                    --Doubles the bet if they doubled--
                    local winnings = (4 * tonumber(text[1]))
                    return true, winnings
                else
                    local winnings = (2 * tonumber(text[1]))
                    return true, winnings
                end
            end
        end
    end

    --If the player and dealer havent won or gone bust by this point they check totals--
    total = getTotal(false)
    if dealerTotal > total then
        --Player has less than dealer so they loss--
        endGame()
        if (doubled) then
            local winnings = (2 * tonumber(text[1]))
            return false, winnings
        else
            return false, tonumber(text[1])
        end
    elseif total > dealerTotal then
        --Player has more than dealer so they win--
        endGame()
        if (doubled) then
            --Doubles the bet if they doubled--
            local winnings = (4 * tonumber(text[1]))
            return true, winnings
        else
            local winnings = (2 * tonumber(text[1]))
            return true, winnings
        end
    elseif total == dealerTotal then
        --They have the same score so its a push--
        endGame()
        return true, tonumber(text[1])
    else
        error("Cant Calculate Score")
    end
end


while true do
    local win, bat = runGame()
    term.setBackgroundColor(background)
    if (win) then
        term.setCursorPos(12, 30)
        term.setTextColor(colors.red)
        if bat ~= 0 then
            --Add winnings to their card--
            local suc, res = deposit(betting[3], bat, atm, text[2])
            if (suc) then
                term.write("Deposited your winings of: ".. bat)
            else
                term.write("Error: ".. res)
            end
        else
            term.write("Push")
        end
    else
        term.setCursorPos(21, 30)
        term.setTextColor(colors.black)
        term.write("You Lost")
    end
    sleep(3)
end
