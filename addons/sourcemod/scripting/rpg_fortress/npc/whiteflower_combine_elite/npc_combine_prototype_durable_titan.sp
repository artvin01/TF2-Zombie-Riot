#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

static char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static const char g_HurtSound[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
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
	"weapons/physcannon/energy_sing_explosion2.wav",
};

static char g_RangedAttack[][] = {
	"weapons/ar2/fire1.wav",
};
public void Whiteflower_PrototypeDDT_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttack));	i++) { PrecacheSound(g_RangedAttack[i]);	}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Prototype DDT");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_whiteflower_prototype_titan");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Whiteflower_PrototypeDDT(vecPos, vecAng, team);
}

methodmap Whiteflower_PrototypeDDT < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound()
	{
		
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayGunShot() 
	{
		EmitSoundToAll(g_RangedAttack[GetRandomInt(0, sizeof(g_RangedAttack) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayKilledEnemySound(int target) 
	{
		int Health = GetEntProp(target, Prop_Data, "m_iHealth");
		
		if(Health <= 0)
		{
			if(target <= MaxClients)
			{
				static Race race;
				Races_GetClientInfo(target, race);
				if(StrEqual(race.Name, "Iberian"))
				{
					switch(GetRandomInt(0,2))
					{
						case 0:
							NpcSpeechBubble(this.index, "Iberians are like ants.", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
						case 1:
							NpcSpeechBubble(this.index, "Like sand in the desert, iberians in the water.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
						case 2:
							NpcSpeechBubble(this.index, "Annoying birds.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
					}
					return;
				}
			}

			switch(GetRandomInt(0,2))
			{
				case 0:
					NpcSpeechBubble(this.index, "How frail.", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
				case 1:
					NpcSpeechBubble(this.index, "They beat the elites? Hardly believeable.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
				case 2:
					NpcSpeechBubble(this.index, "Such weaklings.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
			}
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
			this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
		}
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
	}
	
	property float m_flCooldownDurationHurt
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public Whiteflower_PrototypeDDT(float vecPos[3], float vecAng[3], int ally)
	{
		Whiteflower_PrototypeDDT npc = view_as<Whiteflower_PrototypeDDT>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.75", "300", ally, false, true));

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");				
		i_NpcWeight[npc.index] = 1;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "sword");

		npc.SetActivity("ACT_COLOSUS_IDLE");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];	
		

		func_NPCDeath[npc.index] = Whiteflower_PrototypeDDT_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Whiteflower_PrototypeDDT_OnTakeDamage;
		func_NPCThink[npc.index] = Whiteflower_PrototypeDDT_ClotThink;
		
	
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/sum21_roaming_roman/sum21_roaming_roman.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntityRenderColor(npc.index, 192, 192, 192, 255);
		
		npc.StopPathing();
			
		
		return npc;
	}
	
}


public void Whiteflower_PrototypeDDT_ClotThink(int iNPC)
{
	Whiteflower_PrototypeDDT npc = view_as<Whiteflower_PrototypeDDT>(iNPC);

	float gameTime = GetGameTime(npc.index);

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	

	if(npc.m_blPlayHurtAnimation) 
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flCooldownDurationHurt)
	{
		if(npc.m_flCooldownDurationHurt < gameTime)
		{
			npc.m_flCooldownDurationHurt = 0.0;
			if(IsValidEntity(npc.m_iWearable1))
			{
				RemoveEntity(npc.m_iWearable1);
			}
			npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_irifle.mdl");
			SetVariantString("1.15");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
		return;
	}

	if(npc.Anger && GetEntProp(npc.index, Prop_Data, "m_iHealth") >= ReturnEntityMaxHealth(npc.index))
	{
		//Reset anger.
		npc.Anger = false;
		if(IsValidEntity(npc.m_iWearable1))
		{
			RemoveEntity(npc.m_iWearable1);
		}
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
	}

	if(GetEntProp(npc.index, Prop_Data, "m_iHealth") < (ReturnEntityMaxHealth(npc.index) * 0.5))
	{
		if(!npc.Anger)
		{
			npc.Anger = true;
			npc.m_flCooldownDurationHurt = gameTime + 2.0;
			if(IsValidEntity(npc.m_iWearable1))
			{
				RemoveEntity(npc.m_iWearable1);
			}
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 7;
			npc.m_flSpeed = 0.0;
			npc.SetActivity("ACT_PICKUP_GROUND");
			npc.SetPlaybackRate(0.5);
			return;
		}
	}

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	if(!npc.Anger)
		Npc_Base_Thinking(iNPC, 400.0, "ACT_COLOSUS_WALK", "ACT_COLOSUS_IDLE", 0.0, gameTime);
	else
		Npc_Base_Thinking(iNPC, 400.0, "ACT_RUN_AIM_RIFLE", "ACT_IDLE_ANGRY", 0.0, gameTime);
	
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
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, .Npc_type = 1) )
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 440000.0;

					
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						// Hit sound
						npc.PlayMeleeHitSound();

						npc.PlayKilledEnemySound(npc.m_iTarget);
					}
				}
				delete swingTrace;
			}
		}
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
		
		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(!npc.Anger)
		{
			if(flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
			{
				npc.m_iState = 1; //Engage in Close Range Destruction.
			}
			else 
			{
				npc.m_iState = 0; //stand and look if close enough.
			}
		}
		else
		{
			if(flDistanceToTarget < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.0) && npc.m_flNextMeleeAttack < gameTime)
			{
				npc.m_iState = 2; //Engage in Close Range Destruction.
			}
			else 
			{
				npc.m_iState = 3; //stand and look if close enough.
			}
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
					
				if(npc.m_iChanged_WalkCycle != 6) 	
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 6;
					npc.SetActivity("ACT_COLOSUS_WALK");
					npc.m_flSpeed = 345.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
			}
			case 3:
			{
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_RUN_AIM_RIFLE");
					npc.m_flSpeed = 345.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE", _,_,_,0.8);

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.5;
					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_flNextMeleeAttack = gameTime + 1.0;
					npc.m_bisWalking = true;
				}
			}
			case 2:
			{
				int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);	
				if(IsValidEnemy(npc.index, target))
				{
					if(npc.m_iChanged_WalkCycle != 9) 	
					{
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 9;
						npc.SetActivity("ACT_IDLE_ANGRY_AR2");
						npc.m_flSpeed = 0.0;
						npc.StopPathing();
					}
					npc.FaceTowards(vecTarget, 15000.0); //Snap to the enemy. make backstabbing hard to do.

					float eyePitch[3], vecDirShooting[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
					
					vecTarget[2] += 15.0;
					MakeVectorFromPoints(vecSelf, vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					vecDirShooting[1] = eyePitch[1];

					npc.m_flNextRangedAttack = gameTime + 0.1;
					
					float x = GetRandomFloat( -0.03, 0.03 );
					float y = GetRandomFloat( -0.03, 0.03 );
					
					float vecRight[3], vecUp[3];
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
					
					float vecDir[3];
					for(int i; i < 3; i++)
					{
						vecDir[i] = vecDirShooting[i] + x * vecRight[i] + y * vecUp[i]; 
					}

					NormalizeVector(vecDir, vecDir);
					
					// E2 L0 = 6.0, E2 L5 = 7.0
					KillFeed_SetKillIcon(npc.index, "pistol");
					float damage = 280000.0;
					FireBullet(npc.index, npc.m_iWearable1, vecSelf, vecDir, damage, 9000.0, DMG_BULLET, "bullet_tracer01_red");
					npc.PlayKilledEnemySound(npc.m_iTarget);

					npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_AR2");
					npc.PlayGunShot();
				}
				else
				{
					//Walk to target
					if(!npc.m_bPathing)
						npc.StartPathing();
						
					if(npc.m_iChanged_WalkCycle != 8) 	
					{
						npc.m_bisWalking = true;
						npc.m_iChanged_WalkCycle = 8;
						npc.SetActivity("ACT_RUN_AIM_RIFLE");
						npc.m_flSpeed = 340.0;
						view_as<CClotBody>(iNPC).StartPathing();
					}
				}
			}
		}
	}
	npc.PlayIdleSound();
}


public Action Whiteflower_PrototypeDDT_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	Whiteflower_PrototypeDDT npc = view_as<Whiteflower_PrototypeDDT>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void Whiteflower_PrototypeDDT_NPCDeath(int entity)
{
	Whiteflower_PrototypeDDT npc = view_as<Whiteflower_PrototypeDDT>(entity);
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
}


