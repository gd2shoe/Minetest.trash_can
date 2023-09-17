local modpath = minetest.get_modpath("trash_can")
dofile(modpath .. '/meta_queue.lua')

local trashDef = minetest.registered_items['trash_can:trash_can_wooden']
magicDef = table.copy(trashDef)
magicDef.color = 'purple'


-- track item enter/move order
-- always keep one empty spot
-- oldest deleted first
magicDef.on_metadata_inventory_put = function(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	trashDef.on_metadata_inventory_put(pos, listname, index, stack, player)
	if not 'trashlist' == listname then return end

end

magicDef.on_metadata_inventory_take = function(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	trashDef.on_metadata_inventory_take(pos, listname, index, stack, player)
	if not 'trashlist' == listname then return end
end

magicDef.on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	trashDef.on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	if not 'trashlist' == listname then return end
end


