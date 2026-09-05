# Reactor Controller

ASCII-only ComputerCraft CC:Tweaked controller for one Extreme Reactors reactor, many turbines, one Mekanism induction matrix, and one directly connected monitor.

## Files

- main.lua: program entry point and event loop
- config.lua: default settings
- devices.lua: peripheral discovery
- reactor.lua: reactor control and steam feedback
- turbines.lua: common RPM control for all turbines
- matrix.lua: induction matrix readings
- ui.lua: monitor display and touch controls
- storage.lua: persistent settings
- install.lua: downloads all Lua files from GitHub

## Installation

Copy all Lua files to the ComputerCraft computer. The files must be in the same folder.

Run:

    main

## GitHub install

Upload all Lua files to the root of a public GitHub repository.

Edit install.lua and replace USERNAME and REPOSITORY in baseUrl.

On the ComputerCraft computer, run:

    edit install.lua
    install

Then run:

    main

The installer removes existing Lua files before downloading new versions. The
reactor.cfg file is preserved.

## Default hardware names

- reactor: back
- matrix: inductionPort_0
- monitor: monitor_1

Change these values in config.lua if needed.

## Control model

Set steamTarget to the desired reactor hot-fluid production rate in mB/t. The controller reads getHotFluidProducedLastTick and changes all control rod levels until reactor production approaches the target.

Set rpmTarget to one common RPM target. Each turbine changes its own fluid limit until it approaches the same RPM target.

The reactor uses setAllControlRodLevels, which changes every control rod in the reactor together.

AUTO starts or stops the reactor and all turbines using matrixStart and matrixStop.

MANUAL disables matrix start and stop logic. The START and STOP buttons still operate the equipment.

STOP enters EMERGENCY mode. RESET is the same action as selecting MANUAL after an emergency and equipment remains off until START is pressed.

## Important

Test with conservative targets first. The exact hot-fluid rate depends on reactor size and turbine load.
