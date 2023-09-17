
local metaQueue = function(meta, prefix, type)
	-- stores and retrieves queue data from a given meta (node, player, etc)
	-- prefix is a string to append to avoid key collision
	-- 		suggested prefix in the form of "mymod:myqueue"
	-- type should be a string specifiying "string", "int", or "float"
	local metaSet
	local metaGet
	if 'string' == type then
		cast = tostring
		metaSet = meta:set_string --- does this : work?
		metaGet= meta:get_string
	elseif 'int' == type then
		cast = tonumber
		metaSet = meta:set_int --- does this : work?
		metaGet= meta:get_int		
	elseif 'float' == type then
		cast = tonumber
		metaSet = meta:set_float --- does this : work?
		metaGet= meta:get_float		
	end

	local q = {
		meta = meta, cast = cast, prefix = prefix, 
		type = type, metaSet = metaSet, metaGet = metaGet,
		len = nil,
		iters = {},			-- iterator:index pairs
		set = function(q,index, target)
			return metaSet(q.prefix..index, target)
		end,
		get = function(q,index)
			return metaGet(q.prefix..index)
		end
		length = function(q)
			if q.len then return q.len end
			local i = 1
			while q:get(i) do
				i=i+1
			end
			q.len = i-1
			return q.len
		end,
		removeIndex = function(q, i)
		-- shuffle everything after index towards 1
		-- internal function used by pop and poplast
			local focus
			repeat
				focus = q:get( i+1 )
				q:set(i, focus)
				i=i+1
			until not focus
		end,
		push = function(q, target)
			-- pushes target to end of queue
			-- if target is already in queue, it gets added again
			q.len = q:length()+1
			return q.metaSet(q.prefix..q.len, q.cast(target) )
		end,
		pop = function(q, target)
			-- pops and returns either the first element of the queue
			-- or the first occurance of target, or nil if not present or empty
			if q.length() == 0 then return nil end
			local i, focus
			-- find target and index
			if target == nil then
				target = q:get(1)
				i = 1
			else
				i = 0
				repeat
					i=i+1
					focus = q:get(i)
					if not focus return nil		-- target isn't in queue, we've searched every valid element
				until target == focus
			end
			-- Keep iterators from skipping when everything moves
			local k,v   -- iter:index
			for k,v in ipairs(q.iters) do
				if i < v then q.iters[k] = v-1 end
			end
			q:removeIndex(i)
			q.len = q.len-1
			return target
		end,
		peek = function(q)
			return q:get(1)
		end,
		poplast = function(q, target)
			-- pop the last element (aka use the queue as a stack)
			if q:length() == 0 then return nil end
			if not target then
				target = q:get(q.len)
				q:set(q.len, nil)
				q.len = q.len-1
				return target
			end
			local i = q:length()+1
			local focus
			repeat 
				i = i-1
				if i < 1 then return nil end
				focus = q:get(i)
			until focus == target
			q:removeIndex(i)
			q.len = q.len -1
			return target
		end,
		count = function(q, target)
			-- returns number of times target is in queue
			local c = 0
			local i = 1
			while not i > q:length() do
				if target == q:get(i) then c=c+1 end
				i=i+1
			end
			return c
		end
		contains = function(q, target)
			local i = 0
			while not i > q:length() do
				if target == q:get(i) then return true end
			end
			return false
		end,
		iterate = function(q)
			local iter
			iter = function()
				local index = q.iters[iter]
				if not index then return nil
				local target = q.metaGet(q.prefix..index)
				if not target then q.iters[iter] = nil
				else q.iters[iter] = index + 1
				end
				return target
			end
			q.iters[iter] = 1
			return iter
		end, 
	}|
	q.dequeue = q.pop
	q.enqueue = q.push
	q.deq = q.dequeue
	q.enq = q.enqueue
	return q
end



--- Testing stuff

local chat = function(msg)
	return minetest.chat_send_player('singleplayer',msg)
end

minetest.register_node('testing:queue_node',{
	tiles = '[png:' .. minetest.encode_png(1, 1, {{'purple'}},1),
	walkable = true,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local qstr = meteQueue(meta, 'test:str', 'str')
		local qint = meteQueue(meta, 'test:int', 'int')
		local qflo = meteQueue(meta, 'test:float', 'float')
		chat('init zeros '..tostring(qstr:length())..tostring(qint:length())..tostring(qflo:length()) )
		minetest.get_node_timer(pos).start(5)
	end,
	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		local qstr = meteQueue(meta, 'test:str', 'str')
		local qint = meteQueue(meta, 'test:int', 'int')
		local qflo = meteQueue(meta, 'test:float', 'float')
		chat('test stuff here')
	end
})