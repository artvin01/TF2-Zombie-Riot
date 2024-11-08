#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "npc/scanner/scanner_explode_crash2.wav";
static const char g_AttackReadySounds[] = "weapons/sentry_spot_client.wav";
static const char g_AttackRocketSounds[] = "weapons/sentry_shoot3.wav";

void VictorianDroneFragments_MapStart()
{
	PrecacheModel("models/props_teaser/saucer.mdl");
	PrecacheModel("models/buildables/gibs/sentry1_gib1.mdl");
	PrecacheModel("models/buildables/gibs/sentry2_gib3.mdl");
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_AttackReadySounds);
	PrecacheSound(g_AttackRocketSounds);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "fragments");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victoria_fragments");
	strcopy(data.Icon, sizeof(data.Icon), "victorian_fragments");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictorianDroneFragments(client, vecPos, vecAng, ally, data);
}

methodmap VictorianDroneFragments < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public VictorianDroneFragments(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianDroneFragments npc = view_as<VictorianDroneFragments>(CClotBody(vecPos, vecAng, "models/props_teaser/saucer.mdl", "1.0", "8000", ally, _, true));
		
		i_NpcWeight[npc.index] = 999;
		npc.SetActivity("ACT_MP_STUN_MIDDLE");
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;
		
	//	SetVariantInt(1);
	//	AcceptEntityInput(npc.index, "SetBodyGroup");

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 100.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flMeleeArmor = 1.00;
		npc.m_flRangedArmor = 1.00;
		
		b_CannotBeKnockedUp[npc.index] = true;
		b_CannotBeSlowed[npc.index] = true;
		b_DoNotUnStuck[npc.index] = true;
		b_NoGravity[npc.index] = true;
		npc.m_bDissapearOnDeath = true;

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 80, 50, 50, 255);
		float Vec[3], Ang[3]={0.0,0.0,0.0};
		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable1 = npc.EquipItemSeperate("partyhat", "models/buildables/gibs/sentry1_gib1.mdl",_,1,1.0,_,true);
		Ang[0] = -90.0;
		Ang[1] = 270.0;
		Vec[0] -= 36.5;
		TeleportEntity(npc.m_iWearable1, Vec, Ang, NULL_VECTOR);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 80, 50, 50, 255);
		GetAbsOrigin(npc.index, Vec);
		npc.m_iWearable2 = npc.EquipItemSeperate("partyhat", "models/buildables/gibs/sentry2_gib3.mdl",_,1,1.0,_,true);
		Ang[0] = 30.0;
		Ang[1] = 0.0;
		Ang[2] = -90.0;
		Vec[0] += 1.0;
		Vec[1] += 31.5;
		Vec[2] -= 21.0;
		TeleportEntity(npc.m_iWearable2, Vec, Ang, NULL_VECTOR);
		
		SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable1, "SetParent", npc.index);
		MakeObjectIntangeable(npc.m_iWearable1);
		SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable2, "SetParent", npc.index);
		MakeObjectIntangeable(npc.m_iWearable2);
		/*SetVariantString("!activator");
		AcceptEntityInput(npc.m_iWearable3, "SetParent", npc.index);
		MakeObjectIntangeable(npc.m_iWearable3);*/
		
		GetAbsOrigin(npc.index, Vec);
		Vec[2]+=35.0;
		PluginBot_Jump(npc.index, Vec);
		
		return npc;
	}
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianDroneFragments npc = view_as<VictorianDroneFragments>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void ClotThink(int iNPC)
{
	VictorianDroneFragments npc = view_as<VictorianDroneFragments>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;
	
	//lul
}

static void ClotDeath(int entity)
{
	VictorianDroneFragments npc = view_as<VictorianDroneFragments>(entity);

	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);

	npc.PlayDeathSound();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);

	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
}
