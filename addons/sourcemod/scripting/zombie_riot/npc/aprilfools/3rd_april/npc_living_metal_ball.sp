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


static const char g_HitSound[][] = {
	"npc/roller/mine/rmine_explode_shock1.wav",
};




void LivingMetalBall_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_HitSound));		i++) { PrecacheSound(g_HitSound[i]);		}
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Living Metal Ball");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_living_metal_ball");
	strcopy(data.Icon, sizeof(data.Icon), "heavy_champ");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = -1;
	data.Func = ClotSummon;
	NPC_Add(data);
	PrecacheSound("npc/roller/mine/rmine_movefast_loop1.wav");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return LivingMetalBall(vecPos, vecAng, team);
}

methodmap LivingMetalBall < CClotBody
{
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayHitSound() 
	{
		EmitSoundToAll(g_HitSound[GetRandomInt(0, sizeof(g_HitSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	
	public LivingMetalBall(float vecPos[3], float vecAng[3], int ally)
	{
		LivingMetalBall npc = view_as<LivingMetalBall>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/bloons_hitbox.mdl", "1.25", "900", ally)); 
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		EmitSoundToAll("npc/roller/mine/rmine_movefast_loop1.wav", npc.index, SNDCHAN_STATIC, 85, _, 1.0, 100);
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_flMeleeArmor = 1.25;	
		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = view_as<Function>(LivingMetalBall_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(LivingMetalBall_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(LivingMetalBall_ClotThink);
		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 255, 255, 255, 0);
		
		
		int shieldModel = npc.EquipItemSeperate("models/roller_spikes.mdl",_,_,_,36.0, true);
		SetVariantString("1.5");
		AcceptEntityInput(shieldModel, "SetModelScale");
		npc.m_iWearable1 = shieldModel;

		npc.StartPathing();
		npc.m_flSpeed = 450.0;
		f_NpcAdjustFriction[npc.index] = 0.15;
		//wwe do it via a buff to give it extra acceleration
		ApplyStatusEffect(npc.index, npc.index, "Ruina's Agility", 99999.0);
		NpcStats_RuinaAgilityStengthen(npc.index, 2.0);
		ApplyStatusEffect(npc.index, npc.index, "Intangible", 999999.0);
		f_CheckIfStuckPlayerDelay[npc.index] = FAR_FUTURE; //She CANT stuck you, so dont make players not unstuck in cant bve stuck ? what ?
		b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
		
		return npc;
	}
}

public void LivingMetalBall_ClotThink(int iNPC)
{
	LivingMetalBall npc = view_as<LivingMetalBall>(iNPC);
	if(IsValidEntity(npc.m_iWearable1))
	{
		float vecTarget[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
		vecTarget[2] += 36.0;
		Custom_SDKCall_SetLocalOrigin(npc.m_iWearable1, vecTarget);
		//reuse vectarget
		GetEntPropVector(npc.m_iWearable1, Prop_Data, "m_angRotation", vecTarget);
		float GetVel[3];
		npc.GetVelocity(GetVel);
		GetVel[0] *= 0.03;
		GetVel[1] *= 0.03;
		vecTarget[0] += GetVel[0];
		vecTarget[2] -= GetVel[1];
		SetEntPropVector(npc.m_iWearable1, Prop_Data, "m_angRotation", vecTarget);
	}
	float gameTime = GetGameTime(npc.index);
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
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
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
		LivingMetalBallSelfDefense(npc,GetGameTime(npc.index)); 
	}
}

public Action LivingMetalBall_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	LivingMetalBall npc = view_as<LivingMetalBall>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void LivingMetalBall_NPCDeath(int entity)
{
	LivingMetalBall npc = view_as<LivingMetalBall>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	
	StopSound(npc.index, SNDCHAN_STATIC, "npc/roller/mine/rmine_movefast_loop1.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "npc/roller/mine/rmine_movefast_loop1.wav");
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void LivingMetalBallSelfDefense(LivingMetalBall npc, float gameTime)
{

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		i_ExplosiveProjectileHexArray[npc.index] |= EP_DEALS_CLUB_DAMAGE;
		float radius = 70.0, damage = 300.0;
		Explode_Logic_Custom(damage, npc.index, npc.index, -1, _, radius, _, _, true, .FunctionToCallOnHit = LivingMetalBallKB);

		if(npc.m_flNextMeleeAttack == FAR_FUTURE)
		{
			npc.PlayHitSound();
			npc.m_flNextMeleeAttack = gameTime + 1.0;
		}
		else
		{

			npc.m_flNextMeleeAttack = gameTime + 0.1;
		}
	}
}


void LivingMetalBallKB(int entity, int victim, float damage, int weapon)
{
	LivingMetalBall npc = view_as<LivingMetalBall>(entity);
	if(npc.m_flNextMeleeAttack != FAR_FUTURE)
	{
		float VecMe[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", VecMe);
		float VecEnemy[3]; GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", VecEnemy);
		float AngleVec[3];
		MakeVectorFromPoints(VecEnemy, VecMe, AngleVec);
		GetVectorAngles(AngleVec, AngleVec);
		AngleVec[0] = -45.0;
		Custom_Knockback(victim, entity, 600.0, true, true, true, .OverrideLookAng = AngleVec);
	}
	Custom_Knockback(entity, victim, 350.0, true, false, true);
	npc.m_flNextMeleeAttack = FAR_FUTURE;
}