local QBCore = exports["qb-core"]:GetCoreObject()

RegisterServerEvent('k-consignment:takefunds', function(data)
    local src = source
    local citizenid = QBCore.Functions.GetPlayer(src).PlayerData.citizenid
    local info = MySQL.query.await('SELECT * FROM players WHERE citizenid = ?', {citizenid})
    local Player = QBCore.Functions.GetPlayer(src)
    if tonumber(table.unpack(info).consignment) > 0 then        
        MySQL.query('UPDATE players SET consignment = ? WHERE citizenid = ?', {0,citizenid})
        Player.Functions.AddMoney('cash', tonumber(table.unpack(info).consignment))
    end
end)

RegisterServerEvent('k-consignment:transferitem', function(data,amount,price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if data.input == 'buy' then
        local item = MySQL.query.await('SELECT * FROM consignment WHERE item = ? AND citizenid = ? AND shop = ?', {data.item,data.cid,data.zone})
        if table.unpack(item).amount then
            if Player.Functions.RemoveMoney('cash', data.price * amount) then
                local plydata = MySQL.query.await('SELECT * FROM players WHERE citizenid = ?', {data.cid})
                if table.unpack(plydata).consignment ~= nil then
                    MySQL.query('UPDATE players SET consignment = ? WHERE citizenid = ?', {table.unpack(plydata).consignment + (data.price * amount),data.cid})
                end    
                Player.Functions.AddItem(data.item,amount)
                if amount == tonumber(data.amount) then
                    MySQL.Async.execute('DELETE FROM consignment WHERE item = ? AND citizenid = ? AND shop = ?', {data.item,data.cid,data.zone})
                else
                    MySQL.query('UPDATE consignment SET amount = ? WHERE item = ? AND citizenid = ? AND shop = ?', {tonumber(table.unpack(item).amount) - amount,data.item,data.cid,data.zone})
                end
            else
                TriggerClientEvent('QBCore:Notify', src, "You don't have enough money.", "error", 5000)
            end
        end
    elseif data.input == 'sell' then
        local restricted = false
        for i = 1,#Config.Locations[data.zone]['restrictedItems'],1 do
            if Config.Locations[data.zone]['restrictedItems'][i] == data.item then
                TriggerClientEvent('QBCore:Notify', src, "You can't post that item at this shop.", "error", 5000)
                restricted = true
            end
        end
        if not restricted then
            local citizenid = QBCore.Functions.GetPlayer(src).PlayerData.citizenid
            local item = MySQL.query.await('SELECT * FROM consignment WHERE item = ? AND citizenid = ? AND shop = ?', {data.item,citizenid,data.zone})
            if not next(item) then
                local percentage = math.floor((amount * price * Config.Items[data.item]['cut']) * 1)
                --print(percentage)
                if Player.Functions.RemoveMoney('cash', percentage) then
                    if Player.Functions.RemoveItem(data.item,amount) then
                        MySQL.insert('INSERT INTO consignment (citizenid, item, shop, price, amount, timer) VALUES (:citizenid, :item, :shop, :price, :amount, :timer)', {
                            ['citizenid'] = citizenid,
                            ['item'] = data.item,
                            ['shop'] = data.zone,
                            ['price'] = price,
                            ['amount'] = amount,
                            ['timer'] = 3600000*Config.ItemHold
                        })
                    end
                end
            else
                TriggerClientEvent('QBCore:Notify', src, "You already have an item of this type here.", "error", 5000)
            end
        end
    end
end)

QBCore.Functions.CreateCallback('k-consignment:getshopfunds', function(source, cb, zone)
    local src = source
    local citizenid = QBCore.Functions.GetPlayer(src).PlayerData.citizenid
    local info = MySQL.query.await('SELECT * FROM players WHERE citizenid = ?', {citizenid})
    local funds = table.unpack(info).consignment
    cb(funds)
end)

QBCore.Functions.CreateCallback('k-consignment:getshopitems', function(source, cb, zone)
    cb(MySQL.query.await('SELECT * FROM consignment WHERE shop = ?', {zone}))
end)

QBCore.Functions.CreateCallback('k-consignment:getsellitems', function(source, cb, zone)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local data = {}
    for k,v in pairs(Config.Items) do
        local restricted = false
        --print(k)
        local item = Player.Functions.GetItemsByName(k)
        if item ~= nil then
            for u,_ in ipairs(Config.Locations[zone]['restrictedItems']) do
                if u == k then
                    restricted = true
                end
            end
            local amount = 0
            for i = 1,#item,1 do
                amount = amount + item[i].amount
            end
           -- print(amount)
            if not restricted and amount > 0 then
                data[k] = amount
            end
            restricted = false
        end
    end
    Wait(0)    
    cb(data)
end)
