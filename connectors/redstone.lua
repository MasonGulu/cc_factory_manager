local lib = require "manager_lib"
---@class RedstoneConnector : Connector
---@field type "redstone"
---@field side string?
---@field peripheral string?
local redstone_con__index = setmetatable({}, lib.con_meta)
---@class RedstonePacket : Packet
---@field level integer

local redstone_con_meta = { __index = redstone_con__index }

---Pass redstone into this connector
---@param packet RedstonePacket
function redstone_con__index:recieve_packet(packet)
    if not self.peripheral and self.side then
        redstone.setAnalogOutput(self.side, packet.level)
        return
    end
    if self.side then
        peripheral.call(self.peripheral, "setAnalogOutput", self.side, packet.level)
    end
end

function redstone_con__index:tick()
    return {
        function()
            if not self.peripheral and self.side then
                lib.send_packet_to_link(self, { level = redstone.getAnalogInput(self.side) })
                return
            end
            if self.side then
                lib.send_packet_to_link(self, { level = peripheral.call(self.peripheral, "getAnalogInput", self.side) })
            end
        end
    }
end

local function serialize(con)

end

local function unserialize(con)
    setmetatable(con, redstone_con_meta)
end

---Create a new redstone connector
---@return RedstoneConnector
local function new_redstone_connector()
    ---@type RedstoneConnector
    local con = lib.new_connector() --[[@as RedstoneConnector]]
    con.con_type = "redstone"
    con.color = colors.red
    return setmetatable(con, redstone_con_meta)
end

local configurable_fields = {
    side = {
        type = "string",
    },
    peripheral = {
        type = "peripheral",
        peripheral = { "redstoneIntegrator" },
        description = "Optional peripheral for redstone I/O"
    }
}

local function set_field(con, key, value)
    if key == "side" then
        con.side = value
    elseif key == "peripheral" then
        con.peripheral = value
    else
        error(("Attempt to set field %s on redstone."):format(key))
    end
end

lib.register_connector("redstone", new_redstone_connector, serialize, unserialize, configurable_fields, set_field,
    colors.red)