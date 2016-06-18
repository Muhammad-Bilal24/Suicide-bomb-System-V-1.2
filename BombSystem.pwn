//==============================includes ======================================//
#include <a_samp>
#include <foreach>
#include <zcmd>
#include <sscanf2>
//================================Define ======================================//
#define SCM 	 			SendClientMessage
#define SCMToAll 			SendClientMessageToAll
#define SetPlayerHoldingObject(%1,%2,%3,%4,%5,%6,%7,%8,%9) SetPlayerAttachedObject(%1,MAX_PLAYER_ATTACHED_OBJECTS-1,%2,%3,%4,%5,%6,%7,%8,%9)
#define StopPlayerHoldingObject(%1) RemovePlayerAttachedObject(%1,MAX_PLAYER_ATTACHED_OBJECTS-1)
#define IsPlayerHoldingObject(%1) IsPlayerAttachedObjectSlotUsed(%1,MAX_PLAYER_ATTACHED_OBJECTS-1)
//================================Color ======================================//
#define 	COLOR_YELLOW	0xFFFF00AA
#define     	COLOR_GREEN     0x33AA33AA
#define     	COLOR_RED 		0xFF4500AA
#define 	COL_WHITE       "{FFFFFF}"
#define 	COL_GREY        "{C3C3C3}"
//==============================Varaibles=====================================//
new Bomb[MAX_PLAYERS][3];
new Float:Pos[MAX_PLAYERS][3];
new pObject[MAX_PLAYERS][2];
new Timer[MAX_PLAYERS];
new RANGE;
new RandomCash[] = {1000,1500,2000,1200,800};
new BUTTON_PUSHED[MAX_PLAYERS];
new EXPLODE_BOMB[MAX_PLAYERS];
new EXPLODE_TIMER[MAX_PLAYERS];
new CountDown[MAX_PLAYERS];
new BOMB_OBJECT[MAX_PLAYERS];
new Text3D:BOMB_CD[MAX_PLAYERS];


public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" BombSystem Un Loaded					");
	print(" Created By Muhammad Bilal				");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	foreach(Player,i)
	{
		Bomb[i][0] = 0;
		Bomb[i][1] = 0;
		Bomb[i][2] = 0;
		BUTTON_PUSHED[i] = 0;
		Delete3DTextLabel(BOMB_CD[i]);
		KillTimer(EXPLODE_TIMER[i]);
		KillTimer(EXPLODE_BOMB[i]);
		DestroyObject(BOMB_OBJECT[i]);
	}
	print("\n--------------------------------------");
	print(" BombSystem Un Loaded					");
	print(" Created By Muhammad Bilal				");
	print("--------------------------------------\n");
	return 1;
}

public OnPlayerConnect(playerid)
{
	SCM(playerid,-1,"[SYSTEM]: Bomb System successfully Loaded created by Muhammad Bilal.");
	Bomb[playerid][0] = 0;
	Bomb[playerid][1] = 0;
	Bomb[playerid][2] = 0;
	BUTTON_PUSHED[playerid] = 0;
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_YES && !BUTTON_PUSHED[playerid])
	{
		if(Bomb[playerid][0])
		{
			if(IsPlayerInAnyVehicle(playerid))return SCM(playerid,COLOR_YELLOW,"You're not allowed to use this bomb using any vehicle.");
            		BUTTON_PUSHED[playerid] = 1;
            		CountDown[playerid] = 10;
			GetPlayerPos(playerid, Pos[playerid][0], Pos[playerid][1], Pos[playerid][2]);
			StopPlayerHoldingObject(playerid);
			BOMB_OBJECT[playerid] = CreateObject(1210, Pos[playerid][0], Pos[playerid][1], Pos[playerid][2]-0.8, 0, 0, 4);
	  		BOMB_CD[playerid] = Create3DTextLabel("Bomb Created",COLOR_RED , Pos[playerid][0], Pos[playerid][1], Pos[playerid][2],40.0,0);
			SCM(playerid, COLOR_GREEN, "Warning: You need to run away from the range of the bomb.");
            		EXPLODE_TIMER[playerid]= SetTimerEx("OnPlayerBombCountdown",1000,1,"i",playerid);
			EXPLODE_BOMB[playerid] = SetTimerEx("OnPlayerUseRemote",10000,0,"i",playerid);
		}
		if(Bomb[playerid][1])
		{
			if(IsPlayerInAnyVehicle(playerid))return SCM(playerid,COLOR_YELLOW,"You're not allowed to use this bomb using any vehicle.");
		    	new count = 0,str[128];
			GetPlayerPos(playerid, Pos[playerid][0], Pos[playerid][1], Pos[playerid][2]);
   			CreateExplosion(Pos[playerid][0], Pos[playerid][1], Pos[playerid][2] , 12, 0.0);
			Bomb[playerid][1] = 0;
			RemovePlayerAttachedObject(playerid,9);
			foreach(Player, i)
			{
					if(IsPlayerInRangeOfPoint(i, RANGE, Pos[playerid][0], Pos[playerid][1], Pos[playerid][2]))
					{
                            				AppliedBombEffect(i);
							if( i != playerid   )
							{
								count++;
							}
					}
			}
			if(count > 0)
			{
				new Random = RandomCash[random(5)];
				GivePlayerMoney(playerid,Random);
				format(str, sizeof(str), "[NEWS ALERT]: "COL_GREY"-| %d peoples are killed in the suicide bomb attack by suicide bomber %s in San Andreas.|-",count,GetName(playerid));
				SCMToAll(COLOR_RED,str);
			}
		}
	}
	if((newkeys & KEY_CROUCH || newkeys & KEY_SECONDARY_ATTACK) && Bomb[playerid][2])
	{
	    new count = 0 , str[128];
		if(!IsPlayerInAnyVehicle(playerid))return SCM(playerid,COLOR_YELLOW,"You're not in any vehicle.");
  		GetPlayerPos(playerid, Pos[playerid][0], Pos[playerid][1], Pos[playerid][2]);
        	CreateExplosion(Pos[playerid][0], Pos[playerid][1], Pos[playerid][2] , 12, 0.0);
		Bomb[playerid][2] = 0;
		foreach(Player,i)
		{
			if( i != playerid )
			{
				if(IsPlayerInRangeOfPoint(i, RANGE, Pos[playerid][0], Pos[playerid][1], Pos[playerid][2]))
				{
						AppliedBombEffect(i);
						count++;
				}
			}
		}
		if(count > 0)
		{
			new Random = RandomCash[random(5)];
			GivePlayerMoney(playerid,Random);
			format(str, sizeof(str), "[NEWS ALERT]: "COL_GREY"-| %d peoples are killed in the suicide vehicle bomb attack in San Andreas.|-",count );
			SCMToAll(COLOR_RED,str);
		}
	}
	return 1;
}

AppliedBombEffect(playerid)
{
	GetPlayerPos(playerid,Pos[playerid][0], Pos[playerid][1], Pos[playerid][2]);
 	pObject[playerid][0] = CreateObject(18668, Pos[playerid][0], Pos[playerid][1], Pos[playerid][2],0.0,0.0, 0.0);
 	pObject[playerid][1] = CreateObject(18682, Pos[playerid][0], Pos[playerid][1], Pos[playerid][2],0.0,0.0, 0.0);
	SetPlayerAttachedObject(playerid, 0, 2906, 5, -0.2, 0.0, 0.0, 0, 0.0, -90, 1.0, 1.0, 1.0);
	SetPlayerAttachedObject(playerid, 1, 2906, 6, -0.2, 0.0, 0.0, 0, 345, 270, 1.0, 1.0, 1.0);
	SetPlayerAttachedObject(playerid, 2, 2908, 2, 0.05,0.06, 0.0, 180, 0.0, 90, 1.1, 1.1, 1.1);
	SetPlayerAttachedObject(playerid, 3, 2905, 12, 0.1, 0.05, 0.0, 0.0, 0.0, -70, 1.0, 1.0, 1.0);
	OnPlayerUseRandomAnim(playerid);
 	OnPlayerDrunkLevel(playerid);
	Timer[playerid] = SetTimerEx("OnPlayerDeathEx",8000,0,"i",playerid);
}

GetName(playerid)
{
	new Name[MAX_PLAYER_NAME];
	GetPlayerName(playerid,Name,MAX_PLAYER_NAME);
	return Name;
}

forward OnPlayerDeathEx(playerid);
public OnPlayerDeathEx(playerid)
{
	DestroyObject(pObject[playerid][0]);
	DestroyObject(pObject[playerid][1]);
	SetPlayerHealth(playerid,0);
	KillTimer(Timer[playerid]);
	return 1;
}

OnPlayerUseRandomAnim(playerid)
{
	new Random = random(4);
	switch(Random)
	{
		case 0:ApplyAnimation(playerid, "SWEET","Sweet_injuredloop", 4.0, 1, 0, 0, 0, 0);
		case 1:ApplyAnimation(playerid, "KNIFE","KILL_Knife_Ped_Die",4.1,0,1,1,1,1);
		case 2:ApplyAnimation(playerid, "PED","KO_skid_front",4.1,0,1,1,1,0);
		case 3:ApplyAnimation(playerid, "PED","WALK_DRUNK",4.1,1,1,1,1,1);
	}
}

OnPlayerDrunkLevel(playerid)
{
	new Random = random(10);
	switch(Random)
	{
		case 0:SetPlayerDrunkLevel (playerid, 5000);
		case 1:SetPlayerDrunkLevel (playerid, 8000);
		case 2:SetPlayerDrunkLevel (playerid, 12000);
		case 3:SetPlayerDrunkLevel (playerid, 16000);
		case 4:SetPlayerDrunkLevel (playerid, 20000);
		case 5:SetPlayerDrunkLevel (playerid, 25000);
		case 6:SetPlayerDrunkLevel (playerid, 30000);
		case 7:SetPlayerDrunkLevel (playerid, 35000);
		case 8:SetPlayerDrunkLevel (playerid, 50000);
		case 9:SetPlayerDrunkLevel (playerid, 40000);
	}
}

forward OnPlayerBombCountdown(playerid);
public OnPlayerBombCountdown(playerid)
{
		new Rstr[128];
		switch(CountDown[playerid])
		{
			case 1..10:
			{
			format(Rstr, sizeof(Rstr),"~y~Briefcase~n~~r~Exploding~n~In~n~~y~Time Left ~n~~b~%d",CountDown[playerid]);
			GameTextForPlayer(playerid,Rstr,1000,5);
   			format(Rstr,sizeof(Rstr),"Bomb Exploding\nTime Left\n  "COL_WHITE"%d",CountDown[playerid]);
            		Update3DTextLabelText(BOMB_CD[playerid], COLOR_RED, Rstr);
			PlayerPlaySound(playerid, 4203, 0.0, 0.0, 0.0);
			}
	  	}
  		CountDown[playerid]--;
 		return 1;
}

forward OnPlayerUseRemote(playerid);
public OnPlayerUseRemote(playerid)
{
	new count = 0,str[128];
	Bomb[playerid][0] = 0;
	BUTTON_PUSHED[playerid] = 0;
    	CreateExplosion(Pos[playerid][0], Pos[playerid][1], Pos[playerid][2] , 12, 0.0);
	Delete3DTextLabel(BOMB_CD[playerid]);
	DestroyObject(BOMB_OBJECT[playerid]);
	KillTimer(EXPLODE_TIMER[playerid]);
	KillTimer(EXPLODE_BOMB[playerid]);
	foreach(Player, i)
	{
		if(IsPlayerInRangeOfPoint(i, RANGE, Pos[playerid][0], Pos[playerid][1], Pos[playerid][2]))
		{
			AppliedBombEffect(i);
			count++;
		}
	}
	if(count > 0)
	{
		new Random = RandomCash[random(5)];
		GivePlayerMoney(playerid,Random);
		format(str, sizeof(str), "[NEWS ALERT]:"COL_GREY" -| %d peoples are killed in the suicide remote bomb attack in San Andreas.|-",count );
		SCMToAll(COLOR_RED,str);
	}
	return 1;
}

CMD:bombhelp(playerid,params[])
{
	SCM(playerid, COLOR_GREEN, "[ BOMB HELP MENU ]");
	SCM(playerid, COLOR_GREEN, "Use /sbbomb [Range 1 - 30]");
	SCM(playerid, COLOR_GREEN, "Use /sjbomb [Range 1 - 30]");
	SCM(playerid, COLOR_GREEN, "Press Y key to use Suicide bomb.");
	SCM(playerid, COLOR_GREEN, "Use /cbomb [ To use suicide car bomb ]");
	SCM(playerid, COLOR_GREEN, "Press H key in car to blow car.");
	return 1;
}

CMD:sbbomb(playerid,params[])
{
	if(IsPlayerInAnyVehicle(playerid))return SCM(playerid,COLOR_YELLOW,"You're not allowed to use this bomb using any vehicle.");
	if(Bomb[playerid][1] == 1 || Bomb[playerid][2] == 1)return SCM(playerid,-1,"[SYSTEM] : You're already have bombs! You can't use this bomb at this moment.");
	if(Bomb[playerid][0])return SCM(playerid,-1,"[SYSTEM] : You're already have bomb.");
	if(sscanf(params,"d",RANGE))return SCM(playerid,COLOR_YELLOW,"/sbbomb [Range 1 - 30]");
	if(RANGE < 1 || RANGE > 30)return SCM(playerid,COLOR_YELLOW,"Range must between 1 to 30.");
	SetPlayerHoldingObject(playerid, 1210, 6,0.3,0.1,0,0,-90,0);
	Bomb[playerid][0] = 1;
	SCM(playerid, COLOR_GREEN, "You successfully got suicide bomb! Press Y key to use Suicide bomb.");
	return 1;
}

CMD:sjbomb(playerid,params[])
{
	if(IsPlayerInAnyVehicle(playerid))return SCM(playerid,COLOR_YELLOW,"You're not allowed to use this bomb using any vehicle.");
	if(Bomb[playerid][0] == 1 || Bomb[playerid][2] == 1)return SCM(playerid,-1,"[SYSTEM] : You're already have bombs! You can't use this bomb at this moment.");
	if(Bomb[playerid][1])return SCM(playerid,-1,"[SYSTEM] : You're already have bomb.");
	if(sscanf(params,"d",RANGE))return SCM(playerid,COLOR_YELLOW,"/sbomb [Range 1 - 30] ");
	if(RANGE < 1 || RANGE > 30)return SCM(playerid,COLOR_YELLOW,"Range must between 1 to 30.");
	SetPlayerAttachedObject(playerid,9, 19142, 1, 0.112397, 0.049958, -0.001576, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000,0xFF00FF00);
	Bomb[playerid][1] = 1;
	SCM(playerid, COLOR_GREEN, "You successfully got suicide bomb! Press Y key to use Suicide bomb.");
	return 1;
}

CMD:cbomb(playerid,params[])
{
	if(!IsPlayerInAnyVehicle(playerid))return SCM(playerid,COLOR_YELLOW,"You're not in any vehicle.");
	if(Bomb[playerid][0] == 1 || Bomb[playerid][1] == 1)return SCM(playerid,-1,"[SYSTEM] : You're already have bombs! You can't use this bomb at this moment.");
	if(Bomb[playerid][2])return SCM(playerid,-1,"[SYSTEM] : You're already have bomb.");
	if(sscanf(params,"d",RANGE))return SCM(playerid,COLOR_YELLOW,"/cbomb [Range [1 - 30]");
	if(RANGE < 1 || RANGE > 30)return SCM(playerid,COLOR_YELLOW,"Range must between 1 to 30.");
	Bomb[playerid][2] = 1;
	SCM(playerid, COLOR_GREEN, "You successfully got suicide car bomb! Press H key in car to use Suicide car bomb.");
	return 1;
}

