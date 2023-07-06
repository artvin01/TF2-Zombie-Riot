#pragma semicolon 1
#pragma newdecls required

static const char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};

static int i_barrage[MAXENTITIES];
static float fl_barragetimer[MAXENTITIES];
static float fl_singularbarrage[MAXENTITIES];
static bool b_barrage[MAXENTITIES];

public void Barrack_Alt_Holy_Knight_MapStart()
{
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++)			{ PrecacheSound(g_RangedAttackSounds[i]);   }
}

methodmap Barrack_Alt_Holy_Knight < BarrackBody
{
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public Barrack_Alt_Holy_Knight(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Barrack_Alt_Holy_Knight npc = view_as<Barrack_Alt_Holy_Knight>(BarrackBody(client, vecPos, vecAng, "1250",_,_,"models/pickups/pickup_powerup_strength_arm.mdl"));
		
		i_NpcInternalId[npc.index] = ALT_BARRACKS_HOLY_KNIGHT;
		i_NpcWeight[npc.index] = 2;
		
		SDKHook(npc.index, SDKHook_Think, Barrack_Alt_Holy_Knight_ClotThink);

		npc.m_flSpeed = 225.0;
		
		int iActivity = npc.LookupActivity("ACT_TEUTON_NEW_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 150, 175, 255, 255);

		npc.m_iState = 0;
		npc.m_flSpeed = 250.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		npc.m_iWearable3 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_shogun_katana/c_shogun_katana.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/Jul13_Se_Headset/Jul13_Se_Headset_soldier.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		
		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/soldier/dec17_brass_bucket/dec17_brass_bucket.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		

		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 255, 1, 1, 255);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 100, 150, 255, 255);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 50, 125, 150, 255);
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		return npc;
	}
}

public void Barrack_Alt_Holy_Knight_ClotThink(int iNPC)
{
	Barrack_Alt_Holy_Knight npc = view_as<Barrack_Alt_Holy_Knight>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;
		if(PrimaryThreatIndex > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			if(fl_barragetimer[npc.index] <= GetGameTime(npc.index) && fl_singularbarrage[npc.index] <= GetGameTime(npc.index))
			{	
				SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
				SetEntityRenderColor(npc.m_iWearable3, 1, 1, 1, 1);

				i_barrage[npc.index]++;
				
				float Angles[3], distance = 100.0, UserLoc[3];
				
				
				UserLoc = GetAbsOrigin(npc.index);
				
				MakeVectorFromPoints(UserLoc, vecTarget, Angles);
				GetVectorAngles(Angles, Angles);
				
				float type;
				
				if(flDistanceToTarget < 62500)	//Target is close, we do wide attack
				{
					Angles[1]-=22.5;
					type = 9.0;
				}
				else	//Target is far, we do long range attack.
				{
					Angles[1]-=10.0;
					type = 4.0;
				}
				
				for(int alpha=1 ; alpha<=5 ; alpha++)	//Shoot 5 rockets dependant on the stuff above this
				{
							
					float tempAngles[3], endLoc[3], Direction[3];
					tempAngles[0] = -32.5;
					tempAngles[1] = Angles[1] + type * alpha;
					tempAngles[2] = 0.0;
							
					GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(Direction, distance);
					AddVectors(UserLoc, Direction, endLoc);
							
					npc.FireParticleRocket(endLoc, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 2500.0, 1) , 850.0 , 100.0 , "raygun_projectile_blue", _ , false, _,_,_, GetClientOfUserId(npc.OwnerUserId));
					//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)
		
				}
				npc.PlayRangedSound();
				npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
				fl_singularbarrage[npc.index] = GetGameTime(npc.index) + 0.1;
				b_barrage[npc.index] = true;
				if (i_barrage[npc.index] >= 1)	//Stays here incase you want this multi shoot to act like a barrage
				{
					SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
					SetEntityRenderColor(npc.m_iWearable3, 255, 1, 1, 255);
					i_barrage[npc.index] = 0;
					fl_barragetimer[npc.index] = GameTime + 30.0 * npc.BonusFireRate;
					b_barrage[npc.index] = false;
				}
			}
			
			if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
						npc.m_flAttackHappens = GameTime+0.4 * npc.BonusFireRate;
						npc.m_flAttackHappens_bullshit = GameTime+0.54 * npc.BonusFireRate;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							
							if(target > 0) 
							{
								SDKHooks_TakeDamage(PrimaryThreatIndex, npc.index, GetClientOfUserId(npc.OwnerUserId), Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 4500.0, 0), DMG_CLUB, -1, _, vecHit);
								npc.PlaySwordHitSound();
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GameTime + 0.8 * npc.BonusFireRate;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GameTime + 0.8 * npc.BonusFireRate;
					}
				}
			}
		}
		else
		{
			npc.PlayIdleSound();
		}
		BarrackBody_ThinkMove(npc.index, 200.0, "ACT_TEUTON_NEW_WALK", "ACT_TEUTON_NEW_WALK", 9999.0);
	}
}

void Barrack_Alt_Holy_Knight_NPCDeath(int entity)
{	
	Barrack_Alt_Holy_Knight npc = view_as<Barrack_Alt_Holy_Knight>(entity);
		
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, Barrack_Alt_Holy_Knight_ClotThink);
}