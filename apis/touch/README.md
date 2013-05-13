# TouchAPI

The touch API aims to simplify the use of touchscreens in ComputerCraft

## Installation

If you're using an extracted version of ComputerCraft, then simply copy the file into the `minecraft\mods\computercraft\lua\rom\apis` directory, and the API will be loaded automatically when any computer is started.
Alternatively, the file can be copied onto individual computers in-game by copying the file into the `minecraft\saves\[worldName]\computer\#` directory, where *worldName* is the name of your world, and *#* is the individual computer index. (Hint: to find a named computer, look in the *labels.txt* file)

***Note:* If you're using a unmodified ComputerCraft bios, then the file extension (`.lua`) should be removed from the filename**

## Usage

### loading the API

If the API is not automatically loaded at startup, it can be loaded manually using the `os.loadAPI` function:

```lua
os.loadAPI("touchAPI")
```

Similarly, once the application has finished with the API, it can be removed using the `os.unloadAPI` method:

```lua
os.unloadAPI("touchAPI")
```

### Adding hit targets

`touchAPI.add(left, top, width, height, touchData)`

Example:
```lua
touchAPI.add(1, 1, 20, 10, "Hit")
```

This defines a new hit area starting at 1, 1 (top left corner), with a width of 20 characters and a height of 10.  The string "Hit" is set as the touch data for this area, which will be returned when a touch is detected in this area.

### Detecting touches

`touchAPI.waitForTouch([side])`

Example:
```lua
local touchData = touchAPI.waitForTouch()
```

`waitForTouch` is a **blocking** call, which means it will pause the application until a predefined touch target is hit.
The return value is the touch data specified in the corresponding call to `add`, so continuing the example code above the value of `touchData` would be `"Hit"` after the area was hit.

### Manual hit testing

It is possible to perform manual hit testing without waiting for a `monitor_touch` event, using the `hitTest` function:

`touchAPI.hitTest(x, y)`

Example:
```lua
local touchData = touchAPI.hitTest(5, 10)
```

Since this is not event based, it will return immediately and not block the application.

### Removing hit targets

The `clear` method can be used to remove all currently defined hit targets

```lua
touchAPI.clear()
```

## Interaction frames

Interaction frames are used to add milti-page functionality to an application, by way of a simple frame stack.

A new interaction frame can be introduced using the `push` method:

```lua
touchAPI.push()
```

At this point all predefined hit targets will be disabled, and any new ones for this page can be added

Once the application wants to return to the previous page, the `pop` method will remove any hit targets for this page, and restore those of the previous page:

```lua
touchAPI.pop()
```

### Mouse clicks

The touch API can also be used for detecting mouse clicks, using the `waitForClick` method:

`touchAPI.waitForClick([button])`

Example:
```lua
local clickData = touchAPI.waitForClick(2)
```

This waits for a right-click on a predefined hit area.  This is also a **blocking** call similar to `waitForTouch`.