{
  ==========================================
  XNetDetect v2.1
  Copyright 2007 - 2008, XCRYSoft.com
  -----------------------------------
  Creation date : Dec 13, 2007
  Last updated  : Mar 23, 2007
  -----------------------------------

  ==========================================
  - Releases:
      * v 2.1   - Mar 23, 2008 + better results for modem connections
      * v 2.0   - Dec 14, 2007 + change detecting connectivity strategy due to bad results for some
                                 systems connecting via proxies
                               + new event for getting results of the connection status  
      * v 1.1   - Sep 20, 2007 + apply a thread for checking connection (better performance)
      * v 1.0   - Jul 08, 2007 + events on connect/disconnect to/from Internet
                               + function to check Internet connectivity
  ==========================================
  - Known Bugs:
      * unfortunately MicroSoft WinInet functions' implementations for TimeOut don't work (not even in Vista)
  ==========================================
  - Support:
      * support@xcrysoft.com
      * contact us for any feedback and suggestions, if you find it useful or not
  ==========================================
}
unit XNetDetect_v2;

interface

uses
  Classes, Windows, ExtCtrls, XuConnCheckThread;

type
  TConnectionStatusEvent = procedure(Sender: TObject; isConnected: boolean) of object;

  TXNetDetect = class(TComponent)
  private
    FCheckingIndependent: boolean;
    FConnected: boolean;
    FConnectionLost: boolean;
    
    // unfortunately MicroSoft WinInet functions' implementations for this
    // timeOut don't work (not even in Vista)
    // but maybe we can use it for the next versions of WinInet library
    FTimeOut: Cardinal;

    FUrlCheck: string;

    FTimer: TTimer;
    FOnConnectionStatusChanged: TConnectionStatusEvent;
    FOnConnectionStatus: TConnectionStatusEvent;
    FConnCheckThread: TConnCheckThread;

    procedure OnTimer(Sender: TObject);

    function GetEnabled: boolean;
    procedure SetEnabled(value: boolean);
    function GetTimerInterval: integer;
    procedure SetTimerInterval(value: integer);

  protected
    procedure CheckingFinished(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure CheckIfConnected();
    procedure InitiateCheckingConnection();

  published
    property Connected:boolean read Fconnected;
    property Enabled: boolean read GetEnabled write SetEnabled;
    property TimeOut: Cardinal read FTimeOut write FTimeOut;
    property Interval: Integer read GetTimerInterval write SetTimerInterval;
    property Url: string read FUrlCheck write FUrlCheck;

    property OnConnectionStatusChanged: TConnectionStatusEvent
                                read FOnConnectionStatusChanged write FOnConnectionStatusChanged;
    property OnConnectionStatus: TConnectionStatusEvent
                                read FOnConnectionStatus write FOnConnectionStatus;
  end;

implementation

uses XuNetUtil;

constructor TXNetDetect.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // Let's say the smaller site on the internet to save bandwidth
  // but choose whatever url you want, like Google which is the most reliable
  FUrlCheck := 'http://www.guimp.com/';
              {'http://www.google.com';}
  FTimeOut := 500;

  FTimer := TTimer.Create(Self);
  FTimer.Enabled := false;
  FTimer.OnTimer := OnTimer;

  SetTimerInterval(5000);

  FConnected := false;
  FCheckingIndependent := false;
  if not (csDesigning in ComponentState) then
  begin
    InitiateCheckingConnection();
  end;
  
end;

destructor TXNetDetect.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
end;

function TXNetDetect.GetTimerInterval: integer;
begin
  Result := FTimer.Interval;
end;

procedure TXNetDetect.SetTimerInterval(value: integer);
begin
  if (value > 999) and (value <> FTimer.Interval) then
    FTimer.Interval := value;
end;

function TXNetDetect.GetEnabled: boolean;
begin
  Result := FTimer.Enabled;
end;

procedure TXNetDetect.SetEnabled(value: boolean);
begin
  FTimer.Enabled := Value;
end;

procedure TXNetDetect.InitiateCheckingConnection();
begin
  FCheckingIndependent := true;
  CheckIfConnected();
end;

procedure TXNetDetect.OnTimer(Sender: TObject);
begin
  if not (csDesigning in ComponentState) then
  begin
    FCheckingIndependent := false;
    CheckIfConnected();
  end;
end;

procedure TXNetDetect.CheckIfConnected();
begin
  FConnCheckThread := TConnCheckThread.Create(FUrlCheck, FTimeOut);
  FConnCheckThread.OnTerminate := CheckingFinished;
  FConnCheckThread.Resume;
end;

procedure TXNetDetect.CheckingFinished(Sender: TObject);
var checkInternetConn: boolean;
begin

  FConnected := FConnCheckThread.IsConnected;

  if not FCheckingIndependent then
  begin
    checkInternetConn := FConnCheckThread.IsConnected;
    if checkInternetConn = FConnectionLost then
      if Assigned(FOnConnectionStatusChanged) then
         FOnConnectionStatusChanged(Sender, checkInternetConn);
    FConnectionLost := not checkInternetConn;
  end
  else
  begin
    FConnectionLost := not FConnected;
    if Assigned(FOnConnectionStatus) then
      FOnConnectionStatus(Sender, FConnected);
  end;
end;

end.
