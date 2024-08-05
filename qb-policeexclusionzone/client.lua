local QBCore = exports['qb-core']:GetCoreObject()
local exclusionZone = nil
local inZone = false
local notificationSent = false
local timer = 0
local zoneBlip = nil

RegisterNetEvent('police:createExclusionZone')
AddEventHandler('police:createExclusionZone', function(center, radius)
    exclusionZone = {center = center, radius = radius}
    notificationSent = false
    timer = 0
    createZoneBlip(center, radius)
end)

RegisterNetEvent('police:removeExclusionZone')
AddEventHandler('police:removeExclusionZone', function()
    exclusionZone = nil
    inZone = false
    notificationSent = false
    timer = 0
    removeZoneBlip()
end)

function createZoneBlip(center, radius)
    removeZoneBlip() -- Remove existing blip if any

    zoneBlip = AddBlipForRadius(center.x, center.y, center.z, radius + 0.0)
    SetBlipRotation(zoneBlip, 0)
    SetBlipColour(zoneBlip, 1) -- Red color
    SetBlipAlpha(zoneBlip, 128) -- Semi-transparent

    -- Make the blip non-pulsating
    SetBlipFlashes(zoneBlip, false)
    SetBlipFlashInterval(zoneBlip, 0)

    -- Add a marker at the center
    local centerBlip = AddBlipForCoord(center.x, center.y, center.z)
    SetBlipSprite(centerBlip, 1) -- Standard circular blip
    SetBlipColour(centerBlip, 1) -- Red color
    SetBlipScale(centerBlip, 0.8) -- Slightly smaller than default
    SetBlipAsShortRange(centerBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Exclusion Zone Center")
    EndTextCommandSetBlipName(centerBlip)

    -- Ensure the blips are visible from a distance
    SetBlipAsShortRange(zoneBlip, false)
    SetBlipAsShortRange(centerBlip, false)
end

function removeZoneBlip()
    if zoneBlip then
        RemoveBlip(zoneBlip)
        zoneBlip = nil
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if exclusionZone then
            local playerPos = GetEntityCoords(PlayerPedId())
            local distance = #(playerPos - exclusionZone.center)
            if distance <= exclusionZone.radius then
                if not inZone then
                    inZone = true
                    notificationSent = false
                    timer = 0
                end

                if not notificationSent then
                    QBCore.Functions.Notify("You are in a restricted zone. Leave within 120 seconds or face a $15,000 fine.", "error", 10000)
                    notificationSent = true
                end

                timer = timer + 1
                if timer >= 120 then
                    TriggerServerEvent('police:finePlayer')
                    timer = 0
                end
            else
                inZone = false
                notificationSent = false
                timer = 0
            end
        end
    end
end)