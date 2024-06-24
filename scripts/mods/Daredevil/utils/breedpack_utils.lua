local BreedPackTemplate = require("scripts/mods/Daredevil/utils/breedpack_template")

InterestPointUnits = InterestPointUnits or {}

local function calc_num_in_packs(breed_packs, roaming_set_name)
	local num_breed_packs = #breed_packs

	for i = 1, num_breed_packs do
		local pack = breed_packs[i]
		local size = #pack.members

		fassert(InterestPointUnits[size], "The %d pack in BreedPacks[%s] is of size %d. There are no InterestPointUnits matching this size.", i, roaming_set_name, size)

		pack.members_n = size
	end

	return num_breed_packs
end

local function generate_breed_pack_by_size(breed_packs, roaming_set_name)
	local num_breed_packs = calc_num_in_packs(breed_packs, roaming_set_name)

	assert("BreedPack of size have no matching interestpoint of that size.")

	local breed_pack_by_size = {}
	local by_size = {}

	for i = 1, num_breed_packs do
		local pack = breed_packs[i]
		local size = pack.members_n

		if not by_size[size] then
			by_size[size] = {
				packs = {},
				weights = {}
			}
		end

		local slot = by_size[size]
		local packs = slot.packs
		packs[#packs + 1] = pack
		slot.weights[#slot.weights + 1] = pack.spawn_weight
	end

	for size, slot in pairs(by_size) do
		local prob, alias = LoadedDice.create(slot.weights, false)
		breed_pack_by_size[size] = {
			packs = slot.packs,
			prob = prob,
			alias = alias
		}
	end

	return breed_pack_by_size
end

InterestPointUnitsLookup = InterestPointUnitsLookup or false
SizeOfInterestPoint = SizeOfInterestPoint or {}
InterestPointPickListIndexLookup = InterestPointPickListIndexLookup or {}
InterestPointPickList = InterestPointPickList or false

local function redo_BreedPacksBySize()
    BreedPacksBySize = {}

    for roaming_set_name, breed_packs in pairs(BreedPacks) do
        BreedPacksBySize[roaming_set_name] = generate_breed_pack_by_size(breed_packs, roaming_set_name)
    end
    -- if #InterestPointPickListIndexLookup == 0 then
        local weight_lookup = InterestPointPickList or {}
        local items = 0
    
        for i, data in pairs(InterestPointUnits) do
            if data then
                for j = 1, data.spawn_weight do
                    items = items + 1
                    weight_lookup[items] = i
                end
    
                for j = 1, #data do
                    local unit_name = data[j]
                    SizeOfInterestPoint[unit_name] = i
                end
    
                InterestPointPickListIndexLookup[i] = items
    
                -- for roaming_set_name, breed_packs in pairs(BreedPacks) do
                --     fassert(BreedPacksBySize[roaming_set_name][i], "BreedPacks[%s] is missing a pack of size %d. It must be defined, since InterestPointUnits expects there to be a pack like that.", roaming_set_name, i)
                -- end
            else
                InterestPointPickListIndexLookup[i] = InterestPointPickListIndexLookup[#InterestPointPickListIndexLookup]
            end
        end
    
        InterestPointPickList = weight_lookup
    -- end
end

BreedPackUtils = BreedPackUtils or {}

BreedPackUtils.add_breedpack = function(pack_name, ...)
    local list_of_breed_names = {...}
    local template = {
	
        roof_spawning_allowed = true,
        zone_checks = {
            clamp_breeds_hi = nil,
            clamp_breeds_low = nil,
        },
        patrol_overrides = {
            patrol_chance = 1
        }
    }

    local member_template = {
		spawn_weight = 1,
		members_n = 1,
		members = {}
	}
    
    local required_sizes = {1,2,3,4,6,8}
    for i, size in pairs(required_sizes) do
        template[i] = table.clone(member_template)
        template[i].members_n = size
        for j=1, size, 1 do
            template[i].members[j] = Breeds[list_of_breed_names[ math.random( #list_of_breed_names ) ]]
            if size > 8 then
                template[i].spawn_weight = 50
            end
        end
    end

    local new_breedpack = table.clone(template)
    BreedPacks[pack_name] = new_breedpack
    redo_BreedPacksBySize()
end

BreedPackUtils.remove_breedpack = function(pack_name)

    BreedPacks[pack_name] = nil
    redo_BreedPacksBySize()
end


return BreedPackUtils

