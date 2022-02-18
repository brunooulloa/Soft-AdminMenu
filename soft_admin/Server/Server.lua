ESX = nil 

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local isAdmin = false

ESX.RegisterServerCallback('soft_admin:checkAdmin', function(source, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    for k, v in pairs(Config['groups']) do
        if v == xPlayer.getGroup() then
            isAdmin = true
        end
    end

    if isAdmin then
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('soft_admin:setJob', function(args)
    local source = source
    if args[1] and args[2] and args[3] then
        if tonumber(args[1]) and args[2] and tonumber(args[3]) then
            local xPlayer = ESX.GetPlayerFromId(args[1])
    
            if xPlayer then
                xPlayer.setJob(args[2], tonumber(args[3]))
            else
                TriggerClientEvent('esx:showNotification',source, "Jugador ~r~no ~w~online.")
            end
        else
            TriggerClientEvent('esx:showNotification', source, "Así no se usa.")
        end
    else
        TriggerClientEvent('esx:showNotification', source, "Faltan parámetros.")
    end
end)

RegisterNetEvent('soft_admin:kick', function(id, reason)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    DropPlayer(id, 'Fuiste kickeado por: ' .. reason)
end)

RegisterNetEvent('soft_admin:kickAll', function(id, reason)
    local xPlayers = ESX.GetPlayers()
    for i = 1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        xPlayer.kick('Todos han sido kickeados.')
    end
end)

RegisterServerEvent('soft_admin:freeze', function(target)
    local src = source
    local xPlayer
    if target then
        xPlayer = ESX.GetPlayerFromId(target)
    else
        TriggerClientEvent('esx:showNotification', source, "Introduce un parámetro.")
        return
    end

    if not xPlayer then
        TriggerClientEvent('esx:showNotification', source, "Jugador ~r~no ~w~online.")
        return
    end

    TriggerClientEvent('soft_admin:frozen', target)
end)