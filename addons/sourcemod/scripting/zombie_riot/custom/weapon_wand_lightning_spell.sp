static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static float Fireball_Damage[MAXPLAYERS+1]={0.0, ...};
static float Damage_Reduction[MAXPLAYERS+1]={0.0, ...};
static int gLaser1;
#define SOUND_WAND_LIGHTNING_ABILITY "ambient/explosions/citadel_end_explosion1.wav"

void Wand_LightningAbility_Map_Precache()
{
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	PrecacheSound(SOUND_WAND_LIGHTNING_ABILITY);
}

public void Weapon_Wand_LightningSpell(int client, int weapon, const char[] classname, bool &result)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = 100;
		if(mana_cost <= Current_Mana[client])
		{
			if (ability_cooldown[client] < GetGameTime())
			{
				ability_cooldown[client] = GetGameTime() + 15.0; //10 sec CD
				
				float damage = 120.0;
				
				damage *= 7.5;
				
				Address address = TF2Attrib_GetByDefIndex(weapon, 410);
				if(address != Address_Null)
					damage *= TF2Attrib_GetValue(address);
			
				Fireball_Damage[client] = damage;
					
				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
				Mana_Hud_Delay[client] = 0.0;
				
				Current_Mana[client] -= mana_cost;
					
				delay_hud[client] = 0.0;
				Damage_Reduction[client] = 1.0;
				
				float vAngles[3];
				float vOrigin[3];
				float vEnd[3];
				float targPos[3];
	
				GetClientEyePosition(client, vOrigin);
				GetClientEyeAngles(client, vAngles);
				Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, Trace_DontHitEntityOrPlayer);
				
				if(TR_DidHit(trace))
				{   	 
		   		 	TR_GetEndPosition(vEnd, trace);
			
					CloseHandle(trace);
					
					int targ = MaxClients + 1;
					
					while ((targ = FindEntityByClassname(targ, "base_boss")) != -1)
					{
						if (GetEntProp(client, Prop_Send, "m_iTeamNum")!=GetEntProp(targ, Prop_Send, "m_iTeamNum")) 
						{
							GetEntPropVector(targ, Prop_Data, "m_vecAbsOrigin", targPos);
							if (GetVectorDistance(vEnd, targPos) <= 250.0)
							{
								float distance_1 = GetVectorDistance(vEnd, targPos);
								float damage_1 = Custom_Explosive_Logic(client, distance_1, 0.75, damage, 251.0);
								
								damage_1 /= Damage_Reduction[client];
								SDKHooks_TakeDamage(targ, client, client, damage_1, DMG_PLASMA, -1, {0.0, 0.0, -50000.0}, vEnd);
								
								Damage_Reduction[client] *= EXPLOSION_AOE_DAMAGE_FALLOFF;
								//use blast cus it does its own calculations for that ahahahah im evil
							}
						}
					}
					float position[3];
					position[0] = vEnd[0];
					position[1] = vEnd[1];
					position[2] += 1500.0;
					
					int r = 255;
					int g = 255;
					int b = 0;
					int alpha = 125;
					int diameter = 25;
					
					int colorLayer4[4];
					SetColorRGBA(colorLayer4, r, g, b, alpha);
					int colorLayer3[4];
					SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, alpha);
					int colorLayer2[4];
					SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, alpha);
					int colorLayer1[4];
					SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, alpha);
					TE_SetupBeamPoints(vEnd, position, gLaser1, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
					TE_SendToAll(0.0);
					TE_SetupBeamPoints(vEnd, position, gLaser1, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
					TE_SendToAll(0.0);
					TE_SetupBeamPoints(vEnd, position, gLaser1, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
					TE_SendToAll(0.0);
					TE_SetupBeamPoints(vEnd, position, gLaser1, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
					TE_SendToAll(0.0);
					int glowColor[4];
					SetColorRGBA(glowColor, r, g, b, alpha);
					
					int particle_extra;
					float Angles[3];
					
					particle_extra = ParticleEffectAt(vEnd, "utaunt_lightning_bolt", 1.0);
					Angles [1] = GetRandomFloat(-180.0, 180.0);
					TeleportEntity(particle_extra, NULL_VECTOR, Angles, NULL_VECTOR);
					
					particle_extra = ParticleEffectAt(vEnd, "utaunt_lightning_bolt", 1.0);
					Angles [1] = GetRandomFloat(-180.0, 180.0);
					TeleportEntity(particle_extra, NULL_VECTOR, Angles, NULL_VECTOR);
					
					particle_extra = ParticleEffectAt(vEnd, "utaunt_lightning_bolt", 1.0);
					Angles [1] = GetRandomFloat(-180.0, 180.0);
					TeleportEntity(particle_extra, NULL_VECTOR, Angles, NULL_VECTOR);
					
					TE_SetupBeamPoints(vEnd, position, gLaser1, 0, 0, 0, 0.33, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
					TE_SendToAll(0.0);
					EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
					EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);	

				}
				
			}
			else
			{
				float Ability_CD = ability_cooldown[client] - GetGameTime();
		
				if(Ability_CD <= 0.0)
					Ability_CD = 0.0;
			
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}