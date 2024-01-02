util.AddNetworkString("ConCluster")
util.AddNetworkString("Terminal_Receive")
util.AddNetworkString("ConCluster_Fuck")
local meta = FindMetaTable("Player")
local cluster = net
local terminator = {}
function terminator.TerminalNetMsg(pl, boool)
    cluster.Start("Terminal_Receive")
    cluster.WriteTable(pl.Weapons_Inv)
    cluster.WriteBool(boool or false)
    cluster.Send(pl)
end

hook.Add(
    "PlayerSpawn",
    "Weapons",
    function(pl)
        pl.Weapons_Inv = {}
        terminator.TerminalNetMsg(pl)
        pl.InvTimer = 0
        pl.Weapons_Inv_Ammo = {}
    end
)

hook.Add(
    "PlayerSpawn",
    "Weapons",
    function(pl)
        pl.Weapons_Inv = {}
        terminator.TerminalNetMsg(pl)
        pl.InvTimer = 0
        pl.Weapons_Inv_Ammo = {}
    end
)

local function GetAmmoForCurrentWeapon(ply)
    if not IsValid(ply) then return -1 end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return -1 end
    return ply:GetAmmoCount(wep:GetPrimaryAmmoType())
end

--[[
1: Find weapons index
2. loop it 36 times is our panel table to see what slot is empty
3: loop our number to find a active slot
]]
function GetEmptySlot(self, slot)
    return self.Weapons_Inv[slot] == nil
end

function meta:RemoveInventoryItem(pos)
    table.remove(self.Weapons_Inv, pos)
    terminator.TerminalNetMsg(self)
end

local FirstTbl = {}
local freeSlots = {}
local takenslots = {}
local watchthis = 1
local firstSlot = firstSlot or 1
function meta:ModifyInventory(indx, name, pos, newslot, item, ammo)
    local count = 0
    for k, v in pairs(self.Weapons_Inv) do
        self.Weapons_Inv[k] = v
        takenslots[k] = v.Slot
    end

    for i = 1, 35 do
        if self.Weapons_Inv[indx] == nil then
            count = count + 1
            if self.Weapons_Inv[indx] ~= nil and self.Weapons_Inv[indx].Slot == takenslots[i] then watchthis = takenslots[i] end
            print(takenslots[i])
            if i == count then
                self.Weapons_Inv[indx] = {
                    OldIdx = indx,
                    Name = name,
                    Class = pos,
                    Model = item,
                    Slot = watchthis,
                    Ammo = ammo,
                    Taken = true,
                }

                print(indx, newslot, i, count)
            end
        end
    end

    if self.Weapons_Inv[indx] ~= nil then
        self.Weapons_Inv[indx] = {
            OldIdx = newslot,
            Name = name,
            Class = pos,
            Model = item,
            Slot = newslot,
            Ammo = ammo,
            Taken = true,
        }
    end

    terminator.TerminalNetMsg(self, true)
end

function meta:AddInventoryItem(name, pos, item, ammo)
    local olx_idx = #self.Weapons_Inv + 1
    self:ModifyInventory(olx_idx, name, pos, olx_idx, item, ammo)
end

timer.Create(
    "CurryDarkpAdd",
    1,
    0,
    function()
        if DarkRP then
            hook.Add(
                "onDarkRPWeaponDropped",
                "PrintWhenDrop",
                function(ply, ent, wep)
                    local oldwep = wep
                    ent:Remove()
                    ply:AddInventoryItem(oldwep.PrintName, oldwep:GetClass(), oldwep:GetModel(), GetAmmoForCurrentWeapon(ply))
                    oldwep = nil
                end
            )

            timer.Destroy("CurryDarkpAdd")
        end
    end
)

net.Receive(
    "ConCluster_Fuck",
    function(len, ply)
        local name = net.ReadString()
        local flt = net.ReadFloat()
        local newslot = net.ReadFloat()
        ply.Check = {}
        for k, v in pairs(ply.Weapons_Inv) do
            if v.Name == name then
                ply.Check[1] = {
                    Name = v.Name,
                    Class = v.Class,
                    Model = v.Model,
                    Slot = newslot,
                    Ammo = v.Ammo,
                }
            end
        end

        ply:ModifyInventory(flt, ply.Check[1].Name, ply.Check[1].Class, newslot, ply.Check[1].Model)
    end
)

net.Receive(
    "ConCluster",
    function(len, ply)
        local flt = cluster.ReadFloat()
        local str = cluster.ReadString()
        if ply.Weapons_Inv[flt] == nil then return end
        if ply.Weapons_Inv[flt].Model ~= str then return end
        if ply:HasWeapon(ply.Weapons_Inv[flt].Class) then
            -- ply:RemoveInventoryItem(flt)
            return
        end

        ply:Give(ply.Weapons_Inv[flt].Class)
        local class = ply.Weapons_Inv[flt].Class
        for k, v in pairs(ply.Weapons_Inv) do
            if str == v.Name then ply:SetAmmo(v.Ammo, weapons.Get(class).Primary.Ammo) end
        end

        ply:RemoveInventoryItem(flt)
    end
)

hook.Add(
    "PlayerSay",
    "Adminstuff",
    function(ply, text)
        local str = string.Explode(" ", text)
        if string.sub("!inv", 1, 4) == str[1] then ply:ConCommand("nyaaa_inventory") end
        if string.sub("!inv_send", 1, 9) == str[1] then
            local oldwep = ply:GetActiveWeapon()
            local class = oldwep:GetClass()
            class = string.lower(class)
            if oldwep.PrintName == nil then return end
            if DarkRP then ply:AddInventoryItem(oldwep.PrintName, oldwep:GetClass(), oldwep:GetModel(), GetAmmoForCurrentWeapon(ply)) ply:StripWeapon(oldwep:GetClass()) end
        end
    end
)