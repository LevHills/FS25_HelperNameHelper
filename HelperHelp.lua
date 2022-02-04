-- HelperHelp.lua for FS22
-- sperrgebiet 2022
-- Unlike others I see the meaning in mods that others can learn, expand and improve them. So feel free to use this in your own mods, 
-- add stuff to it, improve it. Your own creativity is the limit ;) If you want to mention me in the credits fine. If not, I'll live happily anyway :P
-- Yeah, I know. I should do a better job in document my code... Next time, I promise... 
-- Please see https://gitlab.com/sperrgebiet/FS22_HelperNameHelper for additional information, credits, issues and everything else

HelperHelp = {}

HelperHelp.ModName = g_currentModName
HelperHelp.ModDirectory = g_currentModDirectory
HelperHelp.Version = "1.0.0.0"


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