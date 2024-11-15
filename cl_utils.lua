-- Buy here: (4€+VAT) https://store.brutalscripts.com
function notification(title, text, time, type)
    if Config.BrutalNotify then
        exports['brutal_notify']:SendAlert(title, text, time, type)
    else
        -- Put here your own notify and set the Config.BrutalNotify to false
        TriggerEvent('brutal_pets:client:DefaultNotify', text)
    end
end

RegisterNetEvent('brutal_pets:client:DefaultNotify')
AddEventHandler('brutal_pets:client:DefaultNotify', function(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(0,1)

    -- Default ESX Notify:
    --TriggerEvent('esx:showNotification', text)

    -- Default QB Notify:
    --TriggerEvent('QBCore:Notify', text, 'info', 5000)
end)

function OpenMenuUtil()
    DisplayRadar(false)
    Citizen.CreateThread(function()
        while InMenu do
            N_0xf4f2c0d4ee209e20() -- it's disable the AFK camera zoom
            Citizen.Wait(15000)
        end 
    end)
end

function CloseMenuUtil()
    DisplayRadar(true)
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.025+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end