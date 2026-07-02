unit XuConnCheckThread;

interface

uses
  Classes;

type
  TConnCheckThread = class(TThread)
  private
    FHost: string;
    FTimeOut: Cardinal;
    FIsConnected: boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(host: string; timeOut: Cardinal);
    property IsConnected: boolean read FIsConnected;
  end;

implementation

uses XuNetUtil;

{ TConnCheckThread }

constructor TConnCheckThread.Create(host: string; timeOut: Cardinal);
begin
  inherited Create(true);
  FreeOnTerminate := true;
  FHost := host;
  FTimeOut := timeOut;
end;

procedure TConnCheckThread.Execute;
begin
  FIsConnected := IsConnectedToInternet(FHost, FTimeOut);
end;

end.
 