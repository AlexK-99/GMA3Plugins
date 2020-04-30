--[[
USB Stomper v1.1.0.1
See README.md for more information

MIT License

Copyright (c) 2020 Down Right Technical Inc.

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

local function Main(display_handle,argument)
    local running = "1"
    local var = GlobalVars()
    local name = "EjectUSB"
    SetVar(var, name, "1")
    while running == "1" do
        local drives = Root().Temp.DriveCollect
        for i = 1, drives.count, 1 do
            if drives[i].DriveType == "Removeable" then
                Cmd("Eject Drive " .. i)
            end
        end
        running = GetVar(var, name)
        coroutine.yield(1)
    end
    DelVar(var, name)
    Echo("Stopping Plugin")
end

return Main