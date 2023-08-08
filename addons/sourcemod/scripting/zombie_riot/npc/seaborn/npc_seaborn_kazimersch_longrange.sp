#pragma semicolon 1
#pragma newdecls required
static const char g_DeathSounds[][] = {
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav",
};

static const char g_HurtSounds[][] = {
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/overthere01.wav",
	"vo/npc/male01/overthere02.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/bow_shoot.wav",
};


void KazimierzLongArcher_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	PrecacheModel(COMBINE_CUSTOM_MODEL);
}

methodmap KazimierzLongArcher < CClotBody
{
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	
	public KazimierzLongArcher(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		KazimierzLongArcher npc = view_as<KazimierzLongArcher>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "17500", ally));
		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");			
		i_NpcInternalId[npc.index] = SEABORN_KAZIMIERZ_LONGARCHER;
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_LONGBOW_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_bow/c_bow.mdl");
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/player/items/scout/spr17_the_lightning_lid/spr17_the_lightning_lid.mdl");
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		
		SDKHook(npc.index, SDKHook_Think, KazimierzLongArcher_ClotThink);
	

		npc.m_iState = 0;
		npc.m_flSpeed = 170.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_bCamo = true;
		
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 500.0);
		
		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 500.0);
		
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 500.0);
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 155, 155, 255, 255);	
		
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 155, 155, 255, 255);	
		
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 155, 155, 255, 255);	


		npc.StartPathing();
		
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void KazimierzLongArcher_ClotThink(int iNPC)
{
	KazimierzLongArcher npc = view_as<KazimierzLongArcher>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	bool camo = true;
	Building_CamoOrRegrowBlocker(npc.index, camo);

	if(npc.m_bCamo)
	{
		if(!camo)
		{
			npc.m_bCamo = false;
			SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 1500.0);
			SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 3000.0);
			SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 1500.0);
			SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 3000.0);
			SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 1500.0);
			SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 3000.0);
		}
	}
	else if(camo)
	{
		npc.m_bCamo = true;
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 500.0);
		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 500.0);
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 350.0);
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 500.0);
	}

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
	
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		
			if(npc.m_flJumpStartTime < GetGameTime(npc.index))
			{
				npc.m_flSpeed = 170.0;
			}
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
				/*
				int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);
				*/
				
				
				
				NPC_SetGoalVector(npc.index, vPredictedPos);
			} else {
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
			
			if(flDistanceToTarget < (800.0*800.0))
			{
				int Enemy_I_See;
				
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					
					//Can we attack right now?
					if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
					{
						npc.m_flSpeed = 0.0;
			//			npc.FaceTowards(vecTarget, 30000.0);
						//Play attack anim
						npc.AddGesture("ACT_LONGBOW_ATTACK");
						
			//			npc.PlayMeleeSound();
			//			npc.FireArrow(vecTarget, 25.0, 1200.0);
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 2.0;
						npc.m_flJumpStartTime = GetGameTime(npc.index) + 1.0;
					}
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
				else
				{
					npc.StartPathing();
					
				}
			}
			else
			{
				npc.StartPathing();
				
			}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public void HandleAnimEventKazimierzLongArcher(int entity, int event)
{
	if(event == 1001)
	{
		KazimierzLongArcher npc = view_as<KazimierzLongArcher>(entity);
		
		int PrimaryThreatIndex = npc.m_iTarget;
	
		if(IsValidEnemy(npc.index, PrimaryThreatIndex))
		{
			float vecTargetPredict[3];
				
			float projectile_speed = 1500.0;
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
			npc.FaceTowards(vecTarget, 30000.0);

			vecTargetPredict = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed);

			float damage = 75.0;
			npc.PlayMeleeSound();
			float AllyPos[3];
			float SelfPos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsClientInGame(client) && IsEntityAlive(client))
				{
					GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", AllyPos);
					float flDistanceToTarget = GetVectorDistance(SelfPos, AllyPos, true);
					if(flDistanceToTarget < (500.0 * 500.0))
					{
						damage = 25.0;
						break;
					}
				}
			}
			if(damage > 50.0)
			{
				for(int entitycount; entitycount<i_MaxcountNpc_Allied; entitycount++) //RED npcs.
				{
					int entity_close = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount]);
					if(IsValidEntity(entity_close))
					{
						CClotBody npcenemy = view_as<CClotBody>(entity_close);
						if(!npcenemy.m_bThisEntityIgnored && IsEntityAlive(entity_close) && !b_NpcIsInvulnerable[entity_close] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity_close]) //Check if dead or even targetable
						{
							GetEntPropVector(entity_close, Prop_Data, "m_vecAbsOrigin", AllyPos);
							float flDistanceToTarget = GetVectorDistance(SelfPos, AllyPos, true);
							if(flDistanceToTarget < (500.0 * 500.0))
							{
								damage = 25.0;
								break;
							}
						}
					}
				}
			}

			if(damage < 50.0)
			{
				npc.FireArrow(vecTarget, damage, projectile_speed);
			}
			else
			{
				npc.FireArrow(vecTargetPredict, damage, projectile_speed);
			}
		}
	}
	
}

public Action KazimierzLongArcher_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	KazimierzLongArcher npc = view_as<KazimierzLongArcher>(victim);
	
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

public void KazimierzLongArcher_NPCDeath(int entity)
{
	KazimierzLongArcher npc = view_as<KazimierzLongArcher>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, KazimierzLongArcher_ClotThink);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}