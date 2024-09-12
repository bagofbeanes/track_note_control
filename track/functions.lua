require "util"

---------------------------------------------------------------------/
-- TRACK FUNCTIONS --                                               |
---------------------------------------------------------------------\

-- defaults
local beatlinesScaleX_Default = Beatlines.scaleX.valueAt(DEFAULT_TIME)
local lineScaleX_Default = Track.divideLine23.scaleX.valueAt(DEFAULT_TIME) * Track.scaleX.valueAt(DEFAULT_TIME)

local beatlinesScaleX_OneLane = beatlinesScaleX_Default / LANE_COUNT_DEFAULT
--

---------------------------------------------------------------------/
-- TRACK SCALE --                                                   |
---------------------------------------------------------------------\

---@class trackScaleOptions
---@field easing ('linear' | 'l' | 'inconstant' | 'inconst' | 'cnsti' | 'outconstant' | 'outconst' | 'cnsto' | 'inoutconstant' | 'inoutconst' | 'cnstb' | 'insine' | 'si' | 'outsine' | 'so' | 'inoutsine' | 'b' | 'inquadratic' | 'inquad' | '2i' | 'outquadratic' | 'outquad' | '2o' | 'inoutquadratic' | 'inoutquad' | '2b' | 'incubic' | '3i' | 'outcubic' | 'outcube' | '3o' | 'inoutcubic' | 'inoutcube' | '3b' | 'inquartic' | 'inquart' | '4i' | 'outquartic' | 'outquart' | '4o' | 'inoutquartic' | 'inoutquart' | '4b' | 'inquintic' | 'inquint' | '5i' | 'outquintic' | 'outquint' | '5o' | 'inoutquintic' | 'inoutquint' | '5b' | 'inexponential' | 'inexpo' | 'exi' | 'outexponential' | 'outexpo' | 'exo' | 'inoutexponential' | 'inoutexpo' | 'exb' | 'incircle' | 'incirc' | 'ci' | 'outcircle' | 'outcirc' | 'co' | 'inoutcircle' | 'inoutcirc' | 'cb' | 'inback' | 'bki' | 'outback' | 'bko' | 'inoutback' | 'bkb' | 'inelastic' | 'eli' | 'outelastic' | 'elo' | 'inoutelastic' | 'elb' | 'inbounce' | 'bni' | 'outbounce' | 'bno' | 'inoutbounce' | 'bnb')
local trackScaleOptions_Default = 
{
    easing = 'l'
}

---Scales the track by lane count  
---NOTE: Scaling origin point is at the center of the track - use in conjunction with TrackTranslate to give the effect of a different origin point
---@param lane_count number
---@param start_time integer
---@param end_time integer
---@param options trackScaleOptions -- Scaling options -> { easing }
function Track_Scale(lane_count, start_time, end_time, options)

    -- options --
    options = MergeTables(trackScaleOptions_Default, options) or trackScaleOptions_Default
    local easing = options.easing
    -------------

    lane_count = math.clamp(lane_count, 0.00001, MAX_LANE_COUNT)

    -- scale track and beatlines --
    local track_width = 0.446285 * lane_count -- USING THIS VERY SPECIFIC VALUE INSTEAD OF TRACKSCALEX_ONELANE BECAUSE THIS DOESNT CAUSE IT TO OVERHANG DONT ASK HOW OR WHY
    local beatlines_width = beatlinesScaleX_OneLane * lane_count

    KeyTween(Track.scaleX, start_time, end_time, track_width, false, easing)
    KeyTween(Beatlines.scaleX, start_time, end_time, beatlines_width, false, easing)

    -- updates lane count keychannel --
    KeyTween(TRACK_SCALE_LANES, start_time, end_time, lane_count, false, easing)
    
    -- offsets edges so they're always at the edge of the track --
    local edge_size = (36 / 512) * LANE_WIDTH

    local track_pos = Track.translationX.valueAt(end_time)
    local edgeL_offset = (track_pos + edge_size + (lane_count / 2) * LANE_WIDTH) - Edge_Canvas.translationX.valueAt(end_time)
    local edgeR_offset = (track_pos - edge_size - (lane_count / 2) * LANE_WIDTH) - Edge_Canvas.translationX.valueAt(end_time)

    KeyTween(Track_EdgeL.translationX, start_time, end_time, edgeL_offset, false, easing)
    KeyTween(Track_EdgeR.translationX, start_time, end_time, edgeR_offset, false, easing)

    local line_count = (lane_count / 2) - 1 -- amount of lines on one half of the track
    local line_count_ceil = math.ceil(line_count)


    -- control all divide lines except middle --
    for i = 1, LANES_LAST do

        if (i ~= LANES_MIDDLE) then -- applies to everything except the middle line for obvious reasons

            if (i <= line_count_ceil or i >= 1 + (LANES_LAST - line_count_ceil)) then
                
                local side_mult = (i < LANES_MIDDLE and -1) or 1
                local distance_from_center = LANES_MIDDLE - line_count - 1

                local move_to = LANE_WIDTH * ((side_mult * distance_from_center) + (LANES_MIDDLE - i)) -- controls where each line needs to go
                
                Divide_Lines[i].active.addKey(start_time, 1, 'inconst')
                KeyTween(Divide_Lines[i].translationX, start_time, end_time, move_to, false, easing)
                KeyTween(Divide_Lines[i].scaleX, start_time, end_time, lineScaleX_Default, false, easing)

            elseif (Divide_Lines[i].translationX.valueAt(start_time) ~= 0) then -- move every other line that's not in the middle to the middle
                KeyTween(Divide_Lines[i].translationX, start_time, end_time, 0, false, easing)
                KeyTween(Divide_Lines[i].scaleX, start_time, end_time, 0, false, easing)
            end
        end
    end

    --------------------------

    -- control middle divide line --

    -- if lane count is even, show a line in the middle
    if (lane_count % 2 == 0 and lane_count ~= 0) then
        Divide_Lines[LANES_MIDDLE].active.addKey(start_time, 1, 'inconst')
        KeyTween(Divide_Lines[LANES_MIDDLE].scaleX, start_time, end_time, 1, false, easing)
    
    -- if not even or lane count is 0, make the line disappear
    else
        Divide_Lines[LANES_MIDDLE].active.addKey(end_time, 0, 'inconst')
        KeyTween(Divide_Lines[LANES_MIDDLE].scaleX, start_time, end_time, 0, false, easing)
    end

    --------------------------

end


---------------------------------------------------------------------/
-- TRACK TRANSLATE --                                               |
---------------------------------------------------------------------\

---@class trackTranslateOptions
---@field add_xyz XYZ -- Whether to add to the current value or set it for each axis (default is (0,0,0) - sets values on all axes by default)
---@field easing ('linear' | 'l' | 'inconstant' | 'inconst' | 'cnsti' | 'outconstant' | 'outconst' | 'cnsto' | 'inoutconstant' | 'inoutconst' | 'cnstb' | 'insine' | 'si' | 'outsine' | 'so' | 'inoutsine' | 'b' | 'inquadratic' | 'inquad' | '2i' | 'outquadratic' | 'outquad' | '2o' | 'inoutquadratic' | 'inoutquad' | '2b' | 'incubic' | '3i' | 'outcubic' | 'outcube' | '3o' | 'inoutcubic' | 'inoutcube' | '3b' | 'inquartic' | 'inquart' | '4i' | 'outquartic' | 'outquart' | '4o' | 'inoutquartic' | 'inoutquart' | '4b' | 'inquintic' | 'inquint' | '5i' | 'outquintic' | 'outquint' | '5o' | 'inoutquintic' | 'inoutquint' | '5b' | 'inexponential' | 'inexpo' | 'exi' | 'outexponential' | 'outexpo' | 'exo' | 'inoutexponential' | 'inoutexpo' | 'exb' | 'incircle' | 'incirc' | 'ci' | 'outcircle' | 'outcirc' | 'co' | 'inoutcircle' | 'inoutcirc' | 'cb' | 'inback' | 'bki' | 'outback' | 'bko' | 'inoutback' | 'bkb' | 'inelastic' | 'eli' | 'outelastic' | 'elo' | 'inoutelastic' | 'elb' | 'inbounce' | 'bni' | 'outbounce' | 'bno' | 'inoutbounce' | 'bnb')
local trackTranslateOptions_Default =
{
    add_xyz = xyz(0,0,0),
    easing = 'l'
}

---Translates the track     
---TIP: Use LANE_WIDTH * X to translate by lane count (where X is the number of lanes to translate by)   
---TIP: LEFT = POSITIVE; RIGHT = NEGATIVE
---@param translation_xyz XYZ
---@param start_time integer
---@param end_time integer
---@param options trackTranslateOptions -- Translation options -> { add_xyz, easing }
function Track_Translate(translation_xyz, start_time, end_time, options)

    translation_xyz = translation_xyz or xyz(0,0,0)
    local x = translation_xyz.x
    local y = translation_xyz.y
    local z = translation_xyz.z

    -- options --
    options = MergeTables(trackTranslateOptions_Default, options) or trackTranslateOptions_Default
    local easing = options.easing

    local add_xyz = options.add_xyz
    local add_x = NumberToBool(add_xyz.x)
    local add_y = NumberToBool(add_xyz.y)
    local add_z = NumberToBool(add_xyz.z)
    --------------
    
    local track_z = (add_z and z) or (z + TRACK_TRANSLATIONZ) -- added to track z
    local track_xyz = xyz(x,y,track_z)
    
    local track_translate_references = { Track, Edge_Canvas, Divide_Canvas, Beatlines }
    local track_translate_xyz = { track_xyz, track_xyz, track_xyz, -translation_xyz }

    for i,v in pairs(track_translate_references) do
        if (x ~= 0 or not add_x) then
            KeyTween(v.translationX, start_time, end_time, track_translate_xyz[i].x, add_x, easing)
        end
        if (y ~= 0 or not add_y) then
            KeyTween(v.translationY, start_time, end_time, track_translate_xyz[i].y, add_y, easing)
        end
        if (z ~= 0 or not add_z) then
            KeyTween(v.translationZ, start_time, end_time, track_translate_xyz[i].z, add_z, easing)
        end
    end
end


---------------------------------------------------------------------/
-- TRACK COLOR --                                                   |
---------------------------------------------------------------------\

---@class trackColorModify
---@field track boolean
---@field edge_left boolean
---@field edge_right boolean
---@field divide_lines boolean
local trackColorModify_Default = {
    track = true,
    edge_left = true,
    edge_right = true,
    divide_lines = true
}
local trackColorModify_References = {
    track = { Track },
    edge_left = { Track_EdgeL },
    edge_right = { Track_EdgeR },
    divide_lines = Divide_Lines
}

---@class trackColorOptions
---@field add_rgba RGBA -- Whether or not to add to the current color value for each color channel (rgba(1,1,1,0) by default)
---@field easing ('linear' | 'l' | 'inconstant' | 'inconst' | 'cnsti' | 'outconstant' | 'outconst' | 'cnsto' | 'inoutconstant' | 'inoutconst' | 'cnstb' | 'insine' | 'si' | 'outsine' | 'so' | 'inoutsine' | 'b' | 'inquadratic' | 'inquad' | '2i' | 'outquadratic' | 'outquad' | '2o' | 'inoutquadratic' | 'inoutquad' | '2b' | 'incubic' | '3i' | 'outcubic' | 'outcube' | '3o' | 'inoutcubic' | 'inoutcube' | '3b' | 'inquartic' | 'inquart' | '4i' | 'outquartic' | 'outquart' | '4o' | 'inoutquartic' | 'inoutquart' | '4b' | 'inquintic' | 'inquint' | '5i' | 'outquintic' | 'outquint' | '5o' | 'inoutquintic' | 'inoutquint' | '5b' | 'inexponential' | 'inexpo' | 'exi' | 'outexponential' | 'outexpo' | 'exo' | 'inoutexponential' | 'inoutexpo' | 'exb' | 'incircle' | 'incirc' | 'ci' | 'outcircle' | 'outcirc' | 'co' | 'inoutcircle' | 'inoutcirc' | 'cb' | 'inback' | 'bki' | 'outback' | 'bko' | 'inoutback' | 'bkb' | 'inelastic' | 'eli' | 'outelastic' | 'elo' | 'inoutelastic' | 'elb' | 'inbounce' | 'bni' | 'outbounce' | 'bno' | 'inoutbounce' | 'bnb')
local trackColorOptions_Default = {
    modify = trackColorModify_Default,
    add_rgba = rgba(1,1,1,0),
    easing = 'l'
}

---Change track RGBA values. Adds to RGB and sets Alpha by default
---@param color_rgba RGBA 
---@param start_time integer
---@param end_time integer
---@param options trackColorOptions -- Coloring options -> { modify -> { track, edge_left, edge_right, divide_lines }, add_rgba, easing }
function Track_Color(color_rgba, start_time, end_time, options)

    color_rgba = color_rgba or rgba(0,0,0,255)
    local r = color_rgba.r
    local g = color_rgba.g
    local b = color_rgba.b
    local a = color_rgba.a

    -- options --
    options = MergeTables(trackColorOptions_Default, options) or trackColorOptions_Default
    local easing = options.easing

    local add_rgba = options.add_rgba
    local add_r = NumberToBool(add_rgba.r)
    local add_g = NumberToBool(add_rgba.g)
    local add_b = NumberToBool(add_rgba.b)
    local add_a = NumberToBool(add_rgba.a)

    local modify = MergeTables(trackColorModify_Default, options.modify) or trackColorModify_Default
    -------------

    for i,v in pairs(trackColorModify_References) do
        if (modify[i] == true) then
            for i_, v_ in ipairs(v) do
                if (r > 0 or not add_r) then
                    KeyTween(v_.colorR, start_time, end_time, r, add_r, easing)
                end
                if (g > 0 or not add_g) then
                    KeyTween(v_.colorG, start_time, end_time, g, add_g, easing)
                end
                if (b > 0 or not add_b) then
                    KeyTween(v_.colorB, start_time, end_time, b, add_b, easing)
                end
                if (a > 0 or not add_a) then
                    KeyTween(v_.colorA, start_time, end_time, a, add_a, easing)
                end
            end
        end
    end
end



---------------------------------------------------------------------/
-- INPUT LINE SCALE --                                              |
---------------------------------------------------------------------\

---@class inputLineScaleModify
---@field sky_input boolean
---@field critical_line boolean
local inputLineScaleModify_Default =
{
    critical_line = false,
    sky_input_line = false,
    sky_input_label = false
}
local inputLineScaleModify_References =
{
    critical_line = Critical_Line,
    sky_input_line = SkyInputLine,
    sky_input_label = SkyInputLabel
}

---@class inputLineScaleOptions
---@field easing ('linear' | 'l' | 'inconstant' | 'inconst' | 'cnsti' | 'outconstant' | 'outconst' | 'cnsto' | 'inoutconstant' | 'inoutconst' | 'cnstb' | 'insine' | 'si' | 'outsine' | 'so' | 'inoutsine' | 'b' | 'inquadratic' | 'inquad' | '2i' | 'outquadratic' | 'outquad' | '2o' | 'inoutquadratic' | 'inoutquad' | '2b' | 'incubic' | '3i' | 'outcubic' | 'outcube' | '3o' | 'inoutcubic' | 'inoutcube' | '3b' | 'inquartic' | 'inquart' | '4i' | 'outquartic' | 'outquart' | '4o' | 'inoutquartic' | 'inoutquart' | '4b' | 'inquintic' | 'inquint' | '5i' | 'outquintic' | 'outquint' | '5o' | 'inoutquintic' | 'inoutquint' | '5b' | 'inexponential' | 'inexpo' | 'exi' | 'outexponential' | 'outexpo' | 'exo' | 'inoutexponential' | 'inoutexpo' | 'exb' | 'incircle' | 'incirc' | 'ci' | 'outcircle' | 'outcirc' | 'co' | 'inoutcircle' | 'inoutcirc' | 'cb' | 'inback' | 'bki' | 'outback' | 'bko' | 'inoutback' | 'bkb' | 'inelastic' | 'eli' | 'outelastic' | 'elo' | 'inoutelastic' | 'elb' | 'inbounce' | 'bni' | 'outbounce' | 'bno' | 'inoutbounce' | 'bnb')
local inputLineScaleOptions_Default =
{
    modify = inputLineScaleModify_Default,
    easing = 'l'
}

---Scales the track input lines (critical line and/or sky input line)   
---NOTE: Critical line already scales along with the track. It's included here just for extra control over it   
---TIP: Use values below 0 to not affect an axis (e.g. xy(2,-1) will scale on the x axis, but won't affect the y)
---@param scale_xy XY
---@param start_time integer
---@param end_time integer
---@param options inputLineScaleOptions -- Translation options -> { modify -> { critical_line, sky_input_line, sky_input_label }, add_xy, easing }
function InputLine_Scale(scale_xy, start_time, end_time, options)

    scale_xy = scale_xy or xy(0,0)
    local x = scale_xy.x
    local y = scale_xy.y

    -- options --
    options = MergeTables(inputLineScaleOptions_Default, options) or inputLineScaleOptions_Default
    local easing = options.easing

    local modify = MergeTables(inputLineScaleModify_Default, options.modify) or inputLineScaleModify_Default

    local inputLineScaleOptions_XY =
    {
        critical_line = xy(x * Critical_Line.scaleX.valueAt(DEFAULT_TIME), y * Critical_Line.scaleY.valueAt(DEFAULT_TIME)),
        sky_input_line = xy(x * SkyInputLine.scaleX.valueAt(DEFAULT_TIME), y * SkyInputLine.scaleY.valueAt(DEFAULT_TIME)),
        sky_input_label = xy(x * SkyInputLabel.scaleX.valueAt(DEFAULT_TIME), y * SkyInputLabel.scaleY.valueAt(DEFAULT_TIME))
    }
    -------------

    for i,v in pairs(inputLineScaleModify_References) do
        if (modify[i] == true) then
            if (x >= 0) then
                KeyTween(v.scaleX, start_time, end_time, inputLineScaleOptions_XY[i].x, false, easing)
            end
            if (y >= 0) then
                KeyTween(v.scaleY, start_time, end_time, inputLineScaleOptions_XY[i].y, false, easing)
            end
        end
    end
end


---------------------------------------------------------------------/
-- INPUT LINE TRANSLATE --                                          |
---------------------------------------------------------------------\

---@class inputLineTranslateModify
---@field sky_input boolean
---@field critical_line boolean
local inputLineTranslateModify_Default =
{
    critical_line = false,
    sky_input_line = false,
    sky_input_label = false
}
local inputLineTranslateModify_References =
{
    critical_line = Critical_Line,
    sky_input_line = SkyInputLine,
    sky_input_label = SkyInputLabel
}

---@class inputLineTranslateOptions
---@field add_xyz XYZ -- Whether to add to the current value or set it for each axis (default is (0,0,0) - sets values on all axes by default)
---@field easing ('linear' | 'l' | 'inconstant' | 'inconst' | 'cnsti' | 'outconstant' | 'outconst' | 'cnsto' | 'inoutconstant' | 'inoutconst' | 'cnstb' | 'insine' | 'si' | 'outsine' | 'so' | 'inoutsine' | 'b' | 'inquadratic' | 'inquad' | '2i' | 'outquadratic' | 'outquad' | '2o' | 'inoutquadratic' | 'inoutquad' | '2b' | 'incubic' | '3i' | 'outcubic' | 'outcube' | '3o' | 'inoutcubic' | 'inoutcube' | '3b' | 'inquartic' | 'inquart' | '4i' | 'outquartic' | 'outquart' | '4o' | 'inoutquartic' | 'inoutquart' | '4b' | 'inquintic' | 'inquint' | '5i' | 'outquintic' | 'outquint' | '5o' | 'inoutquintic' | 'inoutquint' | '5b' | 'inexponential' | 'inexpo' | 'exi' | 'outexponential' | 'outexpo' | 'exo' | 'inoutexponential' | 'inoutexpo' | 'exb' | 'incircle' | 'incirc' | 'ci' | 'outcircle' | 'outcirc' | 'co' | 'inoutcircle' | 'inoutcirc' | 'cb' | 'inback' | 'bki' | 'outback' | 'bko' | 'inoutback' | 'bkb' | 'inelastic' | 'eli' | 'outelastic' | 'elo' | 'inoutelastic' | 'elb' | 'inbounce' | 'bni' | 'outbounce' | 'bno' | 'inoutbounce' | 'bnb')
local inputLineTranslateOptions_Default =
{
    modify = inputLineTranslateModify_Default,
    add_xyz = xyz(0,0,0),
    easing = 'l'
}

---Translates the track input lines (critical line and/or sky input line)   
---NOTE: Critical line already moves along with the track. It's included here just for extra control over it    
---NOTE: Translating sky_input_line doesn't change its boundary. Use SkyInput_Translate() for that  
---TIP: LEFT = POSITIVE; RIGHT = NEGATIVE
---@param translation_xyz XYZ
---@param start_time integer
---@param end_time integer
---@param options inputLineTranslateOptions -- Translation options -> { modify -> { critical_line, sky_input_line, sky_input_label }, add_xy, easing }
function InputLine_Translate(translation_xyz, start_time, end_time, options)

    translation_xyz = translation_xyz or xyz(0,0,0)
    local x = translation_xyz.x
    local y = translation_xyz.y
    local z = translation_xyz.z

    -- options --
    options = MergeTables(inputLineTranslateOptions_Default, options) or inputLineTranslateOptions_Default
    local easing = options.easing

    local add_xyz = options.add_xyz
    local add_x = NumberToBool(add_xyz.x)
    local add_y = NumberToBool(add_xyz.y)
    local add_z = NumberToBool(add_xyz.z)

    local skyinputlabel_translation_y = SkyInputLabel.translationY.valueAt(DEFAULT_TIME)
    --
    local skylabel_x = (add_x and x) or (x - 7.1) -- added to sky input label x
    local skylabel_y = (add_y and y) or (y + skyinputlabel_translation_y) -- added to sky input label y

    local skyinput_y = (add_y and y) or (y + SKYINPUTLINE_TRANSLATIONY) -- added to sky input line y

    local critical_y = (add_y and y) or (y + CRITICALLINE_TRANSLATIONY) -- added to critical line y
    --
    
    local inputLineTranslateOptions_XYZ =
    {
        critical_line = xyz(x, critical_y, z),
        sky_input_line = xyz(x,skyinput_y, z),
        sky_input_label = xyz(skylabel_x, skylabel_y, z)
    }
    -------------

    local modify = MergeTables(inputLineTranslateModify_Default, options.modify) or inputLineTranslateModify_Default

    for i,v in pairs(inputLineTranslateModify_References) do
        if (modify[i] == true) then
            if (x ~= 0 or not add_x) then
                KeyTween(v.translationX, start_time, end_time, inputLineTranslateOptions_XYZ[i].x, add_x, easing)
            end
            if (y ~= 0 or not add_y) then
                KeyTween(v.translationY, start_time, end_time, inputLineTranslateOptions_XYZ[i].y, add_y, easing)
            end
            if (z ~= 0 or not add_z) then
                KeyTween(v.translationZ, start_time, end_time, inputLineTranslateOptions_XYZ[i].z, add_z, easing)
            end
        end
    end
end

---------------------------------------------------------------------/
-- INPUT LINE COLOR --                                              |
---------------------------------------------------------------------\

---@class inputLineColorModify
---@field critical_line boolean
---@field sky_input_line boolean
---@field sky_input_label boolean
local inputLineColorModify_Default = {
    critical_line = false,
    sky_input_line = false,
    sky_input_label = false
}
local inputLineColorModify_References = {
    critical_line = Critical_Line,
    sky_input_line = SkyInputLine,
    sky_input_label = SkyInputLabel
}

---@class inputLineColorOptions
---@field add_rgba RGBA -- Whether or not to add to the current color value for each color channel (rgba(1,1,1,0) by default)
---@field easing ('linear' | 'l' | 'inconstant' | 'inconst' | 'cnsti' | 'outconstant' | 'outconst' | 'cnsto' | 'inoutconstant' | 'inoutconst' | 'cnstb' | 'insine' | 'si' | 'outsine' | 'so' | 'inoutsine' | 'b' | 'inquadratic' | 'inquad' | '2i' | 'outquadratic' | 'outquad' | '2o' | 'inoutquadratic' | 'inoutquad' | '2b' | 'incubic' | '3i' | 'outcubic' | 'outcube' | '3o' | 'inoutcubic' | 'inoutcube' | '3b' | 'inquartic' | 'inquart' | '4i' | 'outquartic' | 'outquart' | '4o' | 'inoutquartic' | 'inoutquart' | '4b' | 'inquintic' | 'inquint' | '5i' | 'outquintic' | 'outquint' | '5o' | 'inoutquintic' | 'inoutquint' | '5b' | 'inexponential' | 'inexpo' | 'exi' | 'outexponential' | 'outexpo' | 'exo' | 'inoutexponential' | 'inoutexpo' | 'exb' | 'incircle' | 'incirc' | 'ci' | 'outcircle' | 'outcirc' | 'co' | 'inoutcircle' | 'inoutcirc' | 'cb' | 'inback' | 'bki' | 'outback' | 'bko' | 'inoutback' | 'bkb' | 'inelastic' | 'eli' | 'outelastic' | 'elo' | 'inoutelastic' | 'elb' | 'inbounce' | 'bni' | 'outbounce' | 'bno' | 'inoutbounce' | 'bnb')
local inputLineColorOptions_Default = {
    modify = inputLineColorModify_Default,
    add_rgba = rgba(1,1,1,0),
    easing = 'l'
}

---Change track line (critical line and/or sky input line) RGBA values. Adds to RGB and sets Alpha by default
---@param color_rgba RGBA 
---@param start_time integer
---@param end_time integer
---@param options inputLineColorOptions -- Coloring options -> { modify -> { critical_line, sky_input_line, sky_input_label }, add_rgba, easing }
function InputLine_Color(color_rgba, start_time, end_time, options)

    color_rgba = color_rgba or rgba(0,0,0,255)
    local r = color_rgba.r
    local g = color_rgba.g
    local b = color_rgba.b
    local a = color_rgba.a

    -- options --
    options = MergeTables(inputLineColorOptions_Default, options) or inputLineColorOptions_Default
    local easing = options.easing

    local add_rgba = options.add_rgba
    local add_r = NumberToBool(add_rgba.r)
    local add_g = NumberToBool(add_rgba.g)
    local add_b = NumberToBool(add_rgba.b)
    local add_a = NumberToBool(add_rgba.a)
    -------------

    local modify = MergeTables(inputLineColorModify_Default, options.modify) or inputLineColorModify_Default
    for i,v in pairs(inputLineColorModify_References) do
        if (modify[i] == true) then
            if (r > 0 or not add_r) then
                KeyTween(v.colorR, start_time, end_time, r, add_r, easing)
            end
            if (g > 0 or not add_g) then
                KeyTween(v.colorG, start_time, end_time, g, add_g, easing)
            end
            if (b > 0 or not add_b) then
                KeyTween(v.colorB, start_time, end_time, b, add_b, easing)
            end
            if (a > 0 or not add_a) then
                KeyTween(v.colorA, start_time, end_time, a, add_a, easing)
            end
        end
    end
end



---------------------------------------------------------------------/
-- FLOOR INPUT TRANSLATE --                                         |
---------------------------------------------------------------------\

---@class floorInputTranslateOptions
---@field easing ('linear' | 'l' | 'inconstant' | 'inconst' | 'cnsti' | 'outconstant' | 'outconst' | 'cnsto' | 'inoutconstant' | 'inoutconst' | 'cnstb' | 'insine' | 'si' | 'outsine' | 'so' | 'inoutsine' | 'b' | 'inquadratic' | 'inquad' | '2i' | 'outquadratic' | 'outquad' | '2o' | 'inoutquadratic' | 'inoutquad' | '2b' | 'incubic' | '3i' | 'outcubic' | 'outcube' | '3o' | 'inoutcubic' | 'inoutcube' | '3b' | 'inquartic' | 'inquart' | '4i' | 'outquartic' | 'outquart' | '4o' | 'inoutquartic' | 'inoutquart' | '4b' | 'inquintic' | 'inquint' | '5i' | 'outquintic' | 'outquint' | '5o' | 'inoutquintic' | 'inoutquint' | '5b' | 'inexponential' | 'inexpo' | 'exi' | 'outexponential' | 'outexpo' | 'exo' | 'inoutexponential' | 'inoutexpo' | 'exb' | 'incircle' | 'incirc' | 'ci' | 'outcircle' | 'outcirc' | 'co' | 'inoutcircle' | 'inoutcirc' | 'cb' | 'inback' | 'bki' | 'outback' | 'bko' | 'inoutback' | 'bkb' | 'inelastic' | 'eli' | 'outelastic' | 'elo' | 'inoutelastic' | 'elb' | 'inbounce' | 'bni' | 'outbounce' | 'bno' | 'inoutbounce' | 'bnb')
local floorInputTranslateOptions_Default =
{
    easing = 'l',
    add_lanefrom = 0,
    add_laneto = 0
}

---Translates the floor input boundaries (from lane/to lane, by default from lane 1 to lane 4)
---@param lanefrom integer -- left hand side boundary
---@param laneto integer -- right hand side boundary
---@param start_time integer
---@param end_time integer
---@param options floorInputTranslateOptions -- Translation options -> { easing }
function FloorInput_Translate(lanefrom, laneto, start_time, end_time, options)

    -- options --
    options = MergeTables(floorInputTranslateOptions_Default, options) or floorInputTranslateOptions_Default
    local easing = options.easing

    local add_lanefrom = NumberToBool(options.add_lanefrom)
    local add_laneto = NumberToBool(options.add_laneto)
    -------------

    KeyTween(Context.laneFrom, start_time, end_time, lanefrom, add_lanefrom, easing)
    KeyTween(Context.laneTo, start_time, end_time, laneto, add_laneto, easing)
end

---------------------------------------------------------------------/
-- SKY INPUT TRANSLATE --                                           |
---------------------------------------------------------------------\

---@class skyInputTranslateOptions
---@field easing ('linear' | 'l' | 'inconstant' | 'inconst' | 'cnsti' | 'outconstant' | 'outconst' | 'cnsto' | 'inoutconstant' | 'inoutconst' | 'cnstb' | 'insine' | 'si' | 'outsine' | 'so' | 'inoutsine' | 'b' | 'inquadratic' | 'inquad' | '2i' | 'outquadratic' | 'outquad' | '2o' | 'inoutquadratic' | 'inoutquad' | '2b' | 'incubic' | '3i' | 'outcubic' | 'outcube' | '3o' | 'inoutcubic' | 'inoutcube' | '3b' | 'inquartic' | 'inquart' | '4i' | 'outquartic' | 'outquart' | '4o' | 'inoutquartic' | 'inoutquart' | '4b' | 'inquintic' | 'inquint' | '5i' | 'outquintic' | 'outquint' | '5o' | 'inoutquintic' | 'inoutquint' | '5b' | 'inexponential' | 'inexpo' | 'exi' | 'outexponential' | 'outexpo' | 'exo' | 'inoutexponential' | 'inoutexpo' | 'exb' | 'incircle' | 'incirc' | 'ci' | 'outcircle' | 'outcirc' | 'co' | 'inoutcircle' | 'inoutcirc' | 'cb' | 'inback' | 'bki' | 'outback' | 'bko' | 'inoutback' | 'bkb' | 'inelastic' | 'eli' | 'outelastic' | 'elo' | 'inoutelastic' | 'elb' | 'inbounce' | 'bni' | 'outbounce' | 'bno' | 'inoutbounce' | 'bnb')
local skyInputTranslateOptions_Default =
{
    add_y = 0,
    easing = 'l'
}

---Translates the sky input boundary
---@param y number
---@param start_time integer
---@param end_time integer
---@param options skyInputTranslateOptions -- Translation options -> { easing }
function SkyInput_Translate(y, start_time, end_time, options)

    -- options --
    options = MergeTables(skyInputTranslateOptions_Default, options) or skyInputTranslateOptions_Default
    local easing = options.easing

    local add_y = NumberToBool(options.add_y)
    -------------

    local skyinput_y = (add_y and y) or (y + SKYINPUTLINE_TRANSLATIONY) -- added to sky input line y
    KeyTween(SkyInput.translationY, start_time, end_time, skyinput_y, add_y, easing)
end

-- Default settings
Track_Translate(xyz(0,0,0), DEFAULT_TIME, DEFAULT_TIME)
Track_Scale(LANE_COUNT_DEFAULT, DEFAULT_TIME, DEFAULT_TIME)
Track_Color(rgba(0,0,0,255), DEFAULT_TIME, DEFAULT_TIME)