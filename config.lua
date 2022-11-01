------INSTALLATION-----
--[[

1) Run the SQL In your db
2) drag and drop and fill out the fields below

This file uses qb-input qb-menu or nh-context nh-input 
you can only choose one of the two options


UPDATES:

    Farther Down the Road Here I will configure each shop to hold its own funds and u may only collect those funds from the shop that has them

]]


Config = {}

Config.QBMenu = true -- if false it uses nh-context you can configure the items below to display images with them if using context(using this format) ['itemname'] = imageURL,
Config.UseTarget = false
Config.Target = 'qb-target'
Config.ItemHold = 2 -- hours before item disappears

Config.Locations = {
    ['rockford'] = {
        ['ped'] = 'ig_barry',
        ['coords'] = vector4(236.48, -815.38, 30.25, 5.4),
        ['shopLabel'] = 'Rockford Pawn',
        ['buyLabel'] = 'Buy Items',
        ['sellLabel'] = 'Sell Items',
        ['fundsLabel'] = 'Check Funds',
        ['restrictedItems'] = {-- Add items to this list that are below to keep them out of this shop u can set secret shops to take illegal goods this way
            'snikkel_candy' -- this was just for testing purposes u can comment it out or add different items
        }
    }
}

        --['cut'] = 0.2 percentage they charge to post an item number between 0-1
Config.Items = {-- only items added to this list can be sold to stores making this list does 2 things keeps the resource from looping ur entire item list and also allows to add the images and make the cut per item vs per shop
    ['tosti'] = {['img'] = 'https://i.ibb.co/BCWdkFY/tosti.png', ['cut'] = 0.5},
    ['twerks_candy'] = {['img'] = 'https://i.ibb.co/yXBFcDy/twerks-candy.png', ['cut'] = 0.5},
    ['snikkel_candy'] = {['img'] ='https://i.ibb.co/4f9s5Zy/snikkel-candy.png' , ['cut'] = 0.5},
    ['sandwich'] = {['img'] = 'https://i.ibb.co/9qx8jDg/sandwich.png', ['cut'] = 0.5},
    ['water_bottle'] = {['img'] = 'https://i.ibb.co/5sYj0kt/water-bottle.png', ['cut'] = 0.5},
    ['coffee'] = {['img'] = 'https://i.ibb.co/WVpG5v8/coffee.png', ['cut'] = 0.5},
    ['kurkakola'] = {['img'] = 'https://i.ibb.co/w74WD17/cola.png', ['cut'] = 0.5},
    ['whiskey'] = {['img'] = 'https://i.ibb.co/tDYGc59/whiskey.png', ['cut'] = 0.5},
    ['beer'] = {['img'] = 'https://i.ibb.co/0nb7FZ3/beer.png', ['cut'] = 0.5},
    ['vodka'] = {['img'] = 'https://i.ibb.co/Scf3M6z/vodka.png', ['cut'] = 0.5},

}