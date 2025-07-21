#pragma semicolon 1
#pragma newdecls required

//this thing is *kinda* an npc, but also not really

static char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/dragons_fury_shoot.wav",
};

void Ruina_Storm_Weaver_Mid_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Stellar Weaver");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_stellar_weaver_middle");
	data.Category = -1;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), ""); 						//leaderboard_class_(insert the name)
	data.IconCustom = false;												//download needed?
	data.Flags = 0;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{	
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_MeleeHitSounds);

	PrecacheModel(RUINA_STORM_WEAVER_MODEL);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Storm_Weaver_Mid(vecPos, vecAng, team, StringToFloat(data));
}

methodmap Storm_Weaver_Mid < CClotBody
{
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}

	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	
	public Storm_Weaver_Mid(float vecPos[3], float vecAng[3], int ally, float in_line_id)
	{
		Storm_Weaver_Mid npc = view_as<Storm_Weaver_Mid>(CClotBody(vecPos, vecAng, RUINA_STORM_WEAVER_MODEL, RUINA_STORM_WEAVER_MODEL_SIZE, "1250", ally));
		
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		
		npc.m_iState = EntIndexToEntRef(RoundToFloor(in_line_id));


		if(ally != TFTeam_Red)
		{
			//b_thisNpcIsABoss[npc.index] = true;
		}
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);

		Ruina_Set_No_Retreat(npc.index);

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);
		
		npc.m_flGetClosestTargetTime = 0.0;

		npc.StopPathing();
		

		b_NoGravity[npc.index] = true;	//Found ya!

		b_DoNotUnStuck[npc.index] = true;

		npc.m_bDissapearOnDeath = true;
		b_NoKnockbackFromSources[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		return npc;
	}
	
}



static void ClotThink(int iNPC)
{
	Storm_Weaver_Mid npc = view_as<Storm_Weaver_Mid>(iNPC);

	f_StuckOutOfBoundsCheck[npc.index] = GetGameTime() + 10.0;
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}

	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;
	
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}

	int PrimaryThreatIndex = npc.m_iTarget;

	int follow_id = EntRefToEntIndex(npc.m_iState);

	if(IsValidEntity(follow_id))
	{
		float Follow_Loc[3];
		GetEntPropVector(follow_id, Prop_Send, "m_vecOrigin", Follow_Loc);
		Storm_Weaver_Middle_Movement(npc, Follow_Loc);	//we can see it, travel normally!
		
	}
	else
	{
		//CPrintToChatAll("death cause no hp.");
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		func_NPCThink[npc.index] = INVALID_FUNCTION;

		return;
	}
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		int Enemy_I_See;
				
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
		{
			float vecTarget[3];
			WorldSpaceCenter(PrimaryThreatIndex, vecTarget);

			if(b_stellar_weaver_allow_attack[npc.index] && fl_stellar_weaver_special_attack_offset < GameTime)
			{
				float Ratio = (Waves_GetRoundScale()+1)/40.0;
				fl_stellar_weaver_special_attack_offset = GameTime + 0.1;
				Stellar_Weaver_Attack(npc.index, vecTarget, 50.0*Ratio, 500.0, 15.0, 500.0*Ratio, 150.0, 10.0);
				b_stellar_weaver_allow_attack[npc.index] = false;
			}
				

			if(GameTime > npc.m_flNextRangedAttack)
			{
				npc.PlayMeleeHitSound();
				float Ratio = (Waves_GetRoundScale()+1)/40.0;
				float DamageDone = 50.0*Ratio;
				npc.FireParticleRocket(vecTarget, DamageDone, 1250.0, 0.0, "spell_fireball_small_blue", false, true, false,_,_,_,10.0);
				npc.m_flNextRangedAttack = GameTime + 5.0;
			}
		}
	}
	else
	{
		
	}


}
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Storm_Weaver_Mid npc = view_as<Storm_Weaver_Mid>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	if(!b_storm_weaver_solo)
	{
		Storm_Weaver_Share_With_Anchor_Damage(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		Ruina_Add_Battery(npc.index, damage);	//turn damage taken into energy

		SetEntProp(npc.index, Prop_Data, "m_iHealth", Storm_Weaver_Return_Health(npc));
	}
	else if(b_stellar_weaver_true_solo)
	{
		Stellar_Weaver_Share_Damage_With_All(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		Ruina_Add_Battery(npc.index, damage);	//turn damage taken into energy
		SetEntProp(npc.index, Prop_Data, "m_iHealth", Storm_Weaver_Return_Health(npc));
	}

	damage=0.0;	//storm weaver doesn't really take any damage, his "health bar" is just the combined health of all the towers
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void NPC_Death(int entity)
{
	Storm_Weaver_Mid npc = view_as<Storm_Weaver_Mid>(entity);
	
	npc.m_iState = -1;
	
	Ruina_NPCDeath_Override(entity);

	float pos1[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos1);
	DataPack pack_boom1 = new DataPack();
	pack_boom1.WriteFloat(pos1[0]);
	pack_boom1.WriteFloat(pos1[1]);
	pack_boom1.WriteFloat(pos1[2]);
	pack_boom1.WriteCell(1);
	RequestFrame(MakeExplosionFrameLater, pack_boom1);
}