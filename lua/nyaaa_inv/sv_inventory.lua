util.AddNetworkString("ConCluster")
util.AddNetworkString("Terminal_Receive")
local meta = FindMetaTable("Player")
local cluster = net
local terminator = {}
function terminator.TerminalNetMsg(pl)
    cluster.Start("Terminal_Receive")
    cluster.WriteTable(pl.Weapons_Inv)
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

function meta:RemoveInventoryItem(pos)
    table.remove(self.Weapons_Inv, pos)
    terminator.TerminalNetMsg(self)
end

function meta:AddInventoryItem(pos, item)
    table.insert(
        self.Weapons_Inv,
        {
            Class = pos,
            Model = item,
        }
    )

    terminator.TerminalNetMsg(self)
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
                    ply:AddInventoryItem(oldwep:GetClass(), oldwep:GetModel())
                    oldwep = nil
                end
            )

            timer.Destroy("CurryDarkpAdd")
        end
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
            local class = ply.Weapons_Inv[flt].Class
            ply:GiveAmmo(30, weapons.Get(class).Primary.Ammo)
            ply:RemoveInventoryItem(flt)
            return
        end

        ply:Give(ply.Weapons_Inv[flt].Class)
        ply:RemoveInventoryItem(flt)
    end
)