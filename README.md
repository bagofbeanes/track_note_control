# Track & Note Control
Provides scenecontrol functions for transforming/modifying the track and notes in various ways in ArcCreate.

## How to use
1. Create a "Scenecontrol" (case-sensitive) folder within your chart folder
2. [Download the latest .zip](https://github.com/bagofbeanes/track_note_control/releases)
3. Extract the .zip contents into the "Scenecontrol" folder
4. Use `note\controls.lua` and `track\controls.lua` for note group and track control respectively.

## Current features
-   Note group scaling (generic and individual)
-   Note translation
-   Note coloring (rgb and alpha)
-   Note rotation (degrees)
<br></br>
-   Track lane count modification
-   Track translation
-   Track coloring (rgb and alpha)
<br></br>
-   Input line scaling
-   Input line translation
-   Input line coloring (rgba and alpha)
<br></br>
-   Lane boundary translation (from lane, to lane)
-   Sky input upper boundary translation
<br></br>
-   Other utility features for ease of use

## Documentation
You can omit the `options` array, the `modify` array or any of their elements as they use the default values if not specified.

### Main functions
---
### > Note scaling (generic)
Scales all notes in a note group generically on x, y axes.
-   Function: `Note_Scale(group, scale_xy, start_time, end_time, options)`
-   Options: `{ easing }`
-   Example:
```lua
-- Scales notes generically in group 1 to 2x the size on x and y
Note_Scale(1, xy(2,2), 0, 1000, { easing = '2o' })
```
---

### > Note scaling (individual)
Scales all notes in a note group individually on x, y axes. Optionally scales note judgement as well.
-   Function: `Note_ScaleInd(group, scale_xy, start_time, end_time, options)`
-   Options: `{ judge_xy, easing }`
-   Example: 
```lua
-- Scales notes individually in group 2 to 2x the size on x and y, scaling note judgement size along with it
Note_ScaleInd(2, xy(2,2), 0, 1000, { easing = '2o', judge_xy = xy(1,1) })
```
>**Additional information**
>-  `judge_xy` is a toggle between 0 and 1 on each axis that controls if note judgement should be scaled as well.
---

### > Note translation
Translates all notes in a note group on x, y, z axes. Optionally translates note judgement as well.
-   Function: `Note_Translate(group, translation_xyz, start_time, end_time, options)`
-   Options: `{ add_xyz, judge_xyz, easing }`
-   Example: 
```lua
Note_Translate(3, xyz(2,0,0), 0, 1000, { add_xyz = xyz(1,0,0), judge_xyz = xyz(1,0,0), easing = 'b' } )
```
>**Additional information**
>-  `add_xyz` is a toggle between 0 and 1 on each axis that controls if the translation should override or be added to the current translation. Its default value is `xyz(0,0,0)`.
>-  `judge_xyz` is a toggle between 0 and 1 on each axis that controls if note judgement should be translated as well.
---

### > Note coloring
Changes the color values for a note group on r,g,b,a channels.
-   Function: `Note_Color(group, color_rgba, start_time, end_time, options)`
-   Options: `{ add_rgba, easing }`
-   Example:
```lua
-- Change note group alpha to 100 while not changing the other color channels
Note_Color(4, rgba(0,0,0,100), 0, 1000, { add_rgba = rgba(1,1,1,0), easing = 'si' } )
```
>**Additional information**
>-  `add_rgba` is a toggle between 0 and 1 on each color channel that controls if the color value should override or be added to the current color value. Its default value is `rgba(1,1,1,0)`.
---

### > Note rotation
Rotates all notes in a note group on x, y, z axes, in degrees.
-   Function: `Note_Rotate(group, rotation_xyz, start_time, end_time, options)`
-   Options: `{ add_xyz, easing }`
-   Example: 
```lua
-- Make note group "stand up"
Note_Rotate(4, xyz(90,0,0), 0, 1000, { add_xyz = xyz(0,0,0), easing = 'b' } )
```
>**Additional information**
>-  `add_xyz` is a toggle between 0 and 1 on each axis that controls if the rotation should override or be added to the current rotation. Its default value is `xyz(0,0,0)`.
---

### > Track scaling:
Scales the track on the x axis by lane count.
-   Function: `Track_Scale(lane_count, start_time, end_time, options)`
-   Options: `{ easing }`
-   Example:
```lua
-- Change lane count to 6k
Track_Scale(6, 0, 1000, { easing = 'so' })
```
>**Additional information**
>-  Track scaling is capped at 32 lanes. This can be modified in `init.lua` by changing the value of `MAX_LANE_COUNT`. Bear in mind that higher lane counts can cause lag on mobile devices.
---

### > Track translation
Translates the track on x, y, z axes.
-   Function: `Track_Translate(translate_xyz, start_time, end_time, options)`
-   Options: `{ add_xyz, easing }`
-   Example:
```lua
-- Translate the track to 10 on x and y, offset by 1 on z axis
Track_Translate(xyz(10,10,1), 0, 1000, { add_xyz = xyz(0,0,1), easing = '3i' } )
```
>**Additional information**
>-  `add_xyz` is a toggle between 0 and 1 on each axis that controls if the translation should override or be added to the current translation. Its default value is `xyz(0,0,0)`.

---

### > Track coloring
Changes the color values of the track and its elements on r,g,b,a channels.
-   Function: `Track_Color(color_rgba, start_time, end_time, options)`
-   Options: `{ add_rgba, easing, modify }`
-   Modify: `{ track, edge_left, edge_right, divide_lines }`
-   Example:
```lua
-- Set track color to red without changing other color channels
-- Apply to track and its edges
Track_Color(rgba(255,0,0,0), 0, 1000, { add_rgba = rgba(0,1,1,1), easing = 'b', modify = { track = true, edge_left = true, edge_right = true, divide_lines = false } })
```
>**Additional information**
>-  `add_rgba` is a toggle between 0 and 1 on each color channel that controls if the color value should override or be added to the current color value. Its default value is `rgba(1,1,1,0)`.
>- `modify` is an array of boolean values that you can use to toggle which elements are affected by a function.
---

### > Input line scaling
Scales the input lines (critical (floor) and/or sky input line) on the x, y axes.
-   Function: `InputLine_Scale(scale_xy, start_time, end_time, options)`
-   Options: `{ easing, modify }`
-   Modify: `{ critical_line, sky_input_line, sky_input_label }`
-   Example:
```lua
-- Scale the critical line to be 2x the size on the x axis
InputLine_Scale(xy(2,1), 0, 1000, { easing = '2i', modify = { critical_line = true } } )
```
>**Additional information**
>- The critical (floor) line automatically scales with the track. The option to scale it here exists just to add more control over it.
>- `modify` is an array of boolean values that you can use to toggle which elements are affected by a function.
---

### > Input line translation
Translates the input lines (critical (floor) and/or sky input line) on the x, y, z axes.
-   Function: `InputLine_Translate(translation_xyz, start_time, end_time, options)`
-   Options: `{ add_xyz, easing, modify }`
-   Modify: `{ critical_line, sky_input_line, sky_input_label }`
-   Example:
```lua
-- Translate sky input label to 5 on x and z axis while not changing y
InputLine_Translate(xyz(5,0,5), 0, 1000, { add_xyz = xyz(0,1,0), easing = 'so', modify = { sky_input_label = true } })
```
>**Additional information**
>- The critical (floor) line automatically moves with the track. The option to translate it here exists just to add more control over it.
>-  `add_xyz` is a toggle between 0 and 1 on each axis that controls if the translation should override or be added to the current translation. Its default value is `xyz(0,0,0)`.
>- `modify` is an array of boolean values that you can use to toggle which elements are affected by a function.
---

### > Input line coloring
Changes the color values of the input lines (critical (floor) and/or sky input line) on r,g,b,a channels.
-   Function: `InputLine_Color(color_rgba, start_time, end_time, options)`
-   Options: `{ add_rgba, easing, modify }`
-   Modify: `{ critical_line, sky_input_line, sky_input_label }`
-   Example:
```lua
-- Set the sky input line color to aqua without modifying other color channels
InputLine_Color(rgba(0,255,255,0), 0, 1000, { add_rgba = rgba(1,0,0,1), easing = '3o', modify = { sky_input_line = true } })
```
>**Additional information**
>-  `add_rgba` is a toggle between 0 and 1 on each color channel that controls if the color value should override or be added to the current color value. Its default value is `rgba(1,1,1,0)`.
>- `modify` is an array of boolean values that you can use to toggle which elements are affected by a function.
---

### > Floor input boundary modification
Modifies the lane input boundaries. Any floor input below the minimum and above the maximum is clamped. Minimum is lane 1 and maximum is lane 4 by default. Only uses integer values.
-   Function: `FloorInput_Translate(lanefrom, laneto, start_time, end_time, options)`
-   Options: `{ easing }`
-   Example:
```lua
-- If using 6 lanes, you should set the lane boundaries to be lanefrom=0, laneto=5
FloorInput_Translate(0, 5, 0, 1000, { easing = 'so' })
```
>**Additional information**
>-  Translating or scaling the track doesn't transform the input boundaries. You need to manually move them using this function, otherwise they'll stay in the center using the 4k layout.
---

### > Sky input boundary modification
Translates the upper boundary of the sky input.
-   Function: `SkyInput_Translate(y, start_time, end_time, options)`
-   Options: `{ add_y, easing }`
-   Example:
```lua
-- Offset sky input upper boundary by 2 above the default
SkyInput_Translate(2, 0, 1000, { add_y = 1, easing = 'si' })
```
>**Additional information**
>-  `add_y` is a toggle between 0 and 1 that controls if the value should override or be added to the current value.
---

### Utility functions
---
### > Beatlength
A more convenient version of `Context.beatLength.valueAt()`.
-   Function: `Beatlength(multiplier, timing, group)`
-   Example:
```lua
-- Get 2 * beatlength of first bpm (at timing 0) on Base group (0)
Beatlength(2, 0, 0)
-- OR
Beatlength(2)
```
---

### > Repeat
Repeats a function a number of times.
-   Function: `Repeat(start_time, end_time, i_times, func)`
-   Example:
```lua
-- Repeat the function twice
Repeat(0, 1000, 2, function(start_time, i)
    -- Translate track by 1 on the x axis every iteration
    Track_Translate(1, xyz(1,0,0), start_time, start_time + Beatlength(0.25), { add_xyz = xyz(1,0,0) })
end)
```
---

### > RepeatUntil
Repeats a function until a point in time, with each iteration lasting a given amount of time.
-   Function: `RepeatUntil(start_time, end_time, i_length, func)`
-   Example:
```lua
RepeatUntil(0, 2000, 500, function(start_time, i)
    Track_Color(rgba(0,0,0,10), start_time, start_time + Beatlength(0.25), { add_rgba = rgba(1,1,1,1) })
end)
```
---

### Utility variables
-   `DEFAULT_TIME` (constant): -3000ms into the song (used for getting the default values of channels)
-   `START_TIME` (constant): -2001ms into the song (start time of the chart, recommended to place starting scenecontrol functions here)
-   `LANE_WIDTH` (constant): Width of one lane. Can be used for translating objects by a number of lanes.
-   `TRACK_SCALE_LANES` (keychannel): Can be used to get the number of lanes at a given point in time.
-   `CRITICAL_LINE_TRANSLATIONY` (constant): The default y offset of the critical (floor) line.
-   `SKYINPUTLINE_TRANSLATIONY` (constant): The default y offset of the sky input line.
-   `TRACK_TRANSLATIONZ` (constant): The default z offset of the track.


## Known issues:
- Not possible to configure in-editor (can't fix because of ArcCreate handling some controllers differently in-editor)
- Sometimes upon loading the chart the track edges dont load their skin properly, in that case, reload the scenecontrol in the Events tab
- Incompatible with `enwidenlanes` due to the extra lanes scaling with the track (can't fix, might add a custom implementation in the future though)
