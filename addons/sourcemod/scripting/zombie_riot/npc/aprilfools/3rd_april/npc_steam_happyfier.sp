#pragma semicolon 1
#pragma newdecls required

static const char g_IdleAlertedSounds[][] = {
	"zombie_riot/yippe.mp3",
};

static int NPCID;
void SteamHappyfier_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Steam Happy");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_steam_happyfier");
	strcopy(data.Icon, sizeof(data.Icon), "steamhhappy");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = -1;
	data.Func = ClotSummon;
	NPCID = NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return SteamHappyfier(vecPos, vecAng, team);
}

methodmap SteamHappyfier < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
	}
	
	public SteamHappyfier(float vecPos[3], float vecAng[3], int ally)
	{
		SteamHappyfier npc = view_as<SteamHappyfier>(CClotBody(vecPos, vecAng, "models/steamhappy.mdl", "1.5", "900", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = view_as<Function>(SteamHappyfier_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(SteamHappyfier_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(SteamHappyfier_ClotThink);
		
		
		
		npc.StartPathing();
		npc.m_flSpeed = 150.0;
		
		
		return npc;
	}
}

public void SteamHappyfier_ClotThink(int iNPC)
{
	SteamHappyfier npc = view_as<SteamHappyfier>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		SteamHappyfierSelfDefense(npc,GetGameTime(npc.index)); 
	}
	npc.PlayIdleAlertSound();
}

public Action SteamHappyfier_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	SteamHappyfier npc = view_as<SteamHappyfier>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void SteamHappyfier_NPCDeath(int entity)
{
	
}

void SteamHappyfierSelfDefense(SteamHappyfier npc, float gameTime)
{
	b_NpcIsTeamkiller[npc.index] = true;
	Explode_Logic_Custom(0.0,
	npc.index,
	npc.index,
	-1,
	_,
	300.0,
	_,
	_,
	true,
	99,
	false,
	_,
	GiveSteamhappyBuff);
	b_NpcIsTeamkiller[npc.index] = false;

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		npc.m_flNextMeleeAttack = gameTime + 0.5;
		i_ExplosiveProjectileHexArray[npc.index] |= EP_DEALS_CLUB_DAMAGE;
		float radius = 160.0, damage = 150.0;
		float Loc[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Loc);
		Explode_Logic_Custom(damage, npc.index, npc.index, -1, _, radius, _, _, true);
		spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 1.0, "materials/sprites/laserbeam.vmt", 255, 200, 200, 255, 1, 0.2, 8.0, 1.5, 1, radius*2.0);
		spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 255, 200, 200, 255, 1, 0.2, 8.0, 1.5, 1, radius*2.0);
		spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", 255, 200, 200, 255, 1, 0.2, 8.0, 1.5, 1, radius*2.0);
		spawnRing_Vectors(Loc, 0.1, 0.0, 0.0, 65.0, "materials/sprites/laserbeam.vmt", 255, 200, 200, 255, 1, 0.2, 8.0, 1.5, 1, radius*2.0);
	}
}
void GiveSteamhappyBuff(int entity, int victim, float damage, int weapon)
{
	if(entity == victim)
		return;

	if (GetTeam(victim) == GetTeam(entity) && !i_IsABuilding[victim] && !b_NpcHasDied[victim])
	{
		if(NPCID == i_NpcInternalId[victim])
			return;
	
		ApplyStatusEffect(victim, victim, "Steam Happy Prefix", 999999.9);
	}
}