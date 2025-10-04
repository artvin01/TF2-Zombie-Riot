#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"ui/killsound_squasher.wav",
};

static const char g_HurtSounds[][] = {
	"ui/hitsound_vortex1.wav",
	"ui/hitsound_vortex2.wav",
	"ui/hitsound_vortex3.wav",
	"ui/hitsound_vortex4.wav",
	"ui/hitsound_vortex5.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/scout_mvm_beingshotinvincible01.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible02.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible03.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible04.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible05.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible06.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible07.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible08.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible09.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible11.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible12.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible13.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible14.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible15.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible16.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible17.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible18.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible19.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible21.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible22.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible23.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible24.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible25.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible26.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible27.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible28.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible29.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible31.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible32.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible33.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible34.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible35.mp3",
	"vo/mvm/norm/scout_mvm_beingshotinvincible36.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/gunslinger_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/batsaber_hit_world1.wav",
	"weapons/batsaber_hit_world2.wav",
};


void Umbral_Spuud_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/heavy.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Umbral Spuud");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_umbral_spuud");
	strcopy(data.Icon, sizeof(data.Icon), "spuud");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Curtain;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Umbral_Spuud(vecPos, vecAng, team);
}
methodmap Umbral_Spuud < CClotBody
{
	property float m_flSpassOut
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flSpassOut2
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flSpeedIncreaceMeter
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		this.m_flNextIdleSound = GetGameTime(this.index) + 1.0;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(35, 40));
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.3;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(40, 60));
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 50);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 60);
	}
	
	public Umbral_Spuud(float vecPos[3], float vecAng[3], int ally)
	{
		Umbral_Spuud npc = view_as<Umbral_Spuud>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "1.0", "22500", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_UMBRAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Umbral_Spuud_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Umbral_Spuud_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Umbral_Spuud_ClotThink);
		
		npc.StartPathing();
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_flSpeedIncreaceMeter = 1.0;

		npc.m_bDissapearOnDeath = true;
		//dont allow self making
		
		npc.m_flSpeed = 330.0;

		SetEntityRenderFx(npc.index, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.index, GetRandomInt(25, 255), GetRandomInt(25, 255), GetRandomInt(25, 255), 125);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_invasion_bat/c_invasion_bat.mdl");
		SetEntityRenderFx(npc.m_iWearable1, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.m_iWearable1, GetRandomInt(25, 35), GetRandomInt(25, 35), GetRandomInt(25, 35), 125);

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/engineer/dec23_sleuth_suit_style4/dec23_sleuth_suit_style4.mdl");
		SetEntityRenderFx(npc.m_iWearable2, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.m_iWearable2, GetRandomInt(25, 35), GetRandomInt(25, 35), GetRandomInt(25, 35), 125);
		
		ApplyStatusEffect(npc.index, npc.index, "Umbral Grace", 2.0);
		if(ally != TFTeam_Red && Rogue_Mode())
		{
			if(Rogue_GetUmbralLevel() == 0)
			{
				//when friendly and they still spawn as enemies, nerf.
				fl_Extra_Damage[npc.index] *= 0.75;
				fl_Extra_Speed[npc.index] *= 0.85;
				fl_Extra_MeleeArmor[npc.index] *= 1.25;
				fl_Extra_RangedArmor[npc.index] *= 1.25;
			}
			else if(Rogue_GetUmbralLevel() == 4)
			{
				//if completly hated.
				//no need to adjust HP scaling, so it can be done here.
				fl_Extra_Damage[npc.index] *= 1.65;
				fl_Extra_MeleeArmor[npc.index] *= 0.5;
				fl_Extra_RangedArmor[npc.index] *= 0.5;
				fl_Extra_Speed[npc.index] *= 1.05;
				ApplyStatusEffect(npc.index, npc.index, "Umbral Grace", 7.0);
			}
			switch(Rogue_GetFloor() + 1)
			{
				//floor 3
				//10% dmg, 20% res
				//think 10% faster
				case 3:
				{
					fl_Extra_Damage[npc.index] *= 1.1;
					fl_Extra_MeleeArmor[npc.index] *= 0.8;
					fl_Extra_RangedArmor[npc.index] *= 0.8;
					f_AttackSpeedNpcIncrease[npc.index]	*= (1.0 / 1.1);
				}
				//floor 4-5
				// 25% more dmg, 50% more res
				//think 25% faster
				case 4,5:
				{
					fl_Extra_Damage[npc.index] *= 1.25;
					fl_Extra_MeleeArmor[npc.index] *= 0.5;
					fl_Extra_RangedArmor[npc.index] *= 0.5;
					f_AttackSpeedNpcIncrease[npc.index]	*= (1.0 / 1.25);
				}
				//floor 6
				// 35% more dmg, 60% more res
				//think 30% faster
				case 6:
				{
					fl_Extra_Damage[npc.index] *= 1.35;
					fl_Extra_MeleeArmor[npc.index] *= 0.4;
					fl_Extra_RangedArmor[npc.index] *= 0.4;
					f_AttackSpeedNpcIncrease[npc.index]	*= (1.0 / 1.30);
				}
			}
		}
		return npc;
	}
}

public void Umbral_Spuud_ClotThink(int iNPC)
{
	Umbral_Spuud npc = view_as<Umbral_Spuud>(iNPC);
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
	
	if(i_npcspawnprotection[npc.index] <= NPC_SPAWNPROT_INIT)
		npc.m_flSpeedIncreaceMeter *= 0.9975;

	if(npc.m_flSpeedIncreaceMeter <= 0.1)
	{
		npc.m_flSpeedIncreaceMeter = 0.1;
	}
	npc.m_flMeleeArmor = (1.0 / npc.m_flSpeedIncreaceMeter);
	npc.m_flMeleeArmor -= 8.0;
	if(npc.m_flMeleeArmor <= 1.0)
	{
		npc.m_flMeleeArmor = 1.0;
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	
	UmbralSpuudAnimBreak(npc);
	if(npc.m_flGetClosestTargetTime < GetGameTime())
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime() + GetRandomRetargetTime();
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
		Umbral_SpuudSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Umbral_Spuud_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Umbral_Spuud npc = view_as<Umbral_Spuud>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
		
	}
	
	return Plugin_Changed;
}

public void Umbral_Spuud_NPCDeath(int entity)
{
	Umbral_Spuud npc = view_as<Umbral_Spuud>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		
	TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, 		{90.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, 	{90.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, {90.0,0.0,0.0}, -1, _, _, _, _, _, _, _, _, _, 0.0);

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

void Umbral_SpuudSelfDefense(Umbral_Spuud npc, float gameTime, int target, float distance)
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
					float damageDealt = 30.0;
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
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				float MaxAnimSpeed = (1.5 * (1.0 / npc.m_flSpeedIncreaceMeter));
				if(MaxAnimSpeed >= 4.0)
					MaxAnimSpeed = 4.0;

				npc.m_iTarget = Enemy_I_See;
			//	npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",false,_,_,MaxAnimSpeed);
				npc.m_flAttackHappens = gameTime + (0.2 * npc.m_flSpeedIncreaceMeter);
				npc.m_flDoingAnimation = gameTime + (0.2 * npc.m_flSpeedIncreaceMeter);
				npc.m_flNextMeleeAttack = gameTime + (0.75 * npc.m_flSpeedIncreaceMeter);
			}
		}
	}
}



void UmbralSpuudAnimBreak(Umbral_Spuud npc)
{
	float MaxLayer = (0.2 * (1.0 / npc.m_flSpeedIncreaceMeter));
	if(MaxLayer >= 0.9)
		MaxLayer = 0.9;
	if(npc.m_flSpassOut < GetGameTime())
	{
		float Random = GetRandomFloat(0.4, 0.7);
		int Layer;
		npc.m_flSpassOut = GetGameTime() + (Random * 0.5);
		Layer = npc.AddGesture("ACT_KART_IMPACT_BIG", .SetGestureSpeed = (1.5 * (1.0 / Random)));
		npc.SetLayerWeight(Layer, MaxLayer);
		Layer = npc.AddGesture("ACT_GRAPPLE_PULL_START", .SetGestureSpeed = (1.5 * (1.0 / Random)));
		npc.SetLayerWeight(Layer, MaxLayer - 0.1);
	}
	if(npc.m_flSpassOut2 < GetGameTime())
	{
		float Random = GetRandomFloat(0.4, 0.7);
		int Layer;
		npc.m_flSpassOut2 = GetGameTime() + (Random * 0.5);
		Layer = npc.AddGesture("ACT_MP_GESTURE_VC_HANDMOUTH_MELEE", .SetGestureSpeed = (1.5 * (1.0 / Random)));
		npc.SetLayerWeight(Layer, MaxLayer - 0.1);
	}
}
