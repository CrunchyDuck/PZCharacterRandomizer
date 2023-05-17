function ShallowCopy(t)
    local t2 = {};
    for k,v in pairs(t) do
        t2[k] = v;
    end
    return t2;
end

function CDDebug(f_Msg)
	local fileWriterObj = getFileWriter("CDDebug.log", true, true);
	fileWriterObj:write("" .. tostring(f_Msg) .."\r\n");
	fileWriterObj:close();
end

-- Taken from: https://www.programming-idioms.org/idiom/10/shuffle-a-list/2019/lua
function FisherYatesShuffle(x)
    for i = #x, 2, -1 do
        local j = ZombRand(i);
        x[i], x[j] = x[j], x[i];
    end
end

-- I don't have internet right so, so I can't check if java has a Contains method or something.
function JavaArrayContains(array, item)
    for i = 1, #array do
        if array[i].item == item then
            return i;
        end
    end
    return -1;
end

function TableContains(table, item)
    for index, value in pairs(table) do
        if value == item then
            return index;
        end
    end
    return -1;
end