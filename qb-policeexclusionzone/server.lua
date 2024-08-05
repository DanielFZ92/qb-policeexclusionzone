local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add("createzone", "Create an exclusion zone", {{name = "radius", help = "Radius of the zone in meters"}}, true, function(source, args)
    local src = source
local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "police" and Player.PlayerData.job.grade.level >= 4 then
        local radius = tonumber(args[1])
        if not radius then return end
        local ped = GetPlayerPed(src)
        local coords = GetEntityCoords(ped)
        TriggerClientEvent('police:createExclusionZone', -1, coords, radius)
        TriggerClientEvent('QBCore:Notify', src, "Mit Radius erstellte Sperrzone " .. radius .. " meter", "Erfolgreich")
    else
        TriggerClientEvent('QBCore:Notify', src, "Sie sind nicht berechtigt, eine Ausschlusszone zu erstellen", "Fehler")
    end
end)

QBCore.Commands.Add("removezone", "Remove the exclusion zone", {}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == "police" and Player.PlayerData.job.grade.level >= 4 then
        TriggerClientEvent('police:removeExclusionZone', -1)
        TriggerClientEvent('QBCore:Notify', src, "Sperrzone entfernt", "Erfolgreich")
    else
        TriggerClientEvent('QBCore:Notify', src, "Sie sind nicht berechtigt, die Ausschlusszone zu entfernen", "Fehler")
    end
end)

RegisterServerEvent('police:finePlayer')
AddEventHandler('police:finePlayer', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local fine = 15000

    if Player.PlayerData.money['bank'] >= fine then
        Player.Functions.RemoveMoney('bank', fine, "Sperrzone in Ordnung")
        TriggerClientEvent('QBCore:Notify', src, "Für den Verbleib in der Sperrzone wurde Ihnen eine Geldstrafe von 15.000$ auferlegt", "Fehler")
    else
        TriggerClientEvent('QBCore:Notify', src, "Sie haben nicht genug Geld, um die Strafe zu bezahlen. Es können rechtliche Schritte eingeleitet werden.", "Fehler")
        -- You could add additional consequences here, like increasing wanted level or notifying police
    end
end)