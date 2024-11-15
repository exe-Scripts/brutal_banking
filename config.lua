----------------------------------------------------------------------------------------------
-------------------------------------| BRUTAL BANKING :) |------------------------------------
----------------------------------------------------------------------------------------------
-- BY 5M EXCLUSIVE-SCRIPTS
-- JOIN OUR DISCORD FOR MORE FREE SCRIPTS
-- discord.gg/fivemscripts
--[[
Hi, thank you for buying our script, We are very grateful!

For help join our Discord server:     https://discord.gg/85u2u5c8q9
More informations about the script:   https://docs.brutalscripts.com
--]]

Config = {
    Core = 'QBCORE',  -- ESX / QBCORE | Other core setting on the 'core' folder and the client and server utils.lua
    BankLabel = {'BRUTAL', 'BANKING'},
    Target = 'marker', -- 'marker' / 'oxtarget' / 'qb-target'
    BrutalNotify = true, -- Buy here: (4€+VAT) https://store.brutalscripts.com | Or set up your own notify >> cl_utils.lua
    SteamName = true, -- true = Steam name | false = character name
    
    IBAN = {prefix = 'BS', numbers = 6}, -- The prefix of the IBAN and the iban number
    PINChangeCost = 1000, -- Change PINCODE price
    IBANChangeCost = 5000, -- Change IBAN price
    NewSubAccountCost = 25000, -- New Sub account create price

    DailyLimit = 9999999, -- Maximum withdraw limit that the player can set in the permission section of the sub account.
    DateFormat = '%d/%m/%Y', -- Date format
    Distances = {marker = 10.0, open = 2.0}, -- Distances
    AtmModels = {'prop_fleeca_atm', 'prop_atm_01', 'prop_atm_02', 'prop_atm_03'}, -- Atm models
    BankBlips = {color = 69, sprite = 108, size = 0.7}, -- Bank Blips
    MenuOpenKey = 38, -- Menu open key, more key: https://docs.fivem.net/docs/game-references/controls
    MenuReopenLimit = false, -- 10 = 10 sec | false = turn off
    
    Banks = {
        [1] = {
            bankName = 'Bank', -- Bank Name
            blipEnabled = true, -- Enable blip? true / false
            pedEnabled = true, -- Enable Assistant NPC? true / false
            assistantModel = 'ig_bankman', -- Enable Assistant model, more models: https://docs.fivem.net/docs/game-references/ped-models/
            assistantCoords = vector4(149.5513, -1042.1570, 29.3680, 341.6520), -- Assistant NPC coords
            markerCoords = vector3(149.91, -1040.74, 29.374) -- marker coords (if the Target = 'marker')
        },
        [2] = {
            bankName = 'Bank',
            blipEnabled = true,
            pedEnabled = true,
            assistantModel = 'ig_bankman',
            assistantCoords = vector4(-1211.8585, -331.9854, 37.7809, 28.5983),
            markerCoords = vector3(-1212.63, -330.78, 37.59)
        },
        [3] = {
            bankName = 'Bank',
            blipEnabled = true,
            pedEnabled = true,
            assistantModel = 'ig_bankman',
            assistantCoords = vector4(-2961.0720, 483.1107, 15.6970, 88.1986),
            markerCoords = vector3(-2962.47, 482.93, 15.5)
        },
        [4] = {
            bankName = 'Bank',
            blipEnabled = true,
            pedEnabled = true,
            assistantModel = 'ig_bankman',
            assistantCoords = vector4(-112.2223, 6471.1128, 31.6267, 132.7517),
            markerCoords = vector3(-113.01, 6470.24, 31.43)
        },
        [5] = {
            bankName = 'Bank',
            blipEnabled = true,
            pedEnabled = true,
            assistantModel = 'ig_bankman',
            assistantCoords = vector4(313.8176, -280.5338, 54.1647, 339.1609),
            markerCoords = vector3(314.16, -279.09, 53.97)
        },
        [6] = {
            bankName = 'Bank',
            blipEnabled = true,
            pedEnabled = true,
            assistantModel = 'ig_bankman',
            assistantCoords = vector4(-351.3247, -51.3466, 49.0365, 339.3305),
            markerCoords = vector3(-350.99, -49.99, 48.84)
        },
        [7] = {
            bankName = 'Bank',
            blipEnabled = true,
            pedEnabled = true,
            assistantModel = 'ig_bankman',
            assistantCoords = vector4(1174.9718, 2708.2034, 38.0879, 178.2974),
            markerCoords = vector3(1175.02, 2706.87, 37.89)
        },
        [8] = {
            bankName = 'Bank',
            blipEnabled = true,
            pedEnabled = true,
            assistantModel = 'ig_bankman',
            assistantCoords = vector4(247.0348, 225.1851, 106.2875, 158.7528),
            markerCoords = vector3(246.63, 223.62, 106.0)
        },
        -- You can add more bank...
    },

    -----------------------------------------------------------
    -----------------------| TRANSLATE |-----------------------
    -----------------------------------------------------------

    MoneyForm = '$', -- Money form
    MainAccountDefaultLabel = 'Main Account', -- Default main account name (This will be the default name of the player's main account)

    Texts = {
        [1] = {'To open banking menu, press ~w~[~g~E~w~]', 'Open Banking Menu', 'fa-solid fa-building-columns'},
        [2] = {'Press ~INPUT_PICKUP~ to open atm menu', 'Open ATM Menu', 'fa-solid fa-building-columns'},
    },

    Transactions = {
        Deposit = 'Deposit',
        Withdraw = 'Withdraw',
        Transfer = 'Transfer',
        Correction = 'Correction',
        NewSubAccount = 'New Sub Account',
        ChangePincode = 'Change Pincode',
        ChangeIban = 'Change Iban'
    },
    
    -- Notify function EDITABLE >> cl_utils.lua
    Notify = { 
        [1] = {"BANKING", "This IBAN is already in the database!", 6000, "error"},
        [2] = {"BANKING", "You have successfully change the account's IBAN!", 6000, "success"},
        [3] = {"BANKING", "You have successfully change the PINCODE!", 6000, "success"},
        [4] = {"BANKING", "You have successfully change the account's NAME!", 6000, "success"},
        [5] = {"BANKING", "Successfully saved!", 6000, "success"},
        [6] = {"BANKING", "Not enough money in your Account.", 6000, "error"},
        [7] = {"BANKING", "Invalid PlayerID!", 6000, "error"},
        [8] = {"BANKING", "You have successfully added!", 6000, "success"},
        [9] = {"BANKING", "You don't have enough money!", 6000, "error"},
        [10] = {"BANKING", "Invalid IBAN!", 6000, "error"},
        [11] = {"BANKING", "You can't transfer to yourself.", 6000, "error"},
        [12] = {"BANKING", "You have transferred:", 6000, "info"},
        [13] = {"BANKING", "You will exceed your daily limit. Your usable limit:", 6000, "error"},
        [14] = {"BANKING", "The player has already been added!", 6000, "error"},
        [15] = {"BANKING", "Please set the pincode in the bank to open the atm menu!", 6000, "error"},
        [16] = {"BANKING", "Please DO NOT spam the bank opening!", 6000, "error"},
        [17] = {"BANKING", "You cannot open the menu in a vehicle!", 6000, "error"},
    },
    
    Webhooks = {
        Use = true, -- Use webhooks? true / false
        PermissionChangeLog = true, -- You want to log the sub accounts permission edit? true / false
        Locale = {
            ['SubAccountCreated'] = 'Sub Account Created ✅',
            ['SubAccountDeleted'] = 'Sub Account Removed ❌',
            ['PermissionTableRefreshed'] = 'Permission Table Refreshed 🔑',

            ['PlayerName'] = 'Player Name',
            ['Identifier'] = 'Identifier',
            ['AccountID'] = 'Account ID',
            ['IBAN'] = 'IBAN',
            ['Limit'] = 'Limit',
            ['Permissions'] = 'Permissions',
            ['Permission'] = 'Permission',

            ['Time'] = 'Time ⏲️'
        },

        -- To change a webhook color you need to set the decimal value of a color, you can use this website to do that - https://www.mathsisfun.com/hexadecimal-decimal-colors.html
        Colors = {
            ['SubAccountCreated'] = 3145631, 
            ['SubAccountDeleted'] = 16711680,
            ['PermissionTableRefreshed'] = 10155240
        }
    }
}
