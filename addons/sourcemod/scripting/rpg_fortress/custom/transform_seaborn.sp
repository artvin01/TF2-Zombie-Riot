static int ParticleRef[MAXPLAYERS] = {-1, ...};
static float CreepPos[MAXPLAYERS][3];
static float CreepSize[MAXPLAYERS];
static float MeleeRes[MAXPLAYERS] = {1.0, ...};
static float RangedRes[MAXPLAYERS] = {1.0, ...};
static int WeaponRes[MAXPLAYERS] = {-1, ...};
static Handle CreepTimer;
static int Sprite;

void Transform_Seaborn_MapStart()
{
	PrecacheSound("player/souls_receive2.wav");
	PrecacheSound("player/souls_receive3.wav");
	PrecacheSound("misc/halloween/spell_spawn_boss.wav");
	PrecacheSound("misc/halloween/spell_spawn_boss_disappear.wav");
	PrecacheSound("ambient/halloween/male_scream_04.wav");
	PrecacheSound("ambient/halloween/male_scream_13.wav");
	PrecacheSound("ambient/halloween/male_scream_17.wav");

	Sprite = PrecacheModel("materials/sprites/laserbeam.vmt");

	Zero(CreepSize);
}

static void CleanEffects(int client)
{
	if(ParticleRef[client] != -1)
	{
		int entity = EntRefToEntIndex(ParticleRef[client]);
		if(entity != -1)
		{
			AcceptEntityInput(entity, "ClearParent");
			TeleportEntity(entity, {16000.0,16000.0,16000.0});
			CreateTimer(0.1, Timer_RemoveEntity, ParticleRef[client], TIMER_FLAG_NO_MAPCHANGE);
		}
		
		ParticleRef[client] = -1;
	}

	CreepSize[client] = 0.0;
	ResetRes(client);
}

static void ResetRes(int client)
{
	if(WeaponRes[client] != -1)
	{
		int weapon = EntRefToEntIndex(WeaponRes[client]);
		if(weapon != -1)
		{
			if(MeleeRes[client] != 1.0)
				Attributes_SetMulti(weapon, 206, 1.0 / MeleeRes[client]);

			if(RangedRes[client] != 1.0)
				Attributes_SetMulti(weapon, 205, 1.0 / RangedRes[client]);
		}

		MeleeRes[client] = 1.0;
		RangedRes[client] = 1.0;
		WeaponRes[client] = -1;
	}
}

public void Seaborn_Activation_Enable_form_1(int client)
{
	CleanEffects(client);

	EmitSoundToAll("player/souls_receive3.wav", client, SNDCHAN_AUTO, 80);
	
	float pos[3]; GetClientAbsOrigin(client, pos);
	pos[2] += 1.0;

	int entity = ParticleEffectAt(pos, "utaunt_hands_floor2_blue", -1.0);
	if(entity > MaxClients)
	{
		SetParent(client, entity);
		ParticleRef[client] = EntIndexToEntRef(entity);
	}
}

public void Seaborn_Activation_Disable_form_1(int client)
{
	CleanEffects(client);

	EmitSoundToAll("player/souls_receive2.wav", client, SNDCHAN_AUTO, 80);
}

public void Seaborn_Activation_Enable_form_2(int client)
{
	CleanEffects(client);

	EmitSoundToAll("misc/halloween/spell_spawn_boss.wav", client, SNDCHAN_AUTO, 80);

	float pos[3]; GetClientAbsOrigin(client, pos);
	pos[2] += 1.0;

	ParticleEffectAt(pos, "halloween_boss_summon", 8.0);
	
	int entity, i;
	while(TF2U_GetWearable(client, entity, i))
	{
		SetEntityRenderColor(entity, 125, 125, 255, 255);
		SetTeam(entity, 3);
		SetEntProp(entity, Prop_Send, "m_nSkin", 1);
	}	
	
	GetClientAbsOrigin(client, CreepPos[client]);
	CreepPos[client][2] += 1.0;
	entity = ParticleEffectAt(CreepPos[client], "utaunt_spirit_winter_base", -1.0);
	if(entity > MaxClients)
	{
		SetParent(client, entity);
		ParticleRef[client] = EntIndexToEntRef(entity);
	}
}

public void Seaborn_Activation_Disable_form_2(int client)
{
	CleanEffects(client);

	EmitSoundToAll("misc/halloween/spell_spawn_boss_disappear.wav", client, SNDCHAN_AUTO, 80);

	float pos[3]; GetClientAbsOrigin(client, pos);
	pos[2] += 1.0;
	
	ParticleEffectAt(pos, "halloween_boss_death", 1.0);
	int entity, i;
	while(TF2U_GetWearable(client, entity, i))
	{
		SetEntityRenderMode(entity, RENDER_NORMAL);
		SetEntityRenderColor(entity, 255, 255, 255, 255);
		SetTeam(entity, 2);
		SetEntProp(entity, Prop_Send, "m_nSkin", 0);
	}	

}

public bool Seaborn_Activation_Require_form_3(int client)
{
	Race race;
	if(Races_GetRaceByIndex(RaceIndex[client], race) && race.Forms)
	{
		Form form;
		race.Forms.GetArray(1, form);

		float MasteryHas = Stats_GetFormMastery(client, form.Name);
		float MasteryMax = form.Mastery;
		
		if(MasteryHas / MasteryMax >= 0.75)
		{
			return true;
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			ShowGameText(client,"leaderboard_streak", 0, "Your previous form needs to be mastered by 75 Percent.");
		}

	}
	return false;
}

public void Seaborn_Activation_Enable_form_3(int client)
{
	CleanEffects(client);

	EmitSoundToAll("ambient/halloween/male_scream_13.wav", client, SNDCHAN_AUTO, 80);
	
	GetClientAbsOrigin(client, CreepPos[client]);
	CreepPos[client][2] += 1.0;

	float maxMastery;
	float mastery = Stats_GetCurrentFormMastery(client, maxMastery);

	int entity, i;
	while(TF2U_GetWearable(client, entity, i))
	{
		SetEntityRenderColor(entity, 0, 0, 255, 255);
		SetTeam(entity, 3);
		SetEntProp(entity, Prop_Send, "m_nSkin", 1);
	}	
	bool rage;
	if(maxMastery)
	{
		if(mastery > (maxMastery / 4.0))
		{
			EmitSoundToAll("ambient/halloween/male_scream_04.wav", client, SNDCHAN_AUTO, 80);
			CreepSize[client] = 400.0 + (mastery * 400.0 / maxMastery);
			rage = true;
		}
		else
		{
			CreepSize[client] = 300.0;
		}
	}

	entity = ParticleEffectAt(CreepPos[client], rage ? "utaunt_fish_parent" : "utaunt_fish_base2", -1.0);
	if(entity > MaxClients)
	{
		SetParent(client, entity);
		ParticleRef[client] = EntIndexToEntRef(entity);
	}

	if(!CreepTimer)
		CreepTimer = CreateTimer(0.5, Timer_CreepThink, _, TIMER_REPEAT);
}

public void Seaborn_TakeDamage_form_3(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(CreepSize[victim] > 400.0)
	{
		int holding = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
		if(holding == -1)
			return;
		
		int ref = EntIndexToEntRef(holding);
		if(WeaponRes[victim] != -1 && WeaponRes[victim] != ref)
			ResetRes(victim);
		
		WeaponRes[victim] = ref;

		if(damagetype & (DMG_TRUEDAMAGE|DMG_OUTOFBOUNDS))
		{
		}
		else if(damagetype & DMG_CLUB)
		{
			if(MeleeRes[victim] > 0.5)
			{
				MeleeRes[victim] *= 0.95;
				Attributes_SetMulti(holding, 206, 0.95);
			}

			if(RangedRes[victim] < 1.3)
			{
				RangedRes[victim] *= 1.03;
				Attributes_SetMulti(holding, 205, 1.03);
			}
		}
		else
		{
			if(RangedRes[victim] > 0.5)
			{
				RangedRes[victim] *= 0.95;
				Attributes_SetMulti(holding, 205, 0.95);
			}

			if(MeleeRes[victim] < 1.3)
			{
				MeleeRes[victim] *= 1.03;
				Attributes_SetMulti(holding, 206, 1.03);
			}
		}
	}
}

static Action Timer_CreepThink(Handle timer)
{
	bool found;

	for(int client = 1; client <= MaxClients; client++)
	{
		if(CreepSize[client])
		{
			if(IsClientInGame(client) && IsPlayerAlive(client))
			{
				found = true;

				if(CreepSize[client] < 400.0)
				{
					CreepSize[client] += 5.0;
					if(CreepSize[client] > 399.0)
						CreepSize[client] = 399.0;
				}
				else if(CreepSize[client] < 800.0)
				{
					CreepSize[client] += 5.0;
				}

				int targets;
				static int target[12];
				static float pos[3];
				float size = CreepSize[client] * CreepSize[client];

				for(int ally = 1; ally <= MaxClients; ally++)
				{
					if(ally != client)
					{
						if(!IsClientInGame(ally) || (RaceIndex[client] != RaceIndex[ally] && IsPlayerAlive(ally)))
							continue;
					}
					
					if(targets < sizeof(target))
						target[targets++] = ally;

					if(!IsPlayerAlive(ally))
						continue;

					GetEntPropVector(ally, Prop_Send, "m_vecOrigin", pos);
					if(GetVectorDistance(pos, CreepPos[client], true) < size)
						TF2_AddCondition(ally, TFCond_SpeedBuffAlly, 0.55, client);
				}

				TE_SetupBeamRingPoint(CreepPos[client], CreepSize[client] * 1.99, CreepSize[client] * 2.0, Sprite, Sprite, 0, 1, 0.5, 12.0, 0.1, {55, 55, 255, 255}, 1, 0);
				TE_Send(target, targets);

				continue;
			}

			CreepSize[client] = 0.0;
		}
	}

	if(found)
		return Plugin_Continue;
	
	CreepTimer = null;
	return Plugin_Stop;
}

public void Seaborn_Activation_Disable_form_3(int client)
{
	CleanEffects(client);

	int entity, i;
	while(TF2U_GetWearable(client, entity, i))
	{
		SetEntityRenderMode(entity, RENDER_NORMAL);
		SetEntityRenderColor(entity, 255, 255, 255, 255);
		SetTeam(entity, 2);
		SetEntProp(entity, Prop_Send, "m_nSkin", 0);
	}	
	EmitSoundToAll("ambient/halloween/male_scream_17.wav", client, SNDCHAN_AUTO, 80);
}
