local ethtool = require "ethtool"

local pattern_device = "^%s*([^%s:]+):"
local pattern_metric = "^([a-zA-Z0-9:_]+)$"

local function get_devices()
  local devices = {}
  for line in io.lines("/proc/net/dev") do
    local dev = string.match(line, pattern_device)
    if dev then
      table.insert(devices, dev)
    end
  end
  return devices
end

local function scrape()
  local eth = ethtool.open()
  local metrics = {}
  for _, dev in ipairs(get_devices()) do
    local stats = eth:statistics(dev)
    if stats then
      for m_name, m_value in pairs(stats) do
        if string.match(m_name, pattern_metric) then
          local m = metrics[m_name]
          if m == nil then
            m = metric("ethtool_" .. m_name, "counter")
            metrics[m_name] = m
          end
          m({device=dev}, m_value)
        end
      end
    end
  end
  eth:close()
end

return { scrape = scrape }
