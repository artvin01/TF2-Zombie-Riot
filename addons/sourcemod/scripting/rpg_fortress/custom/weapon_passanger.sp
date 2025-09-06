#pragma semicolon 1
#pragma newdecls required

#define SOUND_WAND_PASSANGER "npc/scanner/scanner_electric2.wav"

static int BeamWand_Laser;
static int BeamWand_Glow;
#define PASSANGER_RANGE 200.0
#define CUSTOM_MELEE_RANGE_DETECTION 1000.0

void Passanger_Wand_MapStart()
{
	PrecacheSound(SOUND_WAND_PASSANGER);
	BeamWand_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	BeamWand_Glow = PrecacheModel("sprites/glow02.vmt", true);
}

static bool b_EntityHitByLightning[MAXENTITIES];

public void Weapon_Passanger_Attack(int client, int weapon, bool crit, int slot)
{
	b_LagCompNPC_No_Layers = true;
	float vecSwingForward[3];
	StartLagCompensation_Base_Boss(client);
	Handle swingTrace;
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, CUSTOM_MELEE_RANGE_DETECTION);
		
	int target = TR_GetEntityIndex(swingTrace);
	float vecHit[3];
	TR_GetEndPosition(vecHit, swingTrace);	

	delete swingTrace;
	static float belowBossEyes[3];

	belowBossEyes[0] = 0.0;
	belowBossEyes[1] = 0.0;
	belowBossEyes[2] = 0.0;

	float damage = 65.0;
	damage *= Attributes_Get(weapon, 410, 1.0);

	EmitSoundToAll(SOUND_WAND_PASSANGER, client, SNDCHAN_AUTO, 80, _, 0.9, GetRandomInt(95, 110));

	if(IsValidEnemy(client, target))
	{
		//We have found a victim.
		GetBeamDrawStartPoint_Stock(client, belowBossEyes);
		Passanger_Lightning_Strike(client, target, weapon, damage, belowBossEyes);
	}
	else
	{
		//We will just fire a trace on whatever we hit.
		//Doesnt do anything.
		GetBeamDrawStartPoint_Stock(client, belowBossEyes);
		Passanger_Lightning_Effect(belowBossEyes, vecHit, 1);
	}
	FinishLagCompensation_Base_boss();
}

stock int GetClosestTargetNotAffectedByLightning(float EntityLocation[3])
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 

	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && !b_EntityHitByLightning[baseboss_index] && GetTeam(baseboss_index) != TFTeam_Red)
		{
			float TargetLocation[3]; 
			GetEntPropVector( baseboss_index, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
			float distance = GetVectorDistance( EntityLocation, TargetLocation, true );  
				
			if(distance <= (PASSANGER_RANGE * PASSANGER_RANGE))
			{
				if( TargetDistance ) 
				{
					if( distance < TargetDistance ) 
					{
						ClosestTarget = baseboss_index; 
						TargetDistance = distance;          
					}
				} 
				else 
				{
					ClosestTarget = baseboss_index; 
					TargetDistance = distance;
				}
			}
		}
	}
	if(IsValidEntity(ClosestTarget))
	{
		b_EntityHitByLightning[ClosestTarget] = true;
	}
	return ClosestTarget; 
}


void Passanger_Lightning_Effect(float belowBossEyes[3], float vecHit[3], int Power, float diameter_override = 0.0, int color[3] = {0,0,0})
{	
	
	int r = 255; //Yellow.
	int g = 255;
	int b = 65;
	float diameter = 5.0;
	if(Power == 2)
	{
		diameter = 50.0;
	}
	if(Power == 3)
	{
		diameter = 25.0;
	}
	if(Power == 4)
	{
		diameter = 12.0;
	}
	if(diameter_override != 0.0)
	{
		diameter = diameter_override;
	}
	if(color[0] != 0)
	{
		r = color[0]; //Yellow.
		g = color[1];
		b = color[2];
	}
	int colorLayer4[4];
	SetColorRGBA(colorLayer4, r, g, b, 125);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 60);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 60);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 60);
	if(Power == 4)
	{
		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.1, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
		TE_SendToAll(0.0);
		return;
	}
	if(Power == 3)
	{
		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.1, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
		TE_SendToAll(0.0);

		int glowColor[4];
		SetColorRGBA(glowColor, r, g, b, 125);
		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Glow, 0, 0, 0, 0.1, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
		TE_SendToAll(0.0);
		return;
	}
	if(Power == 2)
	{
		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
		TE_SendToAll(0.0);

		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
		TE_SendToAll(0.0);
	}
	TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
	TE_SendToAll(0.0);

	int glowColor[4];
	SetColorRGBA(glowColor, r, g, b, 125);
	TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Glow, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
	TE_SendToAll(0.0);
}

void Passanger_Lightning_Strike(int client, int target, int weapon, float damage, float StartLightningPos[3], bool Firstlightning = true)
{
	static float vecHit[3];
	GetBeamDrawStartPoint_Stock(client, StartLightningPos);
	GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", vecHit);

	if(Firstlightning)
	{
		float EnemyVecPos[3]; WorldSpaceCenter(target, EnemyVecPos);
		Passanger_Lightning_Effect(StartLightningPos, EnemyVecPos, 1);
	}
	WorldSpaceCenter(target, StartLightningPos);
	ApplyStatusEffect(client, target, "Electric Impairability", 0.15);
	SDKHooks_TakeDamage(target, client, client, damage, DMG_PLASMA, weapon, {0.0, 0.0, -50000.0}, vecHit);	//BURNING TO THE GROUND!!!
	f_CooldownForHurtHud[client] = 0.0;
	b_EntityHitByLightning[target] = true;
	Zero(b_EntityHitByLightning); //delete this logic.
}