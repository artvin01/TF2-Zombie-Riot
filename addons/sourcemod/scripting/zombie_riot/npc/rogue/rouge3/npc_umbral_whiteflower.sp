#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

static const char g_DeathSounds[][] = {
	"ui/killsound_squasher.wav",
};

static char g_HurtSound[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static char g_IdleSound[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};


static char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/chuckle.wav",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static char g_MeleeHitSounds[][] = {
	
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};
static char g_RangedAttackSoundsSecondary[][] = {
	"common/wpn_hudoff.wav",
};
static char g_RocketSound[][] = {
	"weapons/rpg/rocketfire1.wav",
};
static const char g_HealSound[][] = {
	"items/medshot4.wav",
};

static bool b_TouchedEnemyTarget[MAXENTITIES];

public void Umbral_WF_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);	}
	for (int i = 0; i < (sizeof(g_RocketSound));	i++) { PrecacheSound(g_RocketSound[i]);	}
	for (int i = 0; i < (sizeof(g_HealSound)); i++) { PrecacheSound(g_HealSound[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Umbral W.F.");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_umbral_whiteflowers");
	strcopy(data.Icon, sizeof(data.Icon), "whiteflower");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = 0;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
	PrecacheSound("plats/tram_hit4.wav");
	PrecacheModel("models/props_lakeside_event/bomb_temp.mdl");
	PrecacheSound("ambient/machines/teleport3.wav");
}

static void ClotPrecache()
{
	PrecacheSoundCustom("rpg_fortress/enemy/whiteflower_dash.mp3");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Umbral_WF(vecPos, vecAng, team, data);
}

methodmap Umbral_WF < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,80);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,80);
	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_RocketSound[GetRandomInt(0, sizeof(g_RocketSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,150);
		

	}
	public void PlayHealSound() 
	{
		EmitSoundToAll(g_HealSound[GetRandomInt(0, sizeof(g_HealSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.1, 110);

	}
	public void PlayRocketSound()
 	{
		EmitSoundToAll(g_RocketSound[GetRandomInt(0, sizeof(g_RocketSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.6,70);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 50);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,80);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,80);	
	}
	
	property float m_flJumpCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flJumpHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flWasAirbornInJump
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flGetClosestTargetAllyTime
	{
		public get()							{ return fl_GetClosestTargetNoResetTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_GetClosestTargetNoResetTime[this.index] = TempValueForProperty; }
	}
	public Umbral_WF(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Umbral_WF npc = view_as<Umbral_WF>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "1.15", "300", ally, false,_,_,_,_));

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");			
		i_NpcWeight[npc.index] = 1;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "sword");

		npc.SetActivity("ACT_WHITEFLOWER_IDLE");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_UMBRAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];	
		npc.m_flGetClosestTargetAllyTime = 0.0;
		npc.m_flJumpCooldown = GetGameTime() + GetRandomFloat(1.5,3.0);


		func_NPCDeath[npc.index] = Umbral_WF_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Umbral_WF_OnTakeDamage;
		func_NPCThink[npc.index] = Umbral_WF_ClotThink;
		npc.m_bDissapearOnDeath = true;
		
		int Rand_R = GetRandomInt(25, 255);
		int Rand_G = GetRandomInt(25, 255);
		int Rand_B = GetRandomInt(25, 255);

		SetEntityRenderFx(npc.index, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.index, Rand_R, Rand_G, Rand_B, 125);
	
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);
		SetEntityRenderFx(npc.m_iWearable1, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.m_iWearable1, Rand_R, Rand_G, Rand_B, 125);

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/medic/robo_medic_blighted_beak/robo_medic_blighted_beak.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntityRenderFx(npc.m_iWearable2, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.m_iWearable2, Rand_R, Rand_G, Rand_B, 125);

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/sbox2014_knight_helmet/sbox2014_knight_helmet_spy.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntityRenderFx(npc.m_iWearable3, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.m_iWearable3, Rand_R, Rand_G, Rand_B, 125);

		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/hw2013_demo_cape/hw2013_demo_cape.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntityRenderFx(npc.m_iWearable4, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.m_iWearable4, Rand_R, Rand_G, Rand_B, 125);
		
		npc.StartPathing();
		
		return npc;
	}
	
}

public void Umbral_WF_ClotThink(int iNPC)
{
	Umbral_WF npc = view_as<Umbral_WF>(iNPC);

	float gameTime = GetGameTime(npc.index);

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime) //Dont play dodge anim if we are in an animation.
	{
		npc.AddGesture("ACT_HURT", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	npc.m_flNextThinkTime = gameTime + 0.1;

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float WorldSpaceCenterVec[3]; 
				WorldSpaceCenter(npc.m_iTarget, WorldSpaceCenterVec);
				npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 40.0;
					damage *= 0.50;
					damage *= RaidModeScaling;
					
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						// Hit sound
						npc.PlayMeleeHitSound();
					}
				}
				delete swingTrace;
			}
		}
	}
	
	if(npc.m_flJumpHappening)
	{
		int WhichEnemyToJump = 0;
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			WhichEnemyToJump = npc.m_iTarget;

		if(IsValidEntity(WhichEnemyToJump))
		{
			float WorldSpaceCenterVec[3]; 
			WorldSpaceCenter(WhichEnemyToJump, WorldSpaceCenterVec);
			npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
		}
		//We want to jump at the enemy the moment we are allowed to!
		if(npc.m_flJumpHappening < gameTime)
		{
			npc.m_flJumpHappening = 0.0;
			if(IsValidEntity(WhichEnemyToJump))
			{
				float WorldSpaceCenterVec[3]; 
				float WorldSpaceCenterVecSelf[3]; 
				WorldSpaceCenter(WhichEnemyToJump, WorldSpaceCenterVec);
				WorldSpaceCenter(npc.index, WorldSpaceCenterVecSelf);
				
				float flDistanceToTarget = GetVectorDistance(WorldSpaceCenterVecSelf, WorldSpaceCenterVec);
				float SpeedToPredict = flDistanceToTarget * 2.0;

				PredictSubjectPositionForProjectiles(npc, WhichEnemyToJump, SpeedToPredict, _,WorldSpaceCenterVec);
				//da jump!
				npc.m_flDoingAnimation = gameTime + 0.45;
				WorldSpaceCenterVec[2] += 15.0;
				PluginBot_Jump(npc.index, WorldSpaceCenterVec);
				f_CheckIfStuckPlayerDelay[npc.index] = GetGameTime() + 1.0;
				b_ThisEntityIgnoredBeingCarried[npc.index] = true;
				ApplyStatusEffect(npc.index, npc.index, "Intangible", 1.0);
				npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
				npc.m_flWasAirbornInJump = gameTime + 0.5;
				Zero(b_TouchedEnemyTarget);

				EmitCustomToAll("rpg_fortress/enemy/whiteflower_dash.mp3", npc.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 3.0, 80);
				IgniteTargetEffect(npc.index);
				if(npc.m_iChanged_WalkCycle != 7) 	
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 7;
					npc.SetActivity("ACT_WHITEFLOWER_DASH_FLOAT");
					npc.AddGesture("ACT_WHITEFLOWER_DASH_START");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
		}
		return;
	}
	if (!npc.m_flJumpHappening && npc.m_flWasAirbornInJump)
	{
		if(npc.IsOnGround() && npc.m_flWasAirbornInJump < gameTime)
		{
			b_ThisEntityIgnoredBeingCarried[npc.index] = false;
			npc.AddGesture("ACT_WHITEFLOWER_DASH_LAND", .SetGestureSpeed = 2.0);
			npc.m_flWasAirbornInJump = 0.0;
			ExtinguishTarget(npc.index);
		}
		else
		{
			Umbral_WFKickLogic(npc.index);
		}
	}

//always check!
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) {
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}


		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if (npc.m_flJumpCooldown < gameTime)
		{
			//We jump, no matter if far or close, see state to see more logic.
			//we melee them!
			npc.m_iState = 3; //enemy is abit further away.
		}
		else if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else 
		{
			npc.m_iState = 0; //stand and look if close enough.
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 0:
			{
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_WHITEFLOWER_RUN");
					npc.m_flSpeed = 350.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
			}
			case 1:
			{			
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_WHITEFLOWER_RUN");
					npc.m_flSpeed = 350.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					switch(GetRandomInt(0,1))
					{
						case 0:
							npc.AddGesture("ACT_WHITEFLOWER_ATTACK_LEFT", _,_,_,1.0);
						case 1:
							npc.AddGesture("ACT_WHITEFLOWER_ATTACK_RIGHT", _,_,_,1.0);
					}

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.35;
					npc.m_flDoingAnimation = gameTime + 0.35;
					npc.m_flNextMeleeAttack = gameTime + 0.65;
				}
			}
			case 3:
			{		
				//Jump at enemy	
				int WhichEnemyToJump = 0;
				if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
					WhichEnemyToJump = npc.m_iTarget;

				if(WhichEnemyToJump)
				{
					npc.FaceTowards(vecTarget, 15000.0);
					npc.m_flAttackHappens = gameTime + 0.5;
					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_flNextMeleeAttack = 0.0;
					npc.m_flJumpCooldown = gameTime + 5.0;
					//if enemy 
					npc.PlayRocketSound();
					/*
					if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.0))
					*/
					{
						npc.m_flJumpHappening = gameTime + 0.25;

						float flPos[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
						flPos[2] += 70.0;
						int particler = ParticleEffectAt(flPos, "scout_dodge_blue", 1.0);
						SetParent(npc.index, particler);
						if(npc.m_iChanged_WalkCycle != 6) 	
						{
							IgniteTargetEffect(npc.index);
							npc.m_bisWalking = false;
							npc.m_iChanged_WalkCycle = 6;
							npc.SetActivity("ACT_WHITEFLOWER_IDLE");
							npc.SetPlaybackRate(0.0);
							npc.m_flSpeed = 0.0;
							npc.StopPathing();
						}
					}
				}
				else
				{
					if(npc.m_iChanged_WalkCycle != 4) 	
					{
						npc.m_bisWalking = true;
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_WHITEFLOWER_RUN");
						npc.m_flSpeed = 350.0;
						view_as<CClotBody>(iNPC).StartPathing();
					}
				}
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}


public Action Umbral_WF_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	Umbral_WF npc = view_as<Umbral_WF>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void Umbral_WF_NPCDeath(int entity)
{
	Umbral_WF npc = view_as<Umbral_WF>(entity);
	npc.PlayDeathSound();
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		
	TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, 		{90.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, 	{90.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, {90.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);

		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}

public void Umbral_WF_NPCDeath_After(int entity)
{
	Umbral_WF npc = view_as<Umbral_WF>(entity);
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
}



static void Umbral_WF_KickTouched(int entity, int enemy)
{
	if(!IsValidEnemy(entity, enemy))
		return;

	if(b_TouchedEnemyTarget[enemy])
		return;

	Umbral_WF npc = view_as<Umbral_WF>(entity);
	b_TouchedEnemyTarget[enemy] = true;
	npc.AddGesture("ACT_WHITEFLOWER_DASH_KICK", .SetGestureSpeed = 2.0);
	
	float targPos[3];
	WorldSpaceCenter(enemy, targPos);
	float damage = 60.0;
	damage *= 0.50;
	damage *= RaidModeScaling;
	SDKHooks_TakeDamage(enemy, entity, entity, damage, DMG_CLUB, -1, NULL_VECTOR, targPos);
	ParticleEffectAt(targPos, "skull_island_embers", 2.0);
	npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
	EmitSoundToAll("plats/tram_hit4.wav", entity, SNDCHAN_STATIC, 80, _, 0.8);
	EmitSoundToAll("plats/tram_hit4.wav", entity, SNDCHAN_STATIC, 80, _, 0.8);

	if(enemy <= MaxClients)
	{
		f_AntiStuckPhaseThrough[enemy] = GetGameTime() + 1.0;
		ApplyStatusEffect(enemy, enemy, "Intangible", 1.0);
		Custom_Knockback(entity, enemy, 1500.0, true, true);
		TF2_AddCondition(enemy, TFCond_LostFooting, 0.5);
		TF2_AddCondition(enemy, TFCond_AirCurrent, 0.5);
	}
	else
	{
		Custom_Knockback(entity, enemy, 800.0, true, true);
	}
}

void Umbral_WFKickLogic(int iNPC)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	static float vel[3];
	static float flMyPos[3];
	npc.GetVelocity(vel);
	GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", flMyPos);
		
	static float hullcheckmins[3];
	static float hullcheckmaxs[3];
	if(b_IsGiant[iNPC])
	{
		hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
		hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
	}
	else if(f3_CustomMinMaxBoundingBox[iNPC][1] != 0.0)
	{
		hullcheckmaxs[0] = f3_CustomMinMaxBoundingBox[iNPC][0];
		hullcheckmaxs[1] = f3_CustomMinMaxBoundingBox[iNPC][1];
		hullcheckmaxs[2] = f3_CustomMinMaxBoundingBox[iNPC][2];

		hullcheckmins[0] = -f3_CustomMinMaxBoundingBox[iNPC][0];
		hullcheckmins[1] = -f3_CustomMinMaxBoundingBox[iNPC][1];
		hullcheckmins[2] = 0.0;	
	}
	else
	{
		hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );			
	}
	
	static float flPosEnd[3];
	flPosEnd = flMyPos;
	ScaleVector(vel, 0.1);
	AddVectors(flMyPos, vel, flPosEnd);
	
	ResetTouchedentityResolve();
	ResolvePlayerCollisions_Npc_Internal(flMyPos, flPosEnd, hullcheckmins, hullcheckmaxs, iNPC);

	for (int entity_traced = 0; entity_traced < MAXENTITIES; entity_traced++)
	{
		if(!TouchedNpcResolve(entity_traced))
			break;

		if(i_IsABuilding[ConvertTouchedResolve(entity_traced)])
			continue;
		
		Umbral_WF_KickTouched(iNPC,ConvertTouchedResolve(entity_traced));
	}
	ResetTouchedentityResolve();
}