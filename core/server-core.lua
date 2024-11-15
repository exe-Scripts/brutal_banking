Core = nil

if Config['Core']:upper() == 'ESX' then
--------------------------------------------------------------------------
---------------------------------| ESX |----------------------------------
--------------------------------------------------------------------------

    Core = exports['es_extended']:getSharedObject()

    RESCB = Core.RegisterServerCallback
    GETPFI = Core.GetPlayerFromId
    RUI = Core.RegisterUsableItem

    function GetIdentifier(source)
        local xPlayer = GETPFI(source)
        return xPlayer.identifier
    end

    function GetPlayerByIdentifier(identifier)
        return Core.GetPlayerFromIdentifier(identifier)
    end

    function GetAccountMoney(source,account)
        local xPlayer = GETPFI(source)
        return xPlayer.getAccount(account).money
    end

    function AddMoneyFunction(source, account, amount)
        local xPlayer = GETPFI(source)
        xPlayer.addAccountMoney(account, amount)
    end

    function GetItemCount(source, item)
        local xPlayer = GETPFI(source)
        return xPlayer.getInventoryItem(item).count
    end

    function RemoveAccountMoney(source, account, amount)
        local xPlayer = GETPFI(source)
        xPlayer.removeAccountMoney(account, amount)
    end
    
    function RemoveItem(source, item, amount)
        local xPlayer = GETPFI(source)
        xPlayer.removeInventoryItem(item, amount)
    end

    function AddItem(source, item, count)
        local xPlayer = GETPFI(source)
        xPlayer.addInventoryItem(item, count)
    end

    function GetPlayerNameFunction(source)
        local name
        if Config.SteamName then
            name = GetPlayerName(source)
        else
            local xPlayer = GETPFI(source)
            name = xPlayer.get("firstName")..' '..xPlayer.get("lastName")
        end
        return name
    end

    function GetPlayerSex(source)
        local xPlayer = GETPFI(source)
        return xPlayer.get("sex")
    end

elseif Config['Core']:upper() == 'QBCORE' then
--------------------------------------------------------------------------
--------------------------------| QBCORE |--------------------------------
--------------------------------------------------------------------------

    Core = exports['qb-core']:GetCoreObject()
    
    RESCB = Core.Functions.CreateCallback
    GETPFI = Core.Functions.GetPlayer
    RUI = Core.Functions.CreateUseableItem

    function GetIdentifier(source)
        local xPlayer = GETPFI(source)
        return xPlayer.PlayerData.citizenid
    end

    function GetPlayerByIdentifier(identifier)
        return Core.Functions.GetPlayerByCitizenId(identifier)
    end

    function GetPlayersFunction()
        return Core.Functions.GetPlayers()
    end

    function GetAccountMoney(source, account)
        local xPlayer = GETPFI(source)
        if account == 'bank' then
            return xPlayer.PlayerData.money.bank
        elseif account == 'money' then
            return xPlayer.PlayerData.money.cash
        end
    end

    function AddMoneyFunction(source, account, amount)
        local xPlayer = GETPFI(source)
        if account == 'bank' then
            xPlayer.Functions.AddMoney('bank', amount)
        elseif account == 'money' then
            xPlayer.Functions.AddMoney('cash', amount)
        end
    end

    function GetItemCount(source, item)
        local xPlayer = GETPFI(source)
        local items = xPlayer.Functions.GetItemByName(item)
        local item_count = 0
        if items ~= nil then
            item_count = items.amount
        else
            item_count = 0
        end
        return item_count
    end

    function RemoveAccountMoney(source, account, amount)
        local xPlayer = GETPFI(source)
        if account == 'bank' then
            xPlayer.Functions.RemoveMoney('bank', amount)
        elseif account == 'money' then
            xPlayer.Functions.RemoveMoney('cash', amount)
        end
    end

    function RemoveItem(source, item, amount)
        local xPlayer = GETPFI(source)
        xPlayer.Functions.RemoveItem(item, amount)
    end

    function AddItem(source, item, count)
        local xPlayer = GETPFI(source)
        xPlayer.Functions.AddItem(item, count)
    end

    function GetPlayerNameFunction(source)
        local name
        if Config.SteamName then
            name = GetPlayerName(source)
        else
            local xPlayer = GETPFI(source)
            name = xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname
        end
        return name
    end

    function GetPlayerSex(source)
        local xPlayer = GETPFI(source)
        local sex = xPlayer.PlayerData.charinfo.gender

        if sex == 0 then
            sex = 'm'
        else
            sex = 'f'
        end

        return sex
    end

end