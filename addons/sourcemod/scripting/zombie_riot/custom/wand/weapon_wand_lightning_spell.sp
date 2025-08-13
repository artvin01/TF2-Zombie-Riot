#pragma semicolon 1
#pragma newdecls required

static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static float Fireball_Damage[MAXPLAYERS+1]={0.0, ...};
static float Damage_Reduction[MAXPLAYERS+1]={0.0, ...};
static int gLaser1;
#define SOUND_WAND_LIGHTNING_ABILITY "ambient/explosions/explode_9.wav"

void Wand_LightningAbility_Map_Precache()
{
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	PrecacheSound(SOUND_WAND_LIGHTNING_ABILITY);
	PrecacheSound("ambient/explosions/explode_3.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_flyby2.wav", true);
	PrecacheSound("ambient/atmosphere/terrain_rumble1.wav", true);
	PrecacheSound("ambient/explosions/explode_9.wav", true);
}

public void Lighting_Wand_Spell_ClearAll()
{
	Zero(ability_cooldown);
}

public void Weapon_Wand_LightningSpell(int client, int weapon, bool &result, int slot)
{
	Weapon_Wand_LightningSpell_Internal(client, weapon, result, slot, false);
}
public void Weapon_Wand_LightningSpell_Internal(int client, int weapon, bool &result, int slot, bool free)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = 100;
		if(mana_cost <= Current_Mana[client] || free)
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0 || free)
			{
				Rogue_OnAbilityUse(client, weapon);
				if(!free)
				{
					Ability_Apply_Cooldown(client, slot, 15.0);
					SDKhooks_SetManaRegenDelayTime(client, 1.0);
					
					Current_Mana[client] -= mana_cost;
				}
				
				float damage = 130.0;
				
				damage *= 7.5;
				
				damage *= Attributes_Get(weapon, 410, 1.0);
			
				Fireball_Damage[client] = damage;
					
					
				delay_hud[client] = 0.0;
				Damage_Reduction[client] = 1.0;
				
				float vAngles[3];
				float vOrigin[3];
				float vEnd[3];
	
				GetClientEyePosition(client, vOrigin);
				GetClientEyeAngles(client, vAngles);
				b_LagCompNPC_ExtendBoundingBox = true;
				StartLagCompensation_Base_Boss(client);
				Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, client);
				
				if(TR_DidHit(trace))
				{   
		   		 	TR_GetEndPosition(vEnd, trace);
					
					Explode_Logic_Custom(damage, client, client, weapon, vEnd,_,_,_,false);
					
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
					
					DataPack pack = new DataPack();
					pack.WriteFloat(vEnd[0]);
					pack.WriteFloat(vEnd[1]);
					pack.WriteFloat(vEnd[2]);
					pack.WriteCell(1);
					RequestFrame(MakeExplosionFrameLater, pack);
					
					EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
					EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);	

				}
				delete trace;
				FinishLagCompensation_Base_boss();
				
			}
			else
			{
				float Ability_CD = Ability_Check_Cooldown(client, slot);
		
				if(Ability_CD <= 0.0)
					Ability_CD = 0.0;
			
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetDefaultHudPosition(client);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}