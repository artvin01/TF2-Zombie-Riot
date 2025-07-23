#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "misc/rd_robot_explosion01.wav";
static int NPCId;

void VictorianFactory_MapStart()
{
	PrecacheSound("misc/rd_points_return01.wav");
	PrecacheSound("misc/doomsday_lift_start.wav");
	PrecacheSound("misc/hologram_start.wav");
	PrecacheSound("items/bomb_warning.wav");
	PrecacheSound(g_DeathSounds);
	PrecacheModel("models/props_c17/substation_transformer01a.mdl");
	PrecacheModel("models/props_c17/lockers001a.mdl");
	PrecacheModel("models/props_skybox/train_building004_skybox.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Factory");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victoria_factory");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_factory");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int VictorianFactory_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictorianFactory(vecPos, vecAng, ally);
}

static char[] GetBuildingHealth()
{
	int health = 120;
	
	health = RoundToNearest(float(health) * ZRStocks_PlayerScalingDynamic()); //yep its high! will need tos cale with waves expoentially.
	
	float temp_float_hp = float(health);
	float wave = float(Waves_GetRoundScale()+1) / 0.75;
	
	if(wave < 30)
	{
		health = RoundToCeil(Pow(((temp_float_hp + wave) * wave),1.20));
	}
	else if(wave < 45)
	{
		health = RoundToCeil(Pow(((temp_float_hp + wave) * wave),1.25));
	}
	else
	{
		health = RoundToCeil(Pow(((temp_float_hp + wave) * wave),1.35)); //Yes its way higher but i reduced overall hp of him
	}
	
	health /= 2;
	health = RoundToCeil(float(health) * 1.2);
	health = RoundToCeil(float(health) * 0.67);//wtf
	
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}

methodmap VictorianFactory < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public VictorianFactory (float vecPos[3], float vecAng[3], int ally)
	{
		VictorianFactory npc = view_as<VictorianFactory>(CClotBody(vecPos, vecAng, "models/props_skybox/train_building004_skybox.mdl", "2.0", GetBuildingHealth(), ally, _, true, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 0.0;
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = GetGameTime() + 60.0;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flAttackHappens = 0.0;
		i_AttacksTillMegahit[npc.index] = 0;

		npc.m_flMeleeArmor = 0.0;
		npc.m_flRangedArmor = 0.0;
		b_IgnorePlayerCollisionNPC[npc.index] = true;
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
		npc.m_bDissapearOnDeath = true;
		i_NpcIsABuilding[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = false;
		f_ExtraOffsetNpcHudAbove[npc.index] = 1.0;
		if(ally != TFTeam_Red)
		{
			if(LastSpawnDiversio < GetGameTime())
			{
				EmitSoundToAll("misc/rd_points_return01.wav", _, _, _, _, 1.0);
				EmitSoundToAll("misc/rd_points_return01.wav", _, _, _, _, 1.0);
			}
			LastSpawnDiversio = GetGameTime() + 5.0;
			int Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 1000.0);
			switch(Decicion)
			{
				case 2:
				{
					Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 500.0);
					if(Decicion == 2)
					{
						Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 250.0);
						if(Decicion == 2)
						{
							Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 0.0);
						}
					}
				}
				case 3:
				{
					//todo code on what to do if random teleport is disabled
				}
			}
		}

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 80, 50, 50, 60);

		npc.m_iWearable3 = npc.EquipItemSeperate("models/props_c17/substation_transformer01a.mdl",_,1,1.001,5100.0,true);
		SetEntityRenderColor(npc.m_iWearable3, 80, 50, 50, 255);
		TeleportEntity(npc.m_iWearable3, NULL_VECTOR, {0.0, 0.0, 0.0}, NULL_VECTOR);

		return npc;
	}
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianFactory npc = view_as<VictorianFactory>(victim);
		
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
	VictorianFactory npc = view_as<VictorianFactory>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;
		
	if(npc.m_flNextRangedAttack < gameTime && !IsValidAlly(npc.index, GetClosestAlly(npc.index)))
	{
		SmiteNpcToDeath(npc.index);
		return;
	}

	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if(i_AttacksTillMegahit[npc.index] >= 600)
	{
		if(i_AttacksTillMegahit[npc.index] <= 600)
		{
			float Vec[3], Ang[3];
			GetAbsOrigin(npc.m_iWearable3, Vec);
			//CreateTimer(0.1, Timer_MachineShop, npc.index, TIMER_FLAG_NO_MAPCHANGE);
			//VictorianFactory npc = view_as<VictorianFactory>(iNPC);
			float entitypos[3], distance;
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity) && entity!=npc.index && GetTeam(entity) != GetTeam(npc.index))
				{
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
					distance = GetVectorDistance(Vec, entitypos);
					if(distance<200.0)
					{
						float MaxHealth = float(ReturnEntityMaxHealth(entity));
						float damage=(MaxHealth*2.0);
						SDKHooks_TakeDamage(entity, npc.index, npc.index, damage, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE);
					}
				}
			}
			for(int target=1; target<=MaxClients; target++)
			{
				if(IsValidClient(target) && IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE && GetTeam(target) != GetTeam(npc.index))
				{
					GetEntPropVector(target, Prop_Send, "m_vecOrigin", entitypos);
					distance = GetVectorDistance(Vec, entitypos);
					if(distance<=200.0)
					{
						int health = GetClientHealth(target);
						SDKHooks_TakeDamage(target, npc.index, npc.index, float(health)*10.0, DMG_TRUEDAMAGE|DMG_CRIT);
					}
				}
			}
			b_IgnorePlayerCollisionNPC[npc.index] = false;
			npc.m_iWearable1 = npc.EquipItemSeperate("models/props_c17/lockers001a.mdl",_,1,2.0,_,true);
			GetAbsOrigin(npc.m_iWearable1, Vec);
			GetEntPropVector(npc.m_iWearable3, Prop_Data, "m_angRotation", Ang);
			Ang[1] = -90.0;
			Vec[0] -= 25.0;
			Vec[1] -= 62.5;
			Vec[2] += 55.0;
			TeleportEntity(npc.m_iWearable1, Vec, Ang, NULL_VECTOR);
			SetEntityRenderColor(npc.m_iWearable1, 80, 50, 50, 255);
			
			npc.m_iWearable2 = npc.EquipItemSeperate("models/props_c17/lockers001a.mdl",_,1,2.0,_,true);
			GetEntPropVector(npc.m_iWearable3, Prop_Data, "m_angRotation", Ang);
			GetAbsOrigin(npc.m_iWearable2, Vec);
			Ang[1] += 90.0;
			Vec[0] -= 25.0;
			Vec[1] += 62.5;
			Vec[2] += 55.0;
			TeleportEntity(npc.m_iWearable2, Vec, NULL_VECTOR, NULL_VECTOR);
			SetEntityRenderColor(npc.m_iWearable2, 80, 50, 50, 255);
			
			EmitSoundToAll("misc/doomsday_lift_start.wav", _, _, _, _, 1.0);
			EmitSoundToAll("misc/doomsday_lift_start.wav", _, _, _, _, 1.0);
			npc.m_flMeleeArmor = 2.0;
			npc.m_flRangedArmor = 0.5;
			i_AttacksTillMegahit[npc.index] = 601;
			return;
		}
		if(i_AttacksTillMegahit[npc.index] >= 601 && i_AttacksTillMegahit[npc.index] < 606)
		{
			float Vec[3];
			GetAbsOrigin(npc.m_iWearable1, Vec);
			Vec[1] -= 12.5;
			TeleportEntity(npc.m_iWearable1, Vec, NULL_VECTOR, NULL_VECTOR);
			GetAbsOrigin(npc.m_iWearable2, Vec);
			Vec[1] += 12.5;
			TeleportEntity(npc.m_iWearable2, Vec, NULL_VECTOR, NULL_VECTOR);
			i_AttacksTillMegahit[npc.index] += 1;
			return;
		}
		if(i_AttacksTillMegahit[npc.index] <= 606)
		{
			SetVariantString("!activator");
			AcceptEntityInput(npc.m_iWearable1, "SetParent", npc.index);
			MakeObjectIntangeable(npc.m_iWearable1);
			SetVariantString("!activator");
			AcceptEntityInput(npc.m_iWearable2, "SetParent", npc.index);
			MakeObjectIntangeable(npc.m_iWearable2);
			EmitSoundToAll("misc/hologram_start.wav", _, _, _, _, 1.0);
			EmitSoundToAll("misc/hologram_start.wav", _, _, _, _, 1.0);
			npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
			npc.m_bTeamGlowDefault = false;
			SetVariantColor(view_as<int>({255, 255, 255, 200}));
			AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
			i_AttacksTillMegahit[npc.index] = 607;
			return;
		}
		if(i_AttacksTillMegahit[npc.index] <= 607)
		{
			bool GetClosed=false;
			float Vec[3], entitypos[3], distance;
			GetAbsOrigin(npc.m_iWearable3, Vec);
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity) && entity!=npc.index && GetTeam(entity) != GetTeam(npc.index))
				{
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
					distance = GetVectorDistance(Vec, entitypos);
					if(distance<400.0) GetClosed=true;
				}
			}
			for(int target=1; target<=MaxClients; target++)
			{
				if(IsValidClient(target) && IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE && GetTeam(target) != GetTeam(npc.index))
				{
					GetEntPropVector(target, Prop_Send, "m_vecOrigin", entitypos);
					distance = GetVectorDistance(Vec, entitypos);
					if(distance<=400.0) GetClosed=true;
				}
			}
			
			if(GetClosed)
				i_AttacksTillMegahit[npc.index] = 608;
			return;
		}
		if(i_AttacksTillMegahit[npc.index] >= 608 && i_AttacksTillMegahit[npc.index] < 611)
		{
			float Vec[3];
			GetAbsOrigin(npc.m_iWearable3, Vec);
			if(IsValidEntity(npc.m_iWearable4))
			{
				if(gameTime > npc.m_flNextMeleeAttack)
				{
					GetAbsOrigin(npc.m_iWearable3, Vec);
					int spawn_index = NPC_CreateByName("npc_victoria_fragments", npc.index, Vec, {0.0,0.0,0.0}, GetTeam(npc.index), "factory;mk2;isvoli");
					if(spawn_index > MaxClients)
					{
						NpcStats_CopyStats(npc.index, spawn_index);
						int maxhealth = RoundToFloor(ReturnEntityMaxHealth(npc.index)*0.25);
						NpcAddedToZombiesLeftCurrently(spawn_index, true);
						SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
						SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
						IncreaseEntityDamageTakenBy(spawn_index, 0.000001, 1.0);
					}
					npc.m_flNextMeleeAttack = gameTime + 1.0;
					i_AttacksTillMegahit[npc.index] += 1;
				}
			}
			else
			{
				float Ang[3];
				npc.GetAttachment("m_vecAbsOrigin", Vec, Ang);
				Vec[2]+=140.0;
				npc.m_iWearable4 = ParticleEffectAt_Parent(Vec, "cart_flashinglight_red", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0});
				npc.GetAttachment("", Vec, Ang);
				EmitSoundToAll("items/bomb_warning.wav", npc.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			}
		}
	}
	else
	{
		float Vec[3], Parts[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", Vec);
		GetEntPropVector(npc.m_iWearable3, Prop_Send, "m_vecOrigin", Parts);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index));
		Vec[0]=Parts[0];
		Vec[1]=Parts[1];
		Vec[2]+=55.0;
		float YPOS = GetVectorDistance(Vec, Parts);
		if(YPOS<10.0)
		{
			TeleportEntity(npc.m_iWearable3, Vec, NULL_VECTOR, NULL_VECTOR);
			SetVariantString("!activator");
			AcceptEntityInput(npc.m_iWearable3, "SetParent", npc.index);
			MakeObjectIntangeable(npc.m_iWearable3);
			i_AttacksTillMegahit[npc.index] = 600;
		}
		else
		{
			float DownSpeed=5.0;
			if(YPOS>1000.0)
				DownSpeed=100.0;
			else if(YPOS>100.0)
				DownSpeed=50.0;
			else if(YPOS>20.0)
				DownSpeed=10.0;
			Parts[2]-=DownSpeed;
			TeleportEntity(npc.m_iWearable3, Parts, NULL_VECTOR, NULL_VECTOR);
			i_AttacksTillMegahit[npc.index] += 1;
		}
	}
}


static void ClotDeath(int entity)
{
	VictorianFactory npc = view_as<VictorianFactory>(entity);

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
