CDTools = {}

--- Declaring functions like this allows them to be accessed like CDTools.func
--- It kind of mimics static methods, and method forms in other languages
--- I might ditch this to have more homogeneous code, though.
local function ShallowCopy(t)
    local t2 = {};
    for k,v in pairs(t) do
        t2[k] = v;
    end
    return t2;
end
CDTools.ShallowCopy = ShallowCopy;

local function CDDebug(f_Msg)
	local fileWriterObj = getFileWriter("CDDebug.log", true, true);
	fileWriterObj:write("" .. tostring(f_Msg) .."\r\n");
	fileWriterObj:close();
end
CDTools.CDDebug = CDDebug;

-- Taken from: https://www.programming-idioms.org/idiom/10/shuffle-a-list/2019/lua
local function FisherYatesShuffle(x)
    for i = #x, 2, -1 do
        local j = ZombRand(i);
        x[i], x[j] = x[j], x[i];
    end
end
CDTools.FisherYatesShuffle = FisherYatesShuffle;

-- I don't have internet right so, so I can't check if java has a Contains method or something.
local function JavaArrayContains(array, item)
    for i = 1, #array do
        if array[i].item == item then
            return i;
        end
    end
    return -1;
end
CDTools.JavaArrayContains = JavaArrayContains;

local function TableContains(table, item)
    for index, value in pairs(table) do
        if value == item then
            return index;
        end
    end
    return -1;
end
CDTools.TableContains = TableContains;