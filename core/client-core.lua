if Config['Core']:upper() == 'ESX' then
    Core = exports['es_extended']:getSharedObject()

    LoadedEvent = 'esx:playerLoaded'
    TSCB = Core.TriggerServerCallback

    function PlayerJobFunction()
        return Core.GetPlayerData().job.name
    end

    function GetClosestPlayerFunction()
        return Core.Game.GetClosestPlayer()
    end

elseif Config['Core']:upper() == 'QBCORE' then
    Core = exports['qb-core']:GetCoreObject()

    LoadedEvent = 'QBCore:Client:OnPlayerLoaded'
    TSCB = Core.Functions.TriggerCallback

    function PlayerJobFunction()
        return Core.Functions.GetPlayerData().job.name
    end

    function GetClosestPlayerFunction()
        return Core.Functions.GetClosestPlayer()
    end

end