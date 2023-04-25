---Blackjack version 0.6---

--Made by Mavric--
--Code on https://github.com/MavricMC/CC-Blackjack--

---Settings---
local screen = peripheral.wrap("left")
local drive = "bottom"
local xCords = {
    {23},
    {18, 26},
    {14, 22, 30},
    {10, 18, 26, 34},
    {6, 14, 22, 30, 38},
    {3, 11, 19, 27, 35, 43}
}

os.loadAPI("/blackjack/api.lua")

function runGame(balance)
    ---Setup---
    os.loadAPI("/blackjack/cards.lua")
    local xOffset = 2
    local xOffsetDealer = 2
    local double = false
    local doubled = false
    term.clear()
    term.redirect(screen)
    api.clear()
    
    ---Functions---

    --Check if a hand has a ace--
    function isAce(dealer)
        --For the dealer--
        if (dealer) then
            for k, v in pairs(cards.dealer) do
                if (cards.dealer[k][2] == "A") then
                    return true
                end
            end
            return false
        --For the player--
        else
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
        --For the player--
        else
            --Adds card values together--
            local funcTotal = 0
            for k, v in pairs(cards.player) do
                funcTotal = funcTotal + cards.player[k][1]
            end
            if (isAce(false)) then
                --If there is an ace and the total is less than 12 than offset score by 10--
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
            api.clear()
            api.drawButton(double)
            --Draws dealers cards--
            api.drawCard(xCords[2][1], 5, cards.dealer[1][2], cards.dealer[1][3])
            --Dealers second card is hidden untill the has finished--
            api.drawBack(xCords[2][2], 5)
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
                api.drawCard(xCords[xOffset][count], 22, cards.player[k][2], cards.player[k][3])
                count = count + 1
            end
            return false
        else
            return true
        end
    end

    --Gets another card for the dealer--
    function dealerHit()
        if xOffsetDealer < 6 then
            --Preps screen--
            api.clear()
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
                api.drawCard(xCords[xOffset][count], 22, cards.player[k][2], cards.player[k][3])
                count = count + 1
            end
            
            --Draws dealers cards--
            count = 1
            for k, v in pairs(cards.dealer) do
                api.drawCard(xCords[xOffsetDealer][count], 5, cards.dealer[k][2], cards.dealer[k][3])
                count = count + 1
            end
            return false
        else
            return true
        end
    end

    --Draws players and dealers cards without hiden card--
    function endGame()
        api.clear()
        local count = 1
        for k, v in pairs(cards.dealer) do
            api.drawCard(xCords[xOffsetDealer][count], 5, cards.dealer[k][2], cards.dealer[k][3])
            count = count + 1
        end
        count = 1
        for k, v in pairs(cards.player) do
            api.drawCard(xCords[xOffset][count], 22, cards.player[k][2], cards.player[k][3])
            count = count + 1
        end
    end


    --Betting--
    local bet = api.drawBet(20, 5, balance)
    disk.setLabel(drive, tostring(balance - bet))
    --Get players cards--
    api.clear()
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
        api.drawCard(xCords[xOffset][count], 22, cards.player[k][2], cards.player[k][3])
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
    api.drawCard(xCords[2][1], 5, cards.dealer[1][2], cards.dealer[1][3])
    --Dealers second card is hidden untill the has finished--
    api.drawBack(xCords[2][2], 5)

    --Gets players and dealers totals--
    local dealerTotal = getTotal(true)
    local total = getTotal(false)

    --If the dealer of player has 21 they win--
    if (dealerTotal == 21) then
        api.drawCard(xCords[2][2], 5, cards.dealer[2][2], cards.dealer[2][3])
        return false, bet
    elseif (total == 21) then
        return true, bet
    end
    
    if bet + bet > balance then
        api.drawButton(false)
        double = false
    else
        api.drawButton(true)
        double = true
    end
    
    ---Main code---
    local success = true
    while (success) do
        --Checks to see if player has clicked on the screen--
        local event, perph, xp, yp = os.pullEvent("monitor_touch")
        --Checks if x and y pressed are a button--
        local pres, butt = api.checkPress(xp, yp, double)
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
                    api.drawCard(xCords[1][1], 13, cards.deck[rand][2], cards.deck[rand][3])
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
    api.clear()
    count = 1
    for k, v in pairs(cards.dealer) do
        api.drawCard(xCords[2][count], 5, cards.dealer[k][2], cards.dealer[k][3])
        count = count + 1
    end

    --Keeps getting the dealer another card untill they go bust or their total is more than 16--
    dealerTotal = getTotal(true)
    while dealerTotal < 17 do
        local dfull = dealerHit()
        if (dfull) then
            --If the dealer had 6 cards when they hit, they get 1 more card--
            dealerTotal = getTotal(true)
            api.drawCard(xCords[1][1], 13, cards.deck[count][2], cards.deck[count][3])
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
    print(" ")
    local bil = tonumber(disk.getLabel(drive))
    local win, bat = runGame(bil)
    term.setCursorPos(16, 30)
    term.setBackgroundColor(colors.green)
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
    disk.eject(drive)
    sleep(1)
end
