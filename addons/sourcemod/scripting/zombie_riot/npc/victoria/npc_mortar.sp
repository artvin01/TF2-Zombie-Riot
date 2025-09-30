#pragma semicolon 1
#pragma newdecls required

static const char g_IdleAlertedSounds[][] = {
	")vo/medic_mvm_heal_shield01.mp3",
	")vo/medic_mvm_heal_shield02.mp3",
	")vo/medic_mvm_heal_shield03.mp3",
	")vo/medic_mvm_heal_shield04.mp3",
	")vo/medic_mvm_heal_shield05.mp3",
};

static const char g_RageAttackSounds[][] = {
	"weapons/doom_rocket_launcher.wav",
};

void VictoriaMortar_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DefaultMedic_DeathSounds));	   i++) { PrecacheSound(g_DefaultMedic_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_DefaultMedic_HurtSounds));		i++) { PrecacheSound(g_DefaultMedic_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_RageAttackSounds)); i++) { PrecacheSound(g_RageAttackSounds[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victorian Mortar");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_mortar");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_artillerist");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_IberiaExpiAlliance;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictoriaMortar(vecPos, vecAng, ally);
}
methodmap VictoriaMortar < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayRangeSound()
	{
		EmitSoundToAll(g_RageAttackSounds[GetRandomInt(0, sizeof(g_RageAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.2);
	}
	
	property float m_flWeaponSwitchCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public VictoriaMortar(float vecPos[3], float vecAng[3], int ally)
	{
		VictoriaMortar npc = view_as<VictoriaMortar>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "4000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE");
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(VictoriaMortar_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VictoriaMortar_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VictoriaMortar_ClotThink);
		
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "quake_rl");
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 100.0;
		npc.m_iOverlordComboAttack=1;
		
		npc.m_flMeleeArmor = 1.50;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_directhit/c_directhit.mdl");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/cloud_crasher/cloud_crasher.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/hwn2022_victorian_villainy/hwn2022_victorian_villainy.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/cc_summer2015_the_vascular_vestment/cc_summer2015_the_vascular_vestment.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/dec22_wooly_pulli_style1/dec22_wooly_pulli_style1.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable1, 0, 0, 0, 255);
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 255);
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);

		return npc;
	}
}

static void VictoriaMortar_ClotThink(int iNPC)
{
	VictoriaMortar npc = view_as<VictoriaMortar>(iNPC);
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
	
	//Swtich modes depending on area.
	if(npc.m_flWeaponSwitchCooldown < GetGameTime(npc.index))
	{
		npc.m_flWeaponSwitchCooldown = GetGameTime(npc.index) + 5.0;
		static float flMyPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flMyPos);
		static float hullcheckmaxs[3];
		static float hullcheckmins[3];

		//Defaults:
		//hullcheckmaxs = view_as<float>( { 24.0, 24.0, 72.0 } );
		//hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );

		hullcheckmaxs = view_as<float>( { 35.0, 35.0, 500.0 } ); //check if above is free
		hullcheckmins = view_as<float>( { -35.0, -35.0, 17.0 } );

		if(!IsSpaceOccupiedWorldOnly(flMyPos, hullcheckmins, hullcheckmaxs, npc.index))
		{
			if(npc.m_iChanged_WalkCycle != 1)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 1;
				npc.SetActivity("ACT_MP_RUN_MELEE");
				npc.StartPathing();
			}
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 2)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 2;
				npc.SetActivity("ACT_MP_RUN_PRIMARY");
				npc.StartPathing();
			}
		}
	}
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int ActionDo = VictoriaMortarSelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget); 
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
				npc.m_flSpeed = 100.0;
			}
			case 1:
			{
				npc.m_flSpeed = 50.0;
				//Move slower.
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action VictoriaMortar_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaMortar npc = view_as<VictoriaMortar>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void VictoriaMortar_NPCDeath(int entity)
{
	VictoriaMortar npc = view_as<VictoriaMortar>(entity);
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

static int VictoriaMortarSelfDefense(VictoriaMortar npc, float gameTime, float distance)
{
	//Direct mode
	if(gameTime > npc.m_flNextRangedAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 125.0))
		{
			float VecAim[3]; WorldSpaceCenter(npc.m_iTarget, VecAim );
			npc.FaceTowards(VecAim, 20000.0);
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayRangeSound();
				float RocketDamage = 200.0;
				float RocketSpeed = 650.0;
				float CoolDown = 5.0;
				if(NpcStats_VictorianCallToArms(npc.index))
				{
					RocketDamage *= 0.5;
					CoolDown *= 0.5;
				}
				float vecTarget[3];
				float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );
				if(npc.m_iChanged_WalkCycle == 1)
				{
					float SpeedReturn[3];
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,0.25);
					for(int i=0; i<2; i++)
					{
						int RocketGet = npc.FireRocket(vecTarget, RocketDamage, RocketSpeed,_,1.5);
						SetEntProp(RocketGet, Prop_Send, "m_bCritical", true);
						Better_Gravity_Rocket(RocketGet, 55.0);
						WorldSpaceCenter(npc.m_iTarget, vecTarget);
						vecTarget[0] += GetRandomFloat(-200.0, 200.0);
						vecTarget[1] += GetRandomFloat(-200.0, 200.0);
						ArcToLocationViaSpeedProjectile(VecStart, vecTarget, SpeedReturn, 1.5, 1.0);
						TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
					}
				}
				else
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY",_,_,_,0.75);
					//They do a direct attack, slow down the rocket and make it deal less damage.
					RocketDamage *= 0.75;
					RocketSpeed *= 0.75;
					for(int i=0; i<2; i++)
					{
						WorldSpaceCenter(npc.m_iTarget, vecTarget);
						vecTarget[0] += GetRandomFloat(-150.0, 150.0);
						vecTarget[1] += GetRandomFloat(-150.0, 150.0);
						npc.FireRocket(vecTarget, RocketDamage, RocketSpeed);
					}
				}
				npc.m_flNextRangedAttack = gameTime + CoolDown;
				//Launch something to target, unsure if rocket or something else.
				//idea:launch fake rocket with noclip or whatever that passes through all
				//then whereever the orginal goal was, land there.
				//it should be a mortar.
			}
		}
	}
	//No can shooty.
	//Enemy is close enough.
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			/*
			float VecAim[3]; WorldSpaceCenter(npc.m_iTarget, VecAim );
			npc.FaceTowards(VecAim, 20000.0);
			*/
			//walk slower
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