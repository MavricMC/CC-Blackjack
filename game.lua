---Blackjack version 0.8---

--Made by Mavric--
--Code on https://github.com/MavricMC/CC-Blackjack--
---Pinpad remade from the ground up but thanks to blood muffin for the original that got me started on this project---

---Settings---
local screen = "left"
local drive = "bottom"
local version = "0.7"
local background = colors.green
term.redirect(peripheral.wrap(screen)) --Connect and clear screen--
term.clear()
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
    {"Stand", 16, colors.black,},
    {"Hit", 22, colors.gray},
    {"Double", 26, colors.red}
}
--Without double--
local button = {
    {"Stand", 19, colors.black, 18, 24},
    {"Hit", 25, colors.gray, 24, 28}
}

local xOffset = 2
local xOffsetDealer = 2
local double = false
local doubled = false


---PinpadFunctions---

--Checks to see if x and y cords click match with button--
function checkButton(xPressed, yPressed)
    for k, v in pairs(pinpad) do
        if yPressed == v[3] then
            if xPressed >= v[2] and xPressed <= (v[2] + 2) then
                return true, v[1]
            end
        end
    end
    return false
end

--Main pinpad function--
function runPinpad(xDraw, yDraw)
    --Resets everything--
    local pressed = ""
    term.setBackgroundColor(colors.brown)
    term.setTextColor(1)--White--
    --Draws the button as the number or a letter for the controls--
    for k, v in pairs(pinpad) do
        term.setCursorPos(v[2], v[3])
        if v[1] == "10" then
            --Draws the clear button red with a C--
            term.setBackgroundColor(colors.red)
            term.write(" " .. "C" .. " ")
        elseif v[1] == "11" then
            --Draws the clear button green with a E--
            term.setBackgroundColor(colors.green)
            term.write(" " .. "E" .. " ")
        else
            --Draws the number button brown with the number--
            term.setBackgroundColor(colors.brown)
            term.write(" " .. v[1] .. " ")
        end
    end
    term.setBackgroundColor(background)
    term.setTextColor(1)
    term.setCursorPos(xDraw, yDraw)
    --Checks click until clear or enter pressed--
    while true do
        --Sets up event listener for a press on the screen--
        local event, button, xp, yp = os.pullEvent("monitor_touch")
        --Uses checkButton to check the x and y against pinpad--
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


---ApiFunctions---

--Resets the screen--
function clear()
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

--Draw and prosses the betting prosses--
function drawBet(x, y, bal)
    --Repeat until you get a valid bet amount--
    while true do
        clear()
        --Draw the logo--
        local pic = paintutils.loadImage("/blackjack/logo.nfp")
        paintutils.drawImage(pic, x, y)
        --Draw the players balance--
        term.setBackgroundColor(background)
        term.setTextColor(colors.lime)
        term.setCursorPos(1, 3)
        term.write("$")
        term.write(tostring(bal))
        --Draw text entry bar--
        term.setCursorPos(x, y + 9)
        term.setTextColor(1)
        term.write("Bet: ")
        --Run pinpad function--
        local isBet, bet = runPinpad(x + 5, y + 9)
        bet = tonumber(bet)
        --Check they pressed enter, the bet was not nil, the bet was more then 0, and the player has the balance to place the bet--
        if (isBet) then
            if bet ~= nil then
                if bet > 0 then
                    if bet <= bal then
                        --If all true return how much they bet in int form--
                        return bet
                    end
                end
            end
        end
        --If any are false restart the prosses--
    end
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
        clear()
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
        clear()
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
    clear()
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

function runGame(balance)
    ---Setup---
    os.loadAPI("/blackjack/cards.lua")
    xOffset = 2
    xOffsetDealer = 2
    double = false
    doubled = false
    clear()

    --Betting--
    local bet = drawBet(20, 5, balance)
    disk.setLabel(drive, tostring(balance - bet))
    --Get players cards--
    clear()
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
        return false, bet
    elseif (total == 21) then
        return true, bet
    end
    
    if bet + bet > balance then
        drawButton(false)
        double = false
    else
        drawButton(true)
        double = true
    end
    
    ---Main code---
    local success = true
    while (success) do
        --Checks to see if player has clicked on the screen--
        local event, perph, xp, yp = os.pullEvent("monitor_touch")
        --Checks if x and y pressed are a button--
        local pres, butt = checkPress(xp, yp, double)
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
                        return false, bet
                    else
                        return true, bet
                    end
                else
                    --Check total with new card to see if they go bust--
                    total = getTotal(false)
                    if total > 21 then
                        --If they go bust they lose--
                        endGame()
                        return false, bet
                    end
                end
            elseif butt == 3 then
                if (double) then
                    --If they pressed double and double is an option they get one more card--
                    hit()
                    
                    --Check total with new card to see if they go bust--
                    total = getTotal(false)
                    if total > 21 then
                        --If they go bust they lose--
                        endGame()
                        local winnings = bet + bet
                        return false, winnings
                    end
                    
                    --If they dont go bust it exits the loop and their bet is doubled--
                    doubled = true
                    success = false
                end
            end
        end
    end


    --Stand--
    clear()
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
                    local winnings = bet + bet
                    return true, winnings
                else
                    return true, bet
                end
            else
                --Returns false if the dealer doesn't goes bust--
                --It works out the winnings--
                if (doubled) then
                    --Doubles the bet if they doubled--
                    local winnings = bet + bet
                    return false, winnings
                else
                    return false, bet
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
                    local winnings = bet + bet
                    return true, winnings
                else
                    return true, bet
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
            --Doubles the bet if they doubled--
            local winnings = bet + bet
            return false, winnings
        else
            return false, bet
        end
    elseif total > dealerTotal then
        --Player has more than dealer so they win--
        endGame()
        if (doubled) then
            --Doubles the bet if they doubled--
            local winnings = bet + bet
            return true, winnings
        else
            return true, bet
        end
    elseif total == dealerTotal then
        --They have the same score so its a push--
        endGame()
        return true, 0
    else
        error("Cant Calculate Score")
    end
end


while true do
    while disk.isPresent(drive) == false do
        sleep(0.1)
    end
    --checks it was a disk inserted--
    if (disk.getID(drive)) then
        --checks disks label is a number--
        if (tonumber(disk.getLabel(drive))) then
            local bil = tonumber(disk.getLabel(drive))
            local win, bat = runGame(bil)
            term.setCursorPos(16, 30)
            term.setBackgroundColor(background)
            if (win) then
                term.setTextColor(colors.red)
                term.write("You Win: ")
                term.write(tostring(bat))
                --Add winnings to their card--
                disk.setLabel(drive, tostring(bil + bat))
            else
                term.setTextColor(colors.black)
                term.write("You Lose: ")
                term.write(tostring(bat))
            end
        end
    end
    disk.eject(drive)
    sleep(1)
end
