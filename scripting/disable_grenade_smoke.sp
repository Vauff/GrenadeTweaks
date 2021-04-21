#include <sourcemod>
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "Disable Grenade Smoke",
	author = "Vauff",
	description = "Disables the smoke from HE grenades",
	version = "1.0",
	url = "https://github.com/Vauff/disable_grenade_smoke"
};

Handle g_hGetParticleSystemName;

public void OnPluginStart()
{
	if (GetEngineVersion() != Engine_CSGO)
		SetFailState("This plugin only runs on CS:GO!");

	char path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "gamedata/disable_grenade_smoke.games.txt");

	if (!FileExists(path))
		SetFailState("Can't find disable_grenade_smoke.games.txt gamedata");

	Handle gameData = LoadGameConfigFile("disable_grenade_smoke.games");
	
	if (gameData == INVALID_HANDLE)
		SetFailState("Can't find disable_grenade_smoke.games.txt gamedata");

	g_hGetParticleSystemName = DHookCreate(GameConfGetOffset(gameData, "GetParticleSystemName"), HookType_Entity, ReturnType_CharPtr, ThisPointer_Ignore, Hook_GetParticleSystemName);
	DHookAddParam(g_hGetParticleSystemName, HookParamType_Int);
	DHookAddParam(g_hGetParticleSystemName, HookParamType_ObjectPtr);

	CloseHandle(gameData);

	if (!g_hGetParticleSystemName)
		SetFailState("Failed to setup hook for GetParticleSystemName");
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "hegrenade_projectile"))
		DHookEntity(g_hGetParticleSystemName, false, entity);
}

public MRESReturn Hook_GetParticleSystemName(DHookReturn hReturn, DHookParam hParams)
{
	int pointContents;
	pointContents = DHookGetParam(hParams, 1);

	if (pointContents & MASK_WATER)
		DHookSetReturnString(hReturn, "explosion_basic_water");
	else
		DHookSetReturnString(hReturn, "explosion_hegrenade_brief");

	return MRES_Supercede;
}