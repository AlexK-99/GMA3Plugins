--[[
AppearanceBuilder v1.0.0.1
Please note that this will likly break in future version of the console. and to use at your own risk.

Usage:
Call Plugin AppearanceBuilder "COUNT, [FillSaturation], [FillBrightness], [OutlineSaturation], [OutlineBrightness], [ApperanceStartIndex], [MacroStartIndex]"'

Example:
Call Plugin "ApperanceBuilder" "10, 1, 0.5, 1, 1, 201, 401"

Creates 10 Appearances starting at 201 and Macros starting at 401 with the fill being darker then the outline.
 
Properties:
COUNT           between  1 and 360 defalts to 15
FillSaturation  between 0.0 and 1.0 defaults to 1.0
FillBrightness  between 0.0 and 1.0 defaults to 1.0
FillSaturation  between 0.0 and 1.0 defaults to <FillSaturation>
FillBrightness  between 0.0 and 1.0 defaults to <FillBrightness>
ApperanceStartIndex between 0 - 10000 defaults to 101
ApperanceStartIndex between 0 - 10000 defaults to ApperanceStartIndex

Things todo:
- Figure out how to ask a question for the user to input a value
- The name is curretly taken from the outline color, and has a small list of colors.
- Better Appearance overwriteing, currently deletes and creates causing the refrances to be deleted.
- Better Macro overwriting, currently deletes and creates, if not overwriting adds additional lines with the INSERT command
- Better property managment, key value pairs would be much nicer
- Eficancies and Consistantly issues




MIT License

Copyright (c) 2019 Down Right Technical Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]


local pluginName = select(1,...);
local componentName = select(2,...);
local signalTable = select(3,...);
local my_handle = select(4,...);

-- Enter Names for colors, Add your own in the following format
-- {{r, g, b,"NAME"}}
-- r, g and b are between 0 and 255
local names = {
    {{0  ,  0,  0},"Black"},
    {{255,  0,  0},"Red"},
    {{0  ,255,  0},"Green"},
    {{0  ,  0,255},"Blue"},

    {{0  ,255,255},"Cyan"},
    {{255,255,  0},"Yellow"},
    {{255,  0,255},"Magenta"},

    {{255,127,  0},"Orange"},
    {{127,255,  0},"Lime"},
    {{  0,255,127},"Sea Foam"},
    {{  0,127,255},"Lt Blue"},
    {{127,  0,255},"Purple"},
    {{255,  0,127},"Hot Pink"},

    {{255,255,255},"White"}
}

--
-- Main
--
local function Main (display_handle, argument)
    --Echo("Console Version: %s" Version())
    local arguments
    if argument == null then
        Echo("Usage:")
        Echo('Call Plugin HSB2RGB "<COUNT 1 - 360>, [Fill Saturation 0 - 1], [Fill Brightness 0 - 1], [Outline Saturation 0 - 1], [Outline Brightness 0 - 1], [Apperance Start Index 1 - 10000], [Macro Start Index 1 - 10000]"');
        Echo('All options except for COUNT are optional, and will choose some defaults')
        return
    else
        arguments = split(argument, ",")
    end

    local overwrite = PopupInput("Overwrite macros and Apperances?", display_handle, {"NO", "YES, will remove references!"})
    
    -- sanatize our inputs
    --TODO: really need to change this to key=value pairs!
    --count (int)
    local count = clamp(math.floor(tonumber(arguments[1]) or 15 ), 1, 360)

    -- fill saturation (float)
    local fillS = clamp(tonumber(arguments[2]) or 1.0 + .0, 0.0, 1.0)

    -- fill brightness (float)
    local fillB = clamp(tonumber(arguments[3]) + .0, 0.0, 1.0) or 1.0

    --outline saturation (float)
    local outlineS = clamp(tonumber(arguments[4]) + .0, 0.0, 1.0) or fillS    

    -- outline brightness (float)
    local outlineB = clamp(tonumber(arguments[5]) + .0, 0.0, 1.0) or fillB

    -- appearanceStartIndex (int)
    local appearanceStartIndex = clamp(math.floor(tonumber(arguments[6]) or 101),1,10000)

    -- appearanceStartIndex (int)
    local macroStartIndex = clamp(math.floor(tonumber(arguments[7]) or appearanceStartIndex),1,10000)

    local fillIncrement = 1 / count
    -- start index hardcoded to 21 for testing
    local appearanceIndex = appearanceStartIndex
    local macroIndex = macroStartIndex

    -- loop thru count, hack to not include 1 in the loop
    for i = 0, 1-0.001, fillIncrement do
        local a = 1.0
        local rf, gf, bf, namef = toRGB(i, fillS, fillB)
        local ro, go, bo, nameo = toRGB(i, outlineS, outlineB)

        -- Overwrite Apperances
        --TODO: This should do an overwrite insted of a delete
        if overwrite == 1 then
            Cmd("Delete Appearance %d /NC", appearanceIndex)
        end

        -- build Apperances
        local command = ""
        if nameo == null then
            command = string.format('Store Appearance %d Property "Color" "%f,%f,%f,%f" "BackR" "%d" "BackG" "%d" "BackB" "%d" "BackAlpha" "%d"',appearanceIndex, rf, gf, bf, a, math.floor(ro * 255), math.floor(go * 255), math.floor(bo * 255), math.floor(a * 255))
        else
            command = string.format('Store Appearance %d Property "Color" "%f,%f,%f,%f" "BackR" "%d" "BackG" "%d" "BackB" "%d" "BackAlpha" "%d" "Name" "%s"',appearanceIndex, rf, gf, bf, a, math.floor(ro * 255), math.floor(go * 255), math.floor(bo * 255), math.floor(a * 255), nameo)
        end
        Cmd(command)

        -- build macros
        -- Overwrite Macros
        --TODO: This should do an overwrite insted of a delete
        if overwrite == 1 then
            Cmd("Delete Macro %d /NC", macroIndex)
        end

        Cmd("Store Macro " .. macroIndex)
        Cmd("Assign Appearance " .. appearanceIndex .. " at Macro " .. macroIndex)
        Cmd("CD Macro " .. macroIndex)
        Cmd("Insert") --TODO: HMM, how do I first delete all lines.
        Cmd(string.format('Set 1 Command "Assign Appearance %d at" ', appearanceIndex))
        Cmd("Set 1 Execute no")
        Cmd("CD Root")
        local macroName = "Assign " .. (nameo or "Apperance")
        Cmd("Label Macro " .. macroIndex .. '"'.. macroName ..'"')


        -- increment our indexes
        appearanceIndex = appearanceIndex + 1
        macroIndex = macroIndex + 1
    end
end

--
-- Cleanup (placeholder)
--
local function Cleanup()
    Printf("[Start Cleanup]")
end

--
-- Execute (placeholder)
--
local function Execute(Type, ...)
    Printf("[Start Execute]")
    Printf("Type: %s", Type)
end


-- split
-- why is there no split in lua?
function split (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

-- clamp
 function clamp (input, min, max)
    local i = input
    if i < min then i = min end
    if i > max then i = max end
    return i
end

-- convert to RGB
function toRGB (h, s, v)
    -- stuff of magic https://stackoverflow.com/questions/17242144/javascript-convert-hsb-hsv-color-to-rgb-accurately
    if h == null then h = 0 end
    if s == null then s = 1.0 end
    if v == null then v = 1.0 end

    local r = 0
    local g = 0
    local b = 0
    local name = null
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1.0 - s)
    local q = v * (1.0 - f  * s)
    local t = v * (1.0 - (1.0 - f) * s)

    if (i % 6) == 0 then
        r = v
        g = t
        b = p
    elseif (i % 6) == 1 then
        r = q
        g = v
        b = p
    elseif (i % 6) == 2 then
        r = p
        g = v
        b = t
    elseif (i % 6) == 3 then
        r = p
        g = q
        b = v
    elseif (i % 6) == 4 then
        r = t
        g = p
        b = v
    elseif (i % 6) == 5 then
        r = v
        g = p
        b = q
    end

    -- need to round and clamp this!
    name = getColorName(r,g,b)
    return r, g, b, name
end

function getColorName (r, g, b, threshold)
    -- http://chir.ag/projects/ntc/ntc.js
    -- not fully implimented, needs to also check HSV values, but works for now.
    -- safty first
    r = r or 0
    g = g or 0
    b = b or 0
    threshold = threshold or 1500

    r = clamp(math.floor(r * 255), 0, 255)
    g = clamp(math.floor(g * 255), 0, 255)
    b = clamp(math.floor(b * 255), 0, 255)

    local bestScore = -1
    local bestIndex
    for k, v in pairs(names) do
        local cR = v[1][1];
        local cG = v[1][2];
        local cB = v[1][3];

        local score = ((r - cR)*(r - cR)) + ((g - cG)*(g - cG)) + ((b - cB)*(b - cB))
        
        if bestScore < 0 or bestScore > score then
            bestScore = score
            bestIndex = k
        end
    end
    --Echo("%s (%d)", names[bestIndex][2], bestScore)
    local result = null
    if (bestScore < threshold) then
        result = names[bestIndex][2]
    end
    return result
end

return Main, Cleanup, Execute