require "util"

local CONSTANT_OFF = Channel.constant(0)
LANE_COUNT_DEFAULT = 4

---------------------------------------------------------------------/
-- INPUT SETUP --                                                   |
---------------------------------------------------------------------\
Context.laneFrom = SetDefault(1)
Context.laneTo = SetDefault(4)

---------------------------------------------------------------------/
-- TRACK SETUP --                                                   |
---------------------------------------------------------------------\
Track = Scene.track

Track.translationX = CopyDefaultOf(Track.translationX)
Track.translationY = CopyDefaultOf(Track.translationY)
Track.translationZ = CopyDefaultOf(Track.translationZ)

Track.scaleX = CopyDefaultOf(Track.scaleX)
Track.scaleY = CopyDefaultOf(Track.scaleY)
Track.textureScaleX = CopyDefaultOf(Track.textureScaleX)
Track.textureScaleY = CopyDefaultOf(Track.textureScaleY)
TRACK_SCALE_LANES = SetDefault(LANE_COUNT_DEFAULT)

Track.colorR = CopyDefaultOf(Track.colorR)
Track.colorG = CopyDefaultOf(Track.colorG)
Track.colorB = CopyDefaultOf(Track.colorB)
Track.colorA = CopyDefaultOf(Track.colorA)

---------------------------------------------------------------------/
-- SKY INPUT SETUP --                                               |
---------------------------------------------------------------------\

SkyInput = Scene.skyInputLine
SkyInputLine = SkyInput.copy()
SkyInputLabel = Scene.skyInputLabel

SkyInputLine.translationX = CopyDefaultOf(SkyInputLine.translationX)
SkyInputLine.translationY = CopyDefaultOf(SkyInputLine.translationY)
SkyInputLine.translationZ = CopyDefaultOf(SkyInputLine.translationZ)

SkyInputLine.scaleX = CopyDefaultOf(SkyInputLine.scaleX)
SkyInputLine.scaleY = CopyDefaultOf(SkyInputLine.scaleY)

SkyInputLine.colorR = CopyDefaultOf(SkyInputLine.colorR)
SkyInputLine.colorG = CopyDefaultOf(SkyInputLine.colorG)
SkyInputLine.colorB = CopyDefaultOf(SkyInputLine.colorB)
SkyInputLine.colorA = CopyDefaultOf(SkyInput.colorA)

SkyInputLabel.translationX = CopyDefaultOf(SkyInputLabel.translationX)
SkyInputLabel.translationY = CopyDefaultOf(SkyInputLabel.translationY)
SkyInputLabel.translationZ = CopyDefaultOf(SkyInputLabel.translationZ)

SkyInputLabel.scaleX = CopyDefaultOf(SkyInputLabel.scaleX)
SkyInputLabel.scaleY = CopyDefaultOf(SkyInputLabel.scaleY)

SkyInputLabel.colorR = CopyDefaultOf(SkyInputLabel.colorR)
SkyInputLabel.colorG = CopyDefaultOf(SkyInputLabel.colorG)
SkyInputLabel.colorB = CopyDefaultOf(SkyInputLabel.colorB)
SkyInputLabel.colorA = CopyDefaultOf(SkyInputLabel.colorA)

SkyInput.translationY = CopyDefaultOf(SkyInputLine.translationY)
SkyInput.translationZ = 9999999

---------------------------------------------------------------------/
-- TRACK CRITICAL LINE SETUP --                                     |
---------------------------------------------------------------------\
Critical_Line = Track.criticalLine2
Track.criticalLine1.active = CONSTANT_OFF
Track.criticalLine3.active = CONSTANT_OFF
Track.criticalLine4.active = CONSTANT_OFF

Critical_Line.sort = Track.sort.valueAt(DEFAULT_TIME) + 2 -- Above Track and Divide_Lines

Critical_Line.translationX = CopyDefaultOf(Track.translationX)
Critical_Line.translationY = CopyDefaultOf(Track.criticalLine2.translationY)
Critical_Line.translationZ = CopyDefaultOf(Track.criticalLine2.translationZ)

Critical_Line.scaleX = SetDefault(Critical_Line.scaleX.valueAt(DEFAULT_TIME) * 4 * 0.99615)
Critical_Line.scaleY = CopyDefaultOf(Track.criticalLine2.scaleY)

Critical_Line.colorR = CopyDefaultOf(Track.colorR)
Critical_Line.colorG = CopyDefaultOf(Track.colorG)
Critical_Line.colorB = CopyDefaultOf(Track.colorB)
Critical_Line.colorA = CopyDefaultOf(Track.colorA)

---------------------------------------------------------------------/
-- TRACK EDGE SETUP --                                              |
---------------------------------------------------------------------\
Track.edgeLAlpha = CONSTANT_OFF
Track.edgeRAlpha = CONSTANT_OFF

-- Edge Canvas setup --
Edge_Canvas = Scene.createCanvas(true)
Edge_Canvas.translationX = CopyDefaultOf(Track.translationX)
Edge_Canvas.translationY = CopyDefaultOf(Track.translationY)
Edge_Canvas.translationZ = CopyDefaultOf(Track.translationZ)

Edge_Canvas.rotationX = CopyDefaultOf(Track.rotationX)
Edge_Canvas.rotationY = CopyDefaultOf(Track.rotationY)
Edge_Canvas.rotationZ = CopyDefaultOf(Track.rotationZ)
------------------------

Track_EdgeL = Track.edgeExtraL.copy()
Track_EdgeR = Track.edgeExtraR.copy()

Track_EdgeL.setParent(Edge_Canvas)
Track_EdgeR.setParent(Edge_Canvas)

Track_EdgeL.sort = Critical_Line.sort.valueAt(DEFAULT_TIME) + 1 -- Above Track and Critical_Line
Track_EdgeR.sort = Critical_Line.sort.valueAt(DEFAULT_TIME) + 1 -- Above Track and Critical_Line

Track_EdgeL.active = SetDefault(1)
Track_EdgeR.active = SetDefault(1)

Track_EdgeL.translationX = SetDefault(0)
Track_EdgeL.translationY = SetDefault(0)
Track_EdgeL.translationZ = SetDefault(0)

Track_EdgeR.translationX = SetDefault(0)
Track_EdgeR.translationY = SetDefault(0)
Track_EdgeR.translationZ = SetDefault(0)

local thanks_walker = Channel.keyframe().addKey(DEFAULT_TIME,0,'l').addKey(10000000,60000) * (Context.bpm(0) / Context.bpm(0).valueAt(0))
Track_EdgeL.textureOffsetY = thanks_walker
Track_EdgeR.textureOffsetY = thanks_walker

Track_EdgeL.scaleX = CopyDefaultOf(Track.scaleX)
Track_EdgeL.scaleY = CopyDefaultOf(Track.scaleY)
Track_EdgeL.scaleZ = CopyDefaultOf(Track.scaleZ)

Track_EdgeR.scaleX = CopyDefaultOf(Track.scaleX)
Track_EdgeR.scaleY = CopyDefaultOf(Track.scaleY)
Track_EdgeR.scaleZ = CopyDefaultOf(Track.scaleZ)

Track_EdgeL.colorR = CopyDefaultOf(Track.colorR)
Track_EdgeL.colorG = CopyDefaultOf(Track.colorG)
Track_EdgeL.colorB = CopyDefaultOf(Track.colorB)
Track_EdgeL.colorA = CopyDefaultOf(Track.colorA)

Track_EdgeR.colorR = CopyDefaultOf(Track.colorR)
Track_EdgeR.colorG = CopyDefaultOf(Track.colorG)
Track_EdgeR.colorB = CopyDefaultOf(Track.colorB)
Track_EdgeR.colorA = CopyDefaultOf(Track.colorA)

---------------------------------------------------------------------/
-- BEATLINES SETUP --                                               |
---------------------------------------------------------------------\
Beatlines = Scene.beatlines

Beatlines.translationX = CopyDefaultOf(Beatlines.translationX)
Beatlines.translationY = CopyDefaultOf(Beatlines.translationY)
Beatlines.translationZ = CopyDefaultOf(Beatlines.translationZ)

Beatlines.scaleX = CopyDefaultOf(Beatlines.scaleX)
Beatlines.scaleY = CopyDefaultOf(Beatlines.scaleY)
Beatlines.scaleZ = CopyDefaultOf(Beatlines.scaleZ)

---------------------------------------------------------------------/
-- DIVIDE LINES SETUP --                                            |
---------------------------------------------------------------------\

-- Divide Canvas setup --
Divide_Canvas = Scene.createCanvas(true)

Divide_Canvas.translationX = CopyDefaultOf(Track.translationX)
Divide_Canvas.translationY = CopyDefaultOf(Track.translationY)
Divide_Canvas.translationZ = CopyDefaultOf(Track.translationZ)

Divide_Canvas.rotationX = CopyDefaultOf(Track.rotationX)
Divide_Canvas.rotationY = CopyDefaultOf(Track.rotationY)
Divide_Canvas.rotationZ = CopyDefaultOf(Track.rotationZ)

--------------------------

LANES_MIDDLE = math.ceil(MAX_LANE_COUNT / 2 + 1)
LANES_LAST = math.ceil((LANES_MIDDLE * 2) - 1)

LANE_WIDTH = math.truncate(math.abs(math.abs(Track.divideLine01.translationX.valueAt(DEFAULT_TIME)) - math.abs(Track.divideLine12.translationX.valueAt(DEFAULT_TIME))) * Track.scaleX.valueAt(DEFAULT_TIME), 2)
TRACK_FULL_WIDTH = LANES_LAST * LANE_WIDTH

Divide_Lines = {}

local Original_Line = Track.divideLine23
for i = 1, LANES_LAST do
    Divide_Lines[i] = Original_Line.copy()
    Divide_Lines[i].sort = Critical_Line.sort.valueAt(DEFAULT_TIME) - 1
    Divide_Lines[i].setParent(Divide_Canvas)
    local line = Divide_Lines[i]

    line.translationX = CopyDefaultOf(Original_Line.translationX)
    line.translationY = CopyDefaultOf(Original_Line.translationY)
    line.translationZ = CopyDefaultOf(Original_Line.translationZ)

    line.scaleX = SetDefault(0)
    line.scaleY = CopyDefaultOf(Original_Line.scaleY)
    line.scaleZ = CopyDefaultOf(Original_Line.scaleZ)

    line.colorR = CopyDefaultOf(Original_Line.colorR)
    line.colorG = CopyDefaultOf(Original_Line.colorG)
    line.colorB = CopyDefaultOf(Original_Line.colorB)
    line.colorA = CopyDefaultOf(Original_Line.colorA)

    line.active = SetDefault(0)
end

---------------------------------------------------------------------/
-- DISABLE DEFAULT DIVIDE LINES --                                  |
---------------------------------------------------------------------\
Track.divideLine01.active = CONSTANT_OFF
Track.divideLine12.active = CONSTANT_OFF
Track.divideLine23.active = CONSTANT_OFF
Track.divideLine34.active = CONSTANT_OFF
Track.divideLine45.active = CONSTANT_OFF
---------------------------------------------------------------------/

-- handy defaults
CRITICALLINE_TRANSLATIONY = Critical_Line.translationY.valueAt(DEFAULT_TIME)
SKYINPUTLINE_TRANSLATIONY = SkyInputLine.translationY.valueAt(DEFAULT_TIME)
TRACK_TRANSLATIONZ = Track.translationZ.valueAt(DEFAULT_TIME)