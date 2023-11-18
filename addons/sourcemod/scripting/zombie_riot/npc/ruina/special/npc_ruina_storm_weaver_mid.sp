#pragma semicolon 1
#pragma newdecls required

//this thing is *kinda* an npc, but also not really


static const char g_DeathSounds[][] = {
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

void Ruina_Storm_Weaver_Mid_MapStart()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}

	PrecacheModel(RUINA_STORM_WEAVER_MODEL);

}


methodmap Storm_Weaver_Mid < CClotBody
{
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public Storm_Weaver_Mid(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		Storm_Weaver_Mid npc = view_as<Storm_Weaver_Mid>(CClotBody(vecPos, vecAng, RUINA_STORM_WEAVER_MODEL, "1.0", "1250", ally));
		
		i_NpcInternalId[npc.index] = RUINA_STORM_WEAVER_MID;
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");


		if(!ally)
		{
			b_thisNpcIsABoss[npc.index] = true;
		}
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		Ruina_Set_Heirarchy(npc.index, 2);

		Ruina_Set_No_Retreat(npc.index);

		
		
		SDKHook(npc.index, SDKHook_Think, Storm_Weaver_Mid_ClotThink);
		
		npc.m_flGetClosestTargetTime = 0.0;

		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;

		b_NoGravity[npc.index] = true;	//Found ya!

		
		return npc;
	}
	
}


//TODO 
//Rewrite
public void Storm_Weaver_Mid_ClotThink(int iNPC)
{
	Storm_Weaver_Mid npc = view_as<Storm_Weaver_Mid>(iNPC);
	
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

	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		
	}
	else
	{
		
	}


}
public Action Storm_Weaver_Mid_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Storm_Weaver_Mid npc = view_as<Storm_Weaver_Mid>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if(!b_storm_weaver_solo[npc.index])
	{
		//Storm_Weaver_Share_With_Anchor_Damage(npc, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		fl_ruina_battery[npc.index] += damage;	//turn damage taken into energy
		damage=0.0;	//storm weaver doesn't really take any damage, his "health bar" is just the combined health of all the towers
	}
	else
	{
		if(damagetype & DMG_CLUB)	//if a person is brave enough to melee this thing, reward them handsomely
		{
			damage *=2.5;
			fl_ruina_battery[npc.index] += damage;	//turn damage taken into energy
		}
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Storm_Weaver_Mid_NPCDeath(int entity)
{
	Storm_Weaver_Mid npc = view_as<Storm_Weaver_Mid>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, Storm_Weaver_Mid_ClotThink);

}