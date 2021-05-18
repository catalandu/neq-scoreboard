local users = {}
local apiKey = GetConvar('steam_webApiKey')
local players = {}

if (Config.Jobs['enabled']) and (Config.Jobs['framework'] == 'esx') then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end 

RegisterNetEvent('neq_scoreboard:load')
AddEventHandler('neq_scoreboard:load', function()
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    local hex = string.gsub(identifier, 'steam:', '')
    local decimal = tonumber(hex, 16)

    PerformHttpRequest('http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=' .. apiKey .. '&steamids=' .. decimal, function(error, result, header)
        local result = json.decode(result)
        local url = result.response.players[1].avatarfull
        users[src] = {id = src, avatar = url}
    end)
end)

AddEventHandler('playerDropped', function()
    users[source] = nil
end)

RegisterNetEvent('neq_scoreboard:getPlayers')
AddEventHandler('neq_scoreboard:getPlayers', function()
    local src = source 
    local data = {}
    local jobs = {}

    for k,v in pairs(users) do
        if (Config.Jobs['enabled']) then   
            if (Config.Jobs['framework'] == 'esx') then
                for k,v in pairs(GetPlayers()) do
                    local xPlayer = ESX.GetPlayerFromId(tonumber(v))
                    
                    for i, y in pairs(Config.Jobs['jobs']) do
                        if (not jobs[jobs[i]]) then
                            jobs[i] = 0
                        end

                        if (xPlayer.getJob().name == i) then
                            jobs[i] = jobs[i]+1
                            break;
                        end
                    end
                end
            end
        end

        table.insert(data, {id = v.id, name = GetPlayerName(v.id), avatar = v.avatar, ping = GetPlayerPing(src), players = #GetPlayers()})
    end

    TriggerClientEvent('neq_scoreboard:open', src, data, jobs)
end)

  --[[  
██╗░░░██╗██████╗░██╗░░░░░███████╗░█████╗░██╗░░██╗░██████╗
██║░░░██║██╔══██╗██║░░░░░██╔════╝██╔══██╗██║░██╔╝██╔════╝
██║░░░██║██████╔╝██║░░░░░█████╗░░███████║█████═╝░╚█████╗░
██║░░░██║██╔═══╝░██║░░░░░██╔══╝░░██╔══██║██╔═██╗░░╚═══██╗
╚██████╔╝██║░░░░░███████╗███████╗██║░░██║██║░╚██╗██████╔╝
░╚═════╝░╚═╝░░░░░╚══════╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░
█████████████████████████████████████████████████████████
discord.gg/6CRxjqZJFB ]]--