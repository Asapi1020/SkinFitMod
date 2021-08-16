// ===================================================
//  Skin Fit Game
// ---------------------------------------------------
//  To enjoy trying on various weapon skins
// ===================================================

class SkinFitGame extends KFGameInfo_Survival;

//  Initialize Section
event InitGame(string Options, out string ErrorMessage)
{
    super.InitGame(Options, ErrorMessage);
}

function StartMatch()
{
    local int i;

    super.StartMatch();

    DisplayInstruction();
    LogDiscription();

    GotoState('TraderOpen');
    for (i = 0; i < TraderList.Length; i++)
    {
        TraderList[i].OpenTrader();
    }
    MyKFGRI.OpenTrader();
    MyKFGRI.OpenedTrader.HideTraderPath();
    RichStart();
}

State TraderOpen
{
    function BeginState( Name PreviousStateName )
    {
        super.BeginState( PreviousStateName );
        ClearTimer('CloseTraderTimer');
        MyKFGRI.bStopCountDown = !MyKFGRI.bStopCountDown;
    }
}

//  Broadcast Section
//  Control Chat Commands
event Broadcast(Actor Sender, coerce string Msg, optional name Type)
{
    local string MsgHead,MsgBody;
    local array<String> splitbuf;
    local name Stage;
    local SF_PlayerController SFPC;

    super.Broadcast(Sender, Msg, Type);

    if ( Type == 'Say' ){
        SFPC = SF_PlayerController(KFPlayerController(Sender));
        Msg = Locs(Msg);
        ParseStringIntoArray(Msg,splitbuf," ",true);
        if(splitbuf.length < 2) splitbuf.length = 2;
        MsgHead = splitbuf[0];
        MsgBody = splitbuf[1];

        if(SFPC.bNowChatting) SFPC.PlayerResponse = Msg;

        if(MsgHead == "!ss"){
            if(MsgBody == "") Stage = 'SkinSelect';
            InitConversation(SFPC, Stage);
        }
        else if(Msg == "!ot") CC_OpenTrader(KFPlayerController(Sender));
        else if(Msg == "!exit") SFPC.EndConversation();
    }
}

//  Message Sender for chat boxes (everyone)
function BroadcastEcho( string MsgStr, optional name TextColorName='00FF0A' )
{
    local KFPlayerController PC;
    
    foreach WorldInfo.AllControllers(class'KFPlayerController', PC)
    {
        BroadcastPersonalEcho(MsgStr, PC, TextColorName);
    }
}

//  Message Sender for chat boxes (Specific player)
function BroadcastPersonalEcho( string MsgStr, KFPlayerController KFPC, optional name TextColorName='00FF0A' )
{
    BroadcastHandler.BroadcastText( None, KFPC, MsgStr, TextColorName );
}
//  Message Sender for console screens
function LogToConsole( string Msg ){
    BroadcastEcho(Msg, 'Console');
}

function DisplayInstruction()
{
    BroadcastEcho("(See Console)");
}

//  How to play
function LogDiscription(){
    LogToConsole("---How to use this Skin Fit Mod---" $"\n"$
                 "1. Buy a weapon." $"\n"$
                 "  All trader pods are open and you can open trader menu by hitting \"!ot\" in a chat box." $"\n"$
                 "2. Start to search skins." $"\n"$
                 "  Hit \"!ss\" in a chat box so you can see a skin list available." $"\n"$
                 "3. Hit number." $"\n"$
                 "  When some errors prevent you from trying, you can initialize by hitting \"!exit\"." $"\n"$
                 "  This mod is beta. If you cannot use functions even after initializing, please relaunch a map.");
}

//  Prepare for conversation
function InitConversation(SF_PlayerController SFPC, name StageName)
{
    if(SFPC.bNowChatting)
    {
        SFPC.InitialMsg('FailedToStart');
        return;
    }

    SFPC.InitialMsg(StageName);

    SFPC.PlayerResponse = "";
    SFPC.ConversationStage = StageName;
    SFPC.bNowChatting = true;
    SFPC.StartConversation();
}

//  OpenTrader
function CC_OpenTrader(KFPlayerController KFPC)
{
    KFPC.OpenTraderMenu();
}

//  ImRich
function RichStart()
{
    local KFPlayerReplicationInfo KFPRI;
    local KFPlayerController KFPC;
    foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
    {
        KFPRI = KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo);
        if ( KFPRI != None )
        {
            KFPRI.AddDosh( 1000000 );
        }   
    }
}

defaultproperties
{
    PlayerControllerClass = class'SkinFit.SF_PlayerController'
}