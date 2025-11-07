#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/halloween_boss/knight_pain01.mp3",
	"vo/halloween_boss/knight_pain02.mp3",
	"vo/halloween_boss/knight_pain03.mp3"
};


static const char g_IdleAlertedSounds[][] = {
	"player/souls_receive1.wav",
	"player/souls_receive2.wav",
	"player/souls_receive3.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"misc/halloween/strongman_fast_swing_01.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};
static const char g_AngerSound[][] =
{
	"vo/halloween_boss/knight_laugh01.mp3",
	"vo/halloween_boss/knight_laugh02.mp3",
	"vo/halloween_boss/knight_laugh03.mp3",
	"vo/halloween_boss/knight_laugh04.mp3"
};
void Iberia_SeabornAnnihilator_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_AngerSound)); i++) { PrecacheSound(g_AngerSound[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Iberia-Expidonsan Seaborn Eradicator");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_seaborn_eradicator");
	strcopy(data.Icon, sizeof(data.Icon), "seaborn_annihilator");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_IberiaExpiAlliance;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Iberia_SeabornAnnihilator(vecPos, vecAng, team);
}

methodmap Iberia_SeabornAnnihilator < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(2.0, 4.0);
		
	}
	public void PlayAngerSound() 
	{
		EmitSoundToAll(g_AngerSound[GetRandomInt(0, sizeof(g_AngerSound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	property float m_flRecheckIfAlliesDead
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flEnrageHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	
	public Iberia_SeabornAnnihilator(float vecPos[3], float vecAng[3], int ally)
	{
		Iberia_SeabornAnnihilator npc = view_as<Iberia_SeabornAnnihilator>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.35", "50000000", ally, false, true));
		
		i_NpcWeight[npc.index] = 5;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if(iActivity > 0) npc.StartActivity(iActivity);
		SetVariantInt(6);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		npc.g_TimesSummoned = 0;


		npc.m_flMeleeArmor = 0.0012;
		npc.m_flRangedArmor = 0.0015;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Iberia_SeabornAnnihilator_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Iberia_SeabornAnnihilator_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Iberia_SeabornAnnihilator_ClotThink);
		
		
		npc.StartPathing();
		npc.m_flSpeed = 30.0;
		npc.m_flNextRangedSpecialAttack = GetGameTime() + GetRandomFloat(5.0, 15.0);
		if(!VIPBuilding_Active())
		{
			for(int i; i < ZR_MAX_SPAWNERS; i++)
			{
				if(!i_ObjectsSpawners[i] || !IsValidEntity(i_ObjectsSpawners[i]))
				{
					Spawns_AddToArray(EntIndexToEntRef(npc.index), true);
					i_ObjectsSpawners[i] = EntIndexToEntRef(npc.index);
					break;
				}
			}
		}
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetMoraleDoIberia(npc.index, 100.0);
		Is_a_Medic[npc.index] = true;
		

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/mail_bomber/mail_bomber.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_ethereal_hood/hw2013_ethereal_hood_spy.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_the_enlightening_lantern/hw2013_the_enlightening_lantern_demo.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/demo/dec15_shin_shredders/dec15_shin_shredders.mdl");
		int particle = ParticleEffectAt(vecPos, "utaunt_snowring_space_parent", 0.0);
		SetParent(npc.index, particle);
		npc.m_iWearable7 = particle;

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 0, 0, 0, 255);
		SetEntityRenderColor(npc.m_iWearable1, 0, 0, 0, 255);
		SetEntityRenderColor(npc.m_iWearable3, 0, 0, 0, 255);
		SetEntityRenderColor(npc.m_iWearable4, 0, 0, 0, 255);
		SetEntityRenderColor(npc.m_iWearable5, 0, 0, 0, 255);
		SetEntityRenderColor(npc.m_iWearable6, 0, 0, 0, 255);

		return npc;
	}
}

public void Iberia_SeabornAnnihilator_ClotThink(int iNPC)
{
	Iberia_SeabornAnnihilator npc = view_as<Iberia_SeabornAnnihilator>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	
	if(npc.m_flEnrageHappening)
	{
		npc.Anger = true;
		float pos[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
		pos[0] += GetRandomFloat(-30.0,30.0);
		pos[1] += GetRandomFloat(-30.0,30.0);
		pos[2] += GetRandomFloat(15.0,64.0);
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(pos[0]);
		pack_boom.WriteFloat(pos[1]);
		pack_boom.WriteFloat(pos[2]);
		pack_boom.WriteCell(0);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		if(IsValidEntity(npc.m_iWearable1))
		{
			RemoveEntity(npc.m_iWearable1);
		}
		IberiaLighthouse npc2 = view_as<IberiaLighthouse>(iNPC);
		npc2.PlayDeathSound();
		if(npc.m_flEnrageHappening < GetGameTime())
		{
			npc.m_flEnrageHappening = 0.0;
			if(npc.m_iChanged_WalkCycle != 5)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 5;
				npc.SetActivity("ACT_MP_RUN_ITEM1");
				npc.StartPathing();
				npc.m_flSpeed = 335.0;
				npc.m_flMeleeArmor = 1.0;
				npc.m_flRangedArmor = 1.0;
				SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 100);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", ReturnEntityMaxHealth(npc.index) / 100);
				npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
			}
		}
		return;
	}
	if(!npc.Anger)
	{
		if(npc.m_flRecheckIfAlliesDead < GetGameTime())
		{
			if(!IsValidAlly(npc.index, GetClosestAlly(npc.index)))
			{
				if(npc.m_iChanged_WalkCycle == 1)
				{
					npc.m_flEnrageHappening = GetGameTime() + 2.0;
					if(npc.m_iChanged_WalkCycle != 6)
					{
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 6;
						npc.AddActivityViaSequence("dieviolent");
						npc.StartPathing();
						npc.StopPathing();
						npc.m_flSpeed = 0.0;
						npc.PlayAngerSound();
					}
					return;
				}
				//wait before trying again!
				npc.m_flRecheckIfAlliesDead = GetGameTime() + 5.0;
				npc.m_iChanged_WalkCycle = 1;
				return;
			}	
			else
			{
				//5 second waiting time
				npc.m_iChanged_WalkCycle = 2;
			}
			
		}	
	}
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	IberiaMoraleGivingDo(iNPC, GetGameTime(npc.index),_, 1000.0);
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
		Iberia_SeabornAnnihilatorSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Iberia_SeabornAnnihilator_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Iberia_SeabornAnnihilator npc = view_as<Iberia_SeabornAnnihilator>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}


public void Iberia_SeabornAnnihilator_NPCDeath(int entity)
{
	Iberia_SeabornAnnihilator npc = view_as<Iberia_SeabornAnnihilator>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	Spawns_RemoveFromArray(entity);
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(i_ObjectsSpawners[i] == entity)
		{
			i_ObjectsSpawners[i] = 0;
			break;
		}
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

void Iberia_SeabornAnnihilatorSelfDefense(Iberia_SeabornAnnihilator npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					//if you try to tank, you die.
					float damageDealt = 10000.0;
					if(npc.Anger)
						damageDealt = 500.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 10.5;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1",_,_,_,0.5);
						
				npc.m_flAttackHappens = gameTime + 0.75;
				npc.m_flDoingAnimation = gameTime + 0.75;
				npc.m_flNextMeleeAttack = gameTime + 1.5;
			}
		}
	}
}