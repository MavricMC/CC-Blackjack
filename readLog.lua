---Blackjack version 1.0---
local logFile = "blackjack/log"
os.loadAPI("/blackjack/json.lua")

term.clear()
term.setCursorPos(1, 1)
local start = 1
if (#arg == 1) then
    if (tonumber(arg[1])) then
        start = tonumber(arg[1])
    else
        printError("Must be number. Going from 1")
    end
else
    printError("No start given. Going from 1")
end
log = fs.open(logFile, "r")
local logContents = {{}}
if log == nil then
    printError("No log file found")
else
    local num = 1
    while num < start do
        log.readLine()
        num = num + 1
    end
    local line = log.readLine()
    while line ~= nil do
        logContents[num - start + 1] = json.decode(line)
        num = num + 1
        line = log.readLine()
    end
    log.close()
    for k, v in pairs(logContents) do
        local printLine = k - 1 + start.. " | "
        for k2, v2 in pairs(v) do
            printLine = printLine.. k2 .. ":".. tostring(v2).. " "
        end
        print(printLine)
        sleep(1)
    end
end
