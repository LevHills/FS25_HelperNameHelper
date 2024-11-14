-- HelperHelp.lua for FS25 based on the FS22 Mod bz Sperrgebiet
-- Lev Hills 2024
-- see https://github.com/LevHills/FS25_HelperNameHelper for additional information, credits, issues and everything else
-- credits to sperrgebiet 2022
-- original https://gitlab.com/sperrgebiet/FS22_HelperNameHelper

HelperHelp = {}

HelperHelp.ModName = g_currentModName
HelperHelp.ModDirectory = g_currentModDirectory
HelperHelp.Version = "2.0.0.0"


function HelperHelp.changeHelperName(helperIndex, name, noEventSend)
	g_helperManager.indexToHelper[helperIndex].title = name
	g_helperManager.indexToHelper[helperIndex].name = name
	HelperHelpEvent.sendEvent(helperIndex, name, noEventSend)
end

function HelperHelp:aiJobStarted(job, helperIndex, startedFarmId)
	HelperHelp.changeHelperName(helperIndex, self:getName())
end

HelperHelpEvent = {}
local HelperHelpEvent_mt = Class(HelperHelpEvent, Event)

InitEventClass(HelperHelpEvent, "HelperHelpEvent")

function HelperHelpEvent.emptyNew()
    local self = Event.new(HelperHelpEvent_mt)
	self.className = "HelperHelpEvent"
    return self
end

function HelperHelpEvent.new(helperIndex, name)
    local self = HelperHelpEvent:emptyNew()
    self.helperIndex = helperIndex
	self.name = name
    return self
end

function HelperHelpEvent:writeStream(streamId, connection)
	streamWriteUInt8(streamId, self.helperIndex)
	streamWriteString(streamId, self.name)
end

function HelperHelpEvent:readStream(streamId, connection)
	self.helperIndex = streamReadUInt8(streamId, connection)
	self.name = streamReadString(streamId, connection)

	self:run(connection)
end

function HelperHelpEvent:run(connection)
	HelperHelp.changeHelperName(self.helperIndex, self.name, true)
end

function HelperHelpEvent.sendEvent(helperIndex, name, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(HelperHelpEvent.new(helperIndex, name))
		else
			g_client:getServerConnection():sendEvent(HelperHelpEvent.new(helperIndex, name))
		end
	end
end

-- I used the message subscribe functionality first, but it seems that doesn't work in MP, so back to the 'good old way'
AIJobVehicle.aiJobStarted = Utils.appendedFunction(AIJobVehicle.aiJobStarted, HelperHelp.aiJobStarted)