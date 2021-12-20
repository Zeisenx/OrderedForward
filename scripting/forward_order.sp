
#include <sourcemod>

bool g_lateLoad;
Handle g_fwOnReady;
Handle g_fwOnReadyPost;

enum struct PLInfo
{
	Handle plugin;
	char name[128];
	Function func;
	int rank;
}
enum struct ForwardInfo
{
	Handle owner;
	char name[128];
	ArrayList pluginList;
	PrivateForward fw;
	KeyValues orderKV;
	
	void Init(KeyValues kv)
	{
		this.pluginList = new ArrayList(sizeof(PLInfo));
		this.orderKV = kv;
		
		if (this.orderKV.GotoFirstSubKey()) {
			int rank = 1;
			do {
				this.orderKV.SetNum("rank", rank++);
			}
			while (this.orderKV.GotoNextKey())
			
			this.orderKV.Rewind();
		}
	}
	void AddPlugin(PLInfo plInfo)
	{
		char buffer[128];
		Format(buffer, sizeof(buffer), "%s/rank", plInfo.name);
		plInfo.rank = this.orderKV.GetNum(buffer, 9999);
		
		this.pluginList.PushArray(plInfo, sizeof(plInfo));
	}
}
methodmap ForwardList < ArrayList
{
	public ForwardList()
	{
		return view_as<ForwardList>(new ArrayList(sizeof(ForwardInfo)));
	}
	public int FindForward(PrivateForward fw, ForwardInfo info)
	{
		int len = this.Length;
		for (int i=0; i<len; i++) {
			this.GetArray(i, info, sizeof(info));
			
			if (info.fw == fw)
				return i;
		}
		
		return -1;
	}
	public int FindForwardByKey(const char[] keyName, ForwardInfo info)
	{
		int len = this.Length;
		for (int i=0; i<len; i++) {
			this.GetArray(i, info, sizeof(info));
			
			if (StrEqual(info.name, keyName))
				return i;
		}
		
		return -1;
	}
	public void Reorder()
	{	
		ForwardInfo forwardInfo;
		for (int f=0; f<this.Length; f++) {
			this.GetArray(f, forwardInfo, sizeof(forwardInfo));
			
			PLInfo info1, info2;
			
			int len = forwardInfo.pluginList.Length;
			for (int i=0; i<len; i++) {
				forwardInfo.pluginList.GetArray(i, info1, sizeof(PLInfo));
				for (int k=0; k<len; k++) {
					forwardInfo.pluginList.GetArray(k, info2, sizeof(PLInfo));
					if (info1.rank < info2.rank) {
						forwardInfo.pluginList.SwapAt(i, k);
					}
				}
			}
			
			this.SetArray(f, forwardInfo, sizeof(forwardInfo));
		}
		
		for (int f=0; f<this.Length; f++) {
			this.GetArray(f, forwardInfo, sizeof(forwardInfo));
			
			PLInfo info;
			
			int len = forwardInfo.pluginList.Length;
			for (int i=0; i<len; i++) {
				forwardInfo.pluginList.GetArray(i, info, sizeof(PLInfo));
				forwardInfo.fw.RemoveFunction(info.plugin, info.func);
			}
			
			for (int i=0; i<len; i++) {
				forwardInfo.pluginList.GetArray(i, info, sizeof(PLInfo));
				forwardInfo.fw.AddFunction(info.plugin, info.func);
			}
		}
	}
}
ForwardList g_forwardList;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("forward_order");
	
	CreateNative("OrderForward.OrderForward", Native_OrderForward);
	CreateNative("OrderForward.fw.get", Native_PrivateForward_Get);
	CreateNative("OrderForward.RequestFunc", Native_AddPlugin);
	CreateNative("FO_FindForward", Native_FindForward);
	
	g_fwOnReady = CreateGlobalForward("FO_OnReady", ET_Ignore);
	g_fwOnReadyPost = CreateGlobalForward("FO_OnReadyPost", ET_Ignore);
	
	g_lateLoad = late;
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	g_forwardList = new ForwardList();
}

public void OnAllPluginsLoaded()
{
	Call_StartForward(g_fwOnReady);
	Call_Finish();
	
	Call_StartForward(g_fwOnReadyPost);
	Call_Finish();
	
	g_forwardList.Reorder();
}

public int Native_OrderForward(Handle plugin, int numParams)
{
	ForwardInfo info;
	PrivateForward fw = GetNativeCell(1);
	GetNativeString(2, info.name, sizeof(ForwardInfo::name));
	KeyValues orderKV = GetNativeCell(3);
	
	info.owner = plugin;
	info.fw = fw;
	info.Init(orderKV);
	
	g_forwardList.PushArray(info, sizeof(ForwardInfo));
	
	return GetNativeCell(1);
}

public int Native_PrivateForward_Get(Handle plugin, int numParams)
{
	PrivateForward fw = GetNativeCell(1);
	
	ForwardInfo forwardInfo;
	int idx = g_forwardList.FindForward(fw , forwardInfo);
	
	return view_as<int>(forwardInfo.fw);
}

public int Native_AddPlugin(Handle plugin, int numParams)
{
	PrivateForward fw = GetNativeCell(1);
	Function func = GetNativeFunction(2);
	
	ForwardInfo forwardInfo;
	int idx = g_forwardList.FindForward(fw, forwardInfo);
	
	PLInfo info;
	info.plugin = plugin;
	info.func = func;
	GetPluginFilename(plugin, info.name, sizeof(info.name));
	forwardInfo.AddPlugin(info);
	
	g_forwardList.SetArray(idx, forwardInfo, sizeof(forwardInfo));
	
	return 0;
}

public int Native_FindForward(Handle plugin, int numParams)
{
	char keyName[128];
	GetNativeString(1, keyName, sizeof(keyName));
	
	ForwardInfo forwardInfo;
	g_forwardList.FindForwardByKey(keyName, forwardInfo);
	
	return view_as<int>(forwardInfo.fw);
}
