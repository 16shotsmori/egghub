local services = setmetatable({}, {
    __index = function(_, service)
        return game:GetService(service)
    end
})

local client = services.Players.LocalPlayer

--// library

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/16shotsmori/vozoidulib/main/vozoiduilib.lua", true))()

local commons = {}
local uncommons = {}
local rares = {}
local legends = {}
local myths = {}
local colors = {}

do
    local elements = services.ReplicatedStorage.Client.GetElements:InvokeServer()

    for _, tbl in next, elements do
        if type(tbl) == "table" then
            colors[tbl[1]] = tbl[3]
            if tbl[2] == "Common" then
                table.insert(commons, tbl[1])
            elseif tbl[2] == "Uncommon" then
                table.insert(uncommons, tbl[1])
            elseif tbl[2] == "Rare" then
                table.insert(rares, tbl[1])
            elseif tbl[2] == "Legend" then
                table.insert(legends, tbl[1])
            elseif tbl[2] == "Myth" then
                table.insert(myths, tbl[1])
            end
        end
    end
end

local found = false
local request = syn and syn.request or request

local main = library:Load({Name = "EGG Farmer", Theme = "Dark", SizeX = 238, SizeY = (request and 503 or 362), ColorOverrides = {}})
local aimbot = main:Tab("Main")
local section = aimbot:Section({Name = "Autofarm", column = 1})

section:Toggle({Name = "Element Farmer", Flag = "elementfarm", Callback = function(value)
    if value == false then 
        if client.Character and client.Character:FindFirstChild("Humanoid") then
            client.Character.Humanoid.Health = 0
        end

        found = false 
    end
end})

local levelbeforespin = section:Box({Name = "Level Before Spinning", Flag = "levelbeforespin"})
levelbeforespin:Set("2")

section:Toggle({Name = "Level Farmer", Flag = "levelfarm", Callback = function(value)
    if value == false then 
        if client.Character and client.Character:FindFirstChild("Humanoid") then
            client.Character.Humanoid.Health = 0
        end
    end
end})

local maxlevel = section:Box({Name = "Max Level", Flag = "maxlevel"})
maxlevel:Set("100")

local elements = {}
local chosencommon = {}
local chosenuncommon = {}
local chosenrare = {}
local chosenlegend = {}
local chosenmyth = {}

section:Label("Commons")

section:Dropdown({Content = commons, MultiChoice = true, Callback = function(tbl)
    for _, elem in next, tbl do
        elements[elem] = true
        chosencommon = tbl
        for chosen, _ in next, elements do
            if not table.find(chosencommon, chosen) and not table.find(chosenuncommon, chosen) and not table.find(chosenrare, chosen) and not table.find(chosenlegend, chosen) and not table.find(chosenmyth, chosen) then
                elements[chosen] = false
            end
        end
    end
end})

section:Label("Uncommons")

section:Dropdown({Content = uncommons, MultiChoice = true, Callback = function(tbl)
    for _, elem in next, tbl do
        elements[elem] = true
        chosenuncommon = tbl
        for chosen, _ in next, elements do
            if not table.find(chosencommon, chosen) and not table.find(chosenuncommon, chosen) and not table.find(chosenrare, chosen) and not table.find(chosenlegend, chosen) and not table.find(chosenmyth, chosen) then
                elements[chosen] = false
            end
        end
    end
end})

section:Label("Rares")

section:Dropdown({Content = rares, MultiChoice = true, Callback = function(tbl)
    for _, elem in next, tbl do
        elements[elem] = true
        chosenrare = tbl
        for chosen, _ in next, elements do
            if not table.find(chosencommon, chosen) and not table.find(chosenuncommon, chosen) and not table.find(chosenrare, chosen) and not table.find(chosenlegend, chosen) and not table.find(chosenmyth, chosen) then
                elements[chosen] = false
            end
        end
    end
end})

section:Label("Legends")

section:Dropdown({Content = legends, MultiChoice = true, Callback = function(tbl)
    for _, elem in next, tbl do
        elements[elem] = true
        chosenlegend = tbl
        for chosen, _ in next, elements do
            if not table.find(chosencommon, chosen) and not table.find(chosenuncommon, chosen) and not table.find(chosenrare, chosen) and not table.find(chosenlegend, chosen) and not table.find(chosenmyth, chosen) then
                elements[chosen] = false
            end
        end
    end
end})

section:Label("Myths")

section:Dropdown({Content = myths, MultiChoice = true, Callback = function(tbl)
    for _, elem in next, tbl do
        elements[elem] = true
        chosenmyth = tbl
        for chosen, _ in next, elements do
            if not table.find(chosencommon, chosen) and not table.find(chosenuncommon, chosen) and not table.find(chosenrare, chosen) and not table.find(chosenlegend, chosen) and not table.find(chosenmyth, chosen) then
                elements[chosen] = false
            end
        end
    end
end}) 

if request then
    local webhook

    section:Toggle({Name = "Hide Webhook", Callback = function(value)
        if value then
            webhook:Hide()
            main:Resize(-22)
        else
            webhook:Show()
            main:Resize(22)
        end
    end})

    webhook = section:Box({Name = "Discord Webhook", Flag = "webhook"})
    webhook:Set("")

    local webhookname = section:Box({Name = "Webhook Name", Flag = "webhookname"})
    webhookname:Set("")

    local content = isfile("eggwebhooks.json") and services.HttpService:JSONDecode(readfile("eggwebhooks.json")) or {}
    local names = {}

    for name, _ in next, content do
        table.insert(names, name)
    end

    local saved

    section:Button({Name = "Save Webhook", Callback = function()
        local hook = library.flags.webhook
        local name = library.flags.webhookname ~= "" and library.flags.webhookname or "UNNAMED"
        if hook:find("discord.com/api/webhooks/") and (hook:find("https://") or hook:find("http://")) then
            content[name] = hook
            table.clear(names)

            for name, _ in next, content do
                table.insert(names, name)
            end

            writefile("eggwebhooks.json", services.HttpService:JSONEncode(content))
            saved:Refresh(names)
        end
    end})

    section:Label("Saved Webhooks")

    saved = section:Dropdown({Content = names, Flag = "selectedhook", Callback = function(web)
        webhook:Set(content[web])
    end})

    section:Button({Name = "Unsave Webhook", Callback = function()
        local hook = library.flags.selectedhook
        local url = content[hook]
        if url:find("discord.com/api/webhooks/") and (url:find("https://") or url:find("http://")) then
            local index = content[hook]
            if index then
                local newcontent = {}

                for name, web in next, content do
                    if name ~= hook then
                        newcontent[name] = web
                    end
                end

                content = newcontent

                table.clear(names)

                for name, _ in next, content do
                    table.insert(names, name)
                end

                writefile("eggwebhooks.json", services.HttpService:JSONEncode(content))
                saved:Refresh(names)
                saved:Set()
            end
        end
    end})
end

--// main

local moves = services.ReplicatedStorage[client.UserId .. "Client"]

local function getlevel()
    local data = services.ReplicatedStorage.Client.GetLevels:InvokeServer()
    for _, tbl in next, data do
        if table.find(tbl, client) then
            return tbl[2]
        end
    end
end

local function domoves()
    for _, move in next, client.Backpack:GetChildren() do
        move = tostring(move):split(" (")[1]
        moves.StartMove:FireServer(move)
        moves.EndMove:FireServer(move)
    end
end

local function farmspinlevel()
    repeat
        domoves()
        task.wait(0.1)
    until
        getlevel() >= tonumber(library.flags.levelbeforespin)
end

local rolls = 0

function color3hex(color)
	return tostring(tonumber(string.format("0x%02X%02X%02X", math.clamp(color.R * 255, 0, 255), math.clamp(color.G * 255, 0, 255), math.clamp(color.B * 255, 0, 255)), 16))
end

local spin
spin = function()
    repeat
        local currentelement = services.ReplicatedStorage.Client.GetElement:InvokeServer()

        if elements[currentelement] then
            found = true

            if request and library.flags.webhook:find("discord.com/api/webhooks/") and (library.flags.webhook:find("https://") or library.flags.webhook:find("http://")) then
                request{
                    Url = library.flags.webhook,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = services.HttpService:JSONEncode{
                        content = "Element found! ||@everyone||",
                        embeds = {{
                            fields = {
                                {
                                    name = "Element:",
                                    value = tostring(currentelement)
                                },
                                {
                                    name = "Rolls:",
                                    value = tostring(rolls)
                                }
                            },
                            color = color3hex(colors[currentelement])
                        }}
                    }
                }
            end
        else
            if not services.ReplicatedStorage.Client.SpinCooldown:InvokeServer() then
                services.ReplicatedStorage.Client.Spin:InvokeServer()
                rolls = rolls + 1

                if elements[services.ReplicatedStorage.Client.GetElement:InvokeServer()] then
                    return spin()
                end

                if request and library.flags.webhook:find("discord.com/api/webhooks/") and (library.flags.webhook:find("https://") or library.flags.webhook:find("http://")) then
                    request{
                        Url = library.flags.webhook,
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "application/json"
                        },
                        Body = services.HttpService:JSONEncode{
                            content = "",
                            embeds = {{
                                fields = {
                                    {
                                        name = "Element:",
                                        value = tostring(services.ReplicatedStorage.Client.GetElement:InvokeServer())
                                    },
                                    {
                                        name = "Rolls:",
                                        value = tostring(rolls)
                                    }
                                },
                                color = color3hex(colors[services.ReplicatedStorage.Client.GetElement:InvokeServer()])
                            }}
                        }
                    }
                end
            end
        end

        task.wait(0.1)
    until
        library.flags.elementfarm == false or found or services.ReplicatedStorage.Client.GetSpins:InvokeServer() <= 0
end

local pos = Vector3.new(0, math.random(10000, 100000), 0)

local function startgame()
    services.ReplicatedStorage.Client.Teleport:InvokeServer()
    services.ReplicatedStorage.Client.Intro:InvokeServer()
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    workspace.CurrentCamera.CameraSubject = client.Character.Humanoid
    client.PlayerGui.IntroGui.Enabled = false
    client.PlayerGui.Spinner.Enabled = false
    client.PlayerGui.StatsGui.Enabled = true

    workspace.Gravity = 0

    task.spawn(function()
        repeat
            for _, obj in next, client.Character:GetDescendants() do
                if obj:IsA("BasePart") then
                    obj.Velocity = Vector3.new(0, 0, 0)
                    obj.RotVelocity = Vector3.new(0, 0, 0)
                end
            end

            client.Character:MoveTo(pos)
            task.wait()
        until 
            client.Character.Humanoid.Health <= 0
    end)
end

local function farmlevel()
    repeat
        domoves()
        task.wait(0.1)
    until
        getlevel() >= tonumber(library.flags.maxlevel) or library.flags.levelfarm == false
end

--// main loop

while task.wait(0.1) do
    if library.flags.elementfarm and not found then
        repeat
            startgame()
            task.wait(0.1)
        until 
            #client.Backpack:GetChildren() > 0

        farmspinlevel()
        client.Character.Humanoid.Health = 0
        repeat task.wait(0.1) until client.Character and client.Character:WaitForChild("Humanoid").Health > 0
        task.wait(5)
        spin()
    end
    if library.flags.levelfarm and (library.flags.elementfarm and found or true) then
        repeat task.wait(0.1) until client.Character and client.Character:WaitForChild("Humanoid").Health > 0

        repeat
            startgame()
            task.wait(0.1)
        until 
            #client.Backpack:GetChildren() > 0

        farmlevel()
    end
end