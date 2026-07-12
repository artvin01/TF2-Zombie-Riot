
// we only want the 3 biggest gibs


//I moved these up here so they can be precached, because the server crashes if a skeleton is gibbed and these aren't precached:
static char m_cGibModelSkeleton[][] = {
    "models/bots/skeleton_sniper/skeleton_sniper_gib_torso.mdl",
    "models/bots/skeleton_sniper/skeleton_sniper_gib_leg_l.mdl",
    "models/bots/skeleton_sniper/skeleton_sniper_gib_head.mdl"
};

static const char g_GibModelScout[][] =
{
	"models/player/gibs/scoutgib006.mdl", // torso
	"models/player/gibs/scoutgib003.mdl", // waist
	"models/player/gibs/scoutgib007.mdl", // head
};
static const char g_GibModelSniper[][] =
{
	"models/player/gibs/snipergib004.mdl", // torso
	"models/player/gibs/snipergib002.mdl", // waist
	"models/player/gibs/snipergib005.mdl", // head
};
static const char g_GibModelSoldier[][] =
{
	"models/player/gibs/soldiergib006.mdl", // torso
	"models/player/gibs/soldiergib002.mdl", // waist
	"models/player/gibs/soldiergib007.mdl", // head
};
static const char g_GibModelDemoMan[][] =
{
	"models/player/gibs/demogib005.mdl", // torso
	"models/player/gibs/demogib002.mdl", // waist
	"models/player/gibs/demogib006.mdl", // head
};
static const char g_GibModelMedic[][] =
{
	"models/player/gibs/medicgib006.mdl", // torso
	"models/player/gibs/medicgib003.mdl", // waist
	"models/player/gibs/medicgib007.mdl", // head
};
static const char g_GibModelHeavy[][] =
{
	"models/player/gibs/heavygib006.mdl", // torso
	"models/player/gibs/heavygib004.mdl", // waist
	"models/player/gibs/heavygib007.mdl", // head
};
static const char g_GibModelPyro[][] =
{
	"models/player/gibs/pyrogib007.mdl", // torso
	"models/player/gibs/pyrogib006.mdl", // waist
	"models/player/gibs/pyrogib008.mdl", // head
};
static const char g_GibModelSpy[][] =
{
	"models/player/gibs/spygib006.mdl", // torso
	"models/player/gibs/spygib002.mdl", // waist
	"models/player/gibs/spygib007.mdl", // head
};
static const char g_GibModelEngineer[][] =
{
	"models/player/gibs/engineergib005.mdl", // torso
	"models/player/gibs/engineergib002.mdl", // waist
	"models/player/gibs/engineergib006.mdl", // head
};



static const char g_GibModelRobotScout[][] =
{
	"models/bots/gibs/scoutbot_gib_chest.mdl",
	"models/bots/gibs/scoutbot_gib_pelvis.mdl",
	"models/bots/gibs/scoutbot_gib_head.mdl",
};
static const char g_GibModelRobotSniper[][] =
{
	"models/bots/gibs/scoutbot_gib_chest.mdl",
	"models/bots/gibs/scoutbot_gib_pelvis.mdl",
	"models/bots/gibs/sniperbot_gib_head.mdl",
};
static const char g_GibModelRobotSoldier[][] =
{
	"models/bots/gibs/demobot_gib_pelvis.mdl",
	"models/bots/gibs/demobot_gib_leg2.mdl",
	"models/bots/gibs/demobot_gib_head.mdl",
};
static const char g_GibModelRobotDemoMan[][] =
{
	"models/bots/gibs/demobot_gib_pelvis.mdl",
	"models/bots/gibs/demobot_gib_leg2.mdl",
	"models/bots/gibs/demobot_gib_head.mdl",
};
static const char g_GibModelRobotMedic[][] =
{
	"models/bots/gibs/scoutbot_gib_chest.mdl",
	"models/bots/gibs/scoutbot_gib_pelvis.mdl",
	"models/bots/gibs/medicbot_gib_head.mdl",
};
static const char g_GibModelRobotHeavy[][] =
{
	"models/bots/gibs/heavybot_gib_chest.mdl",
	"models/bots/gibs/heavybot_gib_pelvis.mdl",
	"models/bots/gibs/heavybot_gib_head.mdl",
};
static const char g_GibModelRobotPyro[][] =
{
	"models/bots/gibs/pyrobot_gib_chest2.mdl",
	"models/bots/gibs/pyrobot_gib_pelvis.mdl",
	"models/bots/gibs/pyrobot_gib_head.mdl",
};
static const char g_GibModelRobotSpy[][] =
{
	"models/bots/gibs/pyrobot_gib_chest.mdl",
	"models/bots/gibs/pyrobot_gib_pelvis.mdl",
	"models/bots/gibs/spybot_gib_head.mdl",
};
static const char g_GibModelRobotEngineer[][] =
{
	"models/bots/gibs/scoutbot_gib_chest.mdl",
	"models/bots/gibs/scoutbot_gib_pelvis.mdl",
	"models/bots/gibs/scoutbot_gib_head.mdl",
};

static char m_cGibModelDefault[][] =
{
	"models/gibs/antlion_gib_large_1.mdl",
	"models/Gibs/HGIBS_spine.mdl",
	"models/Gibs/HGIBS.mdl"
};
static char m_cGibModelMetal[][] =
{
	"models/gibs/helicopter_brokenpiece_03.mdl",
	"models/gibs/scanner_gib01.mdl",
	"models/gibs/metal_gib2.mdl"
};

void Npc_DoGibLogic(int pThis, float GibAmount = 1.0, bool forcesilentMode = false, int attacker = -1)
{
	CClotBody npc = view_as<CClotBody>(pThis);
	if(npc.m_iBleedType == 0)
		return;
		
	float startPosition[3];
				
	float damageForce[3];
	npc.m_vecpunchforce(damageForce, false);
	float OriginalVel[3]
	OriginalVel = damageForce;
	ScaleVector(damageForce, 0.025); //Reduce overall

	bool Limit_Gibs = false;
	if(CurrentGibCount > ZR_MAX_GIBCOUNT || EnableSilentMode || forcesilentMode || AtEdictLimit(EDICT_NPC))
		Limit_Gibs = true;

	if(npc.m_iBleedType == BLEEDTYPE_METAL)
		npc.PlayGibSoundMetal(attacker);
	else if(npc.m_iBleedType != BLEEDTYPE_RUBBER)
		npc.PlayGibSound(attacker);

	float ang[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
				
	for(int GibLoop; GibLoop < 3; GibLoop++)
	{
		int prop = CreateEntityByName("prop_physics_multiplayer");
		if(!IsValidEntity(prop))
			return; //Emergency backup
		float TempPosition[3];
		float TempForce[3];
		CurrentGibCount += 1;

		TempPosition = startPosition;
		
		float ModelscaleSet = 1.0;
		int GibFound = Npc_DoFittingNpcGibs(pThis, GibLoop, prop);
		if(GibFound == 0)
		{
			switch(GibLoop)
			{
				case 0:
				{
					//main torso
					if(!npc.m_bIsGiant)
						TempPosition[2] += 42;
					else
						TempPosition[2] += 64;
				}
				case 1:
				{
					//Spine, or something
					if(!npc.m_bIsGiant)
						TempPosition[2] += 30;
					else
						TempPosition[2] += 49;
				}
				case 2:
				{
					//Head
					if(!npc.m_bIsGiant)
						TempPosition[2] += 75;
					else
						TempPosition[2] += 110;
				}
			}
			TempForce = damageForce;
			if(GibLoop == 0 && npc.m_iBleedType == BLEEDTYPE_NORMAL)
				ScaleVector(TempForce, 0.75);

			//randomize abit
			ScaleVector(TempForce, GetRandomFloat(0.9, 1.1));
			//This gib in specific has too much knockback.

			if(npc.m_iBleedType == BLEEDTYPE_METAL)
				DispatchKeyValue(prop, "model", m_cGibModelMetal[GibLoop]);
			else if (npc.m_iBleedType == BLEEDTYPE_SKELETON)
			{
				DispatchKeyValue(prop, "model", m_cGibModelSkeleton[GibLoop]);
				SetEntProp(prop, Prop_Send, "m_nSkin", GetEntProp(npc.index, Prop_Send, "m_nSkin", 1));
			}
			else
				DispatchKeyValue(prop, "model", m_cGibModelDefault[GibLoop]);
				
		}

		DispatchKeyValue(prop, "physicsmode", "2");
		DispatchKeyValue(prop, "massScale", "1.0");
		DispatchKeyValue(prop, "spawnflags", "2");

		float Random_time = GetRandomFloat(6.0, 7.0);
		if(EnableSilentMode || CurrentGibCount > ZR_MAX_GIBCOUNT_ABSOLUTE)
		{
			Random_time *= 0.5; //half the duration if there are too many gibs
		}
#if defined RPG
		Random_time *= 0.25; //in RPG, gibs are really not needed as they are purpely cosmetic, for this reason they wont stay long at all.
#endif
		f_GibHealingAmount[prop] = 1.0 * GibAmount; //Set it to false by default first.
		if(Limit_Gibs)	
			f_GibHealingAmount[prop] *= 3.0;

		if(b_thisNpcIsABoss[pThis] || b_thisNpcIsARaid[pThis])
		{
			f_GibHealingAmount[prop] *= 4.0;
		}
		else if(b_IsGiant[pThis])
		{
			f_GibHealingAmount[prop] *= 2.0;
		}
		if(!GibFound)
		{
			switch(GibLoop)
			{
				case 0:
				{
					if(npc.m_iBleedType == BLEEDTYPE_METAL)
						ang[0] = 90.0;
				}
			}
		}
		DispatchKeyValueVector(prop, "origin",	 TempPosition);
		DispatchKeyValueVector(prop, "angles",	 ang);
		DispatchSpawn(prop);
		if(!GibFound)
		{
			if(npc.m_bIsGiant)
			{
				if(npc.m_iBleedType == BLEEDTYPE_METAL && GibLoop == 0)
				{
					ModelscaleSet *= 1.1;
				}
				else
					ModelscaleSet *= 1.6;
			}
			else
			{
				if(npc.m_iBleedType == BLEEDTYPE_METAL && GibLoop == 0)
				{
					ModelscaleSet *= 0.8;
				}
			}
			//head
			if(GibLoop == 2)
				ModelscaleSet *= 1.2;

			//Spine
			if(GibLoop == 1)
				ModelscaleSet *= 2.5;
		}

		if(ModelscaleSet != 1.0)
			SetEntPropFloat(prop, Prop_Send, "m_flModelScale", ModelscaleSet);
			
		if(GibFound)
		{
			TempForce = OriginalVel;
			ScaleVector(TempForce, 0.025); //Reduce overall
		}
		TeleportEntity(prop, NULL_VECTOR, ang, TempForce);
		SetEntityCollisionGroup(prop, 2); //COLLISION_GROUP_DEBRIS_TRIGGER
		CreateTimer(Random_time - 1.5, Prop_Gib_FadeSet, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(Random_time, Timer_RemoveEntity_Prop_Gib, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);

		Random_time -= 1.0;
		ModifyGib(GibFound, pThis, npc.m_iBleedType, prop, Random_time, TempPosition, GibLoop);
		b_IsAGib[prop] = true;
		if(Limit_Gibs)
			return; //only spawn 1 gib.
	}
}

void ModifyGib(int GibFound, int pThis, int bleedtype, int gib, float Random_time, float TempPosition[3], int GibLoop)
{
	int ParticleSet = -1;
	float flPos_l[3]; // original
	float flAng_l[3]; // original
	flPos_l = TempPosition;
	if(GibFound == 1)
		GetAttachment(gib, "bloodpoint", flPos_l, flAng_l);
	else if(GibFound == 2)
		flPos_l[2] += 50.0;
	switch(bleedtype)
	{
		case BLEEDTYPE_NORMAL:
		{
			if(!EnableSilentMode || !AtEdictLimit(EDICT_EFFECT))
				ParticleSet = ParticleEffectAt(flPos_l, "blood_trail_red_01_goop", Random_time); 
			SetEntityRenderColor(gib, 255, 0, 0, 255);
			if(GibLoop == 0)
			{
				WorldSpaceCenter(pThis, TempPosition);
				ParticleEffectAt(TempPosition, "env_sawblood_mist", 0.1);
			}
		}
		case BLEEDTYPE_METAL:
		{
			if(!EnableSilentMode || !AtEdictLimit(EDICT_EFFECT))
				ParticleSet = ParticleEffectAt(flPos_l, "tpdamage_4", Random_time); 
			if(GibLoop == 0)
			{
				WorldSpaceCenter(pThis, TempPosition);
				ParticleEffectAt(TempPosition, "snow_steppuff_mist", 0.1);
			}
		}
		case BLEEDTYPE_RUBBER:
		{
			if(!EnableSilentMode || !AtEdictLimit(EDICT_EFFECT))
				ParticleSet = ParticleEffectAt(flPos_l, "doublejump_trail_alt", Random_time); //This is a permanent particle, gotta delete it manually...
		}
		case BLEEDTYPE_XENO:
		{
			if(!EnableSilentMode || !AtEdictLimit(EDICT_EFFECT))
				ParticleSet = ParticleEffectAt(flPos_l, "blood_impact_green_01", Random_time); 
			SetEntityRenderColor(gib, 0, 255, 0, 255);
			if(GibLoop == 0)
			{
				WorldSpaceCenter(pThis, TempPosition);
				ParticleEffectAt(TempPosition, "merasmus_blood_smoke", 0.1);
			}
		}
		/*case BLEEDTYPE_SKELETON:
		{
			Skeletons don't bleed, so I'm leaving this blank.
		}*/
		case BLEEDTYPE_DWELLER:
		{
			if(!EnableSilentMode || !AtEdictLimit(EDICT_EFFECT))
				ParticleSet = ParticleEffectAt(flPos_l, "flamethrower_rainbow_bubbles02", Random_time); 
			SetEntityRenderColor(gib, 65, 65, 255, 255);
			if(GibLoop == 0)
			{
				WorldSpaceCenter(pThis, TempPosition);
				ParticleEffectAt(TempPosition, "utaunt_tarotcard_blue_glow", 0.1);
			}
		}
		case BLEEDTYPE_VOID:
		{
			if(!EnableSilentMode || !AtEdictLimit(EDICT_EFFECT))
			{
				TE_BloodSprite(TempPosition, { 0.0, 0.0, 0.0 }, 200, 0, 200, 255, 32);
				TE_SendToAllInRange(TempPosition, RangeType_Visibility);
			}
			SetEntityRenderColor(gib, 200, 0, 200, 255);
			if(GibLoop == 0)
			{
				WorldSpaceCenter(pThis, TempPosition);
				ParticleEffectAt(TempPosition, "utaunt_tarotcard_purple_glow", 0.1);
			}
		}
		case BLEEDTYPE_PORTAL:
		{
			//none.
		}
	}	
	if(ParticleSet != -1)
	{
		SetParent(gib, ParticleSet);
	}
}
int Npc_DoFittingNpcGibs(int pThis, int GibLoop, int GibProp)
{
	CClotBody npc = view_as<CClotBody>(pThis);
	TFClassType class;
	bool IsRobot = false;
	char model[PLATFORM_MAX_PATH];
	GetEntPropString(pThis, Prop_Data, "m_ModelName", model, sizeof(model));
	int WhichModel = 0;
	if(ReplaceStringEx(model, sizeof(model), "models/player/", "", _, _, false) != -1)
	{
		int pos = FindCharInString(model, '.', true);
		if(pos != -1)
			model[pos] = '\0';

		class = TF2_GetClass(model);
		WhichModel = 1;
		if(npc.m_iBleedType == BLEEDTYPE_METAL)
		{
			//force robot gibs
			WhichModel = 2;
			IsRobot = true;
		}
	}
	else if(ReplaceStringEx(model, sizeof(model), "models/bots/", "", _, _, false) != -1)
	{
		int pos = FindCharInString(model, '/', true);
		if(pos != -1)
			model[pos] = '\0';

		class = TF2_GetClass(model);
		IsRobot = true;
		WhichModel = 2;
	}
	
	if(WhichModel == 0)
		return false;
	if(!IsRobot)
	{
		switch(class)
		{
			case TFClass_Scout:
				DispatchKeyValue(GibProp, "model", g_GibModelScout[GibLoop]);
			case TFClass_Sniper:
				DispatchKeyValue(GibProp, "model", g_GibModelSniper[GibLoop]);
			case TFClass_Soldier:
				DispatchKeyValue(GibProp, "model", g_GibModelSoldier[GibLoop]);
			case TFClass_DemoMan:
				DispatchKeyValue(GibProp, "model", g_GibModelDemoMan[GibLoop]);
			case TFClass_Medic:
				DispatchKeyValue(GibProp, "model", g_GibModelMedic[GibLoop]);
			case TFClass_Heavy:
				DispatchKeyValue(GibProp, "model", g_GibModelHeavy[GibLoop]);
			case TFClass_Pyro:
				DispatchKeyValue(GibProp, "model", g_GibModelPyro[GibLoop]);
			case TFClass_Spy:
				DispatchKeyValue(GibProp, "model", g_GibModelSpy[GibLoop]);
			case TFClass_Engineer:
				DispatchKeyValue(GibProp, "model", g_GibModelEngineer[GibLoop]);
		}
	}
	else
	{
		switch(class)
		{
			case TFClass_Scout:
				DispatchKeyValue(GibProp, "model", g_GibModelRobotScout[GibLoop]);
			case TFClass_Sniper:
				DispatchKeyValue(GibProp, "model", g_GibModelRobotSniper[GibLoop]);
			case TFClass_Soldier:
				DispatchKeyValue(GibProp, "model", g_GibModelRobotSoldier[GibLoop]);
			case TFClass_DemoMan:
				DispatchKeyValue(GibProp, "model", g_GibModelRobotDemoMan[GibLoop]);
			case TFClass_Medic:
				DispatchKeyValue(GibProp, "model", g_GibModelRobotMedic[GibLoop]);
			case TFClass_Heavy:
				DispatchKeyValue(GibProp, "model", g_GibModelRobotHeavy[GibLoop]);
			case TFClass_Pyro:
				DispatchKeyValue(GibProp, "model", g_GibModelRobotPyro[GibLoop]);
			case TFClass_Spy:
				DispatchKeyValue(GibProp, "model", g_GibModelRobotSpy[GibLoop]);
			case TFClass_Engineer:
				DispatchKeyValue(GibProp, "model", g_GibModelRobotEngineer[GibLoop]);
		}
	}
	return true;
}


void PrecacheAllGibs()
{
	PrecacheModelArray(g_GibModelScout);
	PrecacheModelArray(g_GibModelSniper);
	PrecacheModelArray(g_GibModelSoldier);
	PrecacheModelArray(g_GibModelDemoMan);
	PrecacheModelArray(g_GibModelMedic);
	PrecacheModelArray(g_GibModelHeavy);
	PrecacheModelArray(g_GibModelPyro);
	PrecacheModelArray(g_GibModelSpy);
	PrecacheModelArray(g_GibModelEngineer);
	PrecacheModelArray(m_cGibModelSkeleton);
	
	PrecacheModelArray(g_GibModelRobotScout);
	PrecacheModelArray(g_GibModelRobotSniper);
	PrecacheModelArray(g_GibModelRobotSoldier);
	PrecacheModelArray(g_GibModelRobotDemoMan);
	PrecacheModelArray(g_GibModelRobotMedic);
	PrecacheModelArray(g_GibModelRobotHeavy);
	PrecacheModelArray(g_GibModelRobotPyro);
	PrecacheModelArray(g_GibModelRobotSpy);
	PrecacheModelArray(g_GibModelRobotEngineer);
}