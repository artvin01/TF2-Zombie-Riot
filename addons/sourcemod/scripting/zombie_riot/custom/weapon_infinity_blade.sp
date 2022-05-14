public void Weapon_InfinityBlade(int client, int weapon, const char[] classname, bool &result)
{
	CreateTimer(0.15, ASX_Timer3, client, TIMER_FLAG_NO_MAPCHANGE);
}

#define MAXANGLEPITCH	65.0
#define MAXANGLEYAW		75.0

public Action ASX_Timer3(Handle timer, int client)
{
	if(client <= MaxClients)
	{
		if(IsValidClient(client))
		{
			if(IsPlayerAlive(client))
			{
				static float pos2[3], ang2[3];
				GetClientEyePosition(client, pos2);
				GetClientEyeAngles(client, ang2);
				ang2[0] = fixAngle(ang2[0]);
				ang2[1] = fixAngle(ang2[1]);
				
				float damage = 65.0;
				
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				
				Address address = TF2Attrib_GetByDefIndex(weapon, 1);
				if(address != Address_Null)
					damage *= TF2Attrib_GetValue(address);
			
				address = TF2Attrib_GetByDefIndex(weapon, 2);
				if(address != Address_Null)
					damage *= TF2Attrib_GetValue(address);	
					
				address = TF2Attrib_GetByDefIndex(weapon, 476);
				if(address != Address_Null)
					damage *= TF2Attrib_GetValue(address);	
					
				bool hit = false;
				float hit_enemies = 1.0;
				b_LagCompNPC_No_Layers = true;
				StartLagCompensation_Base_Boss(client, false);
				
				for(int entitycount_2; entitycount_2<i_MaxcountNpc; entitycount_2++)
				{
					int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[entitycount_2]);
					if (IsValidEntity(baseboss_index))
					{
						if(!b_NpcHasDied[baseboss_index])
						{
							static float pos1[3];
							GetEntPropVector(baseboss_index, Prop_Data, "m_vecAbsOrigin", pos1);
							pos1[2] += 54;
							if(GetVectorDistance(pos2, pos1, true) < 30000)
							{
								static float ang3[3];
								GetVectorAnglesTwoPoints(pos2, pos1, ang3);
	
								// fix all angles
								ang3[0] = fixAngle(ang3[0]);
								ang3[1] = fixAngle(ang3[1]);
	
								// verify angle validity
								if(!(fabs(ang2[0] - ang3[0]) <= MAXANGLEPITCH ||
								(fabs(ang2[0] - ang3[0]) >= (360.0-MAXANGLEPITCH))))
									continue;
	
								if(!(fabs(ang2[1] - ang3[1]) <= MAXANGLEYAW ||
								(fabs(ang2[1] - ang3[1]) >= (360.0-MAXANGLEYAW))))
									continue;
	
								// ensure no wall is obstructing
								TR_TraceRayFilter(pos2, pos1, (CONTENTS_SOLID | CONTENTS_AREAPORTAL | CONTENTS_GRATE), RayType_EndPoint, TraceWallsOnly);
								TR_GetEndPosition(ang3);
								if(ang3[0]!=pos1[0] || ang3[1]!=pos1[1] || ang3[2]!=pos1[2])
									continue;
								
								hit = true;
								SDKHooks_TakeDamage(baseboss_index, client, client, damage/hit_enemies, DMG_CLUB, weapon);
								hit_enemies *= 1.4;
							}
						}
					}
				}
				FinishLagCompensation_Base_boss();
				if(hit)
				{
					/*
					if(IsValidEntity(weapon))
					{
						
						
					}
					*/
					EmitSoundToAll("weapons/halloween_boss/knight_axe_hit.wav", client,_ ,_ ,_ ,0.75);	
				}
			}
		}
	}
	return Plugin_Handled;
}