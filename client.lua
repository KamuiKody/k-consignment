
local QBCore = exports["qb-core"]:GetCoreObject()
local pedSpawned = false

local function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(1)
    end
end

local listen = false
local function Listen4Control(zone)
    CreateThread(function()
        listen = true
        while listen do
            if IsControlJustPressed(0, 38) then -- E
                exports["qb-core"]:KeyPressed()
                --print(zone.name)
                ShopType(zone.name)
                listen = false
                break
            end
            Wait(1)
        end
    end)
end


local ShopPed = {}
local function createPeds()
    if pedSpawned then return end
    for k, v in pairs(Config.Locations) do
        if not ShopPed[k] then ShopPed[k] = {} end
        local current = v["ped"]
        current = type(current) == 'string' and GetHashKey(current) or current
        RequestModel(current)
        while not HasModelLoaded(current) do
            Wait(0)
        end
        ShopPed[k] = CreatePed(0, current, v["coords"].x, v["coords"].y, v["coords"].z-1, v["coords"].w, false, false)
        FreezeEntityPosition(ShopPed[k], true)
        SetEntityInvincible(ShopPed[k], true)
        SetBlockingOfNonTemporaryEvents(ShopPed[k], true)
        if Config.UseTarget then
            exports[Config.Target]:AddTargetEntity(ShopPed[k], {
                options = {
                    {
                        label = v["shopLabel"],
                        icon = "fa-solid fa-cash-register",
                        action = function()
                            ShopType(k)
                        end,
                    }
                },
                distance = 2.0
            })
        end
    end
    pedSpawned = true
end

-- Threads
CreateThread(function()
    if not Config.UseTarget then
        local NewZones = {}
        for shop, _ in pairs(Config.Locations) do
            NewZones[#NewZones+1] = CircleZone:Create(vector3(Config.Locations[shop]["coords"]["x"], Config.Locations[shop]["coords"]["y"], Config.Locations[shop]["coords"]["z"]), 3, {
                useZ = true,
                debugPoly = false,
                name = shop,
            })
        end
        local combo = ComboZone:Create(NewZones, {name = "RandomZOneName", debugPoly = false})
        combo:onPlayerInOut(function(isPointInside, _, zone)
            if isPointInside then
                exports["qb-core"]:DrawText('[E] Open Shop')
                Listen4Control(zone)
            else
                exports["qb-core"]:HideText()
            end
        end)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    createPeds()
end)


AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        createPeds()
    end
end)

RegisterNetEvent('k-consignment:openshop', function(data)
    openShop(data.zone,data.type)
end)

RegisterNetEvent('k-consignment:openshop1', function(zone,type)
    --print(zone,type)
    openShop(zone,type)
end)

RegisterNetEvent('k-consignment:input', function(data)
    OpenInput(data)
end)

RegisterNetEvent('k-consignment:takecash', function(data)
    TriggerServerEvent('k-consignment:takefunds', data)
end)
RegisterNetEvent('k-consignment:takecash1', function(zone,funds)
    --print(zone,funds)
    local data = {
        zone = zone,
        price = funds
    }
    TriggerServerEvent('k-consignment:takefunds', data)
end)

if Config.QBMenu then

    function ShopType(zone)
        local shoptype = {
            {
                header = "| Buy or Sell? |",
                isMenuHeader = true
            },
            {
                header = Config.Locations[zone]['buyLabel'],
                params = {
                    event = 'k-consignment:openshop',
                    args = {
                        zone = zone,
                        type = 'buy'
                    }
                }
            },
            {
                header = Config.Locations[zone]['sellLabel'],
                params = {
                    event = 'k-consignment:openshop',
                    args = {
                        zone = zone,
                        type = 'sell'
                    }
                }
            },
            {
                header = Config.Locations[zone]['fundsLabel'],
                params = {
                    event = 'k-consignment:openshop',
                    args = {
                        zone = zone,
                        type = 'check'
                    }
                }
            }
        }
        exports['qb-menu']:openMenu(shoptype)
    end

    function openShop(zone,type)
        if type == 'sell' then
            QBCore.Functions.TriggerCallback('k-consignment:getsellitems', function(item)
                local shop = {
                {
                    header = "| Sell? |",
                    isMenuHeader = true
                }
            }
                if next(item) then
                    for k,v in pairs(item) do
                       -- print(k,v)
                        shop[#shop+1] = {
                            header = '[x'..v..'] '..QBCore.Shared.Items[k].label,
                            params = {
                                event = 'k-consignment:input',
                                args = {
                                    item = k,
                                    amount = v,
                                    input = 'sell',
                                    zone = zone
                                }
                            }
                        }
                    end
                end
                exports['qb-menu']:openMenu(shop)
            end, zone)

        elseif type == 'buy' then
            QBCore.Functions.TriggerCallback('k-consignment:getshopitems', function(items)
                local shop = {
                {
                    header = "| Buy? |",
                    isMenuHeader = true
                }
            }
                if next(items) then
                    for k,v in pairs(items) do
                        shop[#shop+1] = {
                            header = '[x'..v.amount..'] '..QBCore.Shared.Items[v.item].label,
                            txt = '$'..v.price..' | Time Remaining: '..(tonumber(v.timer)/60000)..' minutes',
                            params = {
                                event = 'k-consignment:input',
                                args = {
                                    cid = v.citizenid,
                                    input = 'buy',
                                    item = v.item,
                                    amount = v.amount,
                                    price = v.price,
                                    zone = zone
                                }
                            }
                        }
                    end
                end
                exports['qb-menu']:openMenu(shop)
            end, zone)
        elseif type == 'check' then
            QBCore.Functions.TriggerCallback('k-consignment:getshopfunds', function(funds)
                local shop = {
                {
                    header = "| Cashout? |",
                    isMenuHeader = true
                },
                {
                    header = "Take Cash",
                    txt = '$'..funds..' Available',
                    params = {
                        event = 'k-consignment:takecash',
                        args = {
                            zone = zone,
                            price = tonumber(funds)
                        }
                    }
                }
            }
            exports['qb-menu']:openMenu(shop)
            end, zone)
        end
    end

    function OpenInput(data)
        if data.input == 'sell' then           
            local perc = (Config.Items[data.item]['cut'] * 100)
            local dialog = exports['qb-input']:ShowInput({
                header = "| "..QBCore.Shared.Items[data.item].label.." | Consignment Percent: "..tonumber(perc).."% |",
                submitText = "Submit",
                inputs = {
                    {
                        text = "Amount", 
                        name = "itemamount", 
                        type = "number", 
                        isRequired = true, 
                    },
                    {
                        text = "Price", 
                        name = "itemprice", 
                        type = "number", 
                        isRequired = true, 
                    }
                }
            })
            if dialog ~= nil then
                local amount = tonumber(dialog['itemamount'])
                local price = tonumber(dialog['itemprice'])
                if amount <= data.amount then
                    TriggerServerEvent('k-consignment:transferitem', data, amount, price)
                else
                    QBCore.Functions.Notify('Invalid amount', 'error', 5000)
                end
            else
                QBCore.Functions.Notify('Invalid amount', 'error', 5000)
            end
        elseif data.input == 'buy' then    
            local dialog = exports['qb-input']:ShowInput({
                header = "| "..QBCore.Shared.Items[data.item].label.." | Price: $"..data.price.." | Amount: x"..data.amount.." |",
                submitText = "Submit",
                inputs = {
                    {
                        text = "Amount", 
                        name = "itemamount", 
                        type = "number", 
                        isRequired = true, 
                    }
                }
            })
            if dialog ~= nil then
                local amount = tonumber(dialog['itemamount'])
                if amount <= tonumber(data.amount) then
                    TriggerServerEvent('k-consignment:transferitem', data, amount)
                else
                    QBCore.Functions.Notify('Invalid amount', 'error', 5000)
                end
            else
                QBCore.Functions.Notify('Invalid amount', 'error', 5000)
            end
        end
    end

else

    function ShopType(zone)        
        local shoptype = {
            {
                header = "| Buy or Sell? |"
            },
            {
                header = Config.Locations[zone]['buyLabel'],
                event = 'k-consignment:openshop1',
                args = {zone,'buy'}              
            },
            {
                header = Config.Locations[zone]['sellLabel'],
                event = 'k-consignment:openshop1',
                args = {zone,'sell'}                       
            },
            {
                header = Config.Locations[zone]['fundsLabel'],
                event = 'k-consignment:openshop1',
                args = {zone,'check'}                
            }
        }
        TriggerEvent('nh-context:createMenu', shoptype)
    end

    function openShop(zone,type)
        local shop = {}
        if type == 'sell' then
            QBCore.Functions.TriggerCallback('k-consignment:getsellitems', function(item)
                local shop = {
                    {
                        header = "| Sell? |"
                    }
                }
                if next(item) then
                    for k,v in pairs(item) do
                        table.insert(shop, {
                            header = '[x'..v..'] '..QBCore.Shared.Items[k].label,
                            event = 'k-consignment:input',
                            image = Config.Items[k]['img'],
                            args = { {
                                item = k,
                                amount = v,
                                input = 'sell',
                                zone = zone
                            } }
                        })
                    end
                end
                TriggerEvent('nh-context:createMenu', shop)
            end, zone)
        elseif type == 'buy' then
            local shop = {
            {
                header = "| Buy? |"
            }
        }
            QBCore.Functions.TriggerCallback('k-consignment:getshopitems', function(items)
                if next(items) then
                    for k,v in pairs(items) do
                        table.insert(shop, {
                        header = '[x'..v.amount..'] '..QBCore.Shared.Items[v.item].label,
                        context = '$'..v.price..' | Time Remaining: '..(tonumber(v.timer)/60000)..' minutes',
                        event = 'k-consignment:input',
                        image = Config.Items[v.item]['img'],
                        args = {  {
                            cid = v.citizenid,
                            input = 'buy',
                            item = v.item,
                            amount = v.amount,
                            price = v.price,
                            zone = zone
                            } }
                        })                        
                    end
                end
                TriggerEvent('nh-context:createMenu', shop)
            end, zone)
        elseif type == 'check' then
            QBCore.Functions.TriggerCallback('k-consignment:getshopfunds', function(funds)
                local shop = {
                {
                    header = "| Cashout? |"
                },
                {
                    header = "Take Cash",
                    context = '$'..funds..' Available',
                    event = 'k-consignment:takecash1',
                    args = {zone,tonumber(funds)}                    
                }
            }
            TriggerEvent('nh-context:createMenu', shop)
            end, zone)
        end
    end

    function OpenInput(data)
        if data.input == 'sell' then    
            local perc = (Config.Items[data.item]['cut'] * 100)
            local keyboard, price, amount = exports["nh-keyboard"]:Keyboard({
                header = "| "..QBCore.Shared.Items[data.item].label.." | Consignment Percent: "..tonumber(perc).."% |",
                rows = {"Price", "Amount"}
            })        
            if keyboard then
                if tonumber(price) and tonumber(amount) then
                    --print(tonumber(amount),tonumber(data.amount))
                    if tonumber(amount) <= tonumber(data.amount) then
                        TriggerServerEvent('k-consignment:transferitem', data, tonumber(amount), tonumber(price))
                    else
                        QBCore.Functions.Notify('Invalid amount', 'error', 5000)
                    end
                else
                    QBCore.Functions.Notify('Invalid amount', 'error', 5000)
                end
            end            
        elseif data.input == 'buy' then  
            local keyboard, amount = exports["nh-keyboard"]:Keyboard({
                header = "| "..QBCore.Shared.Items[data.item].label.." | Price: $"..data.price.." | Amount: x"..data.amount.." |",
                rows = {"Amount"}
            })        
            if keyboard then
                if tonumber(amount) then
                    if tonumber(amount) <= tonumber(data.amount) then
                        TriggerServerEvent('k-consignment:transferitem', data, tonumber(amount))
                    else
                        QBCore.Functions.Notify('Invalid amount', 'error', 5000)
                    end
                else
                    QBCore.Functions.Notify('Invalid amount', 'error', 5000)
                end
            end  
        end
    end
    
end