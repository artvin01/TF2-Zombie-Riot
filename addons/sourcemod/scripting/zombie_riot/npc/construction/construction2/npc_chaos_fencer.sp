#pragma semicolon 1
#pragma newdecls required


static char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static char g_IdleSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};
static char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};


static char g_RangedAttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

static char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

static char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};
static char g_DodgeSound[][] = {
	"weapons/fx/nearmiss/arrow_nearmiss.wav",
	"weapons/fx/nearmiss/arrow_nearmiss2.wav",
	"weapons/fx/nearmiss/arrow_nearmiss3.wav",
	"weapons/fx/nearmiss/arrow_nearmiss4.wav",
};

public void ChaosFencer_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));   i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);   }
	for (int i = 0; i < (sizeof(g_DodgeSound));   i++) { PrecacheSound(g_DodgeSound[i]);   }
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Chaos Fencer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_chaos_fencer");
	strcopy(data.Icon, sizeof(data.Icon), "chaos_fencer");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = 0;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ChaosFencer(vecPos, vecAng, team);
}

methodmap ChaosFencer < CClotBody
{
	property float f_CaptinoAgentusTeleport
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
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
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		
	}

	public void PlayDodgeSound() 
	{
		if(!this.m_flRemoveDodgeEffect)
		{
			SetEntityRenderMode(this.index, RENDER_TRANSALPHA);
			SetEntityRenderFx(this.index, RENDERFX_DISTORT);
			SetEntityRenderColor(this.index, 125, 125, 125, 175);
			SetEntityRenderMode(this.m_iWearable1, RENDER_TRANSALPHA);
			SetEntityRenderFx(this.m_iWearable1, RENDERFX_DISTORT);
			SetEntityRenderColor(this.m_iWearable1, 125, 125, 125, 175);
			SetEntityRenderMode(this.m_iWearable2, RENDER_TRANSALPHA);
			SetEntityRenderFx(this.m_iWearable2, RENDERFX_DISTORT);
			SetEntityRenderColor(this.m_iWearable2, 125, 125, 125, 175);
		}
		this.m_flRemoveDodgeEffect = GetGameTime() + 0.2;
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.2;
		EmitSoundToAll(g_DodgeSound[GetRandomInt(0, sizeof(g_DodgeSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayTeleportSound() 
	{
		EmitCustomToAll("zombiesurvival/internius/blinkarrival.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME * 2.0);
	}
	property bool b_SwordIgnition
	{
		public get()							{ return b_follow[this.index]; }
		public set(bool TempValueForProperty) 	{ b_follow[this.index] = TempValueForProperty; }
	}
	property float m_flRemoveDodgeEffect
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	
	public ChaosFencer(float vecPos[3], float vecAng[3], int ally)
	{
		ChaosFencer npc = view_as<ChaosFencer>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "1500", ally));
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");				
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_GENERAL_WALK");
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;
		Elemental_AddChaosDamage(npc.index, npc.index, 1, false);		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		func_NPCDeath[npc.index] = ChaosFencer_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ChaosFencer_OnTakeDamage;
		func_NPCThink[npc.index] = ChaosFencer_ClotThink;
		npc.b_SwordIgnition = false;

		npc.m_iState = 0;
		npc.m_flSpeed = 90.0;
		fl_TotalArmor[npc.index] = 0.25;

		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/short2014_vintage_director/short2014_vintage_director_spy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		float flPos[3], flAng[3];
				
		npc.GetAttachment("eyes", flPos, flAng);
		npc.m_iWearable4 = ParticleEffectAt_Parent(flPos, "unusual_smoking", npc.index, "eyes", {0.0,0.0,0.0});
		npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npc.index, "eyes", {0.0,0.0,-15.0});
		npc.StartPathing();
		SetEntityRenderColor(npc.index, 150, 150, 150, 255);
		SetEntityRenderColor(npc.m_iWearable1, 150, 150, 150, 255);
		SetEntityRenderColor(npc.m_iWearable2, 150, 150, 150, 255);
		
		
		return npc;
	}
	
	
}

static bool ChaosBuffIsAlonedo;

public void ChaosFencer_ClotThink(int iNPC)
{
	ChaosFencer npc = view_as<ChaosFencer>(iNPC);
	
	if(npc.m_flRemoveDodgeEffect)
	{
		//not boostedd or anything
		if(npc.m_flRemoveDodgeEffect < GetGameTime())
		{
			SetEntityRenderMode(npc.index, RENDER_NORMAL);
			SetEntityRenderFx(npc.index, RENDERFX_NONE);
			SetEntityRenderColor(npc.index, 150, 150, 150, 255);
			SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
			SetEntityRenderFx(npc.m_iWearable1, RENDERFX_NONE);
			SetEntityRenderColor(npc.m_iWearable1, 150, 150, 150, 255);
			SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
			SetEntityRenderFx(npc.m_iWearable2, RENDERFX_NONE);
			SetEntityRenderColor(npc.m_iWearable2, 150, 150, 150, 255);
			npc.m_flRemoveDodgeEffect = 0.0;
		}
	}
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_STOMACH", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	ChaosBuffIsAlonedo = true;
	ExpidonsaGroupHeal(npc.index,
	 180.0,
	  99,
	   0.0,
	   1.0,
	    false,
		 ChaosFencer_ApplyAloneBuff ,
  		  _,
   		  true);

	float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
	if(ChaosBuffIsAlonedo)
	{
		if(!npc.b_SwordIgnition)
		{
			IgniteTargetEffect(npc.m_iWearable1);
			npc.b_SwordIgnition = true;
			npc.m_flSpeed = 150.0;
			fl_TotalArmor[npc.index] = 0.15;
		}
		ApplyStatusEffect(npc.index, npc.index, "Ancient Melodies", 0.25);	
		spawnRing_Vectors(VecSelfNpcabs, (180.0 * 0.95) * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 225, 150, 150, 200, 1, /*duration*/ 0.11, 5.0, 2.0, 1);	
	}
	else
	{
		if(npc.b_SwordIgnition)
		{
			ExtinguishTarget(npc.m_iWearable1);
			npc.b_SwordIgnition = false;
			npc.m_flSpeed = 90.0;
			fl_TotalArmor[npc.index] = 0.25;
		}
		spawnRing_Vectors(VecSelfNpcabs, (180.0 * 0.95) * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 200, 200, 200, 200, 1, /*duration*/ 0.11, 5.0, 2.0, 1);	
	}
	
	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	
	if(target > 0)
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
		ChaosFencerSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

void ChaosFencerSelfDefense(ChaosFencer npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 180.0;
					if(ChaosBuffIsAlonedo)
					{
						damageDealt *= 2.0;
					}
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 3.5;
					int PreviousArmor = 0;
					if(IsValidClient(target))
					{
						PreviousArmor = Armor_Charge[target];
						Armor_Charge[target] = 0;
						if(f_ReceivedTruedamageHit[target] < GetGameTime())
						{
							f_ReceivedTruedamageHit[target] = GetGameTime() + 0.5;
							ClientCommand(target, "playgamesound player/crit_received%d.wav", (GetURandomInt() % 3) + 1);
						}
					}
					else
					{
						CClotBody npcenemy = view_as<CClotBody>(target);
						PreviousArmor = RoundToNearest(npcenemy.m_flArmorCount);
						npcenemy.m_flArmorCount = 0.0;
					}

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					if(IsValidClient(target))
					{
						Armor_Charge[target] = PreviousArmor;
					}
					else
					{
						CClotBody npcenemy = view_as<CClotBody>(target);
						npcenemy.m_flArmorCount = float(PreviousArmor);
					}

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 0.7;

				if(!ChaosBuffIsAlonedo)
					npc.AddGesture("ACT_GENERAL_ATTACK_POKE");
				else
				{
					if(GetRandomInt(0,1))
						npc.AddGesture("ACT_GENERAL_ATTACK_POKE");
					else
						npc.AddGesture("ACT_GENERAL_ATTACK_OVERHEAD");
					npc.m_flNextMeleeAttack = gameTime + 0.5;
					
				}
						
			}
		}
	}
}
public Action ChaosFencer_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	ChaosFencer npc = view_as<ChaosFencer>(victim);


	if(npc.b_SwordIgnition)
	{

		float vecTarget[3]; WorldSpaceCenter(attacker, vecTarget );

		float VecSelfNpc[3]; WorldSpaceCenter(victim, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget > (200.0 * 200.0))
		{
			npc.PlayDodgeSound();
			if(attacker <= MaxClients && attacker > 0)
			{
				float chargerPos[3];
				GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
				if(b_BoundingBoxVariant[victim] == 1)
				{
					chargerPos[2] += 120.0;
				}
				else
				{
					chargerPos[2] += 82.0;
				}
				TE_ParticleInt(g_particleMissText, chargerPos);
				TE_SendToClient(attacker);
			}
			damage = 0.0;
			return Plugin_Handled;
		}
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

public void ChaosFencer_NPCDeath(int entity)
{
	ChaosFencer npc = view_as<ChaosFencer>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
}



void ChaosFencer_ApplyAloneBuff(int entity, int victim, float &healingammount)
{
	if(i_NpcIsABuilding[victim])
		return;

	if(GetTeam(entity) == GetTeam(victim))
	{
		ChaosBuffIsAlonedo = false;
	}
	
}
