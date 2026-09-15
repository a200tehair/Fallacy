if arg[1] == nil then error("No file provided to run") end
local script = io.open(arg[1], "r")
if script == nil then error("File provided is non-existent") end

local tokens = {}
local markers = {}

local dataF = script:read("a")

local token = ""
for i = 1, #dataF do
    if dataF:sub(i, i) == " " or dataF:sub(i, i) == "\n" then
        if token ~= "" then table.insert(tokens, token) token = "" end
    else
        token = token .. dataF:sub(i, i)
    end
end

local foundS = false

local x = 1
for i = 1, #tokens do
    if tokens[i] == "startscr" then foundS = true x = i end
    if tokens[i] == "markln" then table.insert(markers, {plc = i, nm = tokens[i + 1]}) end
end
if foundS == false then print("in script: No starting line found") return nil end

local data = {}

local i = x

local flags = {
    ["zeroflag"] = false,
    ["definedflag"] = false,
}

local alreadyran = {}

local prevFlagSet = ""
while i <= #tokens do

    local t = tokens[i]
    if t == "endscr" then break end
    if t == "def" then
        if alreadyran[i] == true then
            goto skip
        end
        local name = tokens[i + 1]
        alreadyran[i] = true
        i = i + 1
        for chk = 1, #data do
            if data[chk].id == name then
                print("in script: variable declared voids previously declared variable at " .. t)
                goto close
            end
        end
        table.insert(data, {id = name, val = nil})
    elseif t == "init" then
        local name = tokens[i + 1]
        local value = tokens[i + 2]

        local f = false
        for chk = 1, #data do
            if data[chk].id == name then
                f = true
                data[chk].val = tonumber(value)
                break
            end
        end
        if f == false then
            print("in script: found undeclared variable " .. name)
            goto close
        end
        i = i + 2
    elseif t == "getusrinput" then
        local name = tokens[i + 1]
        local value = io.read("*L")

        local f = false
        for chk = 1, #data do
            if data[chk].id == name then
                f = true
                data[chk].val = tonumber(value)
                break
            end
        end
        if f == false then
            print("in script: found undeclared variable " .. name)
            goto close
        end
        i = i + 2
    elseif t == "chkdef" then
        local name = tokens[i + 1]
        local f = false
        for chk = 1, #data do
            if data[chk].id == name then
                f = true
                break
            end
        end
        if f == false then print("variable " .. name .. " returned undefined") end

        flags["definedflag"] = f
        prevFlagSet = "definedflag"
        i = i + 1
    elseif t == "ify" then
        local stp

        local f = false
        for j = i, #tokens do
            if tokens[j] == "endbl" then
                f = true
                stp = j
                break
            end
        end

        if f == false then
            print("in script: no endbl")
            goto close
        end

        if flags[prevFlagSet] == true then
            i = stp
        end
    elseif t == "ifn" then
        local stp

        local f = false
        for j = i, #tokens do
            if tokens[j] == "endbl" then
                f = true
                stp = j
                break
            end
        end

        if f == false then
            print("in script: no endbl")
            goto close
        end

        if flags[prevFlagSet] == false then
            i = stp
        end

        i = i + 1
    elseif t == "chk0" then
        local name = tokens[i + 1]
        local f = false

        local ch
        for chk = 1, #data do
            if data[chk].id == name then
                f = true
                ch = data[chk]
                break
            end
        end
        if f == false then print("in script: found undeclared variable .. " .. name) goto close else if ch.val == 0 then f = true else f = false end end
        flags["zeroflag"] = f
        prevFlagSet = "zeroflag"
        i = i + 1
    elseif t == "subvar" then
        local name = tokens[i + 1]
        local value = tokens[i + 2]
        value = tonumber(value) or value
        local f = false

        local ch
        for chk = 1, #data do
            if data[chk].id == name then
                f = true
                ch = data[chk]
                if type(value) == "number" then
                    ch.val = ch.val - value
                else
                    for chk2 = 1, #data do
                        if data[chk2].id == value then
                            ch.val = ch.val - data[chk2].val
                        end
                    end
                end
                break
            end
        end
        if f == false then print("in script: found undeclared variable .. " .. name) goto close end
        i = i + 2
    elseif t == "addvar" then
        local name = tokens[i + 1]
        local value = tokens[i + 2]
        value = tonumber(value) or value
        local f = false

        local ch
        for chk = 1, #data do
            if data[chk].id == name then
                f = true
                ch = data[chk]
                if type(value) == "number" then
                    ch.val = ch.val + value
                else
                    for chk2 = 1, #data do
                        if data[chk2].id == value then
                            ch.val = ch.val + data[chk2].val
                        end
                    end
                end
                break
            end
        end
        if f == false then print("in script: found undeclared variable .. " .. name) goto close end
        i = i + 2
    elseif t == "out" then
        local toPrint = {}

        local f = false
        local ascii = false
        for get = i, #tokens do
            if tokens[get] == "end" or tokens[get] == "ascii" then
                if tokens[get] == "end" then
                    f = true
                    break
                else
                    ascii = true
                end
            else
                table.insert(toPrint, tokens[get])
            end
        end
        if f == false then print("in script: found no end to out at " .. i) goto close end

        local estring = {}
        for k = 1, #toPrint do
            if toPrint[k] == "out" then goto skipi end
            toPrint[k] = tonumber(toPrint[k]) or toPrint[k]
            if type(toPrint[k]) == "number" then
                table.insert(estring, toPrint[k])
            else
                local f = false
                for chk = 1, #data do
                    if data[chk].id == toPrint[k] then
                        f = true
                        table.insert(estring, data[chk].val)
                        break
                    end
                end
                if f == false then print("in script: found undeclared variable .. " .. toPrint[k]) goto close end
            end
            ::skipi::
        end

        local comb = ""
        for p = 1, #estring do
            if ascii == true then
                comb = comb .. string.char(estring[p] % 256)
            else
                comb = comb .. tostring(estring[p])
            end
        end
        print(comb)
    elseif t == "jmp" then
        local name = tokens[i + 1]
        name = tonumber(name) or name
        if type(name) == "number" then
            i = name
        else
            local found = false
            for f = 1, #markers do
                if markers[f].nm == name then
                    found = true
                    i = markers[f].plc
                end
            end
            if found == false then print("in script: found unfinished jmp call") goto close end
        end
    end
    ::skip::
    i = i + 1
end
io.close(script)

::close::