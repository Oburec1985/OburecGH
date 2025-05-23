
unit uFrmSync;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uRecorderEvents;

type
  // ����� ��� ������������� ��������� Recorder � MainThread
  TFrmSync = class(TForm)
    procedure FormCreate(Sender: TObject);
  public
    createThreadId:cardinal;
  protected
    fenterdestroy:boolean;
  private
    // ���������� �� ����������� �� ��������� SwitchToMainThread
    procedure ProcNotifyFrmCreate(sender:tobject);
  protected
    procedure WndProc(var Message: TMessage); override;
  public
  	procedure ProcNotifyMessage(m:TMessage);
    destructor destroy;override;
  end;

const
  WM_PROCNOTIFY = WM_APP + 1;
  WM_CreateFrms = WM_APP + 2;
  WM_ShowModalSettingsFrm = WM_APP + 3;

implementation
uses
  PluginClass,
  uCreateComponents;

{$R *.dfm}

destructor TFrmSync.destroy;
begin
  //exit;
  fenterdestroy:=true;
  if GetCurrentThreadId=MainThreadID then
  begin
    uCreateComponents.destroyForms();
  end
  else
  if GetCurrentThreadId<>createThreadId then
  begin
    //showmessage('TFrmSync.destroy GetCurrentThreadId<>createThreadId');
  end;
  inherited;
end;

procedure TFrmSync.ProcNotifyFrmCreate(sender:tobject);
begin
//----------- �� ������ �� error 5
  createForms;
  TExtRecorderPack(GPluginInstance).EList.CallAllEvents(c_RCreateFrmInMainThread);
end;

procedure TFrmSync.FormCreate(Sender: TObject);
begin
  fenterdestroy:=false;
  // ---------------
  // OnCreate ������� �����
end;

procedure TFrmSync.ProcNotifyMessage(m: TMessage);
var
  obj:tobject;
begin
 	if GPluginInstance = nil then
  begin
		m.Result := 0;
  end
	else
  begin
    if m.Msg=WM_PROCNOTIFY then
    begin
      // ������� �� 03.09.19 �.�. ����� ��� ������� ���������� ������ (1 ��� � ������ ���������, ������ � UI) ProcessNotify
  		//if TExtRecorderPack(GPluginInstance).ProcessNotify(m.WParam, m.LParam) then
      //  m.Result := 1;
    end;
    if m.Msg=WM_CreateFrms then
      ProcNotifyFrmCreate(nil);
    if m.Msg=WM_ShowModalSettingsFrm then
    begin
      obj:=tobject(m.WParam);
      if obj is tForm then
      begin
        tform(obj).FormStyle:=fsStayOnTop;
        tform(obj).showmodal;
      end;
    end;
  end;
end;

procedure TFrmSync.WndProc(var Message: TMessage);
begin
  if not fenterdestroy then
  begin
    ProcNotifyMessage(Message);
    inherited;
  end;
end;

end.
