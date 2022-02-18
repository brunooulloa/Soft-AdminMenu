ESX = nil

local noclip = false
local godmode = false
local vanish = false
local noclipSpeed = 2.01
local onlineplayers = {}
local totalplayers  = 0
local blipsEnabled = false
local namesEnabled = false

Citizen.CreateThread(function()
    while ESX == nil do
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)
        if IsControlJustReleased(0, 344) then
			ESX.TriggerServerCallback('soft_admin:checkAdmin', function(isAdmin)
				if isAdmin then
					local isAdmin = true
					MenuAdmin()
				elseif not isAdmin then 
					exports['mythic_notify']:DoHudText('error', 'No tienes permisos para ver esto')
				end
			end)
		end
        if noclip then
            local ped = PlayerPedId()
            local x, y, z = getPosition()
            local dx, dy, dz = getCamDirection()
            local speed = noclipSpeed
  
            SetEntityVelocity(ped, 0.05,  0.05,  0.05)
  
            if IsControlPressed(0, 32) then
                x = x + speed * dx
                y = y + speed * dy
                z = z + speed * dz
            end
  
            if IsControlPressed(0, 269) then
                x = x - speed * dx
                y = y - speed * dy
                z = z - speed * dz
            end
  
            SetEntityCoordsNoOffset(ped,x,y,z,true,true,true)
        end
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(3000)
		for _, player in ipairs(GetActivePlayers()) do
			if NetworkIsPlayerActive(player) then
				ped     = GetPlayerPed(player)
				blip    = GetBlipFromEntity(ped)
				idTesta = Citizen.InvokeNative(0xBFEFE3321A3F5015, ped, '[' .. GetPlayerServerId(player) .. '] ' .. GetPlayerName(player), false, false, '', false)
				if namesEnabled then
					local numeroid = GetPlayerServerId(NetworkGetEntityOwner(PlayerPedId()))
					if numeroid ~= GetPlayerServerId(player) then
						Citizen.InvokeNative(0x63BB75ABEDC1F6A0, idTesta, 0, true)
					end
				else
					Citizen.InvokeNative(0x63BB75ABEDC1F6A0, idTesta, 0, false)
				end
				if blipsEnabled then
					if not DoesBlipExist(blip) then
						blip = AddBlipForEntity(ped)
						SetBlipSprite(blip, 1) 
						Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true) 
					else
						SetBlipNameToPlayerName(blip, player) 
						SetBlipScale(blip, 0.85)
					end
					
					if IsPauseMenuActive() then
						SetBlipAlpha(blip, 255)
					end
				else
					RemoveBlip(blip)
				end
			end
		end
	end
end)

function MenuAdmin()
    local elements = {
		{ label = 'Opciones Personales', value = 'pers'},
		{ label = 'Opciones Vehiculares', value = 'veh' },
		{ label = 'Opciones del Servidor', value = 'serv' },
		{ label = 'Blips y Nombres', value = 'names' },
		{ label = 'Cerrar', value = 'close' }
    }

    ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminMenu',
	{
		title  = 'Menu administrativo',
		align = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'pers' then
			persMenu()
		elseif data.current.value == 'veh' then
			if IsPedInAnyVehicle(PlayerPedId(), true) then
				vehMenu()
			else
				exports['mythic_notify']:DoHudText('error', 'No estas dentro de un vehiculo!')
			end
		elseif data.current.value == 'serv' then
			servMenu()
		elseif data.current.value == 'names' then
			names_blips()
		elseif data.current.value == 'close' then
			ESX.UI.Menu.CloseAll()
		end
	end, function(data, menu)
		menu.close()
	end)
end

function spawnMenu(type)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'Spawn Menu',
	{
		title = 'Ingrese el argumento correspondiente',
	}, function(data, menu)
		local arg = data.value
		if type == 'spawnCar' then
			TriggerEvent('esx:spawnVehicle', arg)
			exports['mythic_notify']:DoHudText('success', 'Spawneaste un ' .. arg .. '!')
		elseif type == 'setJob' then
			local args = split(arg, ' ')
			TriggerServerEvent('soft_admin:setJob', args)
		elseif type == 'comServ' then
			local args = split(arg, ' ')
			TriggerServerEvent('esx_communityservicecarcel:sendTocommunityservicecarcel', args[1], args[2])
		elseif type == 'endcomServ' then
			TriggerServerEvent('esx_communityservicecarcel:finishcommunityservicecarcel', args)
		elseif type == 'kick' then
			local args = split(arg, ' ')
			TriggerServerEvent('soft_admin:kick', args[1], args[2])
		end
		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

function persMenu()
	local elements = {
		{ label = 'Noclip', value = 'noclip'},
		{ label = 'Teletransportar a marcador', value = 'tpm'},
		{ label = 'Borrar el chat', value = 'clearChat' },
		{ label = 'Curarse', value = 'heal' },
		{ label = 'Spawnear auto', value = 'car' },
		{ label = 'Invisible', value = 'inv' },
		{ label = 'Servicio Comunitario', value = 'comserv' },
		{ label = 'Terminar Servicio Comunitario', value = 'endcomserv' },
		{ label = 'Kickear', value = 'kick' },
		{ label = 'Freezear', value = 'freeze' },
		{ label = 'Dar trabajo', value = 'job' },
		{ label = 'Cambiar el color del arma', value = 'color' },
		{ label = 'Cerrar', value = 'close' }
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'persMenu',
	{
		title = 'Menu Personal',
		align = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'noclip' then
			TriggerEvent('soft_admin:nocliped')
		elseif data.current.value == 'godmode' then
			TriggerEvent('soft_admin:godmodePlayer')
		elseif data.current.value == 'tpm' then
			TriggerEvent('soft_admin:tpm')
		elseif data.current.value == 'clearChat' then
			TriggerEvent('soft_admin:clearchat')
		elseif data.current.value == 'heal' then
			TriggerEvent('soft_admin:heal')
		elseif data.current.value == 'car' then
			spawnMenu('spawnCar')
		elseif data.current.value == 'inv' then
			TriggerEvent('soft_admin:invisible')
		elseif data.current.value == 'color' then
			if IsPedArmed(PlayerPedId(), 4) then
				TriggerEvent('soft_admin:color')
			else
				exports['mythic_notify']:DoHudText('error', 'No tienes ningun arma en mano!')
			end
		elseif data.current.value == 'kick' then
			spawnMenu('kick')
		elseif data.current.value == 'freeze' then
			spawnMenu('freeze')
		elseif data.current.value == 'job' then
			spawnMenu('setJob')
		elseif data.current.value == 'comserv' then
			spawnMenu('comServ')
		elseif data.current.value == 'endcomserv' then
			spawnMenu('endcomServ')
		elseif data.current.value == 'close' then
			menu.close()
		end
	end, function(data, menu)
		MenuAdmin()
	end)
end

function servMenu()
	local elements = {
		{ label = 'Revivir a Todos', value = 'reviveall' },
		{ label = 'Matar a Todos', value = 'killall' },
		{ label = 'Traer a Todos', value = 'bringall' },
		{ label = 'Terminar Servicio Comunitario a Todos', value = 'endcomserv' },
		{ label = 'Kickear a Todos', value = 'kickall'}
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'servMenu', {
		title = 'Menu del Server',
		align = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'reviveall' then
			TriggerEvent('esx_ambulancejob:revive', -1)
			exports['mythic_notify']:DoHudText('success', 'Reviviste a todos!')
		elseif data.current.value == 'killall' then
			SetEntityHealth(GetPlayerPed(-1), 0)
			exports['mythic_notify']:DoHudText('success', 'Mataste a todos!')
		elseif data.current.value == 'bringall' then
			SetEntityCoords(PlayerPedId(), GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(-1)))) 
			exports['mythic_notify']:DoHudText('success', 'Trajiste a todos!')
		elseif data.current.value == 'endcomserv' then
			TriggerServerEvent('esx_communityservicecarcel:finishcommunityservicecarcel', -1)
		elseif data.current.value == 'kickall' then
			TriggerServerEvent('soft_admin:kickAll')
		end
	end, function(data, menu)
		MenuAdmin()
	end)
end

function vehMenu()
	local elements = {
		{ label = 'Multiplicador de Velocidad', value = 'multiplier' },
		{ label = 'Tunning al Maximo', value = 'max'},
		{ label = 'Borrar Vehiculo', value = 'dv' },
		{ label = 'Arreglar Vehiculo', value = 'fix' },
		{ label = 'Cerrar', value = 'close' }
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehMenu',
	{
		title = 'Menu Vehicular',
		align = 'top-left',
		elements = elements
	}, function (data, menu)
		if data.current.value == 'dv' then
			if IsPedInAnyVehicle(PlayerPedId(), true) then
				TriggerEvent('esx:deleteVehicle')
				exports['mythic_notify']:DoHudText('success', 'Vehiculo borrado!')
			else
				exports['mythic_notify']:DoHudText('error', 'No estas dentro de un vehiculo!')
			end
		elseif data.current.value == 'fix' then
			if IsPedInAnyVehicle(PlayerPedId(), true) then
				TriggerEvent( 'soft_admin:repairVehicle')
				exports['mythic_notify']:DoHudText('success', 'Vehiculo Arreglado')
			else
				exports['mythic_notify']:DoHudText('error', 'No estas dentro de un vehiculo!')
			end
		elseif data.current.value == 'multiplier' then
			if IsPedInAnyVehicle(PlayerPedId(), true) then
				boostMenu()
			else
				exports['mythic_notify']:DoHudText('error', 'No estas dentro de un vehiculo!')
			end
		elseif data.current.value == 'max' then
			if IsPedInAnyVehicle(PlayerPedId(), true) then
				maxTunning(GetVehiclePedIsUsing(PlayerPedId()))
				exports['mythic_notify']:DoHudText('success', 'Vehiculo Maxeado')
			else
				exports['mythic_notify']:DoHudText('error', 'No estas dentro de un vehiculo!')
			end
		elseif data.current.value == 'close' then
			menu.close()
		end
	end, function(data, menu)
		MenuAdmin()
	end)
end

function boostMenu()
	local elements = {
		{ label = 'Engine boost RESET', value = 'reset' },
		{ label = 'Engine boost x2', value = '2' },
		{ label = 'Engine boost x4', value = '4' },
		{ label = 'Engine boost x8', value = '8' },
		{ label = 'Engine boost x16', value = '16' },
		{ label = 'Engine boost x32', value = '32' },
		{ label = 'Engine boost x64', value = '64' },
		{ label = 'Engine boost x128', value = '128' },
		{ label = 'Engine boost x256', value = '256' },
		{ label = 'Engine boost x512', value = '512' },
		{ label = 'Engine boost x1024', value = '1024' },
		{ label = 'Cerrar', value = 'close' }
	}
	
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminMenu',
	{
		title    = 'Menu de Multiplicador',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'reset' then
			ModifyVehicleTopSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 1.0)
		elseif data.current.value == '2' then
			ModifyVehicleTopSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 2.0 * 20.0)
		elseif data.current.value == '4' then
			ModifyVehicleTopSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 4.0 * 20.0)
		elseif data.current.value == '8' then
			ModifyVehicleTopSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 8.0 * 20.0)
		elseif data.current.value == '16' then
			ModifyVehicleTopSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 16.0 * 20.0)
		elseif data.current.value == '32' then
			ModifyVehicleTopSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 32.0 * 20.0)
		elseif data.current.value == '64' then
			ModifyVehicleTopSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 64.0 * 20.0)
		elseif data.current.value == '128' then
			ModifyVehicleTopSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 128.0 * 20.0)
		elseif data.current.value == '256' then
			ModifyVehicleTopSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 256.0 * 20.0)
		elseif data.current.value == '512' then
			ModifyVehicleTopSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 512.0 * 20.0)
		elseif data.current.value == '1024' then
			ModifyVehicleTopSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 1024.0 * 20.0)
		elseif data.current.value == 'close' then
			menu.close()
		end

		if data.current.value == 'reset' then
			exports['mythic_notify']:DoHudText('error', 'Motor de Vehiculo reseteado a su valor original')
		else
			exports['mythic_notify']:DoHudText('success', 'Motor de Vehiculo Multiplicado por ' .. data.current.value)
		end
	end,function(data, menu)
		if IsPedInAnyVehicle(PlayerPedId(), true) then
			vehMenu()
		else
			exports['mythic_notify']:DoHudText('error', 'No estas dentro de un vehiculo!')
		end
		menu.close()
	end)
end

RegisterNetEvent('soft_admin:color', function()
	local ped = PlayerPedId()
	local weaponhash = GetSelectedPedWeapon(PlayerPedId())
	local elements = {
		{ label = 'Normal', value = 'normal' },
		{ label = 'Green', value = 'verde' },
		{ label = 'Gold', value = 'dorada' },
		{ label = 'Pink', value = 'rosa' },
		{ label = 'Militar',	value = 'militar' },
		{ label = 'LSPD', value = 'lspd' },
		{ label = 'Orange', value = 'naranja' },
		{ label = 'Platinum', value = 'platino' }
	}
		
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'buy_storage',
	{
		title = 'Pintura de Armas',
		align = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'normal' then
			SetPedWeaponTintIndex(ped, weaponhash, 0)
		elseif data.current.value == 'verde' then
			SetPedWeaponTintIndex(ped, weaponhash, 1)
		elseif data.current.value == 'dorada' then
			SetPedWeaponTintIndex(ped, weaponhash, 2)
		elseif data.current.value == 'rosa' then
			SetPedWeaponTintIndex(ped, weaponhash, 3)
		elseif data.current.value == 'militar' then
			SetPedWeaponTintIndex(ped, weaponhash, 4)
		elseif data.current.value == 'lspd' then
			SetPedWeaponTintIndex(ped, weaponhash, 5)
		elseif data.current.value == 'naranja' then
			SetPedWeaponTintIndex(ped, weaponhash, 6)
		elseif data.current.value == 'platino' then
			SetPedWeaponTintIndex(ped, weaponhash, 7)
		end
	end, function(data, menu)
		MenuAdmin()
	end)
end)

function names_blips()
	local elements = {}

	local elements = {
		{ label = 'Nombres de Jugadores', value = 'playerName' },
		{ label = 'Blips de Jugadores', value = 'playerBlips' },
	}
	
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'playersnamess',
	{
		title    = 'Menu Nombres y Blips',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'playerName' then
			TriggerEvent('soft_admin:playerName')
		elseif data.current.value == 'playerBlips' then
			TriggerEvent('soft_admin:playerBlips')
		end
	end, function(data, menu)
		MenuAdmin()
	end)
end

RegisterNetEvent('soft_admin:nocliped', function()
	noclip = not noclip
    local ped = PlayerPedId()

    if noclip then
    	SetEntityInvincible(ped, true)
    	SetEntityVisible(ped, false, false)
    else
    	SetEntityInvincible(ped, false)
    	SetEntityVisible(ped, true, false)
    end

    if noclip == true then 
		exports['mythic_notify']:DoHudText('success', 'Noclip Activado.')
    else
		exports['mythic_notify']:DoHudText('error', 'Noclip Desactivado.')
    end
end)

RegisterNetEvent('soft_admin:invisible', function()
	vanish = not vanish
    local ped = PlayerPedId()
    SetEntityVisible(ped, not vanish, false)
    if vanish == true then 
		exports['mythic_notify']:DoHudText('success', 'Modo Invisible Activado.')
    else
		exports['mythic_notify']:DoHudText('error', 'Modo Invisible Desactivado.')
    end
end)

RegisterNetEvent('soft_admin:godmodePlayer', function()
	godmode = not godmode
	local playerPed = PlayerPedId()
	SetEntityInvincible(playerPed, not godmode, false)
	if godmode then
		exports['mythic_notify']:DoHudText('success', 'Godmode Activado.')
	else
		exports['mythic_notify']:DoHudText('error', 'Godmode Desactivado.')
	end
end)

RegisterNetEvent('soft_admin:frozen', function()
	freeze = not freeze
	local ped = PlayerPedId()
	local player = PlayerId()
	if not freeze then
		if not IsEntityVisible(ped) then
			SetEntityVisible(ped, true)
		end

		if not IsPedInAnyVehicle(ped) then
			SetEntityCollision(ped, true)
		end

		FreezeEntityPosition(ped, false)
		SetPlayerInvincible(player, false)
		exports['mythic_notify']:DoCustomHudText('success', 'Te ha descongelado un administrador', 1000)
	else
		SetEntityCollision(ped, false)
		FreezeEntityPosition(ped, true)
		SetPlayerInvincible(player, true)

		if not IsPedFatallyInjured(ped) then
			ClearPedTasksImmediately(ped)
		end
		exports['mythic_notify']:DoCustomHudText('success', 'Te ha congelado un administrador', 1000)
	end
end)

RegisterNetEvent('soft_admin:clearchat', function()
    TriggerEvent('chat:clear', -1)
	exports['mythic_notify']:DoHudText('info', 'Has limpiado todo el chat.')
end)

RegisterNetEvent('soft_admin:repairVehicle', function()
    local ply = PlayerPedId()
    local plyVeh = GetVehiclePedIsIn(ply)
    if IsPedInAnyVehicle(ply) then 
        SetVehicleFixed(plyVeh)
        SetVehicleDeformationFixed(plyVeh)
        SetVehicleUndriveable(plyVeh, false)
        SetVehicleEngineOn(plyVeh, true, true)
		exports['mythic_notify']:DoHudText('success', 'Vehiculo Reparado.')
    else
		exports['mythic_notify']:DoHudText('error', 'Debes estar en un vehiculo para poder repararlo.')
    end
end)

RegisterNetEvent('soft_admin:heal', function()
	local ped = PlayerPedId()
	SetEntityHealth(ped, 200)
	TriggerEvent('esx_status:set', 'hunger', 1000000)
	TriggerEvent('esx_status:set', 'thirst', 1000000)
	TriggerEvent('esx_status:set', 'stress', 1000)
	exports['mythic_notify']:DoHudText('info', 'Te curaste con éxito.')
	ClearPedBloodDamage(ped)
	ResetPedVisibleDamage(ped)
	ClearPedLastWeaponDamage(ped)
end)

RegisterNetEvent('soft_admin:tpm', function()
    local WaypointHandle = GetFirstBlipInfoId(8)
    if DoesBlipExist(WaypointHandle) then
        local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)

        for height = 1, 1000 do
            SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords['x'], waypointCoords['y'], height + 0.0)

            local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords['x'], waypointCoords['y'], height + 0.0)

            if foundGround then
                SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords['x'], waypointCoords['y'], height + 0.0)
                break
            end

            Citizen.Wait(5)
        end
		exports['mythic_notify']:DoHudText('success', 'Te teletrasportaste con exito.')
    else
		exports['mythic_notify']:DoHudText('info', 'Seleccione el destino en el Mapa.')
    end
end)

RegisterNetEvent('soft_admin:killed', function()
	local Ped = PlayerPedId()
	SetEntityHealth(Ped, 0)
	exports['mythic_notify']:DoHudText('success', 'Mataste a todos en el server')
end)

RegisterNetEvent('soft_admin:playerBlips', function()
	if blipsEnabled == false then
		blipsEnabled = true
		exports['mythic_notify']:DoHudText('success', '¡Blips activados!', 1000)
	else
		blipsEnabled = false
		exports['mythic_notify']:DoHudText('error', '¡Blips desactivados!', 1000)
	end
end)

RegisterNetEvent('soft_admin:playerName', function()
	if namesEnabled == false then
		namesEnabled = true
		exports['mythic_notify']:DoHudText('success', '¡Nombres activados!', 1000)
	else
		namesEnabled = false
		exports['mythic_notify']:DoHudText('error', '¡Nombres desactivados!', 1000)
	end
end)

function maxTunning(veh)
	SetVehicleModKit(GetVehiclePedIsIn(PlayerPedId(), false), 0)
	SetVehicleWheelType(GetVehiclePedIsIn(PlayerPedId(), false), 7)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 0, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 0) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 1, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 1) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 2, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 2) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 3, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 3) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 4, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 4) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 5, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 5) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 6, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 6) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 7, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 7) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 8, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 8) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 9, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 9) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 10, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 10) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 11) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 12) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 13) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 14, 16, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 15) - 2, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 16) - 1, false)
	ToggleVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 17, true)
	ToggleVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 18, true)
	ToggleVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 19, true)
	ToggleVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 20, true)
	ToggleVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 21, true)
	ToggleVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 22, true)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 23, 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 24, 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 25, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 25) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 27, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 27) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 28, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 28) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 30, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 30) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 33, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 33) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 34, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 34) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 35, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 35) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(PlayerPedId(), false), 38, GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), 38) - 1, true)
	SetVehicleWindowTint(GetVehiclePedIsIn(PlayerPedId(), false), 1)
	SetVehicleTyresCanBurst(GetVehiclePedIsIn(PlayerPedId(), false), false)
	SetVehicleNumberPlateTextIndex(GetVehiclePedIsIn(PlayerPedId(), false), 5)
end

function getPosition()
	local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(),true))
  	return x,y,z
end

function getCamDirection()
	local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
	local pitch = GetGameplayCamRelativePitch()
  
	local x = -math.sin(heading * math.pi/180.0)
	local y = math.cos(heading * math.pi/180.0)
	local z = math.sin(pitch * math.pi/180.0)
  
	local len = math.sqrt(x * x + y * y + z * z)
	if len ~= 0 then
	  x = x / len
	  y = y / len
	  z = z / len
	end
  
	return x, y, z
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

--[[ split function` ]]