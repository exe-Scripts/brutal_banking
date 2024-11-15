Assistants = {}
MyBankData = {}
PlayerData = {}
closestATM = nil
InMenu = false
CanOpenMenu = true

-- BY 5M EXCLUSIVE-SCRIPTS
-- JOIN OUR DISCORD FOR MORE FREE SCRIPTS
-- discord.gg/fivemscripts

Citizen.CreateThread(function()
	for k,v in pairs(Config.Banks) do
		-- Blip
		if v.blipEnabled then
			local blip = AddBlipForCoord(v.markerCoords)
			SetBlipSprite(blip, Config.BankBlips.sprite)
			SetBlipColour(blip, Config.BankBlips.color)
			SetBlipScale(blip, Config.BankBlips.size)
			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName(v.bankName)
			EndTextCommandSetBlipName(blip)
			SetBlipAsShortRange(blip, true)
		end

		-- Assistant
		if v.pedEnabled then
			loadModel(v.assistantModel)
			Assistant = CreatePed(4, v.assistantModel, v.assistantCoords[1], v.assistantCoords[2], v.assistantCoords[3]-1, v.assistantCoords[4], false, true)
			FreezeEntityPosition(Assistant, true)
			SetEntityInvincible(Assistant, true)
			SetBlockingOfNonTemporaryEvents(Assistant, true)
			table.insert(Assistants, Assistant)
		end
		
		-- Bank Menu open
		if Config.Target:upper() == 'MARKER' then
			Citizen.CreateThread(function()
				while true do
					sleep = 1000
					local playerCoords = GetEntityCoords(PlayerPedId())
		
					if #(playerCoords - v.markerCoords) < Config.Distances.marker then
						sleep = 1
						DrawMarker(20, v.markerCoords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.2, 187, 255, 0, 255, false, true, 2, nil, nil, false)
					end

					if #(playerCoords - v.markerCoords) < Config.Distances.open and not InMenu then
						sleep = 1
						DrawText3D(v.markerCoords[1], v.markerCoords[2], v.markerCoords[3]+0.2, Config.Texts[1][1])
						
						if IsControlJustReleased(0, Config.MenuOpenKey) then
							TriggerEvent('brutal_banking:client:OpenBankingMenu')
						end
					end
					Citizen.Wait(sleep)
				end
			end)
		elseif Config.Target:upper() == 'OXTARGET' and v.pedEnabled then
			local data = {
				{
					name = 'banking',
					event = 'brutal_banking:client:OpenBankingMenu',
					label = Config.Texts[1][2],
					icon = Config.Texts[1][3],
					distance = Config.Distances.open
				}
			}
			exports.ox_target:addLocalEntity(Assistant, data)
		elseif Config.Target:upper() == 'QB-TARGET' and v.pedEnabled then
			exports['qb-target']:AddTargetEntity(Assistant, {
				options = {{
					num = 1,
					type = "client",
					event = "brutal_banking:client:OpenBankingMenu",
					label = Config.Texts[1][2],
					icon = Config.Texts[1][3],
				}},
				distance = Config.Distances.open,
			})
		end
	end
end)

Citizen.CreateThread(function()
	-- Atm Menu open
	if Config.Target:upper() == 'MARKER' then
		Citizen.CreateThread(function()
			while true do
				sleep = 2500
				local playerCoords = GetEntityCoords(PlayerPedId())

				for k,v in pairs(Config.AtmModels) do
					local atm = GetClosestObjectOfType(playerCoords, Config.Distances.open+5.0, GetHashKey(v), false, false, false)
					if DoesEntityExist(atm) then
						sleep = 1
						if atm ~= closestATM then
							closestATM = atm
							atmCoords = GetEntityCoords(atm)
						end
						
						if #(playerCoords - atmCoords) <= Config.Distances.open and not InMenu then
							HelpNotify(Config.Texts[2][1])

							if IsControlJustReleased(0, Config.MenuOpenKey) then
								TriggerEvent('brutal_banking:client:OpenAtmMenu')
							end
						end
					end
				end
				Citizen.Wait(sleep)
			end
		end)
	elseif Config.Target:upper() == 'OXTARGET' then
		local data = {
			{
				name = 'banking',
				event = 'brutal_banking:client:OpenAtmMenu',
				label = Config.Texts[2][2],
				icon = Config.Texts[2][3],
				distance = Config.Distances.open
			}
		}
		exports.ox_target:addModel(Config.AtmModels, data)
	elseif Config.Target:upper() == 'QB-TARGET' then
		exports['qb-target']:AddTargetModel(Config.AtmModels, {
			options = {{
				num = 1,
				type = "client",
				event = "brutal_banking:client:OpenAtmMenu",
				label = Config.Texts[1][2],
				icon = Config.Texts[1][3],
			}},
			distance = Config.Distances.open,
		})
	end
end)

RegisterNetEvent('brutal_banking:client:OpenBankingMenu')
AddEventHandler('brutal_banking:client:OpenBankingMenu', function()
	if CanOpenMenuFunction() then
		InMenuFunction()
		TSCB('brutal_banking:server:GetPlayerDatas', function(_MyBankData, _PlayerData)
			MyBankData = _MyBankData
			PlayerData = _PlayerData

			if not PlayerData.new then
				for k,v in pairs(MyBankData[1].transactions) do
					local value = 10
					if #MyBankData[1].transactions < 10 then
						value = #MyBankData[1].transactions
					end

					if v.id == value then
						if v.balance ~= MyBankData[1].bank then
							if MyBankData[1].bank < v.balance then
								TriggerEvent('brutal_banking:client:AddTransaction', v.balance-MyBankData[1].bank,'remove', Config.Transactions.Correction, {correction = true})
							elseif MyBankData[1].bank > v.balance then
								TriggerEvent('brutal_banking:client:AddTransaction', MyBankData[1].bank-v.balance,'add', Config.Transactions.Correction, {correction = true})
							end
						end
						break
					end
				end
			end

			OpenMenuUtil()
			SetNuiFocus(true, true)
			SendNUIMessage({ 
				action = "OpenBankingMenu",
				banklabel = Config.BankLabel,
				mybankdata = MyBankData,
				playerdata = PlayerData,
				moneyform = Config.MoneyForm,
				ibannumbers = Config.IBAN.numbers,
				ibanprefix = Config.IBAN.prefix,
				costs = {pincode = Config.PINChangeCost, iban = Config.IBANChangeCost, sub = Config.NewSubAccountCost},
				dailylimit = Config.DailyLimit,
			})
		end)
	end
end)

RegisterNetEvent('brutal_banking:client:OpenAtmMenu')
AddEventHandler('brutal_banking:client:OpenAtmMenu', function()
	if CanOpenMenuFunction() then
		InMenuFunction()
		TSCB('brutal_banking:server:GetPlayerDatas', function(_MyBankData, _PlayerData)
			MyBankData = _MyBankData
			PlayerData = _PlayerData

			if PlayerData.pincode ~= '' then
				OpenMenuUtil()
				SetNuiFocus(true, true)
				SendNUIMessage({ 
					action = "OpenAtmMenu",
					banklabel = Config.BankLabel,
					mybankdata = MyBankData,
					playerdata = PlayerData,
					moneyform = Config.MoneyForm,
					ibannumbers = Config.IBAN.numbers,
					ibanprefix = Config.IBAN.prefix,
					costs = {pincode = Config.PINChangeCost, iban = Config.IBANChangeCost, sub = Config.NewSubAccountCost},
					dailylimit = Config.DailyLimit,
				})
			else
				SendNotify(15)
				InMenu = false
			end
		end)
	end
end)

function CanOpenMenuFunction()
	if not IsPedInAnyVehicle(PlayerPedId(), false) then
		if not InMenu then
			if CanOpenMenu then
				return true
			else
				SendNotify(16)
				return false
			end
		else
			return false
		end
	else
		SendNotify(17)
		return false
	end
end

function InMenuFunction()
	InMenu = true
	CanOpenMenu = false
	Citizen.CreateThread(function()
		if Config.MenuReopenLimit ~= false then
			Citizen.Wait(1000*Config.MenuReopenLimit)
			CanOpenMenu = true
		else
			CanOpenMenu = true
		end
	end)
end

RegisterNetEvent('brutal_banking:client:AddTransaction')
AddEventHandler('brutal_banking:client:AddTransaction', function(amount, type, label, extraData)
	if (amount > 0 or extraData.correction) and (type == 'add' or type == 'remove') and label ~= nil then
		local NilData = false
		if MyBankData[1] == nil then
			TSCB('brutal_banking:server:GetPlayerDatas', function(_MyBankData, _PlayerData)
				MyBankData = _MyBankData
				PlayerData = _PlayerData
				NilData = true
			end)
		end

		while MyBankData[1] == nil do
			Citizen.Wait(1)
		end

		if extraData == nil or extraData.correction == false then
			if type == 'remove' then
				if not NilData then
					MyBankData[1].bank -= amount
				end
				table.insert(MyBankData[1].transactions, {id = #MyBankData[1].transactions+1, balance = MyBankData[1].bank, amount = amount, type = type, label = label})
			elseif type == 'add' then
				if not NilData then
					MyBankData[1].bank += amount
				end
				table.insert(MyBankData[1].transactions, {id = #MyBankData[1].transactions+1, balance = MyBankData[1].bank, amount = amount, type = type, label = label})
			end
		else
			if type == 'remove' then
				table.insert(MyBankData[1].transactions, {id = #MyBankData[1].transactions+1, balance = MyBankData[1].bank, amount = amount, type = type, label = label})
			elseif type == 'add' then
				table.insert(MyBankData[1].transactions, {id = #MyBankData[1].transactions+1, balance = MyBankData[1].bank, amount = amount, type = type, label = label})
			end
		end

		if #MyBankData[1].transactions > 10 then
			for k,v in pairs(MyBankData[1].transactions) do
				v.id -= 1
			end

			for k,v in pairs(MyBankData[1].transactions) do
				if v.id == 0 then
					table.remove(MyBankData[1].transactions, k)
				end
			end
		end
		TriggerServerEvent('brutal_banking:server:SaveTransaction', 'MAIN', MyBankData[1].transactions)
	end
end)

RegisterNetEvent('brutal_banking:client:AddTransactionSubAccount')
AddEventHandler('brutal_banking:client:AddTransactionSubAccount', function(id, amount, type, label)
	if type == 'remove' then
        table.insert(MyBankData[id].transactions, {id = #MyBankData[id].transactions+1, balance = MyBankData[id].bank-amount, amount = amount, type = type, label = label})
    elseif type == 'add' then
        table.insert(MyBankData[id].transactions, {id = #MyBankData[id].transactions+1, balance = MyBankData[id].bank+amount, amount = amount, type = type, label = label})
    end

	if #MyBankData[id].transactions > 10 then
		for k,v in pairs(MyBankData[id].transactions) do
			v.id -= 1
		end

		for k,v in pairs(MyBankData[id].transactions) do
			if v.id == 0 then
				table.remove(MyBankData[id].transactions, k)
			end
		end
	end
	TriggerServerEvent('brutal_banking:server:SaveTransaction', MyBankData[id].account_id, MyBankData[id].transactions)
end)

RegisterNetEvent('brutal_banking:client:RefreshAccountBalance')
AddEventHandler('brutal_banking:client:RefreshAccountBalance', function(id, newBalance, money, newTransactions)
	MyBankData[id].bank = newBalance
	if newTransactions ~= nil then 
		MyBankData[id].transactions = newTransactions 
	end
	PlayerData.money = money
	SendNUIMessage({ 
		action = "RefreshBankingMenu",
		mybankdata = MyBankData,
		playerdata = PlayerData
	})
end)

RegisterNetEvent('brutal_banking:client:RefreshDataValues')
AddEventHandler('brutal_banking:client:RefreshDataValues', function(id, newPincode, newName, newIBAN, DeleteSubAccount, CreateSubAccount, newPermissions, newPartnerList)
	if newPincode ~= nil then 
		PlayerData.pincode = newPincode
	end

	if id ~= nil and newName ~= nil then 
		MyBankData[id].account_name = newName
	end

	if id ~= nil and newIBAN ~= nil then 
		MyBankData[id].iban = newIBAN
	end

	if DeleteSubAccount then
		for k, v in pairs(MyBankData) do
			if v.account_id == id then
				table.remove(MyBankData, k)
			end
		end
	end

	if CreateSubAccount then
		InMenuFunction()
		TSCB('brutal_banking:server:GetPlayerDatas', function(_MyBankData, _PlayerData)
			MyBankData = _MyBankData
			PlayerData = _PlayerData

			OpenMenuUtil()
			SetNuiFocus(true, true)
			SendNUIMessage({ 
				action = "OpenBankingMenu",
				banklabel = Config.BankLabel,
				mybankdata = MyBankData,
				playerdata = PlayerData,
				moneyform = Config.MoneyForm,
				ibannumbers = Config.IBAN.numbers,
				ibanprefix = Config.IBAN.prefix,
				costs = {pincode = Config.PINChangeCost, iban = Config.IBANChangeCost, sub = Config.NewSubAccountCost},
				dailylimit = Config.DailyLimit,
			})
		end)
	end

	if newPermissions ~= nil then
		MyBankData[id].permissions = newPermissions
	end

	if newPartnerList ~= nil then
		PlayerData.partners = newPartnerList
	end

	if not CreateSubAccount then
		SendNUIMessage({ 
			action = "RefreshBankingMenu",
			mybankdata = MyBankData,
			playerdata = PlayerData
		})
	end
end)

RegisterCommand("newpartner", function()
    TriggerEvent('brutal_banking:client:AddNewPartner', 'BS123456', 'Új partner')
end)

RegisterNetEvent('brutal_banking:client:AddNewPartner')
AddEventHandler('brutal_banking:client:AddNewPartner', function(account_id, label)
	table.insert(PlayerData.partners, {account_id = account_id, label = label})
	TriggerServerEvent('brutal_banking:server:SaveNewPartner', PlayerData.partners)
end)

RegisterCommand("changeiban", function()
	local newIban = 'BS123456'
    TriggerServerEvent('brutal_banking:server:ChangeIBAN', 'MAIN', newIban)
end)

RegisterCommand('createsub', function()
	TriggerServerEvent('brutal_banking:server:CreateSubAccount', 'Új számla', 1234)
end)

RegisterCommand('deletesub', function()
	TriggerServerEvent('brutal_banking:server:DeleteSubAccount', 'ID116220')
end)

function GetPlayerLimit(account_id)
	for k,v in pairs(MyBankData) do
        if v.account_id == account_id then
            return v.limit
        end
    end
end

-----------------------------------------------------------
-------------------| script stop event |-------------------
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() == resourceName) then
		for k,v in pairs(Assistants) do
			DeletePed(v)
		end
	end
end)

-----------------------------------------------------------
-------------------| default functions |-------------------
-----------------------------------------------------------

RegisterNetEvent('brutal_banking:client:SendNotify')
AddEventHandler('brutal_banking:client:SendNotify', function(title, text, time, type)
	notification(title, text, time, type)
end)

function SendNotify(Number)
    notification(Config.Notify[Number][1], Config.Notify[Number][2], Config.Notify[Number][3], Config.Notify[Number][4])
end

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do        
        Citizen.Wait(1)
    end
end
  
function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end

function HelpNotify(text)
    AddTextEntry('HelpNotification', text)
    BeginTextCommandDisplayHelp('HelpNotification')
    EndTextCommandDisplayHelp(0, false)
end

---------------------------------------------------
-------------- NOT RENAME THE SCRIPT --------------
---------------------------------------------------

Citizen.CreateThread(function()
	Citizen.Wait(1000*30)
	if GetCurrentResourceName() ~= 'brutal_banking' then
		while true do
			Citizen.Wait(1)
			print("Please don't rename the script! Please rename it back to 'brutal_banking'")
		end
	end
end)