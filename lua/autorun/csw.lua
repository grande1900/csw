local CSWEnabled = CreateConVar("csw_enabled",0,"Enables Custom Spawn Weapons")
local CSWAddWep = CreateConVar("csw_wep","","Weapon to add/remove next time the toggle button is clicked")
local CSWAmmoMult = CreateConVar("csw_ammo_mult",1,"Multiplier for reserve ammo")
local WEPFILE
if !file.Exists("csw/weapondata.json","DATA") then
	file.CreateDir("csw/")
	file.Write("csw/weapondata.json","")
end
if file.Exists("csw/weapondata.txt","DATA") then
	WEPFILE = file.Read("csw/weapondata.txt","DATA")
	CSWeaponsServer = string.Explode(";",WEPFILE)
	file.Write("csw/weapondata.json",util.TableToJSON(CSWeaponsServer,true))
	file.Delete("csw/weapondata.txt")
else
	WEPFILE = file.Read("csw/weapondata.json","DATA")
	CSWeaponsServer = util.JSONToTable(WEPFILE)
end
-- local CSWClientEnabled = CreateConVar("csw_allow_client",1,"Enables client-customizable weapon list")

hook.Add("PlayerLoadout","CSW_TESTW",function(ply)
	if CSWEnabled:GetBool() then
		for _, i in pairs(CSWeaponsServer) do
			ply:Give(i)
		end
		for _, i in pairs(ply:GetWeapons()) do
			ply:GiveAmmo(i:GetMaxClip1()*CSWAmmoMult:GetFloat(),i:GetPrimaryAmmoType())
			ply:GiveAmmo(i:GetMaxClip2()*CSWAmmoMult:GetFloat(),i:GetSecondaryAmmoType())
		end
		-- if CSWClientEnabled:GetBool() then
			-- for _, i in ipairs(CSWeaponsClient) do
				-- ply:Give(i)
			-- end
		-- end
		ply:SwitchToDefaultWeapon()
		return true
	end
end)

hook.Add( "AddToolMenuCategories", "GRANDES_SETTINGS", function()
	spawnmenu.AddToolCategory( "Utilities", "GrandesSettings", "#Grande's Settings" )
end )

hook.Add( "PopulateToolMenu", "GRANDES_CSW_SETTINGS", function()
	spawnmenu.AddToolMenuOption( "Utilities", "GrandesSettings", "CSWSETTINGS", "#CSWSETTINGS", "", "", function( panel )
		panel:ClearControls()
		panel:Help("CSW V1.5")
		panel:CheckBox( "Enable", "csw_enabled" )
		-- panel:CheckBox( "Enable Client Weapons")
		panel:Button( "Print Weapons","csw_print" )
		panel:TextEntry( "Weapon", "csw_wep" )
		panel:Button( "Toggle Weapon","csw_tog" )
		panel:NumSlider( "Ammo multiplier","csw_ammo_mult",0,10 )
		-- Add stuff here
	end )
end )

concommand.Add("csw_print", function()
	PrintMessage(HUD_PRINTTALK,"Weapons:\n")
	for _, i in pairs(CSWeaponsServer) do
		PrintMessage(HUD_PRINTTALK,i)
	end
end)
concommand.Add("csw_tog", function()
	local wep = nil
	local key = nil
	for j, i in pairs(CSWeaponsServer) do
		if i == CSWAddWep:GetString() then
			key = j
			break
		end
	end
	if key == nil then
		table.insert(CSWeaponsServer, CSWAddWep:GetString())
	else
		CSWeaponsServer[key] = nil
	end
	file.Write("csw/weapondata.json",util.TableToJSON(CSWeaponsServer,true))
	RunConsoleCommand("csw_print")
end)