#pragma semicolon 1
#pragma newdecls required

//stolen from ruina
int BEAM_Combine_Black;
int BEAM_Combine_Phys;

void Mage_Oblitiration_Shot_Map_Precache()
{
	BEAM_Combine_Black 	= PrecacheModel("materials/sprites/laserbeam.vmt", true);
	BEAM_Combine_Phys 	= PrecacheModel("materials/sprites/physbeam.vmt", true);
	PrecacheSound("npc/vort/attack_shoot.wav");
	PrecacheSound("npc/vort/attack_charge.wav");
}

public float AbilityOblitirationShot(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(!kv)
	{
		return 0.0;
	}

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon))
	{
		return 0.0;
	}

	static char classname[36];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if (!i_IsWandWeapon[weapon])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Magic Wand.");
		return 0.0;
	}
	if(Stats_Intelligence(client) < 750)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [750]");
		return 0.0;
	}

	int StatsForCalcMultiAdd;
	Stats_Artifice(client, StatsForCalcMultiAdd);
	StatsForCalcMultiAdd /= 4;
	//get base endurance for cost
	if(i_CurrentStamina[client] < StatsForCalcMultiAdd)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Stamina");
		return 0.0;
	}

	int StatsForCalcMultiAdd_Capacity;

	StatsForCalcMultiAdd_Capacity = StatsForCalcMultiAdd * 2;

	if(Current_Mana[client] < StatsForCalcMultiAdd_Capacity)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Mana");
		return 0.0;
	}
	float Time = 20.0;
	if(ChronoShiftReady(client) == 2)
	{
		ChronoShiftDoCooldown(client);
		Time = 0.0;
	}
	else
	{
		RPGCore_StaminaReduction(weapon, client, StatsForCalcMultiAdd / 2);
	}
	RPGCore_ResourceReduction(client, StatsForCalcMultiAdd_Capacity);
	
	StatsForCalcMultiAdd = Stats_Artifice(client);

	float damageDelt = RPGStats_FlatDamageSetStats(client, 0, StatsForCalcMultiAdd);

	damageDelt *= 3.6;

	Weapon_Wand_OblitirationShot(client, 1, weapon, damageDelt);

	return (GetGameTime() + Time);
}

int BeamTargets_HitWhoFirst[MAXENTITIES];

int BeamTargets_HitConfirmed[MAXENTITIES];

public void Weapon_Wand_OblitirationShot(int client, int weapon, int level, float damage)
{
	float eyePos[3];
	float eyeAng[3];
	float vecEndGoal[3];
			   
	StartLagCompensation_Base_Boss(client);

	Zero(BeamTargets_HitWhoFirst);
	Zero(BeamTargets_HitConfirmed);
	//The first trace gets all enemies hit (HITSCAN, NOT COLLISION HIT!!!)
	GetClientEyePosition(client, eyePos);
	GetClientEyeAngles(client, eyeAng);
	Handle trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, BEAM_TraceUsers, client);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(vecEndGoal, trace);
	} 	
	delete trace;		
	//We save vecEndGoal for later!
	float Fatness = 7.0;
	if(MagicFocusReady(client))
		Fatness *= 0.5;

	float Duration = 0.44;
	float Amplitude = 12.0;
	float OffsetOfRocket[3];
	OffsetOfRocket = {0.0, -20.0, 0.0};
	float EyesBelowClient[3];
	GetBeamDrawStartPoint_Stock(client, EyesBelowClient, OffsetOfRocket);
	if(MagicFocusReady(client))
	{
		TE_SetupBeamPoints(EyesBelowClient, vecEndGoal, BEAM_Combine_Phys, BEAM_Combine_Phys, 0, 44, Duration, Fatness, Fatness, 0, Amplitude,  {25,25,255,200}, 3);
		TE_SendToAll(0.0);
	}
	else
	{
		TE_SetupBeamPoints(EyesBelowClient, vecEndGoal, BEAM_Combine_Phys, BEAM_Combine_Phys, 0, 44, Duration, Fatness, Fatness, 0, Amplitude,  {255,210,25,200}, 3);
		TE_SendToAll(0.0);
	}

	
	for(int i=0; i < (4); i++)
	{
		Fatness *= 1.15;
		Duration -= 0.11;
		if(Duration <= 0.11)
			Duration = 0.11;
		Amplitude *= 1.3;
		if(MagicFocusReady(client))
		{
			TE_SetupBeamPoints(EyesBelowClient, vecEndGoal, BEAM_Combine_Black, BEAM_Combine_Phys, 0, 44, Duration, Fatness, Fatness, 0, Amplitude,  {25,25,255,100}, 3);
			TE_SendToAll(0.0);
		}
		else
		{
			TE_SetupBeamPoints(EyesBelowClient, vecEndGoal, BEAM_Combine_Black, BEAM_Combine_Phys, 0, 44, Duration, Fatness, Fatness, 0, Amplitude,  {255,210,25,100}, 3);
			TE_SendToAll(0.0);			
		}
	}
	DataPack pack_boom = new DataPack();
	pack_boom.WriteFloat(vecEndGoal[0]);
	pack_boom.WriteFloat(vecEndGoal[1]);
	pack_boom.WriteFloat(vecEndGoal[2]);
	pack_boom.WriteCell(0);
	RequestFrame(MakeExplosionFrameLater, pack_boom);
	EmitAmbientSound("ambient/explosions/explode_3.wav", vecEndGoal, _, 90, _,0.7, GetRandomInt(75, 110));
	TE_Particle("hightower_explosion", vecEndGoal, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0, .clientspec = client);
	TE_Particle("mvm_soldier_shockwave", EyesBelowClient, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	Client_Shake(client, 0, 35.0, 20.0, 0.8);
	EmitSoundToAll("npc/vort/attack_shoot.wav", client, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,120);	
	
	float vecTempHit[3];
	for(int i=0; i < (MAXENTITIES); i++)
	{
		int HitEnemy = BeamTargets_HitWhoFirst[i];
		if(HitEnemy)
		{
			//We have a confirmed hit on someone. Lets do a check.
			bool HeadshotDone = false;
			trace = TR_TraceRayFilterEx(eyePos, eyeAng, MASK_SHOT, RayType_Infinite, BEAM_TraceUsersConfirm, HitEnemy);
			if (TR_DidHit(trace))
			{
				int target = TR_GetEntityIndex(trace);
				//its confirmed to hit the same target.
				if (target == HitEnemy)
				{
					//its confirmed to be a headshot.
					HeadshotDone = (TR_GetHitGroup(trace) == HITGROUP_HEAD && !b_CannotBeHeadshot[HitEnemy]);
				}
				TR_GetEndPosition(vecTempHit, trace);
			} 	
			if(MagicFocusReady(client))
			{
				ApplyStatusEffect(client, HitEnemy, "Teslar Shock", 5.0);
			}
			float DamageDiff = damage;
			if(HeadshotDone)
			{
				DisplayCritAboveNpc(HitEnemy, client, true);
				DamageDiff *= 2.0;
			}

			SDKHooks_TakeDamage(HitEnemy, client, client, DamageDiff, DMG_PLASMA, -1, NULL_VECTOR, vecTempHit);
			delete trace;		
		}
		else
		{
			//There are no more targets left to hit, lets cancel everything.
			break;
		}
	}
	
	Explode_Logic_Custom(damage * 0.75, client, client, -1, vecEndGoal, 150.0, 1.45, _, false);

	MagicFocusUse(client);
	FinishLagCompensation_Base_boss();

	
	delete trace;
}



static bool BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if(IsValidEnemy(client, entity))
	{
		for(int i=0; i < (MAXENTITIES); i++)
		{
			if(!BeamTargets_HitWhoFirst[i])
			{
				BeamTargets_HitWhoFirst[i] = entity;
				break;
			}
		}
	}
	return false;
}

static bool BEAM_TraceUsersConfirm(int entity, int contentsMask, int confirmedTarget)
{
	for(int i=0; i < (MAXENTITIES); i++)
	{
		int HitEnemy = BeamTargets_HitWhoFirst[i];
		if(HitEnemy == confirmedTarget)
		{
			return true;
		}
	}
	return false;
}
