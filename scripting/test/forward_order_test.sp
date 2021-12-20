
#include <sourcemod>
#include <sdkhooks>
#include <forward_order>

OrderForward g_fwTest;

public void OnPluginStart()
{
	for (int i=1; i<=MaxClients; i++)
		if (IsClientInGame(i)) OnClientPutInServer(i);
}

public void FO_OnReady()
{
	KeyValues kv = new KeyValues("test");
	kv.ImportFromFile("addons/sourcemod/data/test_order.kv");
	
	g_fwTest = new OrderForward(CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell), "OnTakeDamage", kv);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	Call_StartForward(g_fwTest.fw);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_PushCell(inflictor);
	Call_PushFloat(damage);
	Call_PushCell(damagetype);
	Call_Finish();
}