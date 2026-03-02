local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `sticky_notes` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `identifier` varchar(50) NOT NULL,
            `slot` int(11) NOT NULL,
            `title` varchar(255) DEFAULT 'Pealkirjata märkmik',
            `content` longtext,
            `locked` tinyint(1) DEFAULT 0,
            `last_edited` bigint(20) DEFAULT NULL,
            `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `unique_slot` (`identifier`, `slot`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)

RegisterNetEvent('takenncs_notepad:server:saveDocument', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not data.slot then return end

    local identifier = Player.PlayerData.citizenid
    local slot = tonumber(data.slot)
    if not slot then return end

    MySQL.insert([[
        INSERT INTO sticky_notes (identifier, slot, title, content, locked, last_edited)
        VALUES (?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            title = VALUES(title),
            content = VALUES(content),
            locked = VALUES(locked),
            last_edited = VALUES(last_edited)
    ]], {
        identifier,
        slot,
        data.title or "Pealkirjata märkmik",
        data.content or "",
        data.locked and 1 or 0,
        data.lastEdited
    })

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Märkmik',
        description = 'Märkmed salvestatud!',
        type = 'success'
    })
end)

RegisterNetEvent('takenncs_notepad:server:duplicateDocument', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local identifier = Player.PlayerData.citizenid
    local newTitle = (data.title or "Pealkirjata märkmik") .. " (koopia)"

    exports.ox_inventory:AddItem(src, Config.ItemName, 1, {})
    Citizen.Wait(100)
    
    local items = exports.ox_inventory:GetItems(src, nil, Config.ItemName)
    if items and #items > 0 then
        local newSlot = items[#items].slot
        MySQL.insert('INSERT INTO sticky_notes (identifier, slot, title, content, locked, last_edited) VALUES (?, ?, ?, ?, ?, ?)', {
            identifier,
            newSlot,
            newTitle,
            data.content or "",
            0,
            data.lastEdited
        })
    end

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Märkmik',
        description = 'Uus koopia loodud!',
        type = 'success'
    })
end)

RegisterNetEvent('takenncs_notepad:server:loadDocument', function(slot)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local identifier = Player.PlayerData.citizenid
    local slotNum = tonumber(slot)
    if not slotNum then return end

    MySQL.single(
        'SELECT * FROM sticky_notes WHERE identifier = ? AND slot = ?',
        { identifier, slotNum },
        function(result)
            if result then
                TriggerClientEvent('takenncs_notepad:client:loadDocument', src, {
                    title = result.title,
                    content = result.content,
                    locked = result.locked == 1,
                    lastEdited = result.last_edited,
                    slot = slotNum
                })
            else
                TriggerClientEvent('takenncs_notepad:client:loadDocument', src, {
                    title = "Uus märkmik",
                    content = "",
                    locked = false,
                    lastEdited = os.time() * 1000,
                    slot = slotNum
                })
            end
        end
    )
end)