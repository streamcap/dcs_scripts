----------------------------------------------------------------------------------------
---
-- Name: BOS-101 - Truman
-- Date Created: 		 25/01/2023
-- CASE I recoveries:	 08:00 - 19:55
-- CASE III recoveries:	 20:00 - 04:55
-- Deck closed:			 05:00 - 08:00
----------------------------------------------------------------------------------------

-- No MOOSE settings menu. Comment out this line if required.
_SETTINGS:SetPlayerMenuOff()

  
-- Create AIRBOSS object.
local AirbossCVN75=AIRBOSS:New("CVN75")

-- Add recovery windows:

local window1=AirbossCVN75:AddRecoveryWindow( "08:00", "09:55", 1, nil, true, 25)
local window1=AirbossCVN75:AddRecoveryWindow( "10:00", "11:55", 1, nil, true, 25)
local window1=AirbossCVN75:AddRecoveryWindow( "12:00", "13:55", 1, nil, true, 25)
local window1=AirbossCVN75:AddRecoveryWindow( "14:00", "15:55", 1, nil, true, 25)
local window1=AirbossCVN75:AddRecoveryWindow( "16:00", "17:55", 1, nil, true, 25)
local window1=AirbossCVN75:AddRecoveryWindow( "18:00", "19:55", 1, nil, true, 25)
local window3=AirbossCVN75:AddRecoveryWindow( "20:00", "21:55", 3, 0, true, 15)
local window3=AirbossCVN75:AddRecoveryWindow( "22:00", "01:55", 3, 0, true, 15)
local window3=AirbossCVN75:AddRecoveryWindow( "03:00", "05:55", 3, 0, true, 15)

-- Set folder of airboss sound files within miz file.
AirbossCVN75:SetSoundfilesFolder("Airboss Soundfiles/")

--FunkyBOT
AirbossCVN75:SetFunkManOn(10042, "127.0.0.1")

-- Single carrier menu optimization.
AirbossCVN75:SetMenuSingleCarrier()

-- Set carrier frequencies
AirbossCVN75:SetLSORadio(254, AM)
AirbossCVN75:SetMarshalRadio(250, AM)

-- Ser Carrier TACAN to X 106 LW
AirbossCVN75:SetTACAN(106, X, "LW")
AirbossCVN75:SetICLS(6, "LW")

-- Skipper menu.
AirbossCVN75:SetMenuRecovery(30, 20, false)

-- Remove landed AI planes from flight deck.
AirbossCVN75:SetDespawnOnEngineShutdown()

-- Load all saved player grades from your "Saved Games\DCS" folder (if lfs was desanitized).
AirbossCVN75:Load()

-- Automatically save player results to your "Saved Games\DCS" folder each time a player get a final grade from the LSO.
AirbossCVN75:SetAutoSave()

-- Enable trap sheet.
AirbossCVN75:SetTrapSheet()

-- Start airboss class.
AirbossCVN75:Start()


--- Function called when a player gets graded by the LSO.
function AirbossCVN75:OnAfterLSOGrade(From, Event, To, playerData, grade)
  local PlayerData=playerData --Ops.Airboss#AIRBOSS.PlayerData
  local Grade=grade --Ops.Airboss#AIRBOSS.LSOgrade

  ----------------------------------------
  --- Interface your Discord bot here! ---
  ----------------------------------------
  
  local score=tonumber(Grade.points)
  local name=tostring(PlayerData.name)
  
  -- Report LSO grade to dcs.log file.
  env.info(string.format("Player %s scored %.1f", name, score))
end

