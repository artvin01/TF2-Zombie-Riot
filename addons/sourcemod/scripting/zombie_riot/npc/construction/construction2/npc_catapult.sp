#pragma semicolon 1
#pragma newdecls required


static const char g_DeathSounds[][] = {
	")physics/metal/metal_canister_impact_hard1.wav",
	")physics/metal/metal_canister_impact_hard2.wav",
	")physics/metal/metal_canister_impact_hard3.wav",
};

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};


static const char g_MeleeAttackSounds[][] = {
	"mvm/giant_demoman/giant_demoman_grenade_shoot.wav",
};

static const char g_MeleeChargeAttack[][] = {
	"weapons/loose_cannon_charge.wav",
};

void Catapult_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeChargeAttack)); i++) { PrecacheSound(g_MeleeChargeAttack[i]); }
	PrecacheModel("models/props_vehicles/mining_car_metal.mdl");
	PrecacheModel("models/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Catapult");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_catapult");
	strcopy(data.Icon, sizeof(data.Icon), "catapult_heavy");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = 0;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Catapult(vecPos, vecAng, team);
}
methodmap Catapult < CClotBody
{
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.2;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.2);
	}
	public void PlayChargeSound()
	{
		EmitSoundToAll(g_MeleeChargeAttack[GetRandomInt(0, sizeof(g_MeleeChargeAttack) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 170);
	}

	property float m_flWeaponSwitchCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	
	public Catapult(float vecPos[3], float vecAng[3], int ally)
	{
		Catapult npc = view_as<Catapult>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/bloons_hitbox.mdl", "0.8", "1500", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		
		npc.m_flNextMeleeAttack = 0.0;

		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 255, 255, 255, 0);
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Catapult_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Catapult_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Catapult_ClotThink);
		
		npc.m_flMeleeArmor = 1.5;
		npc.m_flRangedArmor = 0.75;
		
		
		npc.StartPathing();
		npc.m_flSpeed = 100.0;
		b_DoNotChangeTargetTouchNpc[npc.index] = 1;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItemSeperate("models/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl",_,_, 1.2);
		float RandFloat[3];
		RandFloat[0] = GetRandomFloat(-7.0,7.0);
		RandFloat[1] = GetRandomFloat(-7.0,7.0);
		RandFloat[2] = 40.0 + GetRandomFloat(-5.0,5.0);
		SDKCall_SetLocalOrigin(npc.m_iWearable1, RandFloat);	
		RandFloat[0] = -90.0 + GetRandomFloat(-15.0,15.0);
		RandFloat[1] = GetRandomFloat(-18.0,180.0);
		RandFloat[2] = GetRandomFloat(-15.0,15.0);
		SDKCall_SetLocalAngles(npc.m_iWearable1, RandFloat);

		
		npc.m_iWearable2 = npc.EquipItemSeperate("models/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl",_,_, 1.2);
		
		RandFloat[0] = GetRandomFloat(-7.0,7.0);
		RandFloat[1] = GetRandomFloat(-7.0,7.0);
		RandFloat[2] = 40.0 + GetRandomFloat(-5.0,5.0);
		SDKCall_SetLocalOrigin(npc.m_iWearable2, RandFloat);	
		RandFloat[0] = -90.0 + GetRandomFloat(-15.0,15.0);
		RandFloat[1] = GetRandomFloat(-18.0,180.0);
		RandFloat[2] = GetRandomFloat(-15.0,15.0);
		SDKCall_SetLocalAngles(npc.m_iWearable2, RandFloat);

		
		npc.m_iWearable3 = npc.EquipItemSeperate("models/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl",_,_, 1.2);
		
		RandFloat[0] = GetRandomFloat(-7.0,7.0);
		RandFloat[1] = GetRandomFloat(-7.0,7.0);
		RandFloat[2] = 40.0 + GetRandomFloat(-5.0,5.0);
		SDKCall_SetLocalOrigin(npc.m_iWearable3, RandFloat);	
		RandFloat[0] = -90.0 + GetRandomFloat(-15.0,15.0);
		RandFloat[1] = GetRandomFloat(-18.0,180.0);
		RandFloat[2] = GetRandomFloat(-15.0,15.0);
		SDKCall_SetLocalAngles(npc.m_iWearable3, RandFloat);
		npc.m_bDissapearOnDeath = true;

		
		npc.m_iWearable4 = npc.EquipItemSeperate("models/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl",_,_, 1.2);

		RandFloat[0] = GetRandomFloat(-7.0,7.0);
		RandFloat[1] = GetRandomFloat(-7.0,7.0);
		RandFloat[2] = 40.0 + GetRandomFloat(-5.0,5.0);
		SDKCall_SetLocalOrigin(npc.m_iWearable4, RandFloat);	
		RandFloat[0] = -90.0 + GetRandomFloat(-15.0,15.0);
		RandFloat[1] = GetRandomFloat(-18.0,180.0);
		RandFloat[2] = GetRandomFloat(-15.0,15.0);
		SDKCall_SetLocalAngles(npc.m_iWearable4, RandFloat);	

		
		npc.m_iWearable5 = npc.EquipItemSeperate("models/props_vehicles/mining_car_metal.mdl",_,_, 1.0);

		RandFloat[0] = 0.0;
		RandFloat[1] = 90.0;
		RandFloat[2] = 0.0;
		SDKCall_SetLocalAngles(npc.m_iWearable5, RandFloat);	

		return npc;
	}
}

public void Catapult_ClotThink(int iNPC)
{
	Catapult npc = view_as<Catapult>(iNPC);

	ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ 10.0);

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

	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		target = GetClosestTarget(npc.index,_,1200.0,_,_,_,_,_,_, true);
		if(!IsValidEnemy(npc.index, target))
		{
			target = GetClosestTarget(npc.index);
		}
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int ActionDo = CatapultSelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget); 
		switch(ActionDo)
		{
			case 0:
			{
				npc.StartPathing();
				//We run at them.
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
				npc.m_flSpeed = 200.0;
			}
			case 1:
			{
				npc.StopPathing();
				npc.m_flSpeed = 0.0;
				//Stand still.
			}
		}
	}

	CatapultSelfDefense_Init(npc, GetGameTime(npc.index));
}

public Action Catapult_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Catapult npc = view_as<Catapult>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Catapult_NPCDeath(int entity)
{
	Catapult npc = view_as<Catapult>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);
		
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

int CatapultSelfDefense(Catapult npc, float gameTime, float distance)
{
	//Direct mode
	if(!npc.m_flAttackHappens && gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.0))
		{
			WorldSpaceCenter(npc.m_iTarget, fl_AbilityVectorData[npc.index] );
			//save pos to attack
			npc.m_flAttackHappens = gameTime + 1.0;
			float ProjectileLoc[3];
			npc.PlayChargeSound();
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
			ProjectileLoc[2] += 60.0;
			spawnRing_Vectors(ProjectileLoc, 80.0 * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 65, 65, 65, 200, 1, 1.0, 3.0, 12.0, 3, 1.0);	
		}
	}

	//No can shooty.
	//Enemy is close enough.
	if(npc.m_flAttackHappens)
	{
		return 1;
	}
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0))
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			//stand
			return 1;
		}
		//cant see enemy somewhy.
		return 0;
	}
	else //enemy is too far away.
	{
		return 0;
	}
}


void CatapultSelfDefense_Init(Catapult npc, float gameTime)
{
	if(npc.m_flAttackHappens && gameTime > npc.m_flAttackHappens)
	{
		npc.m_flAttackHappens = 0.0;
		float VecAim[3]; 
		VecAim = fl_AbilityVectorData[npc.index];
		float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );
		VecStart[2] += 30.0;
		TE_Particle("mvm_loot_smoke", VecStart, NULL_VECTOR, NULL_VECTOR, npc.index, _, _, _, _, _, _, _, _, _, 0.0);
		VecStart[2] -= 30.0;

		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.m_iTarget = Enemy_I_See;
			npc.PlayMeleeSound();
			for(int rocketcount ; rocketcount < 10 ; rocketcount++)
			{
				float RocketDamage = 125.0;
				float RocketSpeed = 500.0;
				float vecTarget[3]; 
				vecTarget = VecAim;
				vecTarget[0] += GetRandomFloat(-150.0, 150.0);
				vecTarget[1] += GetRandomFloat(-150.0, 150.0);
				vecTarget[2] += GetRandomFloat(-30.0, 30.0);

				float SpeedReturn[3];
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,0.75);

				int RocketGet = npc.FireRocket(vecTarget, RocketDamage, RocketSpeed);
				Attributes_Set(RocketGet, Attrib_MultiBuildingDamage, 7.0);
				//Reducing gravity, reduces speed, lol.
				SetEntityGravity(RocketGet, 1.0); 	
				//I dont care if its not too accurate, ig they suck with the weapon idk lol, lore.
				ArcToLocationViaSpeedProjectile(VecStart, vecTarget, SpeedReturn, 2.45, 1.0);
				SetEntityMoveType(RocketGet, MOVETYPE_FLYGRAVITY);
				TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
						
				npc.m_flNextMeleeAttack = gameTime + 7.5;
				//Launch something to target, unsure if rocket or something else.
				//idea:launch fake rocket with noclip or whatever that passes through all
				//then whereever the orginal goal was, land there.
				//it should be a mortar.
			}
		}
	}
}