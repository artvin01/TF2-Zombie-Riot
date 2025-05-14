#pragma semicolon 1
#pragma newdecls required

/*
	Placement Type
*/
static DynamicHook g_Particle_cannon_2nd_fire;

public void OnPluginStartMangler()
{
	GameData gamedata = new GameData("zombie_riot");
	if (gamedata == null)
		SetFailState("Could not find zombie_riot gamedata");
	
	g_Particle_cannon_2nd_fire = DynamicHook.FromConf(gamedata, "CTFParticleCannon::FireChargedShot");
	
	delete gamedata;
}

void OnManglerCreated(int entity) 
{
	g_Particle_cannon_2nd_fire.HookEntity(Hook_Pre, entity, Mangler_2nd);
}

#define MANGLERSLOT_DEFAULT 2
public MRESReturn Mangler_2nd(int entity, DHookReturn ret, DHookParam param)
{	
	int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	{
		
		if (Ability_Check_Cooldown(client, MANGLERSLOT_DEFAULT) > 0.0)
		{

			float Ability_CD = Ability_Check_Cooldown(client, MANGLERSLOT_DEFAULT);
			
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
				
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
			return MRES_Ignored;
		}
		//ignore rest.
		int new_ammo = GetAmmo(client, 23);
		if(new_ammo >= 80)
		{
			Ability_Apply_Cooldown(client, MANGLERSLOT_DEFAULT, 30.0);
			Rogue_OnAbilityUse(client, entity);
			new_ammo -= 80;
			SetAmmo(client, 23, new_ammo);
			CurrentAmmo[client][23] = GetAmmo(client, 23);
			
			SetGlobalTransTarget(client);
			
			PrintHintText(client,"%t: %i", "Laser Battery", new_ammo);

			
			Client_Shake(client, 0, 50.0, 25.0, 0.5);
			
			float damage = 112.0;

			//okay, interesting
			damage *= 1.3; //tiny penalty.
			damage *= 2.0; //tiny penalty.
			damage *= Attributes_Get(entity, 335, 1.0);		
			damage *= Attributes_Get(entity, 1, 1.0);		
			damage *= Attributes_Get(entity, 2, 1.0);
	
			float reverse_attackspeed = 1.0;
			reverse_attackspeed = Attributes_Get(entity, 6, 1.0);
			
			damage /= reverse_attackspeed;
			
			Player_Laser_Logic Laser;
			float Radius = 15.0;
			Laser.client = client;
			Laser.Radius = Radius;
			Laser.damagetype = DMG_PLASMA;
			Laser.DoForwardTrace_Basic(2500.0);
			PlayerLaserDoDamageCombined(Laser, damage, damage);
			Offset_Vector({0.0, -8.0, -10.0}, Laser.Angles, Laser.Start_Point);
			int color[4] = {65, 105, 225, 60};
			DoPlayerLaserEffectsBigger(Laser, color);
		}
		else
		{
			SetGlobalTransTarget(client);
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			PrintHintText(client,"%t", "Out of Laser Battery");
		}
	}
	/*
	SetEntPropFloat(entity, Prop_Send, "m_flChargeBeginTime", 0.0);
	SetEntPropFloat(entity, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 0.5);
	SDKCall_SetSpeed(client);
	TF2_RemoveCondition(client, TFCond_Slowed);
	return MRES_Supercede;
	*/
	return MRES_Ignored;
}