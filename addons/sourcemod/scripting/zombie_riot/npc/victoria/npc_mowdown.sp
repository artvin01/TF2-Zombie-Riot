#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/mght/heavy_mvm_m_negativevocalization01.mp3",
	"vo/mvm/mght/heavy_mvm_m_negativevocalization02.mp3",
	"vo/mvm/mght/heavy_mvm_m_negativevocalization03.mp3",
	"vo/mvm/mght/heavy_mvm_m_negativevocalization04.mp3",
	"vo/mvm/mght/heavy_mvm_m_negativevocalization05.mp3",
	"vo/mvm/mght/heavy_mvm_m_negativevocalization06.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/mght/heavy_mvm_m_laughshort01.mp3",
	"vo/mvm/mght/heavy_mvm_m_laughshort02.mp3",
	"vo/mvm/mght/heavy_mvm_m_laughshort03.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/mght/heavy_mvm_m_specials01.mp3",
	"vo/mvm/mght/heavy_mvm_m_specials02.mp3",
	"vo/mvm/mght/heavy_mvm_m_specials03.mp3",
	"vo/mvm/mght/heavy_mvm_m_specials04.mp3",
	"vo/mvm/mght/heavy_mvm_m_specials05.mp3",
};


void VictoriaMowdown_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	PrecacheModel("models/bots/heavy/bot_heavy.mdl");
	PrecacheSound("mvm/giant_heavy/giant_heavy_gunspin.wav");
	PrecacheSound("mvm/giant_heavy/giant_heavy_gunfire.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Mowdown");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_mowdown");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_mowdown");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);

}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictoriaMowdown(vecPos, vecAng, ally);
}

methodmap VictoriaMowdown < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
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
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMinigunSound(bool Shooting) 
    {
        if(Shooting)
        {
            if(this.i_GunMode != 0)
            {
                StopSound(this.index, SNDCHAN_STATIC, "mvm/giant_heavy/giant_heavy_gunspin.wav");
                EmitSoundToAll("mvm/giant_heavy/giant_heavy_gunfire.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL - 20, _, 0.70);
            }
            this.i_GunMode = 0;
        }
        else
        {
            if(this.i_GunMode != 1)
            {
                StopSound(this.index, SNDCHAN_STATIC, "mvm/giant_heavy/giant_heavy_gunfire.wav");
                EmitSoundToAll("mvm/giant_heavy/giant_heavy_gunspin.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.70);
            }
            this.i_GunMode = 1;
        }
    }

	public VictoriaMowdown(float vecPos[3], float vecAng[3], int ally)
	{
		VictoriaMowdown npc = view_as<VictoriaMowdown>(CClotBody(vecPos, vecAng, "models/bots/heavy/bot_heavy.mdl", "1.4", "26000", ally, .isGiant = true));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_DEPLOYED_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		func_NPCDeath[npc.index] = VictoriaMowdown_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictoriaMowdown_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaMowdown_ClotThink;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;

		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 100.0;
		
		f_HeadshotDamageMultiNpc[npc.index] = 0.25;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 100, 75, 75, 255);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_iron_curtain/c_iron_curtain.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/heavy/hwn2016_mad_mask/hwn2016_mad_mask.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/sum20_breach_and_bomb/sum20_breach_and_bomb.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		return npc;
	}
}

public void VictoriaMowdown_ClotThink(int iNPC)
{
	VictoriaMowdown npc = view_as<VictoriaMowdown>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	f_HeadshotDamageMultiNpc[npc.index] = 1.0;
	if(NpcStats_VictorianCallToArms(npc.index))
	{
		f_HeadshotDamageMultiNpc[npc.index] = 0.0;
	}

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
		VictoriaMowdownSelfDefense(npc); 
	}
	else
	{
		npc.PlayMinigunSound(false);
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action VictoriaMowdown_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaMowdown npc = view_as<VictoriaMowdown>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void VictoriaMowdown_NPCDeath(int entity)
{
	VictoriaMowdown npc = view_as<VictoriaMowdown>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	npc.PlayMinigunSound(false);

	StopSound(npc.index, SNDCHAN_STATIC, "mvm/giant_heavy/giant_heavy_gunspin.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "mvm/giant_heavy/giant_heavy_gunfire.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "mvm/giant_heavy/giant_heavy_gunspin.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "mvm/giant_heavy/giant_heavy_gunfire.wav");
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void VictoriaMowdownSelfDefense(VictoriaMowdown npc)
{
	int target;
	target = npc.m_iTarget;
	//some Ranged units will behave differently.
	//not this one.
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
	bool SpinSound = true;
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
	{
			npc.PlayMinigunSound(true);
			SpinSound = false;
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", false);
			npc.FaceTowards(vecTarget, 20000.0);
			Handle swingTrace;
			if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
			{
				target = TR_GetEntityIndex(swingTrace);	
					
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				float origin[3], angles[3];
				view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
				ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue", origin, vecHit, false );
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 22.5;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 4.0;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
				}
			}
			delete swingTrace;
	}
	if(SpinSound)
		npc.PlayMinigunSound(false);
}