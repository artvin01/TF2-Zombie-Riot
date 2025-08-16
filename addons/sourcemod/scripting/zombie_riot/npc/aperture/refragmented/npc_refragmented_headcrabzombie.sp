#pragma semicolon 1
#pragma newdecls required
 
static char g_DeathSounds[][] = {
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav",
};

static char g_HurtSounds[][] = {
	"npc/zombie/zombie_pain1.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain3.wav",
	"npc/zombie/zombie_pain4.wav",
	"npc/zombie/zombie_pain5.wav",
	"npc/zombie/zombie_pain6.wav",
};

static char g_IdleSounds[][] = {
	"npc/zombie/zombie_voice_idle1.wav",
	"npc/zombie/zombie_voice_idle2.wav",
	"npc/zombie/zombie_voice_idle3.wav",
	"npc/zombie/zombie_voice_idle4.wav",
	"npc/zombie/zombie_voice_idle5.wav",
	"npc/zombie/zombie_voice_idle6.wav",
	"npc/zombie/zombie_voice_idle7.wav",
	"npc/zombie/zombie_voice_idle8.wav",
	"npc/zombie/zombie_voice_idle9.wav",
	"npc/zombie/zombie_voice_idle10.wav",
	"npc/zombie/zombie_voice_idle11.wav",
	"npc/zombie/zombie_voice_idle12.wav",
	"npc/zombie/zombie_voice_idle13.wav",
	"npc/zombie/zombie_voice_idle14.wav",
};

static char g_IdleAlertedSounds[][] = {
	"npc/zombie/zombie_alert1.wav",
	"npc/zombie/zombie_alert2.wav",
	"npc/zombie/zombie_alert3.wav",
};

static char g_MeleeHitSounds[][] = {
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav",
};
static char g_MeleeAttackSounds[][] = {
	"npc/zombie/zo_attack1.wav",
	"npc/zombie/zo_attack2.wav",
};

static char g_MeleeMissSounds[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};

/*
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "TestName");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_test");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);

	#define MVM_CLASS_FLAG_NONE				0
	#define MVM_CLASS_FLAG_NORMAL			(1 << 0)	// Base Normal
	#define MVM_CLASS_FLAG_SUPPORT			(1 << 1)	// Base Support
	#define MVM_CLASS_FLAG_MISSION			(1 << 2)	// Base Support, Always Show
	#define MVM_CLASS_FLAG_MINIBOSS			(1 << 3)	// Add Red Background
	#define MVM_CLASS_FLAG_ALWAYSCRIT		(1 << 4)	// Add Blue Borders
	#define MVM_CLASS_FLAG_SUPPORT_LIMITED	(1 << 5)	// Add to Support?

	Type_Hidden = -1,
	Type_Ally = 0,
	Type_Special,
	Type_Raid,
	Type_Common,
	Type_Alt,
	Type_Xeno,
	Type_BTD,
	Type_Medieval,
	Type_COF,
	Type_Seaborn,
	Type_Expidonsa,
	Type_Interitus

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return TestNpcSpawn(vecPos, vecAng, team);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return TestNpcSpawn(vecPos, vecAng, team, data);
}
		If barracks
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = _NPCDeath;
		func_NPCThink[npc.index] = _ClotThink;


		func_NPCDeath[npc.index] = _NPCDeath;
		func_NPCOnTakeDamage[npc.index] = _OnTakeDamage;
		func_NPCThink[npc.index] = _ClotThink;
		func_NPCAnimEvent[npc.index] = INVALID_FUNCTION;
	
*/

public void RefragmentedHeadcrabZombie_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }

//	g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");

	PrecacheSound("player/flow.wav");
	PrecacheModel("models/zombie/classic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Refragmented Headcrab Zombie");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_refragmented_headcrabzombie");
	strcopy(data.Icon, sizeof(data.Icon), "norm_headcrab_zombie");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return RefragmentedHeadcrabZombie(vecPos, vecAng, team);
}

methodmap RefragmentedHeadcrabZombie < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		
	}
	
	
	
	public RefragmentedHeadcrabZombie(float vecPos[3], float vecAng[3], int ally)
	{
		RefragmentedHeadcrabZombie npc = view_as<RefragmentedHeadcrabZombie>(CClotBody(vecPos, vecAng, "models/zombie/classic.mdl", "1.15", "300", ally, false));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		npc.m_flMeleeArmor = 0.10;
		npc.m_flRangedArmor = 0.10;

		//This is the guy responsible for the sick ass unusual effect attached to the npc
		//Originally wasn't a wearable, had to be made a wearable though because tf2 code is gay and flame particles remove the unusual effect
		npc.m_iWearable1 = TF2_CreateGlow_White("models/zombie/classic.mdl", npc.index, 1.15);
		if(IsValidEntity(npc.m_iWearable1))
		{
			SetEntProp(npc.m_iWearable1, Prop_Send, "m_bGlowEnabled", false);
			SetEntityRenderMode(npc.m_iWearable1, RENDER_ENVIRONMENTAL);
			TE_SetupParticleEffect("utaunt_signalinterference_parent", PATTACH_ABSORIGIN_FOLLOW, npc.m_iWearable1);
			TE_WriteNum("m_bControlPoint1", npc.m_iWearable1);	
			TE_SendToAll();
		}

		//MUST be set to render_glow, otherwise aforementioned unusual effect will overlap with the npc's transparent-ness and it'll look shit
		SetEntityRenderMode(npc.index, RENDER_GLOW);
		SetEntityRenderColor(npc.index, 0, 0, 125, 200);
		
		//IDLE
		npc.m_flSpeed = 200.0;
		func_NPCDeath[npc.index] = RefragmentedHeadcrabZombie_NPCDeath;
		func_NPCThink[npc.index] = RefragmentedHeadcrabZombie_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		
		npc.StartPathing();
		
		return npc;
	}
	
}


public void RefragmentedHeadcrabZombie_ClotThink(int iNPC)
{
	RefragmentedHeadcrabZombie npc = view_as<RefragmentedHeadcrabZombie>(iNPC);
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		if(!npc.m_flAttackHappenswillhappen)
			npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
		npc.StartPathing();
		//PluginBot_NormalJump(npc.index);
	}
	
	int closest = npc.m_iTarget;

	//Shitty poopy code but it works, if you're close enough and if you're not a building, the npc will take true damage-damage
	float vecTarget2[3]; WorldSpaceCenter(closest, vecTarget2);
	float VecSelfNpc2[3]; WorldSpaceCenter(npc.index, VecSelfNpc2);
	float distance = GetVectorDistance(vecTarget2, VecSelfNpc2, true);
	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.25) && !i_IsABuilding[closest])
	{
		npc.PlayHurtSound();
		SDKHooks_TakeDamage(npc.index, closest, closest, 10.0, DMG_TRUEDAMAGE, -1, _, vecMe);
		//Explode_Logic_Custom(10.0, npc.index, npc.index, -1, vecMe, 15.0, _, _, false, 1, false);
		SetEntityRenderColor(npc.index, 180, 0, 0, 200);
	}
	if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.25) && !i_IsABuilding[closest])
	{
		SetEntityRenderColor(npc.index, 0, 0, 125, 200);
	}
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
			
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, closest,_,_, vPredictedPos);
	//		PrintToChatAll("cutoff");
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(closest);
		}
		
		//Target close enough to hit
		
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
		{
			//Look at target so we hit.
		//	npc.FaceTowards(vecTarget, 20000.0);
			
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				//Play attack ani
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MELEE_ATTACK1");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.7;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.83;
					npc.m_flAttackHappenswillhappen = true;
				}
				//Can we attack right now?
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, closest))
					{
						npc.m_iOverlordComboAttack++;
						if(npc.m_iOverlordComboAttack >= 5)
						{
							float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
							float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
							int spawn_index = NPC_CreateByName("npc_refragmented_headcrabzombie", -1, pos, ang, TFTeam_Blue);
							if(spawn_index > MaxClients)
							{
								NpcStats_CopyStats(npc.index, spawn_index);
								NpcAddedToZombiesLeftCurrently(spawn_index, true);
								SetEntProp(spawn_index, Prop_Data, "m_iHealth", 1000);
								SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 1000);
							}
							npc.m_iOverlordComboAttack = 0;
						}
						int target = TR_GetEntityIndex(swingTrace);	
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						if(target > 0) 
						{
							{
								if(!ShouldNpcDealBonusDamage(target))
									SDKHooks_TakeDamage(target, npc.index, npc.index, 50.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 80.0, DMG_CLUB, -1, _, vecHit);					
							}
							
							
								
							// Hit sound
							npc.PlayMeleeHitSound();
						}
						else
						{
							npc.PlayMeleeMissSound();
						}
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.2;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.2;
				}
			}
			
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

public void RefragmentedHeadcrabZombie_NPCDeath(int entity)
{
	RefragmentedHeadcrabZombie npc = view_as<RefragmentedHeadcrabZombie>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}