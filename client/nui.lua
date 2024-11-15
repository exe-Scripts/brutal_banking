-- BY 5M EXCLUSIVE-SCRIPTS
-- JOIN OUR DISCORD FOR MORE FREE SCRIPTS
-- discord.gg/fivemscripts
RegisterNUICallback("UseButton", function(data)
	if data.action == 'close' then
		InMenu = false
		SetNuiFocus(false, false)
		CloseMenuUtil()
	elseif data.action == 'ChangePIN' then
		TriggerServerEvent('brutal_banking:server:ChangePINCODE', data.value)
	elseif data.action == 'ChangeIBAN' then
		if data.account == 1 then
			TriggerServerEvent('brutal_banking:server:ChangeIBAN', 'MAIN', data.value, data.account)
		else
			TriggerServerEvent('brutal_banking:server:ChangeIBAN', MyBankData[data.account].account_id, data.value, data.account)
		end
	elseif data.action == 'ChangeNAME' then
		if data.account == 1 then
			TriggerServerEvent('brutal_banking:server:ChangeNAME', 'MAIN', data.account, data.value)
		else
			TriggerServerEvent('brutal_banking:server:ChangeNAME', MyBankData[data.account].account_id, data.account, data.value)
		end
	elseif data.action == 'SavePermission' then
		TriggerServerEvent('brutal_banking:server:SaveSubAccountPermission', MyBankData[data.account].account_id, data.account, data.permission_table) 
	elseif data.action == 'AddMemberPermission' then
		TriggerServerEvent('brutal_banking:server:AddMemberPermission', MyBankData[data.account].account_id, data.account, data.permission_table, tonumber(data.target_id), data.permission, tonumber(data.limit))
	elseif data.action == 'RefreshPartnerList' then
		TriggerServerEvent('brutal_banking:server:SaveNewPartner', data.partnerlist) 
	elseif data.action == 'CreateSubAccount' then
		TriggerServerEvent('brutal_banking:server:CreateSubAccount', data.account_name, data.pincode)
	elseif data.action == 'DeleteSubAccount' then
		TriggerServerEvent('brutal_banking:server:DeleteSubAccount', MyBankData[data.account].account_id)
	elseif data.action == 'Deposit' then
		if tonumber(data.amount) > 0 then
			if data.account == 1 then
				TriggerServerEvent('brutal_banking:server:Deposit', 'MAIN', tonumber(data.amount), data.account)
			else
				TriggerServerEvent('brutal_banking:server:Deposit', MyBankData[data.account].account_id, tonumber(data.amount), data.account)
			end
		end
	elseif data.action == 'Withdraw' then
		if tonumber(data.amount) > 0 then
			if data.account == 1 then
				TriggerServerEvent('brutal_banking:server:Withdraw', 'MAIN', tonumber(data.amount), data.account, GetPlayerLimit(MyBankData[data.account].account_id))
			else
				TriggerServerEvent('brutal_banking:server:Withdraw', MyBankData[data.account].account_id, tonumber(data.amount), data.account, GetPlayerLimit(MyBankData[data.account].account_id))
			end
		end
	elseif data.action == 'Transfer' then
		TriggerServerEvent('brutal_banking:server:Transfer', tonumber(data.amount), data.iban, tonumber(data.account), MyBankData[data.account].account_id, GetPlayerLimit(MyBankData[data.account].account_id))
	end
end)