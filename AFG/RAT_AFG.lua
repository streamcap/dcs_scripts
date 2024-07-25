---
-- Name: RAT-011 - Traffic at Kandahar
-- Author: seavoyage
-- Date Created: 25 July 2024
-- Updated: 25 July 2024
-- 
-- # Situation:
--
-- We want to generate some random air traffic at Kandahar, Camp Bastion, Dwyer, and Shindad.
-- 
-- # Test cases:
--
-- 1. A-10C are spawned at Kandahar with desitation Camp Bastion, Dwyer or Shinhad.
-- 2. V-22 are spawned at Camp Bastion with desitation Kandahar, Dwyer or Shindad.
-- 3. F-18C are spawned at Kandahar with desitation Camp Bastion.
-- 4. KC-130 are spawned in air at two zones heading for Kandahar.

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create RAT object from A-10C template.
local a10=RAT:New("RAT_A10C")

-- Departure Kandahar.
a10:SetDeparture(AIRBASE.Afghanistan.Kandahar)
a10:SetCoalition("same")

-- Destination Camp Bastion, Dwyer or Shinddad.
a10:SetDestination({AIRBASE.Afghanistan.Camp_Bastion, AIRBASE.Afghanistan.Dwyer, AIRBASE.Afghanistan.Shindad})

-- Spawn three flights.
a10:Spawn(3)

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------

local v22=RAT:New("RAT_V22")

-- Departure Kandahar.
v22:SetDeparture(AIRBASE.Afghanistan.Camp_Bastion)
v22:SetCoalition("same")

-- Destination Camp Bastion, Dwyer or Shinddad.
v22:SetDestination({AIRBASE.Afghanistan.Kandahar, AIRBASE.Afghanistan.Dwyer, AIRBASE.Afghanistan.Shindad})

-- Spawn three flights.
v22:Spawn(3)

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Creat RAT object from F/A-18C template.
local f18=RAT:New("RAT_F18C")
f18:SetCoalition("same")

-- Departure airports.
f18:SetDeparture(AIRBASE.Afghanistan.Kandahar)

-- Destination Nellis.
f18:SetDestination(AIRBASE.Afghanistan.Camp_Bastion)

-- Spawn two flights.
f18:Spawn(2)


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create RAT object from KC-130 template.
local kc130=RAT:New("RAT_KC130")

-- Set departure zones. We need takeoff "air" for that.
kc130:SetDeparture({"RAT Zone North", "RAT Zone East"})

-- Set spawn in air.
kc130:SetTakeoff("air")

-- Aircraft will fly to Kandahar
kc130:SetDestination(AIRBASE.Afghanistan.Kandahar)

-- Spawning of aircraft will happen in 2 minute intervalls.
kc130:SetSpawnInterval(120)

-- Spawn two aircraft.
kc135:Spawn(2)

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Store time at mission start
local T0=timer.getTime()

-- Send message with current misson time to all coalisions
local function print_mission_time()
  local Tnow=timer.getTime()
  local mission_time=Tnow-T0
  local mission_time_minutes=mission_time/60
  local mission_time_seconds=mission_time%60
  local text=string.format("Mission Time: %i:%02d", mission_time_minutes,mission_time_seconds)
  MESSAGE:New(text, 5):ToAll()
end

-- Start scheduler to report mission time.
local Scheduler_Mission_Time = SCHEDULER:New(nil, print_mission_time, {}, 0, 10)