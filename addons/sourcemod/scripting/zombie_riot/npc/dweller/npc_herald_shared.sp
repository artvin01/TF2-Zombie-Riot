#pragma semicolon 1
#pragma newdecls required

methodmap CSeaBody < CClotBody
{
	property bool m_bElite
	{
		public get()
		{
			return this.m_iMedkitAnnoyance == 1;
		}
	}

	property bool m_bCarrier
	{
		public get()
		{
			return this.m_iMedkitAnnoyance == 2;
		}
	}

	public void SetElite(bool elite, bool carrier = false)
	{
		this.m_iMedkitAnnoyance = carrier ? 2 : (elite ? 1 : 0);

		if(carrier || elite)
			RequestFrame(SetNameFrame, EntIndexToEntRef(this.index));
	}
}

static void SetNameFrame(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != -1 && c_NpcName[entity][0])
	{
		int pos = FindCharInString(c_NpcName[entity], ' ', true);
		if(pos != -1)
		{
			if(view_as<CSeaBody>(entity).m_bCarrier)
			{
				Format(c_NpcName[entity], sizeof(c_NpcName[]), "Regressed %s", c_NpcName[entity][pos + 1]);
			}
			else
			{
				Format(c_NpcName[entity], sizeof(c_NpcName[]), "Nourished %s", c_NpcName[entity][pos + 1]);
			}
		}
	}
}
