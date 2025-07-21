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
	"weapons/physcannon/energy_sing_explosion2.wav",
};
static char g_RocketSound[][] = {
	"weapons/rpg/rocketfire1.wav",
};
static const char g_HealSound[][] = {
	"items/medshot4.wav",
};


public void Whiteflower_selected_few_OnMapStart_NPC()
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
	strcopy(data.Name, sizeof(data.Name), "W.F. Selected Few");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_whiteflower_selected_few");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Whiteflower_selected_few(vecPos, vecAng, team);
}

methodmap Whiteflower_selected_few < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound()
	{
		
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		

	}
	public void PlayHealSound() 
	{
		EmitSoundToAll(g_HealSound[GetRandomInt(0, sizeof(g_HealSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.1, 110);

	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
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
							NpcSpeechBubble(this.index, "Iberians...", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
						case 1:
							NpcSpeechBubble(this.index, "Here comes payday.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
						case 2:
							NpcSpeechBubble(this.index, "Foolish Avians.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
					}
					return;
				}
			}

			switch(GetRandomInt(0,2))
			{
				case 0:
					NpcSpeechBubble(this.index, "Not on my hitlist, but regardless.", 7, {255,0,0,255}, {0.0,0.0,120.0}, "");
				case 1:
					NpcSpeechBubble(this.index, "In my way? Extra pay.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
				case 2:
					NpcSpeechBubble(this.index, "I wonder how much is put on their head.", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
			}
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
			this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
		}
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);
	}
	public void PlayRocketSound()
 	{
		EmitSoundToAll(g_RocketSound[GetRandomInt(0, sizeof(g_RocketSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,_);	
	}
	
	property float m_flJumpCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flJumpHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flCooldownDurationHurt
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flSpawnTempClone
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	public Whiteflower_selected_few(float vecPos[3], float vecAng[3], int ally)
	{
		Whiteflower_selected_few npc = view_as<Whiteflower_selected_few>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "300", ally, false,_,_,_,_));

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
		

		func_NPCDeath[npc.index] = Whiteflower_selected_few_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Whiteflower_selected_few_OnTakeDamage;
		func_NPCThink[npc.index] = Whiteflower_selected_few_ClotThink;
		
	
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/sniper/dec2014_hunter_ushanka/dec2014_hunter_ushanka.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/spy/sum22_night_vision_gawkers/sum22_night_vision_gawkers.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/medic/sum23_medical_emergency/sum23_medical_emergency.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
	
		npc.StopPathing();
			
		
		return npc;
	}
	
}

void RPGDoHealEffect(int entity, float range)
{
	float ProjectileLoc[3];
	Whiteflower_selected_few npc1 = view_as<Whiteflower_selected_few>(entity);
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	spawnRing_Vectors(ProjectileLoc, 1.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 0, 125, 0, 200, 1, 0.3, 5.0, 8.0, 3, range * 2.0);	
	npc1.PlayHealSound();
}

public void Whiteflower_selected_few_ClotThink(int iNPC)
{
	Whiteflower_selected_few npc = view_as<Whiteflower_selected_few>(iNPC);

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
			if(IsValidEntity(npc.m_iWearable4))
			{
				RemoveEntity(npc.m_iWearable4);
			}
			float flMaxhealth = float(ReturnEntityMaxHealth(npc.index));
			if(npc.m_iOverlordComboAttack != 1)
				flMaxhealth *= 0.15;

			HealEntityGlobal(npc.index, npc.index, flMaxhealth, 1.0, 0.0, HEAL_SELFHEAL);
			RPGDoHealEffect(npc.index, 150.0);
			npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
			SetVariantString("0.8");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);
			if(npc.m_iChanged_WalkCycle != 4) 	
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 4;
				npc.SetActivity("ACT_RUN");
				npc.m_flSpeed = 350.0;
				view_as<CClotBody>(iNPC).StartPathing();
			}
		}
		return;
	}

	if(!b_NpcIsInADungeon[npc.index] && npc.Anger && GetEntProp(npc.index, Prop_Data, "m_iHealth") >= ReturnEntityMaxHealth(npc.index))
	{
		//Reset anger.
		npc.Anger = false;
		if(IsValidEntity(npc.m_iWearable1))
		{
			RemoveEntity(npc.m_iWearable1);
		}
		if(IsValidEntity(npc.m_iWearable4))
		{
			RemoveEntity(npc.m_iWearable4);
		}
		
		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/medic/sum23_medical_emergency/sum23_medical_emergency.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);
	}

	if(GetEntProp(npc.index, Prop_Data, "m_iHealth") < (ReturnEntityMaxHealth(npc.index) * 0.5))
	{
		if(!npc.Anger)
		{
			npc.Anger = true;
			npc.m_flCooldownDurationHurt = gameTime + 0.75;
			
	
			if(IsValidEntity(npc.m_iWearable1))
			{
				RemoveEntity(npc.m_iWearable1);
			}
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 7;
			npc.m_flSpeed = 0.0;
			npc.AddActivityViaSequence("preSkewer");
			npc.SetPlaybackRate(0.35);
			npc.StopPathing();
			return;
		}
	}

	if(npc.Anger)
	{
		if(npc.m_flSpawnTempClone < gameTime)
		{
			npc.m_flSpawnTempClone = gameTime + 1.5;
			if(npc.m_iOverlordComboAttack == 1)
				npc.m_flSpawnTempClone = gameTime + 0.75;

			npc.PlayRocketSound();
			
			int entity_death = CreateEntityByName("prop_dynamic_override");
			if(IsValidEntity(entity_death))
			{
				Whiteflower_selected_few prop = view_as<Whiteflower_selected_few>(entity_death);
				float pos[3];
				float Angles[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);

				GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
				SetEntPropEnt(entity_death, Prop_Send, "m_hOwnerEntity", npc.index);			
				TeleportEntity(entity_death, pos, Angles, NULL_VECTOR);
				
				DispatchKeyValue(entity_death, "model", COMBINE_CUSTOM_MODEL);
				SetVariantInt(1);
				AcceptEntityInput(entity_death, "SetBodyGroup");	
				DispatchSpawn(entity_death);


				prop.m_iWearable2 = prop.EquipItem("partyhat", "models/workshop/player/items/sniper/dec2014_hunter_ushanka/dec2014_hunter_ushanka.mdl");
				SetVariantString("1.0");
				AcceptEntityInput(prop.m_iWearable2, "SetModelScale");

				prop.m_iWearable3 = prop.EquipItem("partyhat", "models/workshop/player/items/spy/sum22_night_vision_gawkers/sum22_night_vision_gawkers.mdl");
				SetVariantString("1.25");
				AcceptEntityInput(prop.m_iWearable3, "SetModelScale");

				//Cape

				SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.15); 
				SetEntityCollisionGroup(entity_death, 2);

				CreateTimer(2.7, Timer_RemoveEntity_SelectedFew, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(2.7, Timer_RemoveEntity, EntIndexToEntRef(prop.m_iWearable2), TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(2.7, Timer_RemoveEntity, EntIndexToEntRef(prop.m_iWearable3), TIMER_FLAG_NO_MAPCHANGE);
				SetVariantString("forcescanner");
				AcceptEntityInput(entity_death, "SetAnimation");
			}
		}
	}

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	Npc_Base_Thinking(iNPC, 500.0, "ACT_RUN", "p_jumpuploop", 0.0, gameTime, _ , true);
	if(npc.m_flJumpHappening)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float WorldSpaceCenterVec[3]; 
			WorldSpaceCenter(npc.m_iTarget, WorldSpaceCenterVec);
			npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
		}
		//We want to jump at the enemy the moment we are allowed to!
		if(npc.m_flJumpHappening < gameTime)
		{
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				npc.m_flJumpHappening = 0.0;
				//da jump!
				npc.m_flDoingAnimation = gameTime + 0.45;
				if(npc.m_iOverlordComboAttack == 1)
					npc.m_flDoingAnimation = gameTime + 0.215;

				float WorldSpaceCenterVec[3]; 
				WorldSpaceCenter(npc.m_iTarget, WorldSpaceCenterVec);
				PluginBot_Jump(npc.index, WorldSpaceCenterVec);
				npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
				if(npc.m_iChanged_WalkCycle != 7) 	
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 7;
					npc.SetActivity("ACT_JUMP");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
		}
		return;
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
					float damage = 450000.0;
						
					
					if(target > 0) 
					{
						if(npc.Anger)
							DealTruedamageToEnemy(npc.index, target, damage);
						else
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
		else if (npc.m_flJumpCooldown < gameTime)
		{
			//We jump, no matter if far or close, see state to see more logic.
			//we melee them!
			npc.m_iState = 2; //enemy is abit further away.
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
					
				if(npc.m_iChanged_WalkCycle != 3) 	
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_RUN");
					npc.m_flSpeed = 350.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(npc.m_iChanged_WalkCycle != 3) 	
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_RUN");
					npc.m_flSpeed = 350.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE", _,_,_,0.8);

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.5;
					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_flNextMeleeAttack = gameTime + 1.0;
				}
			}
			case 2:
			{		
				//Jump at enemy	
				if(npc.m_iChanged_WalkCycle != 7) 	
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 7;
					npc.SetActivity("ACT_RUN");
					npc.m_flSpeed = 350.0;
					view_as<CClotBody>(iNPC).StartPathing();
				}
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.m_flAttackHappens = gameTime + 0.5;
					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_flNextMeleeAttack = 0.0;
					npc.m_flJumpCooldown = gameTime + 7.5;
					//if enemy 
					npc.PlayRocketSound();
					for(float loopDo = 1.0; loopDo <= 2.0; loopDo += 0.5)
					{
						float vecSelf2[3];
						WorldSpaceCenter(npc.index, vecSelf2);
						vecSelf2[2] += 50.0;
						vecSelf2[0] += GetRandomFloat(-10.0, 10.0);
						vecSelf2[1] += GetRandomFloat(-10.0, 10.0);
						float RocketDamage = 500000.0;
						int RocketGet = npc.FireRocket(vecSelf2, RocketDamage, 200.0);
						DataPack pack;
						CreateDataTimer(loopDo, WhiteflowerTank_Rocket_Stand, pack, TIMER_FLAG_NO_MAPCHANGE);
						pack.WriteCell(EntIndexToEntRef(RocketGet));
						pack.WriteCell(EntIndexToEntRef(npc.m_iTarget));
					}
					/*
					if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.0))
					*/
					{
						//enemy is indeed to far away, jump at them
						npc.m_flJumpHappening = gameTime + 0.5;
						if(npc.m_iChanged_WalkCycle != 6) 	
						{
							npc.m_bisWalking = false;
							npc.m_iChanged_WalkCycle = 6;
							npc.AddActivityViaSequence("citizen4_preaction");
							npc.SetPlaybackRate(0.0);
							npc.m_flSpeed = 0.0;
							npc.StopPathing();
						}
					}
				}
			}
		}
	}
	npc.PlayIdleSound();
}


public Action Whiteflower_selected_few_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	Whiteflower_selected_few npc = view_as<Whiteflower_selected_few>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void Whiteflower_selected_few_NPCDeath(int entity)
{
	Whiteflower_selected_few npc = view_as<Whiteflower_selected_few>(entity);
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


//TODO: Make kaboom
public Action Timer_RemoveEntity_SelectedFew(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity))
	{
		int Owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(IsValidEntity(Owner))
		{
			float abspos[3]; 
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", abspos);
			abspos[2] += 45.0;
			float Range = 100.0;
			float DamageDeal = 350000.0;
			Explode_Logic_Custom(DamageDeal, Owner, Owner, -1, abspos, Range);
			EmitSoundToAll("ambient/explosions/explode_4.wav", -1, _, 80, _, _, _, _,abspos);
			SpawnSmallExplosionNotRandom(abspos);
		}
		RemoveEntity(entity);
	}
	return Plugin_Stop;
}
