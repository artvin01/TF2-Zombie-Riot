#pragma semicolon 1
#pragma newdecls required

#define BOOMERANG_MODEL "models/props_forest/saw_blade.mdl"

static int targets_hit[MAXPLAYERS+1]={0, ...};
static int Max_Hits_Allowed[MAXPLAYERS+1]={0, ...};
static bool b_EntityHitByBoomerang[MAXENTITIES];
static float RMR_HomingPerSecond[MAXENTITIES];
static float vecHit[3];
static int RMR_CurrentHomingTarget[MAXENTITIES];
static bool RMR_HasTargeted[MAXENTITIES];
static int RMR_RocketOwner[MAXENTITIES];
static float RWI_HomeAngle[MAXENTITIES];
static float RWI_LockOnAngle[MAXENTITIES];
static float RMR_RocketVelocity[MAXENTITIES];
static int Boomerang_Owner[MAXENTITIES] = { -1, ... };
//static int store_owner;


//#define SOUND_WAND_SHOT_LIGHTNING	"weapons/dragons_fury_shoot.wav"
//#define SOUND_LIGHTNING_IMPACT "misc/halloween/spell_lightning_ball_impact.wav"
/*
void Wand_Lightning_Map_Precache()
{
	PrecacheSound(SOUND_WAND_SHOT_LIGHTNING);
	PrecacheSound(SOUND_LIGHTNING_IMPACT);
}
*/
public void Weapon_Boomerang_Attack(int client, int weapon, bool crit)
{
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
		float damage = 65.0;
		damage *= Attributes_Get(weapon, 410, 1.0);
		
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
				
		float speed = 1100.0;
		speed *= Attributes_Get(weapon, 103, 1.0);
		speed *= Attributes_Get(weapon, 104, 1.0);
		speed *= Attributes_Get(weapon, 475, 1.0);
		
		float time = 2500.0 / speed;
		time *= Attributes_Get(weapon, 101, 1.0);
		time *= Attributes_Get(weapon, 102, 1.0);

        float fAng[3];
	    GetClientEyeAngles(client, fAng);

        float fPos[3];
	    GetClientEyePosition(client, fPos);

        targets_hit[client] = 0;
			
		EmitSoundToAll(SOUND_WAND_SHOT_LIGHTNING, client, SNDCHAN_AUTO, 65, _, 0.45, 100);
        int projectile = Wand_Projectile_Spawn(client, speed, time, damage, WEAPON_BOOMERANG, weapon, "", fAng, false , fPos);
		Boomerang_Owner[projectile] = -1;
		Boomerang_Owner[projectile] = GetClientUserId(client);
		//store_owner = GetClientUserId(client);
        ApplyCustomModelToWandProjectile(projectile, BOOMERANG_MODEL, 1.0, "");
        CreateTimer(0.1, Boomerang_Homing_Repeat_Timer, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		RMR_HomingPerSecond[projectile] = 150.0;
		RMR_RocketOwner[projectile] = client;
		RMR_HasTargeted[projectile] = false;
		RWI_HomeAngle[projectile] = 180.0;
		RWI_LockOnAngle[projectile] = 180.0;
		RMR_RocketVelocity[projectile] = speed;
		RMR_CurrentHomingTarget[projectile] = -1;
		b_NpcIsTeamkiller[projectile] = true; //allows self hitting
		b_EntityHitByBoomerang[client] = true; //set it to true so it cant hit you when you launch it
		Max_Hits_Allowed[client] = 2;
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

stock int GetClosestTargetNotHitByBoomerang(float EntityLocation[3])
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 
	//int Weapon_User = GetClientOfUserId(Boomerang_Owner[entity]);

	for(int targ; targ<i_MaxcountNpcTotal; targ++)
	{
		int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && !b_EntityHitByBoomerang[baseboss_index] && GetTeam(baseboss_index) != TFTeam_Red)
		{
			float TargetLocation[3]; 
			GetEntPropVector( baseboss_index, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
			float distance = GetVectorDistance( EntityLocation, TargetLocation, true );  
				
			if(distance <= (200.0 * 200.0))
			{
				
				if( TargetDistance ) 
				{
					if( distance < TargetDistance ) 
					{
						PrintToChatAll("Found next target"); //this never gets called ???
						ClosestTarget = baseboss_index; 
						TargetDistance = distance;          
					}
				} 
				else 
				{
					PrintToChatAll("Found valid enemy");
					ClosestTarget = baseboss_index; 
					TargetDistance = distance;
				}
			}
		}
	}
	if(IsValidEntity(ClosestTarget))
	{
		b_EntityHitByBoomerang[ClosestTarget] = true;
	}
	return ClosestTarget; 
}

public Action Boomerang_Homing_Repeat_Timer(Handle timer, int ref)
{
    //entity is the projectile itself
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		if(!IsValidClient(RMR_RocketOwner[entity]))
		{
			RemoveEntity(entity);
			return Plugin_Stop;
		}
        int owner = EntRefToEntIndex(i_WandOwner[entity]);
        if(targets_hit[owner] < 2)
        {
            if(IsValidEnemy(entity, RMR_CurrentHomingTarget[entity]))
            {
                if(Can_I_See_Enemy_Only(RMR_CurrentHomingTarget[entity],entity)) //Insta home!
                {
                    HomingProjectile_TurnToTarget(RMR_CurrentHomingTarget[entity], entity);
                }
                return Plugin_Continue;
            }
            int Closest = GetClosestTargetNotHitByBoomerang(vecHit); // this code is fucked
            if(IsValidEnemy(RMR_RocketOwner[entity], Closest))
            {
                RMR_CurrentHomingTarget[entity] = Closest;
                if(IsValidEnemy(entity, RMR_CurrentHomingTarget[entity]))
                {
                    if(Can_I_See_Enemy_Only(RMR_CurrentHomingTarget[entity],entity)) //Insta home!
                    {
                        HomingProjectile_TurnToTarget(RMR_CurrentHomingTarget[entity], entity);
                    }
                    return Plugin_Continue;
                }
            }
        }
		
		if(targets_hit[owner] >= 2) 
        {
			HomingProjectile_TurnToTarget(owner, entity); // this works
		}
			/*
            if(IsValidEnemy(entity, RMR_CurrentHomingTarget[entity]))
            {
                if(Can_I_See_Enemy_Only(RMR_CurrentHomingTarget[entity],entity)) //Insta home!
                {
                    HomingProjectile_TurnToTarget(RMR_CurrentHomingTarget[entity], entity);
                }
                return Plugin_Continue;
            }
            //int Closest = owner;
			//int Closest = GetClosestTargetNotHitByBoomerang(clientposition);
            if(IsValidEnemy(RMR_RocketOwner[entity], Closest))
            {
                RMR_CurrentHomingTarget[entity] = Closest;
                if(IsValidEnemy(entity, RMR_CurrentHomingTarget[entity]))
                {
                    if(Can_I_See_Enemy_Only(RMR_CurrentHomingTarget[entity],entity)) //Insta home!
                    {
                        HomingProjectile_TurnToTarget(owner, entity);
                    }
                    return Plugin_Continue;
                }
            }
			
        }
		*/
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}	

public void Weapon_Boomerang_Touch(int entity, int target)
{
	int owner = EntRefToEntIndex(i_WandOwner[entity]);
	int weapon = EntRefToEntIndex(i_WandWeapon[entity]);
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	int Weapon_User = GetClientOfUserId(Boomerang_Owner[entity]);
	if(target == Weapon_User)//hits client
	{
		if(targets_hit[owner] >= 1)//so our own projectile cant hit us while we are shooting it
		{
			if(IsValidEntity(particle))
			{
				RemoveEntity(particle);
				Zero(b_EntityHitByBoomerang);
			}
			float position[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
			ParticleEffectAt(position, "utaunt_lightning_bolt", 1.0);
			EmitSoundToAll(SOUND_LIGHTNING_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
			PrintToChatAll("Glaive Recovered");
			RemoveEntity(entity);
			Zero(b_EntityHitByBoomerang);
		}
		
	}
	if (target > 0 && target != Weapon_User)//hits any entity EXCEPT client
	{
		//Code to do damage position and ragdolls
		static float angles[3];
		GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		static float Entity_Position[3];
		WorldSpaceCenter(target, Entity_Position);
		//Code to do damage position and ragdolls
        GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", vecHit);
		
		float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);

        if(!b_EntityHitByBoomerang[target])//so we can only hit each enemy one time
        {
			if(targets_hit[owner] < Max_Hits_Allowed[owner])
			{
				b_EntityHitByBoomerang[target] = true;
				b_EntityHitByBoomerang[Weapon_User] = false;
				targets_hit[owner] += 1;
				float position[3];
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
				ParticleEffectAt(position, "utaunt_lightning_bolt", 1.0);
				EmitSoundToAll(SOUND_LIGHTNING_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
				SDKHooks_TakeDamage(target, owner, owner, f_WandDamage[entity], DMG_PLASMA, weapon, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
			}
        }
		//b_EntityHitByBoomerang[target] = true;
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
            Zero(b_EntityHitByBoomerang);
		}
		
        if(targets_hit[owner] > 3)
        {
            RemoveEntity(entity);
            Zero(b_EntityHitByBoomerang);
        }
	}
	else if(target == 0)//hits ground/wall
	{
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
            Zero(b_EntityHitByBoomerang);
		}
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		//ParticleEffectAt(position, "utaunt_lightning_bolt", 1.0); //no need for particles when coliding with terrain
		//EmitSoundToAll(SOUND_LIGHTNING_IMPACT, entity, SNDCHAN_STATIC, 80, _, 1.0);
		RemoveEntity(entity);
        Zero(b_EntityHitByBoomerang);
	}
}