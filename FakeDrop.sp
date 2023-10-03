KeyValues kv;
int itemId[2] = {0,0}, iClientSelectedWeapon[MAXPLAYERS+1] = {-1,...}, counter;
ArrayList hArray[10];

char g_WeaponClasses[][] = {
/* 0*/ "awp", /* 1*/ "ak47", /* 2*/ "m4a1", /* 3*/ "m4a1_silencer", /* 4*/ "deagle", /* 5*/ "usp_silencer", /* 6*/ "hkp2000", /* 7*/ "glock", /* 8*/ "elite", 
/* 9*/ "p250", /*10*/ "cz75a", /*11*/ "fiveseven", /*12*/ "tec9", /*13*/ "revolver", /*14*/ "nova", /*15*/ "xm1014", /*16*/ "mag7", /*17*/ "sawedoff", 
/*18*/ "m249", /*19*/ "negev", /*20*/ "mp9", /*21*/ "mac10", /*22*/ "mp7", /*23*/ "ump45", /*24*/ "p90", /*25*/ "bizon", /*26*/ "famas", /*27*/ "galilar", 
/*28*/ "ssg08", /*29*/ "aug", /*30*/ "sg556", /*31*/ "scar20", /*32*/ "g3sg1", /*33*/ "knife_karambit", /*34*/ "knife_m9_bayonet", /*35*/ "bayonet", 
/*36*/ "knife_survival_bowie", /*37*/ "knife_butterfly", /*38*/ "knife_flip", /*39*/ "knife_push", /*40*/ "knife_tactical", /*41*/ "knife_falchion", /*42*/ "knife_gut",
/*43*/ "knife_ursus", /*44*/ "knife_gypsy_jackknife", /*45*/ "knife_stiletto", /*46*/ "knife_widowmaker", /*47*/ "mp5sd", /*48*/ "knife_css", /*49*/ "knife_cord", 
/*50*/ "knife_canis", /*51*/ "knife_outdoor", /*52*/ "knife_skeleton"
};

int g_iWeaponDefIndex[] = {
/* 0*/ 9, /* 1*/ 7, /* 2*/ 16, /* 3*/ 60, /* 4*/ 1, /* 5*/ 61, /* 6*/ 32, /* 7*/ 4, /* 8*/ 2, 
/* 9*/ 36, /*10*/ 63, /*11*/ 3, /*12*/ 30, /*13*/ 64, /*14*/ 35, /*15*/ 25, /*16*/ 27, /*17*/ 29, 
/*18*/ 14, /*19*/ 28, /*20*/ 34, /*21*/ 17, /*22*/ 33, /*23*/ 24, /*24*/ 19, /*25*/ 26, /*26*/ 10, /*27*/ 13, 
/*28*/ 40, /*29*/ 8, /*30*/ 39, /*31*/ 38, /*32*/ 11, /*33*/ 507, /*34*/ 508, /*35*/ 500, 
/*36*/ 514, /*37*/ 515, /*38*/ 505, /*39*/ 516, /*40*/ 509, /*41*/ 512, /*42*/ 506,
/*43*/ 519, /*44*/ 520, /*45*/ 522, /*46*/ 523, /*47*/ 23, /*48*/ 503, /*49*/ 517,
/*50*/ 518, /*51*/ 521, /*52*/ 525
};

public Plugin myinfo = 
{ 
    name = "FAKE DROP", 
    author = "Palonez", 
    description = "Fake Drop by command !drop", 
    version = "1.15", 
    url = "https://hlmod.ru/members/palonez.92448/"
}

public void OnPluginStart()
{
	char sPath[PLATFORM_MAX_PATH];
	HookEvent("cs_win_panel_match", EventMatch);
	RegAdminCmd("sm_drop", commandDrop, ADMFLAG_ROOT);
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/weapons/weapons_english.cfg");
	kv = CreateKeyValues("Skins");
	if(!kv.ImportFromFile(sPath))
		SetFailState("Cant find configs/weapons/weapons_****.cfg")
}

public void OnMapStart()
{
    counter = 0;
}

public void EventMatch(Event event, const char[] name, bool dontBroadcast)
{
	Protobuf pb = view_as<Protobuf>(StartMessageAll("SendPlayerItemDrops", USERMSG_RELIABLE));
	Protobuf entity_updates;
	for(int i = 0; i < counter; i++)
	{
		int iAR[2];
		hArray[i].GetArray(1, iAR, 2);	
	
		entity_updates = pb.AddMessage("entity_updates");
		
		entity_updates.SetInt("accountid", GetSteamAccountID(hArray[i].Get(0)));
		entity_updates.SetInt64("itemid", iAR);
		entity_updates.SetInt("defindex", g_iWeaponDefIndex[hArray[i].Get(2)]);
		entity_updates.SetInt("paintindex", hArray[i].Get(3));
		entity_updates.SetInt("rarity", hArray[i].Get(4));
		
		hArray[i].Clear();
	}
	EndMessage();
}

public Action commandDrop(int client, int args)
{
    Menu hMenu = new Menu(SelectPlayer);
    hMenu.SetTitle("Players");
    char tmp[2][256];
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i))
        {
            if(!IsFakeClient(i))
            {
                Format(tmp[0], sizeof(tmp[]), "%i", i);
                Format(tmp[1], sizeof(tmp[]), "%N (%i)", i, GetClientUserId(i));
                hMenu.AddItem(tmp[0], tmp[1]);                
            }
        }
    }
    hMenu.ExitBackButton = true;
    hMenu.ExitButton = true;
    hMenu.Display(client, 0);
    return Plugin_Handled;
}

public int SelectPlayer(Menu menu, MenuAction action, int param1, int param2)
{
    switch(action)
    {
        case MenuAction_End: delete menu;
        case MenuAction_Select:
        {
            char sItem[256], tmpl[11];
            menu.GetItem(param2, sItem[0], sizeof(sItem));
            hArray[counter] = CreateArray();
            hArray[counter].Push(StringToInt(sItem[0]));
            Menu hMenu = CreateMenu(SelectWeapon);
            hMenu.SetTitle("Weapons");
            for(int i = 0; i < sizeof(g_WeaponClasses); i++)
            {
                IntToString(i, tmpl, sizeof(tmpl));
                hMenu.AddItem(tmpl, g_WeaponClasses[i]);
            }
            hMenu.ExitBackButton = true;
            hMenu.ExitButton = true;
            hMenu.Display(param1, 0);
        }
    }
    return 0;
}

public int SelectWeapon(Menu menu, MenuAction action, int param1, int param2)
{
    switch(action)
    {
        case MenuAction_Cancel: hArray[counter].Clear();
        case MenuAction_End: delete menu;
        case MenuAction_Select:
        {
            char sItem[2][256], tmp[512], section[128], sTest[512], buffer[52][64], tms[16], virtBuf[128];
            menu.GetItem(param2, sItem[0], sizeof(sItem[]), _, sItem[1], sizeof(sItem[]));
            iClientSelectedWeapon[param1] = StringToInt(sItem[0]);
            Menu hMenu = CreateMenu(SelectSkin);
            hMenu.SetTitle("Skins");
            kv.Rewind();
            kv.GotoFirstSubKey();
            do{
                kv.GetString("classes", tmp, sizeof(tmp));
                ExplodeString(tmp, ";", buffer, sizeof(buffer), sizeof(buffer[]));
                Format(sTest, sizeof(sTest), "weapon_%s", g_WeaponClasses[iClientSelectedWeapon[param1]]);
                int indexd;
                for(int i = 0; i < sizeof(buffer); i++)
                {
                    if(StrEqual(sTest, buffer[i]))
                    {
                        kv.GetSectionName(section, sizeof(section));
                        indexd = kv.GetNum("index");
                        IntToString(iClientSelectedWeapon[param1], tms, sizeof(tms));
                        Format(virtBuf, sizeof(virtBuf), "%s;%i", tms, indexd);
                        hMenu.AddItem(virtBuf, section);
                        break;
                    }
                }
            } while(kv.GotoNextKey())                

            hMenu.ExitBackButton = true;
            hMenu.ExitButton = true;
            hMenu.Display(param1, 0);
        }
    }
    return 0;
}

public int SelectSkin(Menu menu, MenuAction action, int param1, int param2)
{
    switch(action)
    {
        case MenuAction_Cancel: hArray[counter].Clear();
        case MenuAction_End: delete menu;
        case MenuAction_Select:
        {
            char sItem[256], sDef[128], stores[2][32];
            menu.GetItem(param2, sDef, sizeof(sDef), _, sItem, sizeof(sItem));
            ExplodeString(sDef, ";", stores, 2, 32);
            kv.Rewind();
            
            itemId[0]++;
            itemId[1]++;

            hArray[counter].PushArray(itemId, 2);
            hArray[counter].Push(StringToInt(stores[0]));
            hArray[counter].Push(StringToInt(stores[1]));
            hArray[counter].Push(6);

            // PrintToChat(param1, "CLIENT = %i", hArray[counter].Get(0));
            // PrintToChat(param1, "ItemID[0] = %i, ItemID[0] = %i", itemId[0], itemId[1]);
            // PrintToChat(param1, "DEF = %i", hArray[counter].Get(2));
            // PrintToChat(param1, "SKIN = %i", hArray[counter].Get(3));
            // PrintToChat(param1, "RARE = %i", hArray[counter].Get(4));

            counter++;
        }
    } 
    return 0;
}