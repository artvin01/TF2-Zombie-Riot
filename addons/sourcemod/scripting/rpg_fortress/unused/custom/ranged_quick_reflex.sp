void QuickReflex_MapStart()
{
	PrecacheSound("items/powerup_pickup_haste.wav");
}

public float AbilityQuickReflex(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(weapon))
		{
			static char classname[36];
			GetEntityClassname(weapon, classname, sizeof(classname));
			if (TF2_GetClassnameSlot(classname) != TFWeaponSlot_Melee && !i_IsWandWeapon[weapon] && !i_IsWrench[weapon])
			{
				if(Stats_Dexterity(client) >= 20)
				{
					Ability_QuickReflex(client, 1, weapon);
					return (GetGameTime() + 30.0);
				}
				else
				{
					ClientCommand(client, "playgamesound items/medshotno1.wav");
					ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Dexterity [20]");
					return 0.0;
				}

			}
			else
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Ranged Weapon.");
				return 0.0;
			}
		}

	//	if(kv.GetNum("consume", 1))

	}
	return 0.0;
}

public void Ability_QuickReflex(int client, int level, int weapon)
{
	float flPos[3];
	float flAng[3];
	GetAttachment(client, "head", flPos, flAng);		
	int particler = ParticleEffectAt(flPos, "scout_dodge_red", 6.0);
	SetParent(client, particler, "head");

	EmitSoundToAll("items/powerup_pickup_haste.wav", client, _, 70);
	ApplyTempAttrib(weapon, 6, 0.65, 5.0);
	ApplyTempAttrib(weapon, 97, 0.65, 5.0);
	Attributes_Set(client, 442, 1.35);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
	CreateTimer(5.0, Timer_UpdateMovementSpeed, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_UpdateMovementSpeed(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{
		Attributes_Set(client, 442, 1.0);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
	}
	return Plugin_Handled;
}