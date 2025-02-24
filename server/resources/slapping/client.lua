local VolumeDeLaMusique = 0.2

function getPlayers()
    local playerList = {}
    for i = 0, 256 do
        local player = GetPlayerFromServerId(i)
        if NetworkIsPlayerActive(player) then
            table.insert(playerList, player)
        end
    end
    return playerList
end

function getNearPlayer()
    local players = getPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)
    
    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = Vdist(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"])
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

RegisterNetEvent('RebornProject:SyncSon_Client')
AddEventHandler('RebornProject:SyncSon_Client', function(playerNetId)
    local lCoords = GetEntityCoords(GetPlayerPed(-1))
    local eCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerNetId)))
    local distIs  = Vdist(lCoords.x, lCoords.y, lCoords.z, eCoords.x, eCoords.y, eCoords.z)
    if (distIs <= 1.0001) then
        SendNUIMessage({
            DemarrerLaMusique     = 'DemarrerLaMusique',
            VolumeDeLaMusique   = VolumeDeLaMusique
        })
    end
end)

RegisterNetEvent('RebornProject:SyncAnimation')
AddEventHandler('RebornProject:SyncAnimation', function(playerNetId)
    Wait(250)
    TriggerServerEvent("RebornProject:SyncSon_Serveur")
    SetPedToRagdoll(GetPlayerPed(-1), 2000, 2000, 0, 0, 0, 0)
end)

function ChargementAnimation(donnees)
    while (not HasAnimDictLoaded(donnees)) do 
        RequestAnimDict(donnees)
        Wait(5)
    end
end

CreateThread(function()
    while true do
        Wait(0)
        if IsControlPressed(1, 19) and IsControlJustPressed(1, 46) then  -- alt + E
            local CitoyenCible, distance = getNearPlayer()
            if (distance ~= -1 and distance < 0.9001) then

                if IsPedArmed(GetPlayerPed(-1), 7) then
                    SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey('WEAPON_UNARMED'), true)
                end

                if (DoesEntityExist(GetPlayerPed(-1)) and not IsEntityDead(GetPlayerPed(-1))) then
                    ChargementAnimation("melee@unarmed@streamed_variations")
                    TaskPlayAnim(GetPlayerPed(-1), "melee@unarmed@streamed_variations", "plyr_takedown_front_slap", 8.0, 1.0, 1500, 1, 0, 0, 0, 0)
                    TriggerServerEvent("RebornProject:SyncGiffle", GetPlayerServerId(CitoyenCible))
					 Wait(10000)
                end
			else
			    	                        TriggerEvent("pNotify:SendNotification",{
                            text = "Du skal stå foran en før du kan give en lussing!",
                            type = "error",
                            timeout = 3000,
                            layout = "centerRight",
                            queue = "global",
                            animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"},
                        })
            end
        end
    end
end)
