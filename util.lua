--- Get Context.beatLength at a timing (0 by default), optionally multiplied
---@param multiplier number
---@param timing integer
---@param group integer
---@return number
function Beatlength(multiplier, timing, group)
    group = group or 0
    timing = timing or 0
    multiplier = multiplier or 1
    return Context.beatLength(group).valueAt(timing) * multiplier
end

-- For loop but with timings. a little more convenient to set up than a for loop
---@param start_time integer -- start time of the first iteration, and of the whole loop
---@param end_time integer -- end time of the first iteration
---@param i_times integer -- number of iterations including the first
---@param func function
function Repeat(start_time, end_time, i_times, func)
    if (end_time > start_time and i_times > 0) then
        local add = end_time - start_time
        for i = 0, i_times do
            func(start_time, i)
            start_time = start_time + add
        end
    end
end

-- Repeat until but with timings
---@param start_time integer -- start time of the loop
---@param end_time integer -- end time of the loop
---@param i_length integer -- length of an iteration in ms
---@param func function
function RepeatUntil(start_time, end_time, i_length, func)
    if (end_time > start_time and i_length > 0) then
        local j = 0
        for i = start_time, end_time, i_length do
            func(i, j)
            j = j + 1
        end
    end
end

--- Set the default value of a Channel, at DEFAULT_TIME (used in setup.lua)
---@param channel KeyChannel
---@param value any
---@return KeyChannel
function SetDefault(value)
    local _channel = Channel.keyframe()
    return _channel.addKey(DEFAULT_TIME - 1, value, 'inconst')
end

--- Used for copying the first key of a Channel (used in setup.lua)
---@param channel KeyChannel
---@return KeyChannel
function CopyDefaultOf(channel)
    local _channel = Channel.keyframe()
    return _channel.addKey(DEFAULT_TIME - 1, channel.valueAt(DEFAULT_TIME - 1), 'inconst')
end

--- Custom thing for handling keys where I can specify an end time and other stuff more conveniently
---@param keychannel KeyChannel
---@param start_time integer
---@param end_time integer
---@param end_value number
---@param add boolean -- Specifies if the value should be added or set
---@param easing ('linear' | 'l' | 'inconstant' | 'inconst' | 'cnsti' | 'outconstant' | 'outconst' | 'cnsto' | 'inoutconstant' | 'inoutconst' | 'cnstb' | 'insine' | 'si' | 'outsine' | 'so' | 'inoutsine' | 'b' | 'inquadratic' | 'inquad' | '2i' | 'outquadratic' | 'outquad' | '2o' | 'inoutquadratic' | 'inoutquad' | '2b' | 'incubic' | '3i' | 'outcubic' | 'outcube' | '3o' | 'inoutcubic' | 'inoutcube' | '3b' | 'inquartic' | 'inquart' | '4i' | 'outquartic' | 'outquart' | '4o' | 'inoutquartic' | 'inoutquart' | '4b' | 'inquintic' | 'inquint' | '5i' | 'outquintic' | 'outquint' | '5o' | 'inoutquintic' | 'inoutquint' | '5b' | 'inexponential' | 'inexpo' | 'exi' | 'outexponential' | 'outexpo' | 'exo' | 'inoutexponential' | 'inoutexpo' | 'exb' | 'incircle' | 'incirc' | 'ci' | 'outcircle' | 'outcirc' | 'co' | 'inoutcircle' | 'inoutcirc' | 'cb' | 'inback' | 'bki' | 'outback' | 'bko' | 'inoutback' | 'bkb' | 'inelastic' | 'eli' | 'outelastic' | 'elo' | 'inoutelastic' | 'elb' | 'inbounce' | 'bni' | 'outbounce' | 'bno' | 'inoutbounce' | 'bnb')
function KeyTween(keychannel, start_time, end_time, end_value, add, easing)
    local _add = add or false
    local start_value = keychannel.valueAt(start_time) or 0
    end_value = (_add and start_value + end_value) or end_value
    local instant = (start_time == end_time)

    if (instant) then
        keychannel.addKey(end_time, end_value, 'inconst')
    else
        keychannel.addKey(start_time, start_value, easing)
                  .addKey(end_time, end_value, 'inconst')
    end
end

--- Used for moving stuff in in-game grid units
---@param value number
---@param x_y ('x' | 'y')
---@return number
function ConvertFromGrid(value, x_y)
    local multiplier = xy(-8.5, 4.5)
    if (x_y == 'x') then
        return value * multiplier.x
    elseif (x_y == 'y') then
        return value * multiplier.y
    end
    return value
end

--- Converts number to boolean
---@param value number
---@return boolean
function NumberToBool(value)
    if (value == nil) then return false end
    if (value > 0) then return true end
    return false
end

--- Creates a copy of a table
---@param table table
---@return table
function CopyTable(table)
    local _table = {}
    if (table ~= nil) then
        for i,v in pairs(table) do
            _table[i] = v
        end
    end
    return _table
end

--- Merges two tables
---@param table1 table
---@param table2 table
---@return table | nil
function MergeTables(table1, table2)
    if (table1 ~= nil and table2 ~= nil) then
        local _table1 = CopyTable(table1)
        for i,v in pairs(table2) do
            _table1[i] = v
        end
        return _table1
    end
    return nil
end

--- Clamp a number between a minimum and maximum number
---@param x number
---@param min number
---@param max number
---@return number
function math.clamp(x, min, max)
    if (x < min) then
        return min
    elseif (x > max) then
        return max
    end
    return x
end

--- Rounds a number, optionally to a given number of decimals
---@param x number
---@param decimals integer
---@return number
function math.round(x, decimals)
    if (decimals < 0) then decimals = 0 end
    decimals = 10 ^ decimals
    return math.floor((x * decimals) + 0.5) / decimals
end

--- Truncates a number at the given number of decimals
---@param x number
---@param decimals integer
---@return number
function math.truncate(x, decimals)
    if (decimals < 1) then decimals = 1 end
    decimals = 10 ^ decimals
    return math.floor((x * decimals)) / decimals
end

function math.map(x, from_min, from_max, to_min, to_max)
    local min_span = from_max - from_min -- 4
    local max_span = to_max - to_min -- 3.2

    if (x == 0) then x = 0.00001 end
    local scale = (x - from_min) / (min_span)
    return to_min + (max_span * scale)
end