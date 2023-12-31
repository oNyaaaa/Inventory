local Tbl = {}
local ButtonTable = {}
local modelPanel = {}
local buttonPanel = {}
local keepler = {}
curry = {}
curry.Modules = {}
Terminal = Terminal or {}
local SetInventoryPosition
function curry:GetBool(Names)
    for k, v in pairs(curry.Modules) do
        if v.Name == Names then return v.Enable end
    end
end

function curry:Add(str, val)
    if curry:GetBool(str) == str then
        print("Failed to load module for: " .. tostring(str))
        return
    else
        print("Loaded module: " .. tostring(str))
    end

    local meltdown = {{function() return {val(str)} end}}
    meltdown[1][1]()
end

Terminal.Table = Terminal.Table or {}
local panel
net.Receive(
    "Terminal_Receive",
    function()
        Terminal.Table = {}
        local terminal_Tbl = net.ReadTable()
        Terminal.Table = terminal_Tbl
        if panel and IsValid(panel) then
            panel:Remove()
            LocalPlayer():ConCommand("Nyaaa_Inventory")
        end
    end
)

curry:Add(
    "SetInventoryPosition",
    function(n)
        function SetInventoryPosition(wong, name, model, slot, wep)
            local OpenSlot = true
            for k, v in pairs(Terminal.Table) do
                if v.Slot == k and v.Occupied == true then OpenSlot = false end
            end

            if OpenSlot == false then return end
            modelPanel[slot] = vgui.Create("DModelPanel", wong)
            modelPanel[slot]:SetModel(model)
            modelPanel[slot].Models = model
            modelPanel[slot].Nice = name
            modelPanel[slot].Class = wep
            modelPanel[slot]:SetSize(100, 100)
            if modelPanel[slot].Entity ~= nil then
                local PrevMins, PrevMaxs = modelPanel[slot].Entity:GetRenderBounds()
                modelPanel[slot]:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.5, 0.5, 0.5))
                modelPanel[slot]:SetLookAt((PrevMaxs + PrevMins) / 2)
            end

            modelPanel[slot].LayoutEntity = function(ent) end
            modelPanel[slot].Slot = slot
            modelPanel[slot].Occupied = true
            buttonPanel[slot] = vgui.Create("DButton", modelPanel[slot])
            buttonPanel[slot]:Dock(BOTTOM)
            buttonPanel[slot]:SetText(name)
            buttonPanel[slot]:SetSize(0, 20)
            buttonPanel[slot].DoClick = function()
                Derma_Query(
                    "Equip this weapon!",
                    "Confirmation:",
                    "Yes",
                    function()
                        net.Start("ConCluster")
                        net.WriteFloat(slot)
                        net.WriteString(model)
                        net.SendToServer()
                    end,
                    "No",
                    function() end
                )
            end
            return modelPanel[slot]
        end
    end
)

local Position_Slot = {}
curry:Add(
    "Inventory",
    function(n)
        function Drop(self, tableOfDroppedPanels, isDropped, menuIndex, mouseX, mouseY)
            if isDropped then
                net.Start("ConCluster_Fuck")
                net.WriteString(tableOfDroppedPanels[1].Nice)
                net.WriteFloat(tableOfDroppedPanels[1].Slot)
                net.WriteFloat(vgui.GetHoveredPanel().Item)
                net.WriteString(tableOfDroppedPanels[1].Models)
                net.WriteString(tableOfDroppedPanels[1].Class)
                net.SendToServer()
                tableOfDroppedPanels[1]:SetParent(Tbl[vgui.GetHoveredPanel().Item])
            end
        end

        local function Inventory(pl, c, args)
            if panel and IsValid(panel) then panel:Remove() end
            panel = vgui.Create("DFrame")
            panel:SetSize(800, 600)
            panel:SetPos(ScrW() * 0.3, ScrH() * 0.2)
            panel:MakePopup()
            local panel2 = vgui.Create("DPanel", panel)
            panel2:SetSize(800, 600)
            panel2:SetPos(0, 25)
            local grid = vgui.Create("DGrid", panel2)
            grid:SetPos(35, 30)
            grid:SetCols(7)
            grid:SetColWide(105)
            grid:SetRowHeight(105)
            for i = 1, 36 do
                Tbl[i] = vgui.Create("DPanel")
                Tbl[i]:SetSize(100, 100)
                Tbl[i].Item = i
                Tbl[i]:Receiver("Minge", Drop)
                grid:AddItem(Tbl[i])
            end

            local fill = 1
            if #Terminal.Table > 0 then
                for k, v in pairs(Terminal.Table) do
                    keepler[k] = SetInventoryPosition(Tbl[v.Slot], v.Name, v.Model, fill, v.Class)
                    keepler[k]:Droppable("Minge")
                    --keepler[k]:SetParent(Tbl[5])
                    fill = fill + 1
                end
            end
        end

        concommand.Add("Nyaaa_Inventory", Inventory)
    end
)