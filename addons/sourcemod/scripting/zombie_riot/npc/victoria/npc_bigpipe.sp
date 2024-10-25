#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav",
};

static const char g_HurtSounds[][] = {
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/overthere01.wav",
	"vo/npc/male01/overthere02.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"mvm/giant_demoman/giant_demoman_grenade_shoot.wav",
};

static const char g_ReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};


void VictoriaBigPipe_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bigpipe");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bigpipe");
	strcopy(data.Icon, sizeof(data.Icon), "demo");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static float fl_npc_basespeed;

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictoriaBigPipe(client, vecPos, vecAng, ally);
}

/*
static int i_ally_index;


public void VictoriaBigPipe_Set_Ally_Index(int ref)
{	
	i_ally_index = EntIndexToEntRef(ref);
}
*/

methodmap VictoriaBigPipe < CClotBody
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
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}

	public void PlayReloadSound() 
	{
		EmitSoundToAll(g_ReloadSound[GetRandomInt(0, sizeof(g_ReloadSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.2);
	}
	property float m_flWeaponSwitchCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	
	public VictoriaBigPipe(int client, float vecPos[3], float vecAng[3], int ally)
	{
		VictoriaBigPipe npc = view_as<VictoriaBigPipe>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.0", "1250", ally,false));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_SECONDARY");
			
		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(VictoriaBigPipe_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VictoriaBigPipe_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VictoriaBigPipe_ClotThink);
		
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 180.0;
		fl_npc_basespeed = 180.0;
		npc.m_iOverlordComboAttack = 6;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 80, 50, 50, 255);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_grenadelauncher/c_grenadelauncher.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/sum19_dancing_doe/sum19_dancing_doe.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/demo_beardpipe_s2/demo_beardpipe_s2.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/sum19_staplers_specs/sum19_staplers_specs_demo.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2023_mad_lad/hwn2023_mad_lad.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 3);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 50, 150, 255, 255);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 255);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);

		return npc;
	}
}

public void VictoriaBigPipe_ClotThink(int iNPC)
{
	VictoriaBigPipe npc = view_as<VictoriaBigPipe>(iNPC);
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
	
	if(npc.m_iOverlordComboAttack <= 0)
	{
		if(npc.m_iChanged_WalkCycle != 6)
		{
			npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 2.5;
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 6;
			npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY", true,_,_,0.37);
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
			npc.PlayReloadSound();
			npc.m_iOverlordComboAttack = 6;
		}
		return;
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
				npc.SetActivity("ACT_MP_RUN_SECONDARY");
				npc.StartPathing();
				npc.m_flSpeed = 275.0;
			}
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 2)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 2;
				npc.SetActivity("ACT_MP_RUN_SECONDARY");
				npc.StartPathing();
				npc.m_flSpeed = 310.0;
			}
		}
	}
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int ActionDo = VictoriaBigPipeSelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget); 
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
					NPC_SetGoalVector(npc.index, vPredictedPos);
				}
				else 
				{
					NPC_SetGoalEntity(npc.index, npc.m_iTarget);
				}
				npc.m_flSpeed = 200.0;
			}
			case 1:
			{
				NPC_StopPathing(npc.index);
				npc.m_flSpeed = 0.0;
				//Stand still.
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

public Action VictoriaBigPipe_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaBigPipe npc = view_as<VictoriaBigPipe>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void VictoriaBigPipe_NPCDeath(int entity)
{
	VictoriaBigPipe npc = view_as<VictoriaBigPipe>(entity);
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

int VictoriaBigPipeSelfDefense(VictoriaBigPipe npc, float gameTime, float distance)
{
	//Direct mode
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
		{
			float VecAim[3]; WorldSpaceCenter(npc.m_iTarget, VecAim );
			npc.FaceTowards(VecAim, 20000.0);
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				float RocketDamage = 200.0;
				float RocketSpeed = 1500.0;
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
				float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );
				float vecDest[3];
				vecDest = vecTarget;
				vecDest[0] += GetRandomFloat(-50.0, 50.0);
				vecDest[1] += GetRandomFloat(-50.0, 50.0);
				if(npc.m_iChanged_WalkCycle == 1)
				{
					float SpeedReturn[3];
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");

					int RocketGet = npc.FireRocket(vecDest, RocketDamage, RocketSpeed, "models/weapons/w_models/w_grenade_grenadelauncher.mdl", 1.2);
					//Reducing gravity, reduces speed, lol.
					SetEntityGravity(RocketGet, 1.0); 	
					//I dont care if its not too accurate, ig they suck with the weapon idk lol, lore.
					ArcToLocationViaSpeedProjectile(VecStart, vecDest, SpeedReturn, 1.75, 1.0);
					SetEntityMoveType(RocketGet, MOVETYPE_FLYGRAVITY);
					TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);

					//This will return vecTarget as the speed we need.
				}
				else
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY",_,_,_,1.5);
					//They do a direct attack, slow down the rocket and make it deal less damage.
					RocketDamage *= 0.75;
					RocketSpeed *= 0.75;
					//	npc.PlayRangedSound();
					npc.FireRocket(vecTarget, RocketDamage, RocketSpeed, "models/weapons/w_models/w_grenade_grenadelauncher.mdl", 1.2);
				}
				npc.m_iOverlordComboAttack --;
						
				npc.m_flNextMeleeAttack = gameTime + 0.25;
				//Launch something to target, unsure if rocket or something else.
				//idea:launch fake rocket with noclip or whatever that passes through all
				//then whereever the orginal goal was, land there.
				//it should be a mortar.
			}
		}
	}
	if(npc.m_flNextMeleeAttack > gameTime)
	{
		npc.m_flSpeed = 0.0;
	}
	else
	{
		npc.m_flSpeed = fl_npc_basespeed;
	}
	//No can shooty.
	//Enemy is close enough.
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			float VecAim[3]; WorldSpaceCenter(npc.m_iTarget, VecAim );
			npc.FaceTowards(VecAim, 20000.0);
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