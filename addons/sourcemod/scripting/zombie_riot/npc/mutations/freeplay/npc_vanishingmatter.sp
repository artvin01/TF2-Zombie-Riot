#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"ui/killsound_squasher.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/medic_sf13_magic_reac07.mp3",
	"vo/medic_sf13_magic_reac02.mp3",
	"vo/medic_sf13_magic_reac03.mp3",
	"vo/medic_sf13_magic_reac05.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"player/taunt_yeti_standee_demo_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/ubersaw_hit1.wav",
	"weapons/ubersaw_hit2.wav",
	"weapons/ubersaw_hit3.wav",
	"weapons/ubersaw_hit4.wav",
};

void VanishingMatter_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Vanishing Matter");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_vanishingmatter");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return VanishingMatter(vecPos, vecAng, team);
}
methodmap VanishingMatter < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(60, 135));
		this.m_flNextIdleSound = GetGameTime(this.index) + 6.0;
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 50);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	
	
	public VanishingMatter(float vecPos[3], float vecAng[3], int ally)
	{
		VanishingMatter npc = view_as<VanishingMatter>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "75000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(VanishingMatter_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VanishingMatter_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VanishingMatter_ClotThink);
		
		npc.StartPathing();
		npc.m_flSpeed = 325.0;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/medic/medic_zombie.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_ubersaw/c_ubersaw.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2024_spider_sights/hwn2024_spider_sights_medic.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sum20_self_care/sum20_self_care.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(65, 255));
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(65, 255));
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(65, 255));
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(65, 255));
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(65, 255));
		SetEntityRenderFx(npc.m_iWearable1, RENDERFX_HOLOGRAM);
		SetEntityRenderFx(npc.m_iWearable2, RENDERFX_HOLOGRAM);
		SetEntityRenderFx(npc.m_iWearable3, RENDERFX_HOLOGRAM);
		SetEntityRenderFx(npc.m_iWearable4, RENDERFX_HOLOGRAM);
		SetEntityRenderFx(npc.m_iWearable5, RENDERFX_HOLOGRAM);

		SetEntityRenderFx(npc.index, RENDERFX_HOLOGRAM);
		SetEntityRenderColor(npc.index, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(65, 255));

		return npc;
	}
}

public void VanishingMatter_ClotThink(int iNPC)
{
	VanishingMatter npc = view_as<VanishingMatter>(iNPC);
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
		VanishingMatterSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if(GetEntProp(npc.index, Prop_Data, "m_iHealth") > RoundToCeil(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") * 0.5))
	{
		npc.Anger = false;
		int newhp = RoundToCeil(float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")) * 0.004);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") - newhp);
	}
	else
	{
		npc.Anger = true;
	}

	if(npc.Anger)
	{
		npc.m_flSpeed = 350.0;
	}
	else
	{
		npc.m_flSpeed = 300.0;
	}	

	npc.PlayIdleAlertSound();
}

public Action VanishingMatter_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VanishingMatter npc = view_as<VanishingMatter>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if (!npc.Anger && damage > 20000.0)
	{
		damage = 20000.0;
		return Plugin_Handled;
	}
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void VanishingMatter_NPCDeath(int entity)
{
	VanishingMatter npc = view_as<VanishingMatter>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
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

void VanishingMatterSelfDefense(VanishingMatter npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{	
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 150.0;

					if(!npc.Anger)
					{
						damageDealt = 100.0;
					}

					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 2.5;
						
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					if(GetEntProp(npc.index, Prop_Data, "m_iHealth") > 2)
					{
						int newhp = RoundToCeil(float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")) * 0.01);
						SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") - newhp);
						if(GetEntProp(npc.index, Prop_Data, "m_iHealth") < 0)
							SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
					}

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();

				if(npc.Anger)
				{
					if(!NpcStats_IsEnemySilenced(npc.index))
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,4.0);
						npc.m_flAttackHappens = gameTime + 0.02;
						npc.m_flDoingAnimation = gameTime + 0.02;
						npc.m_flNextMeleeAttack = gameTime + 0.1;
					}
					else
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,2.5);
						npc.m_flAttackHappens = gameTime + 0.1;
						npc.m_flDoingAnimation = gameTime + 0.1;
						npc.m_flNextMeleeAttack = gameTime + 0.3;
					}
				}
				else
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,1.5);
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.8;
					if(GetEntProp(npc.index, Prop_Data, "m_iHealth") > RoundToCeil(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") * 0.5))
					{
						int newhp = RoundToCeil(float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")) * 0.01);
						SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") - newhp);
					}
				}		
			}
		}
	}
}
