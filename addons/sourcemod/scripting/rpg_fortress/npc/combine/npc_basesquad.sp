#pragma semicolon 1
#pragma newdecls required

static const char PistolFire[][] =
{
	"weapons/pistol/pistol_fire2.wav"
};

static const char PistolReload[][] =
{
	"weapons/pistol/pistol_reload1.wav"
};

static const char StunStickDeploy[][] =
{
	"weapons/stunstick/spark1.wav",
	"weapons/stunstick/spark2.wav",
	"weapons/stunstick/spark3.wav"
};

static const char StunStickHit[][] =
{
	"weapons/stunstick/stunstick_fleshhit1.wav",
	"weapons/stunstick/stunstick_fleshhit2.wav"
};

static const char StunStickFire[][] =
{
	"weapons/stunstick/stunstick_swing1.wav",
	"weapons/stunstick/stunstick_swing2.wav"
};

static const char SMGFire[][] =
{
	"weapons/smg1/smg1_fire1.wav"
};

static const char SMGReload[][] =
{
	"weapons/smg1/smg1_reload.wav"
};

static const char PoliceIdle[][] =
{
	"npc/metropolice/vo/catchthatbliponstabilization.wav",
	"npc/metropolice/vo/clearandcode100.wav",
	"npc/metropolice/vo/clearno647no10-107.wav",
	"npc/metropolice/vo/control100percent.wav",
	"npc/metropolice/vo/wearesociostablethislocation.wav"
};

static const char PoliceIdleAlert[][] =
{
	"npc/metropolice/vo/airwatchsubjectis505.wav",
	"npc/metropolice/vo/allunitscloseonsuspect.wav",
	"npc/metropolice/vo/allunitsmovein.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/destroythatcover.wav"
};

static const char PoliceHurt[][] =
{
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav"
};

static const char PolicePanic[][] =
{
	"npc/metropolice/vo/officerdowncode3tomy10-20.wav",
	"npc/metropolice/vo/officerdowniam10-99.wav",
	"npc/metropolice/vo/officerneedsassistance.wav",
	"npc/metropolice/vo/officerneedsassistance.wav",
	"npc/metropolice/vo/officerneedshelp.wav"
};

static const char PoliceDeath[][] =
{
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav"
};

static const char SoldierIdle[][] =
{
	"npc/combine_soldier/vo/copythat.wav",
	"npc/combine_soldier/vo/hardenthatposition.wav",
	"npc/combine_soldier/vo/motioncheckallradials.wav",
	"npc/combine_soldier/vo/overwatchreportspossiblehostiles.wav",
	"npc/combine_soldier/vo/prepforcontact.wav",
	"npc/combine_soldier/vo/readyweaponshostilesinbound.wav",
	"npc/combine_soldier/vo/reportingclear.wav",
	"npc/combine_soldier/vo/sectorissecurenovison.wav",
	"npc/combine_soldier/vo/sightlineisclear.wav",
	"npc/combine_soldier/vo/standingby].wav",
	"npc/combine_soldier/vo/stayalertreportsightlines.wav"
};

static const char SoldierIdleAlert[][] =
{
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
	"npc/combine_soldier/vo/engaging.wav",
	"npc/combine_soldier/vo/suppressing.wav",
	"npc/combine_soldier/vo/targetmyradial.wav"
};

static const char SoldierDeath[][] =
{
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav"
};

static const char SoldierHurt[][] =
{
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav"
};

static const char SwordsmanIdle[][] =
{
	"npc/combine_soldier/vo/blade.wav",
	"npc/combine_soldier/vo/dagger.wav",
	"npc/combine_soldier/vo/fist.wav",
	"npc/combine_soldier/vo/hammer.wav",
	"npc/combine_soldier/vo/razor.wav",
	"npc/combine_soldier/vo/spear.wav",
	"npc/combine_soldier/vo/sword.wav"
};

static const char SwordsmanIdleAlert[][] =
{
	"npc/combine_soldier/vo/displace.wav",
	"npc/combine_soldier/vo/displace2.wav",
	"npc/combine_soldier/vo/gosharp.wav",
	"npc/combine_soldier/vo/gosharpgosharp.wav",
	"npc/combine_soldier/vo/sharpzone.wav",
	"npc/combine_soldier/vo/sweepingin.wav",
	"npc/combine_soldier/vo/thatsitwrapitup.wav"
};

static int DeathDamage[MAXENTITIES];

void BaseSquad_MapStart()
{
	PrecacheSoundArray(PistolFire);
	PrecacheSoundArray(PistolReload);
	PrecacheSoundArray(StunStickDeploy);
	PrecacheSoundArray(StunStickHit);
	PrecacheSoundArray(StunStickFire);
	PrecacheSoundArray(SMGFire);
	PrecacheSoundArray(SMGReload);

	PrecacheSoundArray(PoliceIdle);
	PrecacheSoundArray(PoliceIdleAlert);
	PrecacheSoundArray(PoliceHurt);
	PrecacheSoundArray(PoliceDeath);
	PrecacheSoundArray(PolicePanic);
	PrecacheSoundArray(SoldierIdle);
	PrecacheSoundArray(SoldierIdleAlert);
	PrecacheSoundArray(SoldierHurt);
	PrecacheSoundArray(SoldierDeath);
	PrecacheSoundArray(SwordsmanIdle);
	PrecacheSoundArray(SwordsmanIdleAlert);
	
	PrecacheModel("models/police.mdl");
	PrecacheModel("models/combine_soldier.mdl");
}

methodmap BaseSquad < CClotBody
{
	public void PlayPistolFire()
	{
		EmitSoundToAll(PistolFire[GetURandomInt() % sizeof(PistolFire)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayPistolReload()
	{
		EmitSoundToAll(PistolReload[GetURandomInt() % sizeof(PistolReload)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayStunStickDeploy()
	{
		EmitSoundToAll(StunStickDeploy[GetURandomInt() % sizeof(StunStickDeploy)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayStunStickFire()
	{
		EmitSoundToAll(StunStickFire[GetURandomInt() % sizeof(StunStickFire)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayStunStickHit()
	{
		EmitSoundToAll(StunStickHit[GetURandomInt() % sizeof(StunStickHit)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlaySMGFire()
	{
		EmitSoundToAll(SMGFire[GetURandomInt() % sizeof(SMGFire)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlaySMGReload()
	{
		EmitSoundToAll(SMGReload[GetURandomInt() % sizeof(SMGReload)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public BaseSquad(float vecPos[3], float vecAng[3],
						const char[] model,
						const char[] modelscale = "1.0",
						bool Ally = false,
						bool Ally_Invince = false,
						bool isGiant = false,
						bool IgnoreBuildings = false,
						bool IsRaidBoss = false,
						float CustomThreeDimensions[3] = {0.0,0.0,0.0},
						bool Ally_Collideeachother = false)
	{
		BaseSquad npc = view_as<BaseSquad>(CClotBody(vecPos, vecAng, model, modelscale, _, Ally, Ally_Invince, isGiant, IgnoreBuildings, IsRaidBoss, CustomThreeDimensions, Ally_Collideeachother));

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];

		npc.SetActivity("ACT_IDLE");
		if(npc.LookupActivity("ACT_LAND") > 0)
			npc.AddGesture("ACT_LAND");

		npc.m_bAnger = false;
		npc.m_iTargetAttack = 0;
		npc.m_iTargetWalk = 0;
		npc.m_iDeathDamage = 1;
		npc.m_iNoTargetCount = 0;
		npc.m_flNextIdleSound = 0.0;
		npc.m_flNextIdleAlertSound = 0.0;

		return npc;
	}
	public void UpdateHealthBar()
	{
		if(IsValidEntity(this.m_iTextEntity3))
		{
			char string[32];
			Format(string, sizeof(string), "%d / %d", GetEntProp(this.index, Prop_Data, "m_iHealth"), GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));
			DispatchKeyValue(this.m_iTextEntity3, "message", string);
		}
	}
	property bool m_bIsSquad
	{
		public get()		{ return view_as<bool>(this.m_iDeathDamage); }
	}
	property bool m_bAnger
	{
		public get()		{ return this.Anger; }
		public set(bool value) 	{ this.Anger = value; }
	}
	property bool m_bRanged
	{
		public get()		{ return this.m_fbGunout; }
		public set(bool value) 	{ this.m_fbGunout = value; }
	}
	property int m_iTargetAttack
	{
		public get()		{ return this.m_iTarget; }
		public set(int value) 	{ this.m_iTarget = value; }
	}
	property int m_iTargetWalk
	{
		public get()		{ return this.m_iTargetAlly; }
		public set(int value) 	{ this.m_iTargetAlly = value; }
	}
	property int m_iDeathDamage
	{
		public get()		{ return DeathDamage[this.index]; }
		public set(int value) 	{ DeathDamage[this.index] = value; }
	}
	property int m_iNoTargetCount
	{
		public get()		{ return i_NoEntityFoundCount[this.index]; }
		public set(int value) 	{ i_NoEntityFoundCount[this.index] = value; }
	}
	property float m_flNextIdleAlertSound
	{
		public get()		{ return this.m_flNextRangedSpecialAttackHappens; }
		public set(float value)	{ this.m_flNextRangedSpecialAttackHappens = value; }
	}
}

methodmap CombinePolice < BaseSquad
{
	public void PlayIdle(bool anger)
	{
		float gameTime = GetGameTime(this.index);

		if(anger)
		{
			if(this.m_flNextIdleAlertSound > gameTime)
				return;
			
			EmitSoundToAll(PoliceIdleAlert[GetURandomInt() % sizeof(PoliceIdleAlert)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
			this.m_flNextIdleAlertSound = gameTime + GetRandomFloat(12.0, 24.0);
		}
		else
		{
			if(this.m_flNextIdleSound > gameTime)
				return;
			
			EmitSoundToAll(PoliceIdle[GetURandomInt() % sizeof(PoliceIdle)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
			this.m_flNextIdleSound = gameTime + GetRandomFloat(12.0, 24.0);
		}
	}
	public void PlayHurt()
	{
		EmitSoundToAll(PoliceHurt[GetURandomInt() % sizeof(PoliceHurt)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeath()
	{
		EmitSoundToAll(PoliceDeath[GetURandomInt() % sizeof(PoliceDeath)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayPanic()
	{
		EmitSoundToAll(PolicePanic[GetURandomInt() % sizeof(PolicePanic)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
}

void BaseSquad_BaseThinking(any npcIndex, const float vecMe[3])
{
	BaseSquad npc = view_as<BaseSquad>(npcIndex);

	if(npc.m_iTargetAttack && !IsValidEnemy(npc.index, npc.m_iTargetAttack))
	{
		npc.m_iTargetAttack = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		if(npc.m_iTargetAttack == i_NpcFightOwner[npc.index])
			i_NpcFightOwner[npc.index] = 0;
	}

	if(npc.m_iTargetWalk && !IsEntityAlive(npc.m_iTargetAttack))
	{
		npc.m_iTargetWalk = 0;
		npc.m_flGetClosestTargetTime = 0.0;
	}
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		float distance = 500.0;
		if(b_NpcIsInADungeon[npc.index])
			distance = 99999.9;
		
		// We constantly target who attacked us
		if(b_NpcIsInADungeon[npc.index] || !npc.m_iTargetAttack || !i_NpcFightOwner[npc.index] || f_NpcFightTime[npc.index] < gameTime)
		{
			int target = GetClosestTarget(npc.index, false, distance);
			if(target && (b_NpcIsInADungeon[npc.index] || Can_I_See_Enemy(npc.index, target)))
			{
				npc.m_iTargetAttack = target;
				npc.m_iTargetWalk = npc.m_iTargetAttack;
			}
			else
			{
				float vecTarget[3];

				// Ask our squad members if they can see them
				for(int i = MaxClients + 1; i < MAXENTITIES; i++) 
				{
					if(i != npc.index)
					{
						BaseSquad ally = view_as<BaseSquad>(i);
						if(ally.m_bIsSquad && ally.m_iTargetAttack && IsValidAlly(npc.index, ally.index))
						{
							vecTarget = WorldSpaceCenter(ally.index);
							if(GetVectorDistance(vecMe, vecTarget, true) < 100000.0)	// 316 HU
							{
								npc.m_iTargetAttack = ally.m_iTargetAttack;
								npc.m_iTargetWalk = ally.m_iTargetAttack;
								break;
							}
						}
					}
				}
			}
		}

		// We can't run after them, stand still and do shooty logic
		if(npc.m_iTargetWalk && !PF_IsPathToEntityPossible(npc.index, npc.m_iTargetWalk))
		{
			npc.m_iTargetWalk = 0;
		}
	}
}

void BaseSquad_BaseWalking(any npcIndex, const float vecMe[3])
{
	BaseSquad npc = view_as<BaseSquad>(npcIndex);

	if(npc.m_iTargetWalk || npc.m_iTargetAttack)
	{
		npc.m_iNoTargetCount = 0;
		
		if(npc.m_iTargetWalk)
		{
			float vecTarget[3];
			vecTarget = WorldSpaceCenter(npc.m_iTargetWalk);

			if(GetVectorDistance(vecTarget, vecMe, true) < npc.GetLeadRadius())
			{
				vecTarget = PredictSubjectPosition(npc, npc.m_iTargetWalk);
			}
			else
			{
				PF_SetGoalEntity(npc.index, npc.m_iTargetWalk);
			}

			npc.StartPathing();
		}
		else
		{
			npc.StopPathing();
		}
	}
	else if(++npc.m_iNoTargetCount > 19)
	{
		if(GetVectorDistance(vecMe, f3_SpawnPosition[npc.index], true) < 8000.0)	// 90 HU
		{
			PF_SetGoalVector(npc.index, f3_SpawnPosition[npc.index]);
			npc.StartPathing();
		}
		else
		{
			int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
			int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");

			if(health < maxhealth)
			{
				health += maxhealth / 100;
				if(health > maxhealth)
					health = maxhealth;
				
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				npc.UpdateHealthBar();
			}

			npc.StopPathing();
		}
	}
	else
	{
		npc.StopPathing();
	}
}

bool BaseSquad_BaseAnim(any npcIndex, float speedPassive, const char[] idlePassive, const char[] walkPassive, float speedAnger = 0.0, const char[] idleAnger = "", const char[] walkAnger = "")
{
	BaseSquad npc = view_as<BaseSquad>(npcIndex);

	if(npc.m_bPathing)
	{
		if(walkAnger[0] && npc.m_iNoTargetCount < 20)
		{
			npc.m_flSpeed = speedAnger;
			npc.SetActivity(walkAnger);
			return true;
		}
		
		npc.m_flSpeed = speedPassive;
		npc.SetActivity(walkPassive);
		return false;
	}
	
	npc.m_flSpeed = 0.0;

	if(idleAnger[0] && npc.m_iNoTargetCount < 20)
	{
		npc.SetActivity(idleAnger);
		return true;
	}
	
	npc.SetActivity(idlePassive);
	return false;
}

public Action BaseSquad_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;

	BaseSquad npc = view_as<BaseSquad>(victim);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}