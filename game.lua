--Blackjack version 0.0.5--

--Made by Mavric--
--Code on https://pastebin.com/u/MavricMC--


local cords = {
    {23},
    {18, 26},
    {14, 22, 30},
    {10, 18, 26, 34},
    {6, 14, 22, 30, 38},
    {3, 11, 19, 27, 35, 43}
}

function runGame(baall)
os.loadAPI("/blackjack/api.lua")
os.loadAPI("/blackjack/cards.lua")
local num = 0
local card = nil
local suc = true
local succ = true
local total = 0
local Total = 0
local dtotal = 0
local dTotal = 0
local txt = ""
local game = false
local xo = 2
local dxo = 2
local bal = baall
local dub = false
local dubb = false
local m = peripheral.wrap("left")
 
--Functions--

--Work out the total with the aces--
function isAce(DA)
   if (DA) then
	for k, v in pairs(cards.dealer) do
	   if (cards.dealer[k][2] == "A") then
		return true
	   end
	end
	return false
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
function getTotal(D)
    if (D) then
	dTotal = 0
	for k, v in pairs(cards.dealer) do
	   dTotal = dTotal + cards.dealer[k][1]
	end
	if (isAce(true)) then
	   if (dTotal > 11) then
		return dTotal
	   else
		return dTotal + 10
	   end
	else
	   return dTotal
	end
   else
	Total = 0
	for k, v in pairs(cards.player) do
	   Total = Total + cards.player[k][1]
	end
	if (isAce(false)) then
	   if (Total > 11) then
		return Total
	   else
		return Total + 10
	   end
	else
	   return Total
	end
   end
end


--Gets another card for the player--
function hit()
    if xo < 6 then
        xo = xo + 1
        api.clear()
        api.drawButton(dub)
        api.drawCard(cords[2][1], 5, cards.dealer[1][2], cards.dealer[1][3])
        api.drawBack(cords[2][2], 5)
        succ = true
        
        num = math.random(1, table.maxn(cards.deck))
        card = cards.deck[num]
        table.remove(cards.deck, num)
        table.insert(cards.player, card)
        
        num = 1
        for k, v in pairs(cards.player) do
            api.drawCard(cords[xo][num], 22, cards.player[k][2], cards.player[k][3])
            num = num + 1
        end
        return false
    else
        return true
    end
end

function dealerHit()
    if dxo < 6 then
        api.clear()
        dxo = dxo + 1
        num = math.random(1, table.maxn(cards.deck))
        card = cards.deck[num]
        table.remove(cards.deck, num)
        table.insert(cards.dealer, card)
        
        num = 1
        for k, v in pairs(cards.player) do
            api.drawCard(cords[xo][num], 22, cards.player[k][2], cards.player[k][3])
            num = num + 1
        end
        
        num = 1
        for k, v in pairs(cards.dealer) do
            api.drawCard(cords[dxo][num], 5, cards.dealer[k][2], cards.dealer[k][3])
            num = num + 1
        end
        return false
    else
        return true
    end
end


function endd()
    api.clear()
    num = 1
    for k, v in pairs(cards.dealer) do
        api.drawCard(cords[dxo][num], 5, cards.dealer[k][2], cards.dealer[k][3])
        num = num + 1
    end
    num = 1
    for k, v in pairs(cards.player) do
        api.drawCard(cords[xo][num], 22, cards.player[k][2], cards.player[k][3])
        num = num + 1
    end
end


--Setup--
term.clear()
term.redirect(m)
api.clear()
--Betting--
local bet = api.drawBet(20, 5, bal)
disk.setLabel("bottom", tostring(bal - bet))
--Get players cards--
api.clear()
num = math.random(1, table.maxn(cards.deck))
card = cards.deck[num]
table.remove(cards.deck, num)
table.insert(cards.player, card)
 
num = math.random(1, table.maxn(cards.deck))
card = cards.deck[num]
table.remove(cards.deck, num)
table.insert(cards.player, card)

num = 1
for k, v in pairs(cards.player) do
    api.drawCard(cords[xo][num], 22, cards.player[k][2], cards.player[k][3])
    num = num + 1
end
 
--Get dealers cards--
num = math.random(1, table.maxn(cards.deck))
card = cards.deck[num]
table.remove(cards.deck, num)
table.insert(cards.dealer, card)
 
num = math.random(1, table.maxn(cards.deck))
card = cards.deck[num]
table.remove(cards.deck, num)
table.insert(cards.dealer, card)
api.drawCard(cords[2][1], 5, cards.dealer[1][2], cards.dealer[1][3])
api.drawBack(cords[2][2], 5)

dtotal = getTotal(true)
total = getTotal(false)

if (dtotal == 21) then
	api.drawCard(cords[2][2], 5, cards.dealer[2][2], cards.dealer[2][3])
	return false, bet
elseif (total == 21) then
	return true, bet
end

--Main code--
if bet + bet > bal then
    api.drawButton(false)
    dub = false
else
    api.drawButton(true)
    dub = true
end
 
suc = true
while (suc) do
    local event, perph, xp, yp = os.pullEvent("monitor_touch")
    local pres, butt = api.checkPress(xp, yp, dub)
    if (pres) then
        if butt == 1 then
            suc = false
        elseif butt == 2 then
            dub = false
            local full = hit()
            if (full) then
                total = getTotal(false)
                num = math.random(1, table.maxn(cards.deck))
                api.drawCard(cords[1][1], 13, cards.deck[num][2], cards.deck[num][3])
                total = total + cards.deck[num][1]
                if total > 21 then
                    return false, bet
                else
                    return true, bet
                end
            else  
                total = getTotal(false)
                if total > 21 then
                    endd()
                    return false, bet
                end
            end
        elseif butt == 3 then
            if (dub) then
                hit()
                
                total = getTotal(false)
                if total > 21 then
                    endd()
                    local temp321 = bet + bet
                    return false, temp321
                end
                
                dubb = true
                suc = false
            end
        end
    end
end


--Stand--
api.clear()
num = 1
for k, v in pairs(cards.dealer) do
    api.drawCard(cords[2][num], 5, cards.dealer[k][2], cards.dealer[k][3])
    num = num + 1
end

dtotal = getTotal(true)
while dtotal < 17 do
    local dfull = dealerHit()
    if (dfull) then
        dtotal = getTotal(true)
        api.drawCard(cords[1][1], 13, cards.deck[num][2], cards.deck[num][3])
        dtotal = dtotal + cards.deck[num][1]
        if dtotal > 21 then
            if (dubb) then
                local temp123 = bet + bet
                return true, temp123
            else
                return true, bet
            end
        else
            if (dubb) then
                local temp123 = bet + bet
                return false, temp123
            else
                return false, bet
            end
        end
    else
        dtotal = getTotal(true)
        if dtotal > 21 then
            endd()
            if (dubb) then
                local temp123 = bet + bet
                return true, temp123
            else
                return true, bet
            end
        end
    end
end


total = getTotal(false)
if dtotal > total then
    endd()
    if (dubb) then
        local temp123 = bet + bet
        return false, temp123
    else
        return false, bet
    end
elseif total > dtotal then
    endd()
    if (dubb) then
        local temp123 = bet + bet
        return true, temp123
    else
        return true, bet
    end
elseif total == dtotal then
    endd()
    return true, 0
else
    error("Cant Calculate Score")
end
end


while true do
    while disk.isPresent("bottom") == false do
        sleep(0)
    end
    print(" ")
    local bil = tonumber(disk.getLabel("bottom"))
    local plus, bat = runGame(bil)
    term.setCursorPos(16, 30)
    term.setBackgroundColor(colors.green)
    if (plus) then
        term.setTextColor(colors.red)
        term.write("You Win: ")
        term.write(tostring(bat))
        disk.setLabel("bottom", tostring(bil + bat))
    else
        term.setTextColor(colors.black)
        term.write("You Lose: ")
        term.write(tostring(bat))
    end
    disk.eject("bottom")
    sleep(1)
end
