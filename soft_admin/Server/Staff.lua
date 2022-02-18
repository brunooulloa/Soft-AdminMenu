ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function disc(color, title, message, footer)
	local embed = {
		{
			['color'] = color,
			['title'] = title,
			['description'] = message,
			['footer'] = {
				['text'] = footer,
				['icon_url'] = 'https://cdn.discordapp.com/avatars/293148087407476737/a_d0cbdc184155c678ea1ad107163a324b.gif?size=1024'
			},
		}
	}

	PerformHttpRequest(Config['webhook'], function(err, text, headers) end, 'POST', json.encode({ username = name, embeds = embed }), { ['Content-Type'] = 'application/json' })
end

local staff = false

ESX.RegisterCommand('staff', 'mod', function(source)
	local src = source

	if staff then
		staff = false
	else
		staff = true
	end

	if staff then
		disc(3066993, '**' .. src.name .. ' entro de staff!**', '*Hora de entrada: ' .. os.date('%x %X') .. '*', 'Soft#6666')
	else
		disc(10038562, '**' .. src.name .. ' salio de staff!**', '*Hora de salida: ' .. os.date('%x %X') .. '*', 'Soft#6666')
	end
end, true, { help = 'Entrar o salir de staff', validate = true })