#pragma semicolon 1
#pragma newdecls required

#define BLOON_HP_MULTI_GLOBAL 1.1
enum
{
	Bloon_Red = 0,
	Bloon_Blue,
	Bloon_Green,
	Bloon_Yellow,
	Bloon_Pink,
	Bloon_Black,
	Bloon_White,
	Bloon_Purple,
	Bloon_Lead,
	Bloon_Zebra,
	Bloon_Rainbow,
	Bloon_Ceramic
}

static const float BloonSpeeds[] =
{
	250.0,
	260.0,
	280.0,
	315.0,
	360.0,	// Pink
	280.0,	// Black
	290.0,	// White
	310.0,	// Purple
	250.0,	// Lead
	280.0,	// Zebra
	295.0,	// Rainbow
	300.0	// Ceramic
};

static const float BloonRatio[] =
{
//	Health	Type		RGB	Multi
	1.0,	// Red		1
	2.0,	// Blue		2
	3.0,	// Green	3
	4.0,	// Yellow	4
	5.0,	// Pink		5	x1
	11.0,	// Black	11	x6
	11.0,	// White	11	x6
	11.0,	// Purple	11	x6
	23.0,	// Lead		23	x13
	23.0,	// Zebra	23	x13
	47.0,	// Rainbow	47	x27
	104.0	// Ceramic	104	x64
};

static const char Type[] = "12345bwpl789";

static const char SoundPop[][] =
{
	"zombie_riot/btd/pop01.wav",
	"zombie_riot/btd/pop02.wav",
	"zombie_riot/btd/pop03.wav",
	"zombie_riot/btd/pop04.wav"
};

static const char SoundLead[][] =
{
	"zombie_riot/btd/hitmetal01.wav",
	"zombie_riot/btd/hitmetal02.wav",
	"zombie_riot/btd/hitmetal03.wav",
	"zombie_riot/btd/hitmetal04.wav"
};

static const char SoundPurple[][] =
{
	"zombie_riot/btd/hitpurple01.wav",
	"zombie_riot/btd/hitpurple02.wav",
	"zombie_riot/btd/hitpurple03.wav",
	"zombie_riot/btd/hitpurple04.wav"
};

static const char SoundCeramicHit[][] =
{
	"zombie_riot/btd/hitceramic01.wav",
	"zombie_riot/btd/hitceramic02.wav",
	"zombie_riot/btd/hitceramic03.wav",
	"zombie_riot/btd/hitceramic04.wav"
};

static const char SoundCeramicPop[][] =
{
	"zombie_riot/btd/ceramicdestroyed01.wav",
	"zombie_riot/btd/ceramicdestroyed02.wav",
	"zombie_riot/btd/ceramicdestroyed04.wav"
};

static const char BloonSprites[][] =
{
	"red",
	"blue",
	"green",
	"yellow",
	"pink",
	"black",
	"white",
	"purple",
	"lead",
	"zebra",
	"rainbow",
	"ceramic"
};

// Max HP % every 3 second
static const float BloonRegrowRate[] =
{
	1.0,		// 1 / 1
	0.5,		// 1 / 2
	0.333333,	// 1 / 3
	0.25,		// 1 / 4
	0.2,		// 1 / 5

	0.333333,	// 2 / 6
	0.333333,	// 2 / 6
	0.333333,	// 2 / 6

	0.571429,	// 4 / 7
	0.571429,	// 4 / 7

	1.0,		// 8 / 8
	1.777777	// 16 / 9
};

static int GetBloonTypeOfData(const char[] data, bool &camo, bool &fortified, bool &regrow)
{
	int type;
	for(int i; i<sizeof(Type); i++)
	{
		if(data[0] == Type[i])
		{
			type = i;
			break;
		}
	}
	
	camo = StrContains(data[1], "c") != -1;
	fortified = StrContains(data[1], "f") != -1;
	regrow = StrContains(data[1], "r") != -1;
	return type;
}

static float BloonSpeedMulti()
{
	if(CurrentRound < 80)
		return 1.0;
	
	if(CurrentRound < 100)
		return 1.0 + (CurrentRound - 79) * 0.02;
	
	return 1.0 + (CurrentRound - 70) * 0.02;
}

float Bloon_BaseHealth()
{
	float health = 200.0;

	// Nerf late-game health
	if(CurrentCash > 50000)
	{
		health = 75.0;
	}
	else if(CurrentCash > 0)
	{
		health *= 1.0 - (float(CurrentCash) / 133333.333333);
	}
	health *= BLOON_HP_MULTI_GLOBAL;

	return health;
}

float Bloon_HPRatio(bool fortified, int type)
{
	if(!fortified)
		return BloonRatio[type];
	
	if(type == Bloon_Lead)
		return (BloonRatio[type] * 4.0) - (BloonRatio[Bloon_Black] * 3.0);
	
	if(type == Bloon_Ceramic)
		return (BloonRatio[type] * 2.0) - BloonRatio[Bloon_Rainbow];
	
	return BloonRatio[type];
}

void Bloon_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bloon");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bloon");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_BTD;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	char buffer[256];
	for(int i; i<sizeof(SoundCeramicHit); i++)
	{
		PrecacheSoundCustom(SoundCeramicHit[i]);
	}
	for (int i = 0; i < (sizeof(SoundCeramicPop));   i++)
	{
		PrecacheSoundCustom(SoundCeramicPop[i]);
	}
	for(int i; i<sizeof(SoundLead); i++)
	{
		PrecacheSoundCustom(SoundLead[i]);
	}
	for(int i; i<sizeof(SoundPop); i++)
	{
		PrecacheSoundCustom(SoundPop[i]);
	}
	for(int i; i<sizeof(SoundPurple); i++)
	{
		PrecacheSoundCustom(SoundPurple[i]);
	}
	
	static const char Properties[][] = { "", "f", "fg", "g" };
	for(int i; i<sizeof(BloonSprites); i++)
	{
		if(i == Bloon_Ceramic)
			continue;
		
		for(int a; a<sizeof(Properties); a++)
		{
			FormatEx(buffer, sizeof(buffer), "materials/zombie_riot/btd/%s%s.vmt", BloonSprites[i], Properties[a]);
			PrecacheModel(buffer);
		}
	}
	
	for(int i; i<sizeof(Properties); i++)
	{
		for(int a=1; a<5; a++)
		{
			FormatEx(buffer, sizeof(buffer), "materials/zombie_riot/btd/%s%d%s.vmt", BloonSprites[Bloon_Ceramic], a, Properties[i]);
			PrecacheModel(buffer);
		}
	}
	
	PrecacheModel("models/zombie_riot/btd/bloons_hitbox.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Bloon(vecPos, vecAng, team, data);
}

static int BType[MAXENTITIES];
static bool Regrow[MAXENTITIES];
static bool WasCamo[MAXENTITIES];
static int TypeOg[MAXENTITIES];
static int Sprite[MAXENTITIES];

methodmap Bloon < CClotBody
{
	property int m_iType
	{
		public get()
		{
			return BType[this.index];
		}
		public set(int value)
		{
			BType[this.index] = value;
		}
	}
	property int m_iOriginalType
	{
		public get()
		{
			return TypeOg[this.index];
		}
		public set(int value)
		{
			TypeOg[this.index] = value;
		}
	}
	property bool m_bRegrow
	{
		public get()
		{
			return Regrow[this.index];
		}
		public set(bool value)
		{
			Regrow[this.index] = value;
		}
	}
	property bool m_bOriginalCamo
	{
		public get()
		{
			return WasCamo[this.index];
		}
		public set(bool value)
		{
			WasCamo[this.index] = value;
		}
	}
	property bool m_bFortified
	{
		public get()
		{
			return this.m_bLostHalfHealth;
		}
		public set(bool value)
		{
			this.m_bLostHalfHealth = value;
		}
	}
	property int m_iSprite
	{
		public get()
		{
			return EntRefToEntIndex(Sprite[this.index]);
		}
		public set(int value)
		{
			Sprite[this.index] = EntIndexToEntRef(value);
		}
	}
	public void PlayLeadSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundLead) - 1);
		EmitCustomToAll(SoundLead[sound], this.index, SNDCHAN_VOICE, 80, _, 1.0);
	}
	public void PlayPurpleSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundPurple) - 1);
		EmitCustomToAll(SoundPurple[sound], this.index, SNDCHAN_VOICE, 80, _, 1.0);
	}
	public void PlayHitSound()
	{
		int sound = GetRandomInt(0, sizeof(SoundCeramicHit) - 1);
		EmitCustomToAll(SoundCeramicHit[sound], this.index, SNDCHAN_VOICE, 80, _, 1.0);
	}
	public void PlayDeathSound()
	{
		if(this.m_iType == Bloon_Ceramic)
		{
			int sound = GetRandomInt(0, sizeof(SoundCeramicPop) - 1);
			EmitCustomToAll(SoundCeramicPop[sound], this.index, SNDCHAN_AUTO, 80, _, 3.0);
		}
		else
		{
			int sound = GetRandomInt(0, sizeof(SoundPop) - 1);
			EmitCustomToAll(SoundPop[sound], this.index, SNDCHAN_AUTO, 80, _, 3.0);
		}
	}
	public int UpdateBloonInfo()
	{
		this.m_iBleedType = this.m_iType == Bloon_Lead ? BLEEDTYPE_METAL : BLEEDTYPE_RUBBER;
		this.m_flSpeed = BloonSpeeds[this.m_iType] * BloonSpeedMulti();
		
		int sprite = this.m_iSprite;
		if(sprite > MaxClients && IsValidEntity(sprite))
		{
			AcceptEntityInput(sprite, "HideSprite");
			RemoveEntity(sprite);
		}
		
		sprite = CreateEntityByName("env_sprite");
		if(sprite != -1)
		{
			char buffer[128];
			if(this.m_iType == Bloon_Ceramic)
			{
				float total = Bloon_HPRatio(this.m_bFortified, this.m_iOriginalType);
				float rainbow = Bloon_HPRatio(this.m_bFortified, Bloon_Rainbow);

				float health = float(GetEntProp(this.index, Prop_Data, "m_iHealth"));
				float maxhealth = float(GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));

				// Remove health under Rainbow, only above matters
				health -= maxhealth * (rainbow / total);
				maxhealth -= maxhealth * (rainbow / total);

				int type = RoundToFloor(health * 5.0 / maxhealth);
				if(type > 4)
					type = 4;
				
				FormatEx(buffer, sizeof(buffer), "zombie_riot/btd/%s%d%s%s.vmt", BloonSprites[this.m_iType], type + 1, this.m_bFortified ? "f" : "", this.m_bRegrow ? "g" : "");
			}
			else if(this.m_iOriginalType != Bloon_Lead && this.m_iOriginalType != Bloon_Ceramic)
			{
				FormatEx(buffer, sizeof(buffer), "zombie_riot/btd/%s%s%s.vmt", BloonSprites[this.m_iType], this.m_bFortified ? "f" : "", this.m_bRegrow ? "g" : "");
			}
			else
			{
				FormatEx(buffer, sizeof(buffer), "zombie_riot/btd/%s%s.vmt", BloonSprites[this.m_iType], this.m_bRegrow ? "g" : "");
			}
			
			DispatchKeyValue(sprite, "model", buffer);
			DispatchKeyValueFloat(sprite, "scale", 0.25);
			DispatchKeyValue(sprite, "rendermode", "7");
			
			if(this.m_bCamo)
				DispatchKeyValue(sprite, "renderamt", "40");
			
			DispatchSpawn(sprite);
			ActivateEntity(sprite);
			
			SetEntPropEnt(sprite, Prop_Send, "m_hOwnerEntity", this.index);
			AcceptEntityInput(sprite, "ShowSprite");
			
			float pos[3];
			GetEntPropVector(this.index, Prop_Send, "m_vecOrigin", pos);
			pos[2] += 40.0;
			TeleportEntity(sprite, pos, NULL_VECTOR, NULL_VECTOR);
			SetVariantString("!activator");
			AcceptEntityInput(sprite, "SetParent", this.index, sprite);
			
			this.m_iSprite = sprite;
		}
	}
	public int RegrowsInto(int level)
	{
		if(level < Bloon_Black)
			return level;
		
		switch(level)
		{
			case 5:
			{
				switch(this.m_iOriginalType)
				{
					case Bloon_White:
					{
						return Bloon_White;
					}
					case Bloon_Purple:
					{
						return Bloon_Purple;
					}
					default:
					{
						return Bloon_Black;
					}
				}
			}
			case 6:
			{
				switch(this.m_iOriginalType)
				{
					case Bloon_Lead:
					{
						return Bloon_Lead;
					}
					default:
					{
						return Bloon_Zebra;
					}
				}
			}
			case 7:
			{
				return Bloon_Rainbow;
			}
			case 8:
			{
				return Bloon_Ceramic;
			}
		}
		
		return 0;
	}
	public int UpdateBloonOnDamage()
	{
		float ratio = float(GetEntProp(this.index, Prop_Data, "m_iHealth")) / float(GetEntProp(this.index, Prop_Data, "m_iMaxHealth")) * Bloon_HPRatio(this.m_bFortified, this.m_iOriginalType);
		for(int i; i<9; i++)
		{
			int type = this.RegrowsInto(i);
			if(ratio <= Bloon_HPRatio(this.m_bFortified, type))
			{
				if(this.m_iType != type || type == Bloon_Ceramic)
				{
					if(this.m_iType > type)
						this.PlayDeathSound();
					
					this.m_iType = type;
					this.UpdateBloonInfo();
				}
				break;
			}
		}
	}
	public Bloon(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool camo, regrow, fortified;
		int type = GetBloonTypeOfData(data, camo, fortified, regrow);
		
		char buffer[12];
		IntToString(RoundFloat(Bloon_HPRatio(fortified, type) * Bloon_BaseHealth()), buffer, sizeof(buffer));
		
		Bloon npc = view_as<Bloon>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/bloons_hitbox.mdl", "1.0", buffer, ally));
		
		i_NpcWeight[npc.index] = 1;
		KillFeed_SetKillIcon(npc.index, "pumpkindeath");
		
		npc.m_iBleedType = BLEEDTYPE_RUBBER;
		npc.m_iStepNoiseType = STEPTYPE_NONE;	
		npc.m_iNpcStepVariation = STEPTYPE_NONE;	
		npc.m_bDissapearOnDeath = true;
		
		npc.m_bCamo = camo;
		npc.m_bOriginalCamo = camo;
		npc.m_bFortified = fortified;
		npc.m_bRegrow = regrow;
		npc.m_iType = type;
		npc.m_iOriginalType = type;
		npc.UpdateBloonInfo();
		
		npc.m_iStepNoiseType = 0;	
		npc.m_iState = 0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_bDoNotGiveWaveDelay = true;
		
		func_NPCDeath[npc.index] = Bloon_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Bloon_OnTakeDamage;
		func_NPCThink[npc.index] = Bloon_ClotThink;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Bloon_ClotDamagedPost);
		
		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 255, 255, 255, 0);
		
		npc.StartPathing();
		
		
		return npc;
	}
}


public void Bloon_ClotThink(int iNPC)
{
	Bloon npc = view_as<Bloon>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + 0.04;
	
	npc.Update();	
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	bool silenced = NpcStats_IsEnemySilenced(npc.index);
	bool camo = npc.m_bOriginalCamo && !silenced;

	if(camo && HasSpecificBuff(npc.index, "Revealed"))
		camo = false;

	if(!silenced && npc.m_bRegrow && !HasSpecificBuff(npc.index, "Growth Blocker"))
	{
		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		int maxhealth = ReturnEntityMaxHealth(npc.index);
		if(health < maxhealth)
		{
			health += RoundFloat(maxhealth * BloonRegrowRate[npc.m_iOriginalType] / 30.0);
			if(health > maxhealth)
				health = maxhealth;
			
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			npc.UpdateBloonOnDamage();
		}
	}
	
	if(npc.m_bOriginalCamo)
	{
		if(npc.m_bCamo)
		{
			if(!camo)
			{
				npc.m_bCamo = false;
				npc.UpdateBloonOnDamage();
			}
		}
		else if(camo)
		{
			npc.m_bCamo = true;
			npc.UpdateBloonOnDamage();
		}
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
													
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			
			
			float VecPredictPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, VecPredictPos);
			npc.SetGoalVector(VecPredictPos);
		}
		else
		{
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				npc.m_flNextMeleeAttack = gameTime + 0.35;
				float WorldSpaceVec[3]; WorldSpaceCenter(PrimaryThreatIndex, WorldSpaceVec);
				
				for(int i; i<9; i++)
				{
					if(npc.RegrowsInto(i) == npc.m_iType)
					{
						float damageDealDo = 1.0 + float(i);
						if(npc.m_bFortified)
							damageDealDo *= 1.4;
						if(ShouldNpcDealBonusDamage(PrimaryThreatIndex))
							damageDealDo *= 25.0;
							
						SDKHooks_TakeDamage(PrimaryThreatIndex, npc.index, npc.index, damageDealDo, DMG_CLUB, -1, _, WorldSpaceVec);		
						//delete swingTrace;
					}
				}				
			}
		}
		
		npc.StartPathing();
		
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

public Action Bloon_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	
	Bloon npc = view_as<Bloon>(victim);
	
	bool hot;
	bool cold;
	bool magic;
	bool pierce;
	
	if((damagetype & DMG_TRUEDAMAGE))
	{
		pierce = true;
	}
	else
	{
		if((damagetype & DMG_BLAST))
		{
			hot = true;
			pierce = true;
		}
		
		if(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_ICE)
		{
			cold = true;
		}
		
		if(damagetype & DMG_PLASMA)
		{
			magic = true;
			pierce = true;
		}
		else if((damagetype & DMG_SHOCK) || (i_HexCustomDamageTypes[victim] & ZR_DAMAGE_LASER_NO_BLAST))
		{
			magic = true;
		}
	}
	
	switch(npc.m_iType)
	{
		case Bloon_Black:
		{
			if(hot)
			{
				damage *= 0.15 / MultiGlobalHealthBoss;

				damagePosition[2] += 30.0;
				npc.DispatchParticleEffect(npc.index, "medic_resist_match_blast_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
				damagePosition[2] -= 30.0;
			}
		}
		case Bloon_White:
		{
			if(cold)
			{
				damage *= 0.15 / MultiGlobalHealthBoss;

				damagePosition[2] += 30.0;
				npc.DispatchParticleEffect(npc.index, "medic_resist_match_blast_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
				damagePosition[2] -= 30.0;
			}
		}
		case Bloon_Purple:
		{
			if(magic && !NpcStats_IsEnemySilenced(npc.index))
			{
				damage *= 0.1 / MultiGlobalHealthBoss;
				npc.PlayPurpleSound();

				damagePosition[2] += 30.0;
				npc.DispatchParticleEffect(npc.index, "medic_resist_match_fire_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
				damagePosition[2] -= 30.0;
			}
		}
		case Bloon_Lead:
		{
			if(!pierce)
			{
				damage *= 0.15 / MultiGlobalHealthBoss;
				npc.PlayLeadSound();

				damagePosition[2] += 30.0;
				npc.DispatchParticleEffect(npc.index, "medic_resist_match_bullet_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
				damagePosition[2] -= 30.0;
			}
		}
		case Bloon_Zebra:
		{
			if(hot || cold)
			{
				damage *= 0.15 / MultiGlobalHealthBoss;

				damagePosition[2] += 30.0;
				npc.DispatchParticleEffect(npc.index, "medic_resist_match_blast_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
				damagePosition[2] -= 30.0;
			}
		}
		case Bloon_Ceramic:
		{
			npc.PlayHitSound();
		}
	}
	return Plugin_Changed;
}

public void Bloon_ClotDamagedPost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	if(b_NpcHasDied[victim])
		return;
		
	Bloon npc = view_as<Bloon>(victim);
	npc.UpdateBloonOnDamage();
}

public void Bloon_NPCDeath(int entity)
{
	Bloon npc = view_as<Bloon>(entity);
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Bloon_ClotDamagedPost);
	
	int sprite = npc.m_iSprite;
	if(sprite > MaxClients && IsValidEntity(sprite))
	{
		AcceptEntityInput(sprite, "HideSprite");
		RemoveEntity(sprite);
	}
}
