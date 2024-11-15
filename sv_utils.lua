local YourWebhook = 'https://discordapp.com/api/webhooks/1278165798107480165/o2yccwEv44SsBaGnb7xrcPZJkNDTk5gGGn7FGqs6JhlgLx-eEG90cnqqQn5zty19SOsg'  -- help: https://docs.brutalscripts.com/site/others/discord-webhook

function GetWebhook()
    return YourWebhook
end

-- Buy here: (4€+VAT) https://store.brutalscripts.com
function notification(source, title, text, time, type)
    if Config.BrutalNotify then
        TriggerClientEvent('brutal_notify:SendAlert', source, title, text, time, type)
    else
        TriggerClientEvent('brutal_pets:client:DefaultNotify', text)
    end
end

function UpdatePlayerAccount(identifier, amount)
    if Config['Core']:upper() == 'ESX' then
        MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
            ['@identifier'] = identifier
        }, function(results)
            if results[1] then
                local playerAccount = json.decode(results[1].accounts)
                local NewbankBalance = playerAccount.bank + amount
				playerAccount.bank = playerAccount.bank + amount
				playerAccount = json.encode(playerAccount)

                MySQL.Async.execute('UPDATE users SET accounts = @accounts WHERE identifier = @target', {
                    ['@accounts'] = playerAccount,
                    ['@target'] = identifier
                }, nil)

                MySQL.Async.fetchAll('SELECT * FROM brutal_banking_accounts WHERE identifier = @identifier', {
                    ['@identifier'] = identifier
                }, function(results)
                    if results[1] ~= nil then
                        local transactions = json.decode(results[1].transactions)
                        table.insert(transactions, {id = #transactions+1, balance = NewbankBalance, amount = amount, type = 'add', label = 'Transfer'})
                
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

                        MySQL.Async.execute('UPDATE brutal_banking_accounts SET transactions = @transactions WHERE identifier = @identifier', {
                            ['@identifier'] = identifier,
                            ["@transactions"] = json.encode(transactions)
                        }, nil)
                    end
                end)
            end
        end)
    elseif Config['Core']:upper() == 'QBCORE' then
        MySQL.query('SELECT * FROM players WHERE citizenid = @citizenid', {
            ['@citizenid'] = identifier
        }, function(results)
            if results[1] then
                local playerAccount = json.decode(results[1].money)
                local NewbankBalance = playerAccount.bank + amount
				playerAccount.bank = playerAccount.bank + amount
				playerAccount = json.encode(playerAccount)

                MySQL.query('UPDATE players SET money = @money WHERE citizenid = @target', {
                    ['@money'] = playerAccount,
                    ['@target'] = identifier
                }, nil)

                MySQL.Async.fetchAll('SELECT * FROM brutal_banking_accounts WHERE identifier = @identifier', {
                    ['@identifier'] = identifier
                }, function(results)
                    if results[1] ~= nil then
                        local transactions = json.decode(results[1].transactions)
                        table.insert(transactions, {id = #transactions+1, balance = NewbankBalance, amount = amount, type = 'add', label = 'Transfer'})
                
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

                        MySQL.Async.execute('UPDATE brutal_banking_accounts SET transactions = @transactions WHERE identifier = @identifier', {
                            ['@identifier'] = identifier,
                            ["@transactions"] = json.encode(transactions)
                        }, nil)
                    end
                end)
            end
        end)
    end
end