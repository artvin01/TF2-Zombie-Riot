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

static const char g_PassiveSound[][] = {
	"mvm/giant_heavy/giant_heavy_loop.wav",
};

void TheGreatRam_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeChargeAttack)); i++) { PrecacheSound(g_MeleeChargeAttack[i]); }
	for (int i = 0; i < (sizeof(g_PassiveSound));   i++) { PrecacheSound(g_PassiveSound[i]);   }
	PrecacheModel("models/combine_apc_dynamic.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "The Great Ram");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_the_great_ram");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_crit");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = 0;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return TheGreatRam(vecPos, vecAng, team);
}
methodmap TheGreatRam < CClotBody
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

	public void PlayPassiveSound()
	{
		EmitSoundToAll(g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0, 100);
	}
	public void StopPassiveSound()
	{
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)]);
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)]);
	}
	property float m_flWeaponSwitchCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	
	public TheGreatRam(float vecPos[3], float vecAng[3], int ally)
	{
		TheGreatRam npc = view_as<TheGreatRam>(CClotBody(vecPos, vecAng, "models/combine_apc_dynamic.mdl", "0.65", "1500", ally,_,true));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.PlayPassiveSound();
		npc.m_flNextMeleeAttack = 0.0;

		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(TheGreatRam_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(TheGreatRam_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(TheGreatRam_ClotThink);
		
		npc.m_flMeleeArmor = 1.5;
		npc.m_flRangedArmor = 1.0;
		npc.m_bDissapearOnDeath = true;
		
		
		npc.StartPathing();
		npc.m_flSpeed = 50.0;
		b_DoNotChangeTargetTouchNpc[npc.index] = 1;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItemSeperate("models/props_hydro/metal_barrier02.mdl",_,_, 0.7);
		float RandFloat[3];
		RandFloat[0] = 0.0;
		RandFloat[1] = 33.0;
		RandFloat[2] = 60.0;
		SDKCall_SetLocalOrigin(npc.m_iWearable1, RandFloat);	
		RandFloat[0] = -15.0;
		RandFloat[1] = 90.0;
		RandFloat[2] = 0.0;
		SDKCall_SetLocalAngles(npc.m_iWearable1, RandFloat);

		
		npc.m_iWearable2 = npc.EquipItemSeperate("models/props_hydro/metal_barrier02.mdl",_,_, 0.7);
		
		RandFloat[0] = 0.0;
		RandFloat[1] = -33.0;
		RandFloat[2] = 60.0;
		SDKCall_SetLocalOrigin(npc.m_iWearable2, RandFloat);	
		RandFloat[0] = -15.0;
		RandFloat[1] = 270.0;
		RandFloat[2] = 0.0;
		SDKCall_SetLocalAngles(npc.m_iWearable2, RandFloat);

		
		npc.m_iWearable3 = npc.EquipItemSeperate("models/props_farm/roof_vent_skybox001.mdl",_,_, 8.0);
		
		RandFloat[0] = -36.0;
		RandFloat[1] = 0.0;
		RandFloat[2] = 20.0;
		SDKCall_SetLocalOrigin(npc.m_iWearable3, RandFloat);	
		RandFloat[0] = 0.0;
		RandFloat[1] = 180.0;
		RandFloat[2] = 0.0;
		SDKCall_SetLocalAngles(npc.m_iWearable3, RandFloat);

		
		npc.m_iWearable4 = npc.EquipItemSeperate("models/props_powerhouse/powerhouse_turbine.mdl",_,_, 0.25);

		RandFloat[0] = 50.0;
		RandFloat[1] = 0.0;
		RandFloat[2] = 33.0;
		SDKCall_SetLocalOrigin(npc.m_iWearable4, RandFloat);	
		RandFloat[0] = 0.0;
		RandFloat[1] = 90.0;
		RandFloat[2] = 90.0;
		SDKCall_SetLocalAngles(npc.m_iWearable4, RandFloat);

		return npc;
	}
}

public void TheGreatRam_ClotThink(int iNPC)
{
	TheGreatRam npc = view_as<TheGreatRam>(iNPC);

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
		int ActionDo = TheGreatRamSelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget); 
	}

	TheGreatRamSelfDefense_Auto(npc, GetGameTime(npc.index));
}

public Action TheGreatRam_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	TheGreatRam npc = view_as<TheGreatRam>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void TheGreatRam_NPCDeath(int entity)
{
	TheGreatRam npc = view_as<TheGreatRam>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);
	
	npc.StopPassiveSound();
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

int TheGreatRamSelfDefense(TheGreatRam npc, float gameTime, float distance)
{
	
}
void TheGreatRamSelfDefense_Auto(TheGreatRam npc, float gameTime)
{
	if(!npc.m_flAttackHappens && gameTime > npc.m_flNextMeleeAttack)
	{
		//save pos to attack
		npc.m_flAttackHappens = gameTime + 1.0;
		float ProjectileLoc[3];
		npc.PlayChargeSound();
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		ProjectileLoc[2] += 60.0;
		spawnRing_Vectors(ProjectileLoc, 80.0 * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 65, 65, 65, 200, 1, 1.0, 3.0, 12.0, 3, 1.0);	
	}

	if(npc.m_flAttackHappens && gameTime > npc.m_flAttackHappens)
	{
		npc.m_flAttackHappens = 0.0;
		float VecAim[3];
		WorldSpaceCenter(npc.index, VecAim );
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
				vecTarget[0] += GetRandomFloat(-250.0, 250.0);
				vecTarget[1] += GetRandomFloat(-250.0, 250.0);
				vecTarget[2] += GetRandomFloat(-60.0, 60.0);

				float SpeedReturn[3];
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,0.75);

				int RocketGet = npc.FireRocket(vecTarget, RocketDamage, RocketSpeed);
				Attributes_Set(RocketGet, Attrib_MultiBuildingDamage, 10.0);
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

