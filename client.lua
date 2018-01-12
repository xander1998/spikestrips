local SpawnedSpikes = {}
local SpikesSpawned = false
local DeleteDeadSpikes = true


--[[ Looped Thread ]]--
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if IsPedInAnyVehicle(GetPlayerPed(PlayerId()), false) then
			local vehicle = GetVehiclePedIsIn(GetPlayerPed(PlayerId()), false)
			local vehiclePos = GetEntityCoords(vehicle, false)
			local spikes = GetClosestObjectOfType(vehiclePos.x, vehiclePos.y, vehiclePos.z, 75.0, GetHashKey("P_ld_stinger_s"), false, 1, 1)
			local spikesCoords = GetEntityCoords(spikes, false)
			local distance = Vdist(vehiclePos.x, vehiclePos.y, vehiclePos.z, spikesCoords.x, spikesCoords.y, spikesCoords.z)
			if distance <= 75.0 then
				CheckDistanceToStrips()
			end
		end
	end
end)

RegisterCommand("spawn", function(source, args, string)
	SpawnSpikes()
end, false)

RegisterNetEvent("Spikestrips:SpawnSpikes")
AddEventHandler("Spikestrips:SpawnSpikes", function(config, amount)
	if config.isRestricted then
		if CheckPedRestriction(GetPlayerPed(PlayerId()), config.pedList) then
			for a = 1, amount do
				local plyCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 3.0 * a + 0.5, 0.0)
				local plyHead = GetEntityHeading(GetPlayerPed(PlayerId()))
				local spike = CreateObject(GetHashKey("P_ld_stinger_s"), plyCoords.x, plyCoords.y, plyCoords.z, true, 1, true)
				local spikeHeight = GetEntityHeightAboveGround(spike)
				SetEntityCoords(spike, plyCoords.x, plyCoords.y, plyCoords.z - spikeHeight + 0.05, 0.0, 0.0, 0.0, 0)
				SetEntityHeading(spike, plyHead)
				SetEntityAsMissionEntity(spike, 1, 1)
				SetEntityCollision(spike, false, false)
				table.insert(SpawnedSpikes, spike)
				SpikesSpawned = true
			end
		else
			TriggerEvent("chatMessage", "You are not allowed to spawn spike strips.")
		end
	else
		for b = 1, amount do
			local plyCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 3.0 * b + 0.5, 0.0)
			local plyHead = GetEntityHeading(GetPlayerPed(PlayerId()))
			local spike = CreateObject(GetHashKey("P_ld_stinger_s"), plyCoords.x, plyCoords.y, plyCoords.z, true, 1, true)
			local spikeHeight = GetEntityHeightAboveGround(spike)
			SetEntityCoords(spike, plyCoords.x, plyCoords.y, plyCoords.z - spikeHeight + 0.05, 0.0, 0.0, 0.0, 0.0)
			SetEntityHeading(spike, plyHead)
			SetEntityAsMissionEntity(spike, 1, 1)
			SetEntityCollision(spike, false, false)
			table.insert(SpawnedSpikes, spike)
			SpikesSpawned = true
		end
	end
end)

RegisterNetEvent("Spikestrips:RemoveSpikes")
AddEventHandler("Spikestrips:RemoveSpikes", function()
	if SpikesSpawned then
		for i = 1, #SpawnedSpikes do
			local netId = NetworkGetNetworkIdFromEntity(SpawnedSpikes[i])

			Citizen.Trace("Requesting Control of Entity")
			NetworkRequestControlOfNetworkId(netId)
			while not NetworkHasControlOfNetworkId(netId) do
				Citizen.Trace("Waiting For Control of Entity")
				Citizen.Wait(0)
				NetworkRequestControlOfNetworkId(netId)
			end
			Citizen.Trace("You Have Control of Entity")

			local entity = NetworkGetEntityFromNetworkId(netId)

			DeleteEntity(entity)
			Citizen.Trace("Deleted Entity")
			SpawnedSpikes[i] = nil
			SpikesSpawned = false
			DeleteDeadSpikes = true
		end
	end
end)

function CheckDistanceToStrips()
	local vehicle = GetVehiclePedIsIn(GetPlayerPed(PlayerId()), false)
	FrontLeftTire(vehicle)
	FrontRightTire(vehicle)
	BackLeftTire(vehicle)
	BackRightTire(vehicle)
end

function FrontLeftTire(vehicle)
	local tirePosition = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "wheel_lf"))
	local spikestrip = GetClosestObjectOfType(tirePosition.x, tirePosition.y, tirePosition.z, 15.0, GetHashKey("P_ld_stinger_s"), false, 1, 1)
	local spikeCoords = GetEntityCoords(spikestrip, false)
	local distance = Vdist(tirePosition.x, tirePosition.y, tirePosition.z, spikeCoords.x, spikeCoords.y, spikeCoords.z)
	
	if distance < 1.8 then
		if not IsVehicleTyreBurst(vehicle, 0, false) and not IsVehicleTyreBurst(vehicle, 0, true) then
			SetVehicleTyreBurst(vehicle, 0, false, 1000.0)
		end
	end
end

function FrontRightTire(vehicle)
	local tirePosition = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "wheel_rf"))
	local spikestrip = GetClosestObjectOfType(tirePosition.x, tirePosition.y, tirePosition.z, 15.0, GetHashKey("P_ld_stinger_s"), false, 1, 1)
	local spikeCoords = GetEntityCoords(spikestrip, false)
	local distance = Vdist(tirePosition.x, tirePosition.y, tirePosition.z, spikeCoords.x, spikeCoords.y, spikeCoords.z)
	
	if distance < 1.8 then
		if not IsVehicleTyreBurst(vehicle, 1, false) and not IsVehicleTyreBurst(vehicle, 1, true) then
			SetVehicleTyreBurst(vehicle, 1, false, 1000.0)
		end
	end
end

function BackLeftTire(vehicle)
	local tirePosition = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "wheel_lr"))
	local spikestrip = GetClosestObjectOfType(tirePosition.x, tirePosition.y, tirePosition.z, 15.0, GetHashKey("P_ld_stinger_s"), false, 1, 1)
	local spikeCoords = GetEntityCoords(spikestrip, false)
	local distance = Vdist(tirePosition.x, tirePosition.y, tirePosition.z, spikeCoords.x, spikeCoords.y, spikeCoords.z)
	
	if distance < 1.8 then
		if not IsVehicleTyreBurst(vehicle, 4, false) and not IsVehicleTyreBurst(vehicle, 4, true) then
			SetVehicleTyreBurst(vehicle, 4, false, 1000.0)
			SetVehicleTyreBurst(vehicle , 2, false, 1000.0)
		end
	end
end

function BackRightTire(vehicle)
	local tirePosition = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "wheel_rr"))
	local spikestrip = GetClosestObjectOfType(tirePosition.x, tirePosition.y, tirePosition.z, 15.0, GetHashKey("P_ld_stinger_s"), false, 1, 1)
	local spikeCoords = GetEntityCoords(spikestrip, false)
	local distance = Vdist(tirePosition.x, tirePosition.y, tirePosition.z, spikeCoords.x, spikeCoords.y, spikeCoords.z)
	
	if distance < 1.8 then
		if not IsVehicleTyreBurst(vehicle, 5, false) and not IsVehicleTyreBurst(vehicle, 5, true) then
			SetVehicleTyreBurst(vehicle, 5, false, 1000.0)
			SetVehicleTyreBurst(vehicle , 3, false, 1000.0)
		end
	end
end

function CheckPedRestriction(ped, PedList)
	for i = 1, #PedList do
		print(tostring(GetHashKey(PedList[i])))
		if GetHashKey(PedList[i]) == GetEntityModel(ped) then
			return true
		end
	end
	return false
end

function DisplayNotification(string)
	SetTextComponentFormat("STRING")
	AddTextComponentString(string)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if SpikesSpawned then
			for i = 1, #SpawnedSpikes do
				FreezeEntityPosition(SpawnedSpikes[i], true)
				DisplayNotification("Press ~INPUT_CHARACTER_WHEEL~ + ~INPUT_PHONE~" .. " to remove spike strips.")
			end
		end

		if SpikesSpawned and IsControlPressed(1, 19) and IsControlJustPressed(1, 27) then
			TriggerEvent("Spikestrips:RemoveSpikes")
		end

		if SpikesSpawned and IsEntityDead(GetPlayerPed(PlayerId())) and DeleteDeadSpikes then
			DeleteDeadSpikes = false
			TriggerEvent("Spikestrips:RemoveSpikes")
			Citizen.Trace("Auto Deleting Spikes")
		end
	end
end)