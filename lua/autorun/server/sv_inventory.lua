local path = "nyaaa_inv/"

for k, v in pairs(file.Find(path .. "sv_*", "LUA")) do
    print("File Loaded " .. v)
    include(path .. v)
end

for k, v in pairs(file.Find(path .. "cl_*", "LUA")) do
    print("File Loaded " .. v)
    AddCSLuaFile(path .. v)
end