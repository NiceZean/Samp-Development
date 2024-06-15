#define MAX_DAMAGE 500

enum E_DLOG
{
	dlOwner,
	dlTarget[MAX_PLAYER_NAME + 1],
	dlBody,
	dlWeapon,
	Float:dlDamage,
};

new DamageData[MAX_DAMAGE][E_DLOG],
Iterator: DamageLog<MAX_DAMAGE>;

new GetDamageID[MAX_PLAYERS];

CMD:damagelogs(playerid, params[])
{
	if(GetPlayerDamageLog(playerid) <= 0)
		return Error(playerid, "Anda tidak ditembak.");

	new id, count = GetPlayerDamageLog(playerid), strings[5024], lstr[5024], partname[128];

	strcat(strings,"Dari\tSenjata\tDamage\tBagian badan\tWaktu\n", sizeof(strings));
	Looping(itt, (count +1))
	{
		id = ReturnPlayerDamageLogID(playerid, itt);
		if(DamageData[id][dlBody] == 3)
		{
			partname = "Kote";
		}
		else if(DamageData[id][dlBody] == 4)
		{
			partname = "Paha";
		}
		else if(DamageData[id][dlBody] == 5)
		{
			partname = "Tangan Kiri";
		}
		else if(DamageData[id][dlBody] == 6)
		{
			partname = "Tangan Kanan";
		}
		else if(DamageData[id][dlBody] == 7)
		{
			partname = "Kaki Kiri";
		}
		else if(DamageData[id][dlBody] == 8)
		{
			partname = "Kaki Kanan";
		}
		else if(DamageData[id][dlBody] == 9)
		{
			partname = "Kepala";
		}
		else
		{
			partname = "Tidak Di Ketahui";
		}
		if(itt == count)
		{
			format(lstr, sizeof(lstr), "%s\t%s\t%0.1f\n", DamageData[id][dlTarget], ReturnWeaponName(DamageData[id][dlWeapon]), DamageData[id][dlDamage], partname, ReturnTime());
		}
		else format(lstr ,sizeof(lstr), "%s\t%s\t%0.1f\t%s\n", DamageData[id][dlTarget], ReturnWeaponName(DamageData[id][dlWeapon]), DamageData[id][dlDamage], partname, ReturnTime());
		strcat(strings, lstr, sizeof(strings));
	}
	ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_TABLIST_HEADERS, "Damage Logs", strings, "Close", "");
	return 1;
}

GetPlayerNameDamage(playerid)
{
    new name[ 64 ];
    GetPlayerName(playerid, name, sizeof( name ));
    return name;
}

CreateDamageLog(playerid, Float:amount, weaponid, bodypart)
{
	new dlid = Iter_Free(DamageLog);

	if(dlid >= MAX_DAMAGE)
		return 1;
	
	DamageData[dlid][dlOwner] = playerid;
	DamageData[dlid][dlDamage] = amount;
	DamageData[dlid][dlWeapon] = weaponid;
	DamageData[dlid][dlBody] = bodypart;
	if(GetDamageID[playerid] != INVALID_PLAYER_ID)
	{
 		format(DamageData[dlid][dlTarget], MAX_PLAYER_NAME, GetPlayerNameDamage(GetDamageID[playerid]));
 	}
 	else
 	{
 		format(DamageData[dlid][dlTarget], MAX_PLAYER_NAME, "Tidak DiKetahui");
 	}

 	GetDamageID[playerid] = INVALID_PLAYER_ID;

	Iter_Add(DamageLog, dlid);

	if(GetPlayerDamageLog(playerid) > 20)
	{
		Player_ResetDamageLog(playerid);
	}
	return 1;
}

Player_ResetDamageLog(playerid)
{
	for(new i = 0; i != MAX_DAMAGE; i++)
	{
		if(Iter_Contains(DamageLog, i))
		{
			if(DamageData[i][dlOwner] == playerid)
			{
				DamageData[i][dlOwner] = INVALID_PLAYER_ID;
				GetDamageID[playerid] = INVALID_PLAYER_ID;
				Iter_Remove(DamageLog, i);
			}
		}
	}
}

GetPlayerDamageLog(playerid)
{
	new tmpcount = 0;
	foreach(new dlid : DamageLog)
	{
		if(DamageData[dlid][dlOwner] == playerid)
		{
			tmpcount++;
		}
	}
	return tmpcount;
}

ReturnPlayerDamageLogID(playerid, hslot)
{
	new tmpcount = 0;
	if(hslot < 1 && hslot > MAX_DAMAGE) return 1;

	foreach(new dlid : DamageLog)
	{
		if(DamageData[dlid][dlOwner] == playerid)
		{
			tmpcount++;
			if(tmpcount == hslot)
			{
				return dlid;
			}
		}
	}
	return -1;
}

//connect
	GetDamageID[playerid] = INVALID_PLAYER_ID;

//disconnect
	Player_ResetDamageLog(playerid);

//weaponshot
	if(1 <= weaponid <= 46)
	{
		if(hittype == 1 && GetDamageID[hitid] == INVALID_PLAYER_ID)
		{
			GetDamageID[hitid] = playerid;
		}
		if(IsPlayerInRangeOfPoint(playerid, 300.0, 1176.557739, -1323.968994, 14.027276)) return Info(playerid, "Anda berada di zona hijau jangan rusuh!!!");
	}

//takedamage
	CreateDamageLog(playerid, Float:amount, weaponid, bodypart);
