#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_die2.wav",
};

static const char g_HurtSounds[][] = {
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombie_poison/pz_pain3.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/zombie_poison/pz_idle2.wav",
	"npc/zombie_poison/pz_idle3.wav",
	"npc/zombie_poison/pz_idle4.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

static const char g_TeleportSound[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};
void VoidEncasulator_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_TeleportSound)); i++) { PrecacheSound(g_TeleportSound[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Void Encasualtor");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_void_encasulator");
	strcopy(data.Icon, sizeof(data.Icon), "swordsman");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Void; 
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return VoidEncasulator(vecPos, vecAng, team);
}
methodmap VoidEncasulator < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayTeleportSound() 
	{
		EmitSoundToAll(g_TeleportSound[GetRandomInt(0, sizeof(g_TeleportSound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	
	public VoidEncasulator(float vecPos[3], float vecAng[3], int ally)
	{
		VoidEncasulator npc = view_as<VoidEncasulator>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.1", "100000", ally));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_VOID;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(VoidEncasulator_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VoidEncasulator_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VoidEncasulator_ClotThink);
		
		
		
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/player/items/heavy/dex_sarifarm/dex_sarifarm.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/pyro/smnc_pyro.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/demo/fall2013_eod_suit/fall2013_eod_suit.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/spy/spy_zombie.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);

		skin = 23;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		SetEntityRenderColor(npc.index, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable1, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable2, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable3, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable4, 200, 0, 200, 255);
		SetEntityRenderColor(npc.m_iWearable5, 200, 0, 200, 255);
		
		return npc;
	}
}

public void VoidEncasulator_ClotThink(int iNPC)
{
	VoidEncasulator npc = view_as<VoidEncasulator>(iNPC);

	if(npc.m_flAttackHappens_bullshit > GetGameTime(npc.index))
	{
		fl_TotalArmor[iNPC] = 0.65;
	}
	else
	{
		fl_TotalArmor[iNPC] = 1.0;
	}
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
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
		
		if(npc.m_flJumpCooldown < GetGameTime(npc.index) && VoidArea_TouchingNethersea(npc.m_iTarget))
		{
			if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			{
				static float hullcheckmaxs[3];
				static float hullcheckmins[3];
				hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
				hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );	

				float PreviousPos[3];
				WorldSpaceCenter(npc.index, PreviousPos);
				//randomly around the target.
				vecTarget[0] += GetRandomFloat(-15.0, 15.0);
				vecTarget[1] += GetRandomFloat(-15.0, 15.0);
				
				bool Succeed = Npc_Teleport_Safe(npc.index, vecTarget, hullcheckmins, hullcheckmaxs, true);
				if(Succeed)
				{
					npc.PlayTeleportSound();
					ParticleEffectAt(PreviousPos, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
					
					float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
					ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
					float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
					npc.FaceTowards(VecEnemy, 15000.0);
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.7; //so they cant instastab you!
					npc.FaceTowards(vecTarget, 15000.0);
					npc.m_flJumpCooldown = GetGameTime(npc.index) + 5.0;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+1.5;
					static float flPos[3]; 
					GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
					flPos[2] += 5.0;
					int particle = ParticleEffectAt(flPos, "utaunt_headless_glow", 1.5);
					SetParent(npc.index, particle);
				}
				else
				{
					npc.m_flJumpCooldown = GetGameTime(npc.index) + 0.25;
				}
			}
		}
		VoidEncasulatorSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action VoidEncasulator_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VoidEncasulator npc = view_as<VoidEncasulator>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void VoidEncasulator_NPCDeath(int entity)
{
	VoidEncasulator npc = view_as<VoidEncasulator>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

void VoidEncasulatorSelfDefense(VoidEncasulator npc, float gameTime, int target, float distance)
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
					float damageDealt = 75.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.0;


					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					Elemental_AddVoidDamage(target, npc.index, 150, true, true);

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
				if(npc.m_flNextTeleport < GetGameTime(npc.index))
				{
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + 1.5;
					static float flPos[3]; 
					GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
					flPos[2] += 5.0;
					int particle = ParticleEffectAt(flPos, "utaunt_headless_glow", 1.5);
					SetParent(npc.index, particle);
				}

				npc.m_flNextTeleport = GetGameTime(npc.index) + 2.5;
				
				if(npc.m_flAttackHappens_bullshit > gameTime)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1",_,_,_,1.5);
					npc.m_flAttackHappens = gameTime + 0.15;
					npc.m_flDoingAnimation = gameTime + 0.15;
					npc.m_flNextMeleeAttack = gameTime + 0.6;
				}
				else
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1",_,_,_,0.75);		
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 1.2;
				}
			}
		}
	}
}