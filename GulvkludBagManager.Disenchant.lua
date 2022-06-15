------------------------------------------------------------------------------------
-- DISENCHANT TABLE
------------------------------------------------------------------------------------

local weaponSubTypes = {
	["One-Handed Axes"] = true,	
	["Two-Handed Axes"] = true,
	["Bows"] = true,
	["Guns"] = true,
	["One-Handed Maces"] = true,
	["Two-Handed Maces"] = true,
	["Polearms"] = true,
	["One-Handed Swords"] = true,
	["Two-Handed Swords"] = true,
	["Staves"] = true,
	["Fist Weapons"] = true,
	["Daggers"] = true,
	["Thrown"] = true,
	["Crossbows"] = true,
	["Wands"] = true,
	["Fishing Poles"] = false,
};

GBManager.disenchant = {

	-- blue items
	[3] = {

		-- [Small Radiant Shard]
		{
			level = { min = 41, max = 45},
			type = "Armor",
		},
		{
			level = { min = 41, max = 45},
			type = "Weapon",
			subTypes = weaponSubTypes,
		},
	},

	-- green items
	[2] = {

		-- [Lesser Magic Essence] + [Strange Dust]
		{
			level = { min = 5, max = 10}, 
			type = "Armor",
			ignore = true
		},
		{
			level = { min = 5, max = 10},
			type = "Weapon",
			subTypes = weaponSubTypes,
			ignore = true
		},

		-- [Lesser Magic Essence] + [Strange Dust]
		{
			level = { min = 11, max = 15}, 
			type = "Armor"
		},
		{
			level = { min = 11, max = 15}, 
			type = "Weapon",
			subTypes = weaponSubTypes,
		},

		-- [Greater Magic Essence] + [Strange Dust]
		{
			level = { min = 16, max = 20},
			type = "Armor"
		},
		{
			level = { min = 16, max = 20},
			type = "Weapon",
			subTypes = weaponSubTypes
		},

		-- [Lesser Astral Essence] + [Strange Dust]
		{
			level = { min = 21, max = 25},
			type = "Armor",
			quality = 2 },
		{
			level = { min = 21, max = 25},
			type = "Weapon",
			subTypes = weaponSubTypes,
			vendor = true
		},

		-- [Greater Astral Essence] + [Soul Dust]
		{
			level = { min = 26, max = 30},
			type = "Armor",
			ignore = true
		},
		{
			level = { min = 26, max = 30},
			type = "Weapon",
			subTypes = weaponSubTypes,
			vendor = true
		},

		--  [Lesser Mystic Essence] + [Soul Dust]
		{
			level = { min = 31, max = 35},
			type = "Armor",
			ignore = true
		},
		{
			level = { min = 31, max = 35},
			type = "Weapon",
			subTypes = weaponSubTypes,
			vendor = true
		},

		-- [Greater Mystic Essence] + [Vision Dust]
		{ 
			level = { min = 36, max = 40},
			type = "Armor"
		},
		{
			level = { min = 36, max = 40},
			type = "Weapon",
			subTypes = weaponSubTypes,
			vendor = true
		},

		-- [Lesser Nether Essence] + [Vision Dust]
		{
			level = { min = 41, max = 45},
			type = "Armor"
		},
		{
			level = { min = 41, max = 45},
			type = "Weapon",
			subTypes = weaponSubTypes,
			vendor = true
		},

		-- [Greater Nether Essence] + [Dream Dust]
		{
			level = { min = 46, max = 50},
			type = "Armor"
		},
		{
			level = { min = 46, max = 50},
			type = "Weapon",
			subTypes = weaponSubTypes
		},

		-- [Lesser Eternal Essence] + [Dream Dust]
		{
			level = { min = 51, max = 55},
			type = "Armor"
		},
		{
			level = { min = 51, max = 55},
			type = "Weapon",
			subTypes = weaponSubTypes,
			vendor = true
		},

		-- [Greater Eternal Essence] + [Illusion Dust]
		{
			level = { min = 56, max = 60},
			type = "Armor",
		},
		{
			level = { min = 56, max = 60},
			type = "Weapon",
			subTypes = weaponSubTypes,
			vendor = true
		},
		
		-- [Greater Eternal Essence] + [Illusion Dust]
		{
			level = { min = 61, max = 65},
			type = "Armor"
		},
		{
			level = { min = 61, max = 65},
			type = "Weapon",
			subTypes = weaponSubTypes,
			vendor = true
		},

		-- [Lesser Planar Essence] + [Arcane Dust]
		{
			level = { min = 66, max = 79},
			type = "Armor",
		},
		{
			level = { min = 66, max = 79},
			type = "Weapon",
			subTypes = weaponSubTypes,
		},

		-- [Lesser Planar Essence] + [Arcane Dust]
		{
			level = { min = 80, max = 99},
			type = "Armor",
		},
		{
			level = { min = 80, max = 99},
			type = "Weapon",
			subTypes = weaponSubTypes,
		},

		-- [Greater Planar Essence] + [Arcane Dust]
		{
			level = { min = 100, max = 120},
			type = "Armor",
		},
		{
			level = { min = 100, max = 120},
			type = "Weapon",
			subTypes = weaponSubTypes,
		},

		-- [Lesser Cosmic Essence] + [Infite Dust]
		{
			level = { min = 130, max = 151},
			type = "Armor",
		},
		{
			level = { min = 130, max = 151},
			type = "Weapon",
			subTypes = weaponSubTypes,
		},

		-- [Greater Cosmic Essence] + [Infite Dust]
		{
			level = { min = 152, max = 200},
			type = "Armor",
		},
		{
			level = { min = 152, max = 200},
			type = "Weapon",
			subTypes = weaponSubTypes,
		},
	}
};