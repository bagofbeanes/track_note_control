require "util"
require "note.setup"

---------------------------------------------------------------------/
-- NOTE FUNCTIONS --                                                |
---------------------------------------------------------------------\

--- Gets a note group and initializes it if needed
---@param group integer -- Note group to get
---@return NoteGroupController
local function GetNoteGroup(group)
    if (NoteGroups[group] == nil) then -- If NoteGroups table doesn't have the requested TG stored, add it and set it up
        NoteGroups[group] = Scene.getNoteGroup(group)

        local tg = NoteGroups[group]
        tg.translationX = SetDefault(0)
        tg.translationY = SetDefault(0)
        tg.translationZ = SetDefault(0)

        tg.rotationX = SetDefault(0)
        tg.rotationY = SetDefault(0)
        tg.rotationZ = SetDefault(0)

        tg.scaleX = SetDefault(1)
        tg.scaleY = SetDefault(1)
        tg.scaleIndividualX = SetDefault(1)
        tg.scaleIndividualY = SetDefault(1)

        tg.judgeOffsetX = SetDefault(0)
        tg.judgeOffsetY = SetDefault(0)
        tg.judgeOffsetZ = SetDefault(0)

        tg.judgeSizeX = SetDefault(1)
        tg.judgeSizeY = SetDefault(1)

        tg.colorR = SetDefault(255)
        tg.colorG = SetDefault(255)
        tg.colorB = SetDefault(255)
        tg.colorA = SetDefault(255)
    end
    return NoteGroups[group]
end

-----------------------------

---------------------------------------------------------------------/
-- NOTE SCALE --                                                    |
---------------------------------------------------------------------\

---@class noteScaleOptions
---@field easing ('linear' | 'l' | 'inconstant' | 'inconst' | 'cnsti' | 'outconstant' | 'outconst' | 'cnsto' | 'inoutconstant' | 'inoutconst' | 'cnstb' | 'insine' | 'si' | 'outsine' | 'so' | 'inoutsine' | 'b' | 'inquadratic' | 'inquad' | '2i' | 'outquadratic' | 'outquad' | '2o' | 'inoutquadratic' | 'inoutquad' | '2b' | 'incubic' | '3i' | 'outcubic' | 'outcube' | '3o' | 'inoutcubic' | 'inoutcube' | '3b' | 'inquartic' | 'inquart' | '4i' | 'outquartic' | 'outquart' | '4o' | 'inoutquartic' | 'inoutquart' | '4b' | 'inquintic' | 'inquint' | '5i' | 'outquintic' | 'outquint' | '5o' | 'inoutquintic' | 'inoutquint' | '5b' | 'inexponential' | 'inexpo' | 'exi' | 'outexponential' | 'outexpo' | 'exo' | 'inoutexponential' | 'inoutexpo' | 'exb' | 'incircle' | 'incirc' | 'ci' | 'outcircle' | 'outcirc' | 'co' | 'inoutcircle' | 'inoutcirc' | 'cb' | 'inback' | 'bki' | 'outback' | 'bko' | 'inoutback' | 'bkb' | 'inelastic' | 'eli' | 'outelastic' | 'elo' | 'inoutelastic' | 'elb' | 'inbounce' | 'bni' | 'outbounce' | 'bno' | 'inoutbounce' | 'bnb')
local noteScaleOptionsDefault = 
{
    easing = 'l'
}

---Scales notes as a whole in a note group. Doesn't affect judgeSize.   
---TIP: Use values below 0 to not affect an axis (e.g. xy(2,-1) will scale on the x axis, but won't affect the y)
---@param group integer -- Note group to scale
---@param scale_xy XY
---@param start_time integer
---@param end_time integer
---@param options noteScaleOptions -- Scaling options -> { easing }
function Note_Scale(group, scale_xy, start_time, end_time, options)

    local x = scale_xy.x
    local y = scale_xy.y

    -- options --
    options = MergeTables(noteScaleOptionsDefault, options) or noteScaleOptionsDefault
    local easing = options.easing
    -------------

    local tg = GetNoteGroup(group)

    if (x ~= 0) then
        KeyTween(tg.scaleX, start_time, end_time, x, false, easing)
    end
    if (y ~= 0) then
        KeyTween(tg.scaleY, start_time, end_time, y, false, easing)
    end
end

---@class noteScaleIndividualOptions
---@field judge_xy XY -- Whether or not to translate note judgement for each axis
---@field easing ('linear' | 'l' | 'inconstant' | 'inconst' | 'cnsti' | 'outconstant' | 'outconst' | 'cnsto' | 'inoutconstant' | 'inoutconst' | 'cnstb' | 'insine' | 'si' | 'outsine' | 'so' | 'inoutsine' | 'b' | 'inquadratic' | 'inquad' | '2i' | 'outquadratic' | 'outquad' | '2o' | 'inoutquadratic' | 'inoutquad' | '2b' | 'incubic' | '3i' | 'outcubic' | 'outcube' | '3o' | 'inoutcubic' | 'inoutcube' | '3b' | 'inquartic' | 'inquart' | '4i' | 'outquartic' | 'outquart' | '4o' | 'inoutquartic' | 'inoutquart' | '4b' | 'inquintic' | 'inquint' | '5i' | 'outquintic' | 'outquint' | '5o' | 'inoutquintic' | 'inoutquint' | '5b' | 'inexponential' | 'inexpo' | 'exi' | 'outexponential' | 'outexpo' | 'exo' | 'inoutexponential' | 'inoutexpo' | 'exb' | 'incircle' | 'incirc' | 'ci' | 'outcircle' | 'outcirc' | 'co' | 'inoutcircle' | 'inoutcirc' | 'cb' | 'inback' | 'bki' | 'outback' | 'bko' | 'inoutback' | 'bkb' | 'inelastic' | 'eli' | 'outelastic' | 'elo' | 'inoutelastic' | 'elb' | 'inbounce' | 'bni' | 'outbounce' | 'bno' | 'inoutbounce' | 'bnb')
local noteScaleIndividualOptionsDefault = 
{
    judge_xy = xy(0,0),
    easing = 'l'
}

---Individually scales notes in a note group.   
---TIP: Use values below 0 to not affect an axis (e.g. xy(2,-1) will scale on the x axis, but won't affect the y)
---@param group integer -- Note group to scale
---@param scale_xy XY
---@param start_time integer
---@param end_time integer
---@param options noteScaleIndividualOptions -- Scaling options -> { judge_xy, easing }
function Note_ScaleInd(group, scale_xy, start_time, end_time, options)

    local x = scale_xy.x
    local y = scale_xy.y

    -- options --
    options = MergeTables(noteScaleIndividualOptionsDefault, options) or noteScaleIndividualOptionsDefault
    local easing = options.easing

    local judge_xy = options.judge_xy
    local judge_x = NumberToBool(judge_xy.x)
    local judge_y = NumberToBool(judge_xy.y)
    -------------

    local tg = GetNoteGroup(group)

    if (x >= 0) then
        KeyTween(tg.scaleIndividualX, start_time, end_time, x, false, easing)
        if (judge_x) then KeyTween(tg.judgeSizeX, start_time, end_time, x, false, easing) end
    end
    if (y >= 0) then
        KeyTween(tg.scaleIndividualY, start_time, end_time, y, false, easing)
        if (judge_y) then KeyTween(tg.judgeSizeY, start_time, end_time, y, false, easing) end
    end
end

---------------------------------------------------------------------/
-- NOTE TRANSLATE --                                                |
---------------------------------------------------------------------\

---@class noteTranslateOptions
---@field add_xyz XYZ -- Whether to add to the current value or set it for each axis (default is (0,0,0))
---@field judge_xyz XYZ -- Whether or not to translate note judgement for each axis
---@field easing ('linear' | 'l' | 'inconstant' | 'inconst' | 'cnsti' | 'outconstant' | 'outconst' | 'cnsto' | 'inoutconstant' | 'inoutconst' | 'cnstb' | 'insine' | 'si' | 'outsine' | 'so' | 'inoutsine' | 'b' | 'inquadratic' | 'inquad' | '2i' | 'outquadratic' | 'outquad' | '2o' | 'inoutquadratic' | 'inoutquad' | '2b' | 'incubic' | '3i' | 'outcubic' | 'outcube' | '3o' | 'inoutcubic' | 'inoutcube' | '3b' | 'inquartic' | 'inquart' | '4i' | 'outquartic' | 'outquart' | '4o' | 'inoutquartic' | 'inoutquart' | '4b' | 'inquintic' | 'inquint' | '5i' | 'outquintic' | 'outquint' | '5o' | 'inoutquintic' | 'inoutquint' | '5b' | 'inexponential' | 'inexpo' | 'exi' | 'outexponential' | 'outexpo' | 'exo' | 'inoutexponential' | 'inoutexpo' | 'exb' | 'incircle' | 'incirc' | 'ci' | 'outcircle' | 'outcirc' | 'co' | 'inoutcircle' | 'inoutcirc' | 'cb' | 'inback' | 'bki' | 'outback' | 'bko' | 'inoutback' | 'bkb' | 'inelastic' | 'eli' | 'outelastic' | 'elo' | 'inoutelastic' | 'elb' | 'inbounce' | 'bni' | 'outbounce' | 'bno' | 'inoutbounce' | 'bnb')
local noteTranslateOptionsDefault = 
{
    add_xyz = xyz(0,0,0),
    judge_xyz = xyz(0,0,0),
    easing = 'l'
}

---Translates notes in a note group.
---@param group integer -- Note group to translate
---@param translation_xyz XYZ
---@param start_time integer
---@param end_time integer
---@param options noteTranslateOptions -- Translation options -> { add_xyz, judge_xyz, easing }
function Note_Translate(group, translation_xyz, start_time, end_time, options)

    local x = translation_xyz.x
    local y = translation_xyz.y
    local z = translation_xyz.z

    -- options --
    options = MergeTables(noteTranslateOptionsDefault, options) or noteTranslateOptionsDefault
    local easing = options.easing

    local add_xyz = options.add_xyz
    local add_x = NumberToBool(add_xyz.x)
    local add_y = NumberToBool(add_xyz.y)
    local add_z = NumberToBool(add_xyz.z)

    local judge_xyz = options.judge_xyz
    local judge_x = NumberToBool(judge_xyz.x)
    local judge_y = NumberToBool(judge_xyz.y)
    local judge_z = NumberToBool(judge_xyz.z)
    -------------

    local tg = GetNoteGroup(group)

    if (x ~= 0 or not add_x) then
        KeyTween(tg.translationX, start_time, end_time, x, add_x, easing)
        if (judge_x) then KeyTween(tg.judgeOffsetX, start_time, end_time, x, add_x, easing) end
    end

    if (y ~= 0 or not add_y) then
        KeyTween(tg.translationY, start_time, end_time, y, add_y, easing)
        if (judge_y) then KeyTween(tg.judgeOffsetY, start_time, end_time, y, add_y, easing) end
    end

    if (z ~= 0 or not add_z) then
        KeyTween(tg.translationZ, start_time, end_time, z, add_z, easing)
        if (judge_z) then KeyTween(tg.judgeOffsetZ, start_time, end_time, z, add_z, easing) end
    end
end

---------------------------------------------------------------------/
-- NOTE COLOR --                                                    |
---------------------------------------------------------------------\

---@class noteColorOptions
---@field add_rgba RGBA -- Whether or not to add to the current color value for each color channel (rgba(1,1,1,0) by default)
---@field easing ('linear' | 'l' | 'inconstant' | 'inconst' | 'cnsti' | 'outconstant' | 'outconst' | 'cnsto' | 'inoutconstant' | 'inoutconst' | 'cnstb' | 'insine' | 'si' | 'outsine' | 'so' | 'inoutsine' | 'b' | 'inquadratic' | 'inquad' | '2i' | 'outquadratic' | 'outquad' | '2o' | 'inoutquadratic' | 'inoutquad' | '2b' | 'incubic' | '3i' | 'outcubic' | 'outcube' | '3o' | 'inoutcubic' | 'inoutcube' | '3b' | 'inquartic' | 'inquart' | '4i' | 'outquartic' | 'outquart' | '4o' | 'inoutquartic' | 'inoutquart' | '4b' | 'inquintic' | 'inquint' | '5i' | 'outquintic' | 'outquint' | '5o' | 'inoutquintic' | 'inoutquint' | '5b' | 'inexponential' | 'inexpo' | 'exi' | 'outexponential' | 'outexpo' | 'exo' | 'inoutexponential' | 'inoutexpo' | 'exb' | 'incircle' | 'incirc' | 'ci' | 'outcircle' | 'outcirc' | 'co' | 'inoutcircle' | 'inoutcirc' | 'cb' | 'inback' | 'bki' | 'outback' | 'bko' | 'inoutback' | 'bkb' | 'inelastic' | 'eli' | 'outelastic' | 'elo' | 'inoutelastic' | 'elb' | 'inbounce' | 'bni' | 'outbounce' | 'bno' | 'inoutbounce' | 'bnb')
local noteColorOptionsDefault = 
{
    add_rgba = rgba(1,1,1,0),
    easing = 'l'
}

---Change note group RGBA values. Adds to RGB and sets A by default
---@param group integer -- Note group to color
---@param color_rgba RGBA 
---@param start_time integer
---@param end_time integer
---@param easing ('linear' | 'l' | 'inconstant' | 'inconst' | 'cnsti' | 'outconstant' | 'outconst' | 'cnsto' | 'inoutconstant' | 'inoutconst' | 'cnstb' | 'insine' | 'si' | 'outsine' | 'so' | 'inoutsine' | 'b' | 'inquadratic' | 'inquad' | '2i' | 'outquadratic' | 'outquad' | '2o' | 'inoutquadratic' | 'inoutquad' | '2b' | 'incubic' | '3i' | 'outcubic' | 'outcube' | '3o' | 'inoutcubic' | 'inoutcube' | '3b' | 'inquartic' | 'inquart' | '4i' | 'outquartic' | 'outquart' | '4o' | 'inoutquartic' | 'inoutquart' | '4b' | 'inquintic' | 'inquint' | '5i' | 'outquintic' | 'outquint' | '5o' | 'inoutquintic' | 'inoutquint' | '5b' | 'inexponential' | 'inexpo' | 'exi' | 'outexponential' | 'outexpo' | 'exo' | 'inoutexponential' | 'inoutexpo' | 'exb' | 'incircle' | 'incirc' | 'ci' | 'outcircle' | 'outcirc' | 'co' | 'inoutcircle' | 'inoutcirc' | 'cb' | 'inback' | 'bki' | 'outback' | 'bko' | 'inoutback' | 'bkb' | 'inelastic' | 'eli' | 'outelastic' | 'elo' | 'inoutelastic' | 'elb' | 'inbounce' | 'bni' | 'outbounce' | 'bno' | 'inoutbounce' | 'bnb')
---@param options noteColorOptions -- Coloring options -> { add_rgba, easing }
function Note_Color(group, color_rgba, start_time, end_time, options)

    local r = color_rgba.r
    local g = color_rgba.g
    local b = color_rgba.b
    local a = color_rgba.a

    -- options --
    options = MergeTables(noteColorOptionsDefault, options) or noteColorOptionsDefault
    local easing = options.easing

    local add_rgba = options.add_rgba
    local add_r = NumberToBool(add_rgba.r)
    local add_g = NumberToBool(add_rgba.g)
    local add_b = NumberToBool(add_rgba.b)
    local add_a = NumberToBool(add_rgba.a)
    -------------

    local tg = GetNoteGroup(group)

    if (r > 0 or not add_r) then
        KeyTween(tg.colorR, start_time, end_time, r, add_r, easing)
    end
    if (g > 0 or not add_g) then
        KeyTween(tg.colorG, start_time, end_time, g, add_g, easing)
    end
    if (b > 0 or not add_b) then
        KeyTween(tg.colorB, start_time, end_time, b, add_b, easing)
    end
    if (a > 0 or not add_a) then
        KeyTween(tg.colorA, start_time, end_time, a, add_a, easing)
    end
end

---------------------------------------------------------------------/
-- NOTE ROTATE --                                                    |
---------------------------------------------------------------------\

---@class noteRotateOptions
---@field add_xyz XYZ -- Whether or not to add to the current value or set it for each axis (xyz(0,0,0) by default)
---@field easing ('linear' | 'l' | 'inconstant' | 'inconst' | 'cnsti' | 'outconstant' | 'outconst' | 'cnsto' | 'inoutconstant' | 'inoutconst' | 'cnstb' | 'insine' | 'si' | 'outsine' | 'so' | 'inoutsine' | 'b' | 'inquadratic' | 'inquad' | '2i' | 'outquadratic' | 'outquad' | '2o' | 'inoutquadratic' | 'inoutquad' | '2b' | 'incubic' | '3i' | 'outcubic' | 'outcube' | '3o' | 'inoutcubic' | 'inoutcube' | '3b' | 'inquartic' | 'inquart' | '4i' | 'outquartic' | 'outquart' | '4o' | 'inoutquartic' | 'inoutquart' | '4b' | 'inquintic' | 'inquint' | '5i' | 'outquintic' | 'outquint' | '5o' | 'inoutquintic' | 'inoutquint' | '5b' | 'inexponential' | 'inexpo' | 'exi' | 'outexponential' | 'outexpo' | 'exo' | 'inoutexponential' | 'inoutexpo' | 'exb' | 'incircle' | 'incirc' | 'ci' | 'outcircle' | 'outcirc' | 'co' | 'inoutcircle' | 'inoutcirc' | 'cb' | 'inback' | 'bki' | 'outback' | 'bko' | 'inoutback' | 'bkb' | 'inelastic' | 'eli' | 'outelastic' | 'elo' | 'inoutelastic' | 'elb' | 'inbounce' | 'bni' | 'outbounce' | 'bno' | 'inoutbounce' | 'bnb')
local noteRotateOptionsDefault = 
{
    add_xyz = xyz(0,0,0),
    easing = 'l'
}

function Note_Rotate(group, rotation_xyz, start_time, end_time, options)

    local x = rotation_xyz.x
    local y = rotation_xyz.y
    local z = rotation_xyz.z

    -- options --
    options = MergeTables(noteTranslateOptionsDefault, options) or noteTranslateOptionsDefault
    local easing = options.easing

    local add_xyz = options.add_xyz
    local add_x = NumberToBool(add_xyz.x)
    local add_y = NumberToBool(add_xyz.y)
    local add_z = NumberToBool(add_xyz.z)
    ---
    
    local tg = GetNoteGroup(group)
    
    if (x ~= 0 or not add_x) then
        KeyTween(tg.rotationX, start_time, end_time, x, add_x, easing)
    end
    if (y ~= 0 or not add_y) then
        KeyTween(tg.rotationY, start_time, end_time, y, add_y, easing)
    end
    if (z ~= 0 or not add_z) then
        KeyTween(tg.rotationZ, start_time, end_time, z, add_z, easing)
    end
end