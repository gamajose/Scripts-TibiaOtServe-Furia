-- Table to represent JSON encoding and decoding functions
JSON = {}

--- Encodes a Lua value into a JSON string.
-- This function encodes a Lua table, string, number, or boolean into a JSON string.
-- @param input (table|string|number|boolean) - The Lua value to encode.
-- @return The JSON string representation of the input.
function JSON.encode(input)
    local output = {}
    if type(input) == "table" then
        local isArray = #input > 0
        table.insert(output, isArray and "[" or "{")
        local first = true
        for key, value in pairs(input) do
            if not first then
                table.insert(output, ",")
            end
            first = false
            if isArray then
                table.insert(output, JSON.encode(value))
            else
                table.insert(output, '"' .. key .. '":' .. JSON.encode(value))
            end
        end
        table.insert(output, isArray and "]" or "}")
    elseif type(input) == "string" then
        table.insert(output, '"' .. input .. '"')
    elseif type(input) == "number" or type(input) == "boolean" then
        table.insert(output, tostring(input))
    else
        error("Unsupported data type: " .. type(input))
    end
    return table.concat(output)
end

--- Decodes a JSON string into a Lua value.
-- This function decodes a JSON string into a Lua table, string, number, or boolean.
-- @param str (string) - The JSON string to decode.
-- @return The Lua representation of the JSON string.
function JSON.decode(str)
    local parseValue, parseArray, parseObject
    parseArray = function(s)
        local array = {}
        s = s:sub(2, -2)
        for value in s:gmatch('([^,]+)') do
            value = value:match("^%s*(.-)%s*$") -- Trim whitespace
            table.insert(array, parseValue(value))
        end
        return array
    end

    parseObject = function(s)
        local object = {}
        s = s:sub(2, -2)
        for k, v in s:gmatch('([^,:]+):([^,]+)') do
            k = k:match("^%s*(.-)%s*$") -- Trim whitespace
            v = v:match("^%s*(.-)%s*$") -- Trim whitespace
            object[parseValue(k)] = parseValue(v)
        end
        return object
    end

    parseValue = function(s)
        if s:sub(1, 1) == '"' then
            return s:sub(2, -2)
        elseif s == "true" then
            return true
        elseif s == "false" then
            return false
        elseif s == "null" then
            return nil
        elseif tonumber(s) then
            return tonumber(s)
        elseif s:sub(1, 1) == "{" then
            return parseObject(s)
        elseif s:sub(1, 1) == "[" then
            return parseArray(s)
        end
    end

    return parseValue(str)
end