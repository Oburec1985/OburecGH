unit uFrmSync;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type

  TFrmSync = class(TForm)
    procedure FormCreate(Sender: TObject);
  public
    init:boolean;
    fCreateProc:TThreadMethod;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
  	procedure ProcNotifyMessage(m:TMessage);
    destructor destroy;override;
  end;

var
  FrmSync:TFrmSync;

const
  WM_PROCNOTIFY = WM_APP + 1;
  WM_CreateFrms = WM_APP + 2;

implementation


{$R *.dfm}

destructor TFrmSync.destroy;
begin
  inherited;
end;

procedure TFrmSync.FormCreate(Sender: TObject);
begin
  if not init then
  begin
    if assigned(fCreateProc) then
    begin
      if GetCurrentThreadId=MainThreadID then
      begin
        init:=true;
        fCreateProc;
      end;
    end;
  end;
end;

procedure TFrmSync.ProcNotifyMessage(m: TMessage);
begin
 	//if GPluginInstance = nil then
  //begin
		m.Result := 0;
  //end
	//else
  begin
    if m.Msg=WM_PROCNOTIFY then
    begin
  		//if TExtRecorderPack(GPluginInstance).ProcessNotify(m.WParam, m.LParam) then
      //m.Result := 1;
    end;
    if m.Msg=WM_CreateFrms then
      FormCreate(nil);
  end;
end;

procedure TFrmSync.WndProc(var Message: TMessage);
begin
  ProcNotifyMessage(Message);
  inherited;
end;

end.
