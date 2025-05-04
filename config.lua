Config = {}

Config.FarmSpots = {
    {
        label = "Weed Feld",
        coords = vector3(-1833.402222, -2938.193359, 14.131836),
        item = "weed",
        label = "Weed",
        amount = 1,
        anim = { dict = "amb@world_human_gardener_plant@male@idle_a", name = "idle_a"},
        time = 5000,
        boost = { time = 1, effect = "farmboost" },
        marker = {
            radius = 1.5,
            color = { r = 0, g = 255, b = 0, a = 100 }
        }
    },
    {
        label = "Cocaine Feld",
        coords = vector3(-1828.272583, -2964.276855, 14.131836),
        item = "cocaine_leaf",
        label = "Kokain",
        amount = 1,
        anim = { dict = "amb@world_human_gardener_plant@male@idle_a", name = "idle_a" },
        time = 5000,
        boost = nil,
        marker = {
            radius = 1.5,
            color = { r = 0, g = 255, b = 0, a = 100 }
        }
    },

}

Config.Drugs = {
    ["weed_joint"] = {
        label = "Joint",
        health = 25,           
        armor = 0,            
        buff = nil
    },

    ["cocaine_baggy"] = {
        label = "Kokain",
        health = 0,
        armor = 25,
        buff = nil
    },

    ["xtc_baggy"] = {
        label = "XTC",
        health = 0,
        armor = 0,
        buff = {
            name = "farmboost",
            time = 30000,
        }
    }
}
