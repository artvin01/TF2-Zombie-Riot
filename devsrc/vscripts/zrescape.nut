::ROOT  <- getroottable()
::CONST <- getconsttable()

if(!("ConstantNamingConvention" in CONST))
{
	foreach(a, b in Constants)
	{
		foreach(c, d in b)
		{
			CONST[c] <- d == null ? 0 : d
		}
	}
}

IncludeScript("zrescape/consts", ROOT)
IncludeScript("zrescape/stocks", ROOT)
IncludeScript("zrescape/precache", ROOT)
IncludeScript("zrescape/debug", ROOT)
IncludeScript("zrescape/main", ROOT)

if("ZombieRiotEscapeScriptEvents" in ROOT)
{
	ZombieRiotEscapeScriptEvents.clear()
}
else
{
	::ZombieRiotEscapeScriptEvents <- {}
}

IncludeScript("zrescape/events", ZombieRiotEscapeScriptEvents)
__CollectGameEventCallbacks(ZombieRiotEscapeScriptEvents)
