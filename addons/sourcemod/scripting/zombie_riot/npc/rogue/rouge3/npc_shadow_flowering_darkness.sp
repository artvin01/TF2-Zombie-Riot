#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

static char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
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


#define SHADOW_BUFF_RANGE 200.0
static int NPCId;

public void Shadow_FloweringDarkness_OnMapStart_NPC()
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
	strcopy(data.Name, sizeof(data.Name), "W.F. Flowering Darkness");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_shadow_flowering_darkness");
	strcopy(data.Icon, sizeof(data.Icon), "flowering_darkness");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_WhiteflowerSpecial;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Shadow_FloweringDarkness(vecPos, vecAng, team, data);
}

methodmap Shadow_FloweringDarkness < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 50);
		EmitSoundToAll(g_RocketSound[GetRandomInt(0, sizeof(g_RocketSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,150);
		

	}
	public void PlayHealSound() 
	{
		EmitSoundToAll(g_HealSound[GetRandomInt(0, sizeof(g_HealSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.1, 110);

	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayKilledEnemySound(int target) 
	{
		int Health = GetEntProp(target, Prop_Data, "m_iHealth");
		
		if(Health <= 0)
		{
			switch(GetRandomInt(0,2))
			{
				case 0:
					NpcSpeechBubble(this.index, "I had enough of this!", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
				case 1:
					NpcSpeechBubble(this.index, "I need to get to shadowing!", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
				case 2:
					NpcSpeechBubble(this.index, "Out of my way!", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
			}
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
			this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
		}
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);	
	}
	
	property float m_flAirPushHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	property float m_flNextAirPush
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flCloneSuicide
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flDoAnimClone
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flCloneSpawnDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flAuraBuffAllies
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	public Shadow_FloweringDarkness(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Shadow_FloweringDarkness npc = view_as<Shadow_FloweringDarkness>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "300", ally, false,_,_,_,_));

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");				
		i_NpcWeight[npc.index] = 1;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "sword");

		npc.AddActivityViaSequence("p_jumpuploop");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];	

		func_NPCDeath[npc.index] = Shadow_FloweringDarkness_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Shadow_FloweringDarkness_OnTakeDamage;
		func_NPCThink[npc.index] = Shadow_FloweringDarkness_ClotThink;
		
	
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/player/items/mvm_loot/heavy/robo_ushanka.mdl");
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 255);

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop_partner/player/items/sniper/thief_sniper_cape/thief_sniper_cape.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
	
		bool CloneDo = StrContains(data, "clone_ability") != -1;
		if(CloneDo)
		{
			MakeObjectIntangeable(npc.index);
			b_DoNotUnStuck[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			b_NoKillFeed[npc.index] = true;
			npc.m_flCloneSuicide = GetGameTime() + 10.0;
			npc.m_flDoAnimClone = GetGameTime() + 0.1;
			npc.m_flAuraBuffAllies = 1.0;
			npc.m_flCloneSpawnDo = FAR_FUTURE;
			if(IsValidEntity(npc.index))
			{
				SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.index, 0, 0, 0, 125);
			}
			if(IsValidEntity(npc.m_iWearable1))
			{
				SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable1, 0, 0, 0, 125);
			}
			if(IsValidEntity(npc.m_iWearable2))
			{
				SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 125);
			}
			if(IsValidEntity(npc.m_iWearable3))
			{
				SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable3, 0, 0, 0, 125);
			}
		}
		else
		{
			CPrintToChatAll("{black}Flowering Darkness{default} : You again... I'll make {crimson}sure{default} you're dead.");
			npc.StartPathing();
			npc.m_flCloneSpawnDo = GetGameTime() + 5.0;
			npc.m_flNextAirPush = GetGameTime() + 3.0;
		}
		bool raidbattle = StrContains(data, "raidbattle") != -1;
		if(raidbattle)
		{
			RaidModeScaling = 2.5;
			RaidModeTime = FAR_FUTURE;

			RaidBossActive = EntIndexToEntRef(npc.index);

			RaidAllowsBuildings = true;
			i_RaidGrantExtra[npc.index] = 1;
		}
		return npc;
	}
	
}


public void Shadow_FloweringDarkness_ClotThink(int iNPC)
{
	Shadow_FloweringDarkness npc = view_as<Shadow_FloweringDarkness>(iNPC);

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
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flAuraBuffAllies)
	{
		if(npc.m_flAuraBuffAllies < gameTime)
		{
			float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
			Shadow_FloweringDarkness_ApplyBuffInLocation(VecSelfNpcabs, GetTeam(npc.index), npc.index);
			float Range = SHADOW_BUFF_RANGE;
			spawnRing_Vectors(VecSelfNpcabs, Range * 2.0, 0.0, 0.0, 15.0, "materials/sprites/combineball_trail_black_1.vmt", 255, 255, 255, 200, 1, /*duration*/ 0.35, 10.0, 1.0, 1);	
			npc.m_flAuraBuffAllies = gameTime + 0.3;
		}
	}
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	if(npc.m_flDoAnimClone)
	{
		if(npc.m_flDoAnimClone < gameTime)
		{
			npc.m_flDoAnimClone = 0.0;

			if(npc.m_iChanged_WalkCycle != 7) 	
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 7;
				npc.SetActivity("ACT_IDLE");
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
			}

			npc.AddGesture("ACT_PUSH_PLAYER",_,_,_,1.2);
			
			npc.m_flAirPushHappening = gameTime + 0.5;
			npc.m_flDoingAnimation = gameTime + 0.5;
			if(npc.m_flCloneSuicide)
				npc.m_flNextAirPush = gameTime + 1.5;
				
		}
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
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget) )
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 800.0;
					
					if(target > 0) 
					{
						if(npc.Anger)
							DealTruedamageToEnemy(npc.index, target, damage);
						else
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						// Hit sound
						npc.PlayMeleeHitSound();
						if(target <= MaxClients)
							Client_Shake(target, 0, 25.0, 25.0, 0.5, false);

						npc.PlayKilledEnemySound(npc.m_iTarget);
					}
				}
				delete swingTrace;
			}
		}
	}
	
	if(npc.m_flAirPushHappening)
	{
		float vecTarget[3];
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 800.0, _,vecTarget);
			npc.FaceTowards(vecTarget, 20000.0);
		}
		if(npc.m_flAirPushHappening < gameTime)
		{
			npc.m_flAirPushHappening = 0.0;
			if(npc.m_flCloneSuicide)
				npc.m_flDoAnimClone = GetGameTime() + 1.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				

				npc.PlayRangedAttackSecondarySound();
				npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
				
				//This is the primary projectile in the middle.
				float SpeedProjectile = 1000.0;
				float ProjectileDamage = 400.0;
				int Projectile = npc.FireParticleRocket(vecTarget, ProjectileDamage , SpeedProjectile , 100.0 , "raygun_projectile_red");

				ProjectileDamage *= 0.35;
				SpeedProjectile *= 0.65;
				float vecForward[3];

				float vAngles[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles);
				for(int LoopDo = 1 ; LoopDo <= 2; LoopDo++)
				{
					Projectile = npc.FireParticleRocket(vecTarget, ProjectileDamage , SpeedProjectile , 100.0 , "raygun_projectile_blue");
					float vAnglesProj[3];
					GetEntPropVector(Projectile, Prop_Data, "m_angRotation", vAnglesProj);
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles);
					vAnglesProj[1] = vAngles[1];
					switch(LoopDo)
					{
						case 1:
							vAnglesProj[1] -= 30.0;

						case 2:
							vAnglesProj[1] += 30.0;
					}
					
					vecForward[0] = Cosine(DegToRad(vAnglesProj[0]))*Cosine(DegToRad(vAnglesProj[1]))*SpeedProjectile;
					vecForward[1] = Cosine(DegToRad(vAnglesProj[0]))*Sine(DegToRad(vAnglesProj[1]))*SpeedProjectile;
					vecForward[2] = Sine(DegToRad(vAnglesProj[0]))*-SpeedProjectile;

					TeleportEntity(Projectile, NULL_VECTOR, vAnglesProj, vecForward); 

					Initiate_HomingProjectile(Projectile,
					npc.index,
					9999.0,			// float lockonAngleMax,
					13.0,			// float homingaSec,
					false,			// bool LockOnlyOnce,
					true,			// bool changeAngles,
					vAnglesProj,
					npc.m_iTarget);			// float AnglesInitiate[3]);
					
				}
			}
		}
	}
	if(npc.m_flCloneSuicide)
	{	
		if(npc.m_flCloneSuicide < gameTime)
		{
			float pos[3];
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
			pos[2] += 10.0;
			TE_Particle("mvm_cash_explosion_smoke", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			SmiteNpcToDeath(npc.index);
		}
		return;
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float vecSelf[3];
		WorldSpaceCenter(npc.index, vecSelf);

		float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, npc.m_iTarget,_,_,vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		//Get position for just travel here.

		if(npc.m_flCloneSpawnDo < gameTime)
		{
			float SelfPos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
			npc.m_flCloneSpawnDo = gameTime + 4.0;
			CreateCloneFake_ShadowFloweringDarkness(npc.index, npc.m_iTarget, SelfPos);
		}

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(npc.m_flNextAirPush < gameTime)
		{
			npc.m_iState = 2; //Engage in Close Range Destruction.
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
					npc.SetActivity("ACT_RUN");
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
					npc.SetActivity("ACT_RUN");
					npc.m_flSpeed = 350.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE", _,_,_,1.0);

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.35;
					npc.m_flDoingAnimation = gameTime + 0.35;
					npc.m_flNextMeleeAttack = gameTime + 0.65;
				}
			}
			case 2:
			{		
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					if(npc.m_iChanged_WalkCycle != 7) 	
					{
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 7;
						npc.SetActivity("ACT_RUN");
						npc.m_flSpeed = 0.0;
						npc.StopPathing();
					}
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_PUSH_PLAYER",_,_,_,1.2);
					
					npc.m_flAirPushHappening = gameTime + 0.5;
					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_flNextAirPush = gameTime + 3.0;
					if(npc.m_flCloneSuicide)
						npc.m_flNextAirPush = gameTime + 1.5;
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


public Action Shadow_FloweringDarkness_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	Shadow_FloweringDarkness npc = view_as<Shadow_FloweringDarkness>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void Shadow_FloweringDarkness_NPCDeath(int entity)
{
	Shadow_FloweringDarkness npc = view_as<Shadow_FloweringDarkness>(entity);
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

	if(!npc.m_bDissapearOnDeath && i_RaidGrantExtra[npc.index])
	{
		CPrintToChatAll("{black}Flowering Darkness{default} : ... Like boss like co-boss....");
		CPrintToChatAll("{crimson}Flowering Darkness perishes... He drops a map, thats where shadowing darkness is.");	
	}
}


void CreateCloneFake_ShadowFloweringDarkness(int entity, int enemySelect, float SelfPos[3])
{
	int CloneSpawn;
	
	CloneSpawn = NPC_CreateByName("npc_shadow_flowering_darkness", -1, SelfPos, {0.0,0.0,0.0}, GetTeam(entity), "clone_ability"); //can only be enemy
	if(IsValidEntity(CloneSpawn))
	{
		MakeObjectIntangeable(CloneSpawn);
		b_DoNotUnStuck[CloneSpawn] = true;
		b_NoKnockbackFromSources[CloneSpawn] = true;
		b_ThisEntityIgnored[CloneSpawn] = true;
		Shadow_FloweringDarkness npc = view_as<Shadow_FloweringDarkness>(CloneSpawn);
		npc.m_iTarget = enemySelect;
		npc.m_bDissapearOnDeath = true;
	}
}



void Shadow_FloweringDarkness_ApplyBuffInLocation(float BannerPos[3], int Team, int iMe = 0)
{
	float targPos[3];
	for(int ally=1; ally<=MaxClients; ally++)
	{
		if(IsClientInGame(ally) && IsPlayerAlive(ally) && GetTeam(ally) == Team)
		{
			GetClientAbsOrigin(ally, targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= (SHADOW_BUFF_RANGE * SHADOW_BUFF_RANGE))
			{
				ApplyStatusEffect(ally, ally, "Infinite Will", 2.0);
			}
		}
	}
	for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
	{
		int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == Team && iMe != ally && i_NpcInternalId[ally] != NPCId)
		{
			GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= (SHADOW_BUFF_RANGE * SHADOW_BUFF_RANGE))
			{
				ApplyStatusEffect(ally, ally, "Infinite Will", 2.0);
			}
		}
	}
}