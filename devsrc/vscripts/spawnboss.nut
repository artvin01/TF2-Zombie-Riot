
g_bFightStarted <- false
g_hFightEntity <- null

function SummonRaid()
{
	g_hFightEntity = ZR_CreateNPC("npc_sensal", self.GetOrigin(), self.GetAngles(), {
        health = 350000
        is_boss = 1
        data = "sc7;wave_40"
	})

	g_bFightStarted = true
}

function SummonThink()
{
	if(!g_bFightStarted)
		return

	if(g_hFightEntity == null || !g_hFightEntity.IsValid())
	{
		ZR_AddGlobalCash(10000, false)
		EntFire("ending_lock", "Break")
		g_bFightStarted = false
	}
}