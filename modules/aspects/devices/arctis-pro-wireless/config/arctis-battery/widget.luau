--!nonstrict
-- Polls `headsetcontrol -b -o json` and renders the battery level.
--
-- headsetcontrol reports two different kinds of "no answer" and they are worth
-- keeping apart: an empty `devices` array means the base station itself is not
-- on USB, while a device that reports BATTERY_UNAVAILABLE means the station is
-- there and the headset is off or out of range. Both end up hidden, but the
-- tooltip says which.
--
-- Reading the battery needs write access to the device's hidraw node. That is
-- what the udev rules in this aspect's NixOS module are for; without them every
-- poll comes back with a `errors.battery` string instead of a level.

local COMMAND = "headsetcontrol -b -o json"
local TIMEOUT_MS = 5000
-- Tabler icon name. An unknown name renders as the missing-glyph skull rather
-- than failing, so it is worth checking against the shipped tabler.json.
local GLYPH = "headset"

local pollSeconds = noctalia.getConfig("poll_seconds")
local hideWhenAbsent = noctalia.getConfig("hide_when_absent")

-- A poll outlives the update() that started it, so a slow or hung
-- headsetcontrol must not stack up one process per tick.
local inFlight = false

local function show(text, tooltip)
  barWidget.setVisible(true)
  barWidget.setGlyph(GLYPH)
  barWidget.setText(text)
  barWidget.setTooltip(tooltip)
end

local function absent(reason)
  if hideWhenAbsent then
    barWidget.setVisible(false)
  else
    show("--", reason)
  end
end

local function firstDevice(payload)
  if type(payload) ~= "table" then
    return nil
  end
  local devices = payload.devices
  if type(devices) ~= "table" then
    return nil
  end
  return devices[1]
end

local function handle(result)
  inFlight = false

  if result.timedOut then
    absent("headsetcontrol did not answer within " .. TIMEOUT_MS .. " ms")
    return
  end

  local ok, payload = pcall(noctalia.json.decode, result.stdout or "")
  if not ok then
    absent("headsetcontrol returned no usable JSON")
    return
  end

  local device = firstDevice(payload)
  if device == nil then
    absent("No supported headset on USB")
    return
  end

  local name = device.device or "Headset"

  -- On a permission or transport failure the `battery` table is missing
  -- entirely and only `errors.battery` is present.
  local battery = device.battery
  if type(battery) ~= "table" then
    local err = type(device.errors) == "table" and device.errors.battery or nil
    absent(err ~= nil and (name .. ": " .. err) or (name .. ": battery unreadable"))
    return
  end

  local level = tonumber(battery.level) or -1
  local status = battery.status or "BATTERY_UNAVAILABLE"

  if status == "BATTERY_CHARGING" then
    show(level >= 0 and (level .. "%") or "chg", name .. ": charging")
  elseif status == "BATTERY_AVAILABLE" and level >= 0 then
    show(level .. "%", name .. ": " .. level .. "%")
  elseif status == "BATTERY_UNAVAILABLE" then
    absent(name .. ": off or out of range")
  else
    absent(name .. ": " .. status)
  end
end

local function poll()
  if inFlight then
    return
  end
  inFlight = noctalia.runAsync(COMMAND, handle, TIMEOUT_MS)
end

function update()
  noctalia.setUpdateInterval(pollSeconds * 1000)
  poll()
end

-- The poll interval is long enough that waiting for the next tick after
-- switching the headset on is annoying.
function onClick()
  poll()
end
