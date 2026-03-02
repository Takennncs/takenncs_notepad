local QBCore = exports['qb-core']:GetCoreObject()
local currentSlot = nil

local function openEditor(data)
    if not data or not data.slot then return end

    if type(data.slot) == "table" and data.slot.slot then
        currentSlot = tonumber(data.slot.slot)
    elseif type(data.slot) == "number" then
        currentSlot = tonumber(data.slot)
    else
        return
    end

    TriggerServerEvent('takenncs_notepad:server:loadDocument', currentSlot)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        data = {
            slot = currentSlot,
            title = "Laen...",
            content = "",
            locked = false,
            lastEdited = GetGameTimer() * 1000
        }
    })
end

RegisterNetEvent('takenncs_notepad:client:loadDocument', function(data)
    if currentSlot and currentSlot == tonumber(data.slot) then
        SendNUIMessage({
            action = "updateContent",
            data = {
                title = data.title,
                content = data.content,
                locked = data.locked,
                lastEdited = data.lastEdited
            }
        })
    end
end)

RegisterNUICallback('saveDocument', function(data, cb)
    if not currentSlot then
        cb({ ok = false })
        return
    end

    data.slot = currentSlot
    data.lastEdited = GetGameTimer() * 1000

    TriggerServerEvent('takenncs_notepad:server:saveDocument', data)
    cb({ ok = true })
end)

RegisterNUICallback('duplicateDocument', function(data, cb)
    if not currentSlot then
        cb({ ok = false })
        return
    end

    data.slot = currentSlot
    data.lastEdited = GetGameTimer() * 1000

    TriggerServerEvent('takenncs_notepad:server:duplicateDocument', data)
    cb({ ok = true })
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    currentSlot = nil
    cb({ ok = true })
end)

exports('openEditor', function(slot)
    openEditor({ slot = slot })
end)

RegisterNetEvent('ox_inventory:useItem', function(data)
    if data.name == Config.ItemName then
        openEditor({ slot = data.slot })
    end
end)

exports.ox_inventory:displayMetadata(function(item)
    if item.name == Config.ItemName then
        return {
            label = 'Märkmik',
            description = '📝 Kasuta avamiseks'
        }
    end
end)