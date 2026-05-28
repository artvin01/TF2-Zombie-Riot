#pragma semicolon 1
#pragma newdecls required

void TEST_Dummy_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Dummy");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_dum");
	strcopy(data.Icon, sizeof(data.Icon), "medic_uber");
	data.IconCustom = false;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return TEST_Dummy(vecPos, vecAng, ally, data);
}

methodmap TEST_Dummy < CClotBody
{
	property int i_CountHits
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float flCountDamage
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float flCountDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float flLimitDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float flEndTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float flHighDamage
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float flLowDamage
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}

	public TEST_Dummy(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		ally = TFTeam_Stalkers;
		TEST_Dummy npc = view_as<TEST_Dummy>(CClotBody(vecPos, vecAng, "models/player/pyro.mdl", "1.0", "19721121", ally));
		
		b_NoKillFeed[npc.index] = true;
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.AddActivityViaSequence("ref");
		npc.SetCycle(0.01);
		
		func_NPCDeath[npc.index] = TESTDummy_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = TESTDummy_OnTakeDamage;
		func_NPCThink[npc.index] = TESTDummy_ClotThink;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_iState = 0;
		npc.i_CountHits=0;
		npc.flCountDamage=0.0;
		npc.flCountDuration=0.0;
		npc.flLimitDuration=0.0;
		npc.flEndTime=0.0;
		npc.flHighDamage=0.0;
		npc.flLowDamage=0.0;
		
		AddNpcToAliveList(npc.index, 1);
		Is_a_Medic[npc.index] = true;
		npc.m_bStaticNPC = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_DoNotUnStuck[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		b_NoHealthbar[npc.index]=true;
		
		npc.m_bisWalking = false;
		npc.m_bAllowBackWalking = false;
		npc.m_iChanged_WalkCycle = 2;
		npc.m_flSpeed = 0.0;
		npc.StopPathing();
		
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			npc.flLimitDuration = value;
		}
		
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);
		
		if(IsValidEntity(i_InvincibleParticle[npc.index]))
		{
			int particle = EntRefToEntIndex(i_InvincibleParticle[npc.index]);
			SetEntityRenderMode(particle, RENDER_TRANSCOLOR);
			SetEntityRenderColor(particle, 255, 255, 255, 1);
			SetEntPropFloat(particle, Prop_Send, "m_fadeMinDist", 1.0);
			SetEntPropFloat(particle, Prop_Send, "m_fadeMaxDist", 1.0);
		}
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);
			
		b_NpcForcepowerupspawn[npc.index] = 0;
		i_RaidGrantExtra[npc.index] = 0;
		b_DissapearOnDeath[npc.index] = true;
		b_DoGibThisNpc[npc.index] = true;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_the_haha_hairdo/hw2013_the_haha_hairdo.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2019_binoculus/hwn2019_binoculus_pyro.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/pyro/hwn2019_pyro_lantern/hwn2019_pyro_lantern.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable1, 16738740);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable2, 16738740);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable3, 16738740);
		
		return npc;
	}
}

static void TESTDummy_ClotThink(int iNPC)
{
	TEST_Dummy npc = view_as<TEST_Dummy>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;
	if(ReturnEntityMaxHealth(npc.index)!=19721121)
	{
		SetEntProp(npc.index, Prop_Data, "m_iHealth", 19721121);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", 19721121);
	}

	if(npc.flEndTime && npc.flEndTime < gameTime)
	{
		PrintToChatAll("[DMG: %.1f || HIT %i || Duration: %.1f]",npc.flCountDamage,npc.i_CountHits,gameTime-npc.flCountDuration);
		if(npc.flHighDamage==npc.flLowDamage)
			PrintToChatAll("[Single DMG: %.1f]",npc.flHighDamage);
		else
			PrintToChatAll("[High DMG: %.1f || Low DMG: %.1f]",npc.flHighDamage,npc.flLowDamage);
		npc.i_CountHits=0;
		npc.flCountDamage=0.0;
		npc.flCountDuration=0.0;
		npc.flEndTime=0.0;
		npc.flHighDamage=0.0;
		npc.flLowDamage=0.0;
	}
}

static Action TESTDummy_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	TEST_Dummy npc = view_as<TEST_Dummy>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if(TESTDummy_Delete(attacker))
	{
		SmiteNpcToDeath(npc.index);
		return Plugin_Continue;
	}
		
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	float gameTime = GetGameTime(npc.index);
	npc.i_CountHits++;
	npc.flCountDamage+=damage;
	
	if(npc.flHighDamage)
	{
		if(damage < npc.flLowDamage)
			npc.flLowDamage=damage;
		if(damage > npc.flHighDamage)
			npc.flHighDamage=damage;
	}
	else
	{
		npc.flHighDamage=damage;
		npc.flLowDamage=damage;
	}
	
	if(!npc.flCountDuration)
		npc.flCountDuration=gameTime;
	if(npc.flLimitDuration)
	{
		if(!npc.flEndTime)
			npc.flEndTime=gameTime+npc.flLimitDuration;
	}
	else
		npc.flEndTime=gameTime+1.0;
	HealEntityGlobal(npc.index, npc.index, float(ReturnEntityMaxHealth(npc.index)), 1.0, 3.0);
	
	return Plugin_Changed;
}

static bool TESTDummy_Delete(int client)
{
	if(client > MaxClients)
		return false;
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon))
		return false;
	if(i_CustomWeaponEquipLogic[weapon]==WEAPON_BOBS_GUN)
		return true;
	return false;
}

static void TESTDummy_NPCDeath(int entity)
{
	TEST_Dummy npc = view_as<TEST_Dummy>(entity);

	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
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