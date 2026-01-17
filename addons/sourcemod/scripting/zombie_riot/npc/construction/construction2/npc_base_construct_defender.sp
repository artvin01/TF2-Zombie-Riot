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


static const char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",

	"npc/metropolice/vo/pickupthecan3.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/takedown.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/shovel_swing.wav",
};

static int NPCId;
void Const2BaseConstructDefender_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Alive Construct");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_base_construct_defender");
	strcopy(data.Icon, sizeof(data.Icon), "heavy_chief");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Interitus;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int IsConst2Defender()
{
	return NPCId;
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Const2BaseConstructDefender(vecPos, vecAng, team);
}

methodmap Const2BaseConstructDefender < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 70);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 70);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 70);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 70);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 70);

	}
	property float m_flWalkAroundRandomlyDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	
	
	public Const2BaseConstructDefender(float vecPos[3], float vecAng[3], int ally)
	{
		Const2BaseConstructDefender npc = view_as<Const2BaseConstructDefender>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "1.65", "10000", ally, false, true));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		

		npc.SetActivity("ACT_CONSTRUCTION_CONSTRUCT_IDLE");
		b_NpcUnableToDie[npc.index] = true;

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;

		func_NPCDeath[npc.index] = view_as<Function>(Const2BaseConstructDefender_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Const2BaseConstructDefender_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Const2BaseConstructDefender_ClotThink);
		
		
		npc.StartPathing();
		npc.m_flSpeed = 220.0;
		
		
		int skin = 0;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		SetEntityRenderColor(npc.index, 255, 215, 0, 255);
		b_ShowNpcHealthbar[npc.index] = true;
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntityRenderColor(npc.m_iWearable2, 255, 215, 0, 255);
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 2);
		
		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/player/items/soldier/soldier_spartan.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		NpcColourCosmetic_ViaPaint(npc.m_iWearable1, 16766720);
		
		SetEntityRenderColor(npc.m_iWearable1, 255, 215, 0, 255);
		ApplyStatusEffect(npc.index, npc.index, "Const2 Scaling For Enemy Base Nerf", 999999.0);

		return npc;
	}
}

#define MAX_RANGE_DEFEND_BASE 1000.0

public void Const2BaseConstructDefender_ClotThink(int iNPC)
{
	Const2BaseConstructDefender npc = view_as<Const2BaseConstructDefender>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();	
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	if(!b_ShowNpcHealthbar[iNPC])
	{
		//stunned
		return;
	}

	bool DefendingMode;
	if(IsValidEntity(npc.m_iTargetAlly))
		DefendingMode = true;

	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, npc.m_iTarget))
		i_Target[npc.index] = -1;
	else if(DefendingMode)
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecAllyNpc[3]; WorldSpaceCenter(npc.m_iTargetAlly, VecAllyNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecAllyNpc, true);
		if(flDistanceToTarget > ((MAX_RANGE_DEFEND_BASE * 1.2) * (MAX_RANGE_DEFEND_BASE * 1.2)))
		{
			//too far away from my defending thing, go back.
			i_Target[npc.index] = -1;
		}
	}

	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		if(!DefendingMode)
			npc.m_iTarget = GetClosestTarget(npc.index);
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.m_iTargetAlly,_,(MAX_RANGE_DEFEND_BASE * 0.9));
		}
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(npc.m_iTarget > 0)
	{
		npc.StartPathing();
		npc.m_bisWalking = true;
		npc.SetActivity("ACT_CONSTRUCTION_CONSTRUCT_N");
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc );

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
		Const2BaseConstructDefenderSelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget); 
	}
	else if(DefendingMode)
	{
		npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.45;
		//think much slower
		//Walk around randomly
		Const2BaseConstructDefender_WalkCycle(npc,GetGameTime(npc.index)); 
	}
	npc.PlayIdleAlertSound();
}

public Action Const2BaseConstructDefender_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Const2BaseConstructDefender npc = view_as<Const2BaseConstructDefender>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if(b_NpcIsInvulnerable[victim])
		return Plugin_Changed;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	if(RoundToNearest(damage) < GetEntProp(victim, Prop_Data, "m_iHealth"))
		return Plugin_Changed;

	SetDownedState_Construct(victim, 1);
	damage = 0;
	//we died.
	return Plugin_Changed;
}
void SetDownedState_Construct(int iNpc, bool StateDo)
{
	Const2BaseConstructDefender npc = view_as<Const2BaseConstructDefender>(iNpc);
	if(StateDo) //downed
	{
		b_ShowNpcHealthbar[iNpc] = false;	
		b_ThisEntityIgnored[iNpc] = true;
		b_NpcIsInvulnerable[iNpc] = true;
		SetEntProp(iNpc, Prop_Data, "m_iHealth", 1);
		npc.StopPathing();
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_CONSTRUCTION_CONSTRUCT_IDLE");
		SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
		SetEntityRenderColor(npc.index, 255, 215, 0, 125);
		if(IsValidEntity(npc.m_iWearable1))
		{
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSALPHA);
			SetEntityRenderColor(npc.m_iWearable1, 255, 215, 0, 125);
		}
		if(IsValidEntity(npc.m_iWearable2))
		{
			SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSALPHA);
			SetEntityRenderColor(npc.m_iWearable2, 255, 215, 0, 125);
		}
	}
	else
	{
		b_ShowNpcHealthbar[iNpc] = true;	
		b_ThisEntityIgnored[iNpc] = false;
		b_NpcIsInvulnerable[iNpc] = false;
		SetEntProp(iNpc, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(iNpc));
		SetEntityRenderMode(npc.index, RENDER_NORMAL);
		SetEntityRenderColor(npc.index, 255, 215, 0, 255);
		if(IsValidEntity(npc.m_iWearable1))
		{
			SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
			SetEntityRenderColor(npc.m_iWearable1, 255, 215, 0, 255);
		}
		if(IsValidEntity(npc.m_iWearable2))
		{
			SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
			SetEntityRenderColor(npc.m_iWearable2, 255, 215, 0, 255);
		}
	}
	
}

public void Const2BaseConstructDefender_NPCDeath(int entity)
{
	Const2BaseConstructDefender npc = view_as<Const2BaseConstructDefender>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void Const2BaseConstructDefenderSelfDefense(Const2BaseConstructDefender npc, float gameTime, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			int HowManyEnemeisAoeMelee = 64;
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
			delete swingTrace;
			bool PlaySound = false;
			for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
			{
				if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
				{
					if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
					{
						float vecHit[3];
						PlaySound = true;
						int target = i_EntitiesHitAoeSwing_NpcSwing[counter];
						WorldSpaceCenter(target, vecHit);
									
						float damageDealt = Const2AltarDamageGet();

						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					}
				}
			}
			if(PlaySound)
			{
				npc.PlayMeleeHitSound();
			}
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
				npc.AddGesture("ACT_CONSTRUCTION_CONSTRUCT_ATTACK");
						
				npc.m_flAttackHappens = gameTime + 0.35;
				npc.m_flDoingAnimation = gameTime + 0.35;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
		}
	}
}



void Const2BaseConstructDefender_WalkCycle(Const2BaseConstructDefender npc, float gameTime)
{

	if(fl_AbilityVectorData[npc.index][2] != 0.0)
	{
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);

		float flDistanceToTarget = GetVectorDistance(pos, fl_AbilityVectorData[npc.index], true);
		if(flDistanceToTarget <= (50.0 * 50.0))
		{
			fl_AbilityVectorData[npc.index][2] = 0.0;
			npc.SetGoalVector(pos);
			npc.StopPathing();
			npc.m_bisWalking = false;
			npc.SetActivity("ACT_CONSTRUCTION_CONSTRUCT_IDLE");
		}
	}
	if(npc.m_flWalkAroundRandomlyDo < gameTime)
	{
		float pos[3]; GetEntPropVector(npc.m_iTargetAlly, Prop_Data, "m_vecAbsOrigin", pos);
		if(!FindRandomSpotTowalkTo(npc.index, pos, MAX_RANGE_DEFEND_BASE * 0.9))
		{
			npc.m_flWalkAroundRandomlyDo = gameTime + 1.0;
			//retry in 1 second
		}
		else
		{
			npc.m_flWalkAroundRandomlyDo = gameTime + GetRandomFloat(5.0 ,10.0);
			npc.StartPathing();
			npc.SetGoalVector(pos);
			npc.m_bisWalking = true;
			fl_AbilityVectorData[npc.index] = pos;
			npc.SetActivity("ACT_CONSTRUCTION_CONSTRUCT_N");
		}
	}
}


int FindRandomSpotTowalkTo(int entity, float VectorStart[3] = {0.0,0.0,0.0}, float RangeToWalk)
{
	float f3_VecAbs[3];
	f3_VecAbs = VectorStart;
	Diversionistico npc = view_as<Diversionistico>(entity);
	for( int loop = 1; loop <= 50; loop++ ) 
	{
		float AproxRandomSpaceToWalkTo[3];
		CNavArea RandomArea;
		
		RandomArea = GetRandomNearbyArea(f3_VecAbs, RangeToWalk);
			
		if(RandomArea == NULL_AREA) 
			break; //No nav?

		int NavAttribs = RandomArea.GetAttributes();
		if(NavAttribs & NAV_MESH_AVOID)
		{
			continue;
		}

		RandomArea.GetCenter(AproxRandomSpaceToWalkTo);


		if(IsPointOutsideMap(AproxRandomSpaceToWalkTo))
			continue;
		
		VectorStart = AproxRandomSpaceToWalkTo;
		return 1;
	}
	return 0;
}
