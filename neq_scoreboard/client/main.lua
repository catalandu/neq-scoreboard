local opened = false
local hold = false
local id = false;

RegisterNetEvent('neq_scoreboard:open')
AddEventHandler('neq_scoreboard:open', function(users, jobs, players)
    SendNUIMessage({
        type = 'refresh',
        id = GetPlayerServerId(PlayerId()),
        users = users,
        jobs = jobs,
    })
end)

Citizen.CreateThread(function()
    Citizen.Wait(100)
    print('Version 1.2')
    TriggerServerEvent('neq_scoreboard:load')
    initNUI()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if IsControlPressed(1, Config.OpenKey) then
            Citizen.Wait(200)
            
            if IsControlPressed(1, Config.OpenKey) then
                if (not hold) then
                    TriggerServerEvent('neq_scoreboard:getPlayers')
                    hold = true;
                    opened = true;
                end
            else
                if (not hold) then
                    TriggerServerEvent('neq_scoreboard:getPlayers')
                    SetNuiFocus(true, true)
                    opened = true;
                end
            end
        else
            if (hold) then
                SendNUIMessage({
                    type = 'close',
                })
                
                hold = false;
                opened = false;
            end
        end
        
        if (Config.DisplayID) and (opened) then
            displayID()
        end
    end
end)

function initNUI()
    local kvp = GetResourceKvpInt('scoreboard-streamer')
    
    if (kvp) then
        SendNUIMessage({
            type = 'init',
            status = kvp,
            jobs = Config.Jobs['jobs']
        })
    end
end

function DrawText3D(x, y, z, text)
    local screen, x, y = World3dToScreen2d(x, y, z)
    local cam = GetGameplayCamCoords()

    if (screen) then
        SetTextFont(4)
        SetTextScale(0.4, 0.4)
        SetTextColour(255, 255, 255, 255)
        SetTextProportional(1)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry('STRING')
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(x, y)
    end
end 

function displayID()
    if (not id) then
        id = true;

        Citizen.CreateThread(function()
            while opened do
                Citizen.Wait(1)
                for k,v in pairs(GetActivePlayers()) do
                    local id = GetPlayerServerId(v)
                    local player = GetPlayerFromServerId(id)
                    local ped = GetPlayerPed(player)
                    local localCoords = GetEntityCoords(PlayerPedId())
                    local pedCoords = GetEntityCoords(ped)
                    local dist = #(localCoords - pedCoords)

                    if (dist < 20) then
                        DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z+1.20, id)
                    end
                end
            end

            id = false;
        end)
    end
end

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    opened = false    
    cb(true)    
end)

RegisterNUICallback('streamer', function(data, cb)
    SetResourceKvpInt('scoreboard-streamer', tonumber(data.streamer))
    cb(true)
end)  --[[  
██╗░░░██╗██████╗░██╗░░░░░███████╗░█████╗░██╗░░██╗░██████╗
██║░░░██║██╔══██╗██║░░░░░██╔════╝██╔══██╗██║░██╔╝██╔════╝
██║░░░██║██████╔╝██║░░░░░█████╗░░███████║█████═╝░╚█████╗░
██║░░░██║██╔═══╝░██║░░░░░██╔══╝░░██╔══██║██╔═██╗░░╚═══██╗
╚██████╔╝██║░░░░░███████╗███████╗██║░░██║██║░╚██╗██████╔╝
░╚═════╝░╚═╝░░░░░╚══════╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░
█████████████████████████████████████████████████████████
discord.gg/6CRxjqZJFB ]]--