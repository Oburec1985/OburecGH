unit uCreateNotifyProcess;
// ����� ������������� ������������ ��������� �����������

interface

uses
  types, ActiveX, forms, sysutils, windows, Classes, IniFiles, Dialogs,
  uCompMng, cfreg, uRecorderEvents, PluginClass, tags, Recorder, uRCFunc,
  Generics.Collections, Controls, uRecBasicFactory, uMainFrm, uMyRecorderUtils,
  blaccess, uAlarms, Graphics, SyncObjs;

type
  cTagPropNP = class(cNonifyProcessor)
  protected
    m_PictBtnMainFramePtr : ipicture;
    m_btnID  : cardinal;
    ini_path : string;
  protected
    procedure doAddParentList;override;
    procedure doCreateFrm(sender:tobject);
    procedure doUpdateTags(Sender: TObject);
    procedure doStatusNONE(Sender: TObject);
    procedure CreateEvents;
    procedure DestroyEvents;
  public
    constructor create;
    destructor destroy;override;
    function ProcessBtnClick(pMsgInfo:PCB_MESSAGE): boolean;override;
    procedure ReadUserProperties(FilePatch:string);  // ������ �������� �� �����
    procedure WriteUserProperties(FilePatch:string); // ��������� �������� � ����
  end;

var
  // VSN_USER = 28672
  v_NotifyGORN: Integer = VSN_USER + 102;

  m_pMasterWnd_ins : TRecFrm;

const
  c_Pic  = 'GORN';
  c_Name = '������ ����';

  c_plugin_defXSize = 192; // �������������� ������� ������ ��� ��������
  c_plugin_defYSize = 155;

implementation

// -----------------------------------------------------------------------------
procedure cTagPropNP.doAddParentList;
//var
//  str, str1 : string;
begin
  // ��������� ������ � ��������� ����������
  {m_PictBtnMainFramePtr := LoadPicFromRes('Detector');
  str  := '������������� ������� ���';
  str1 := '������������� ������� ���';
  TExtRecorderPack(GPluginInstance).m_CompMng.m_BtnMainFrame.AddButton(m_PictBtnMainFramePtr,
                                m_PictBtnMainFramePtr,
                                m_PictBtnMainFramePtr,
                                m_PictBtnMainFramePtr,
                                pAnsiChar(@str1[1]), @str[1], GPluginInstance, m_btnID);
  //m_CompMng.m_BtnMainFrame.EnableButton(m_btnMainFrameID, TRUE);

  CreateEvents;}
end;

procedure cTagPropNP.CreateEvents;
begin
  //TExtRecorderPack(GPluginInstance).EList.AddEvent('Create RecorderMenuClear Form', c_RCreateFrmInMainThread, doCreateFrm);
  //TExtRecorderPack(GPluginInstance).EList.AddEvent('DataUpdate_KompensDDI', c_RUpdateData, doUpdateTags);
  //TExtRecorderPack(GPluginInstance).EList.AddEvent('StatusToNONE_KompensDDI', c_RC_ChangeState, doStatusNONE);
end;

procedure cTagPropNP.DestroyEvents;
begin
  //TExtRecorderPack(GPluginInstance).EList.removeEvent(doCreateFrm,  c_RCreateFrmInMainThread);
  //TExtRecorderPack(GPluginInstance).EList.removeEvent(doUpdateTags, c_RCreateFrmInMainThread);
  //TExtRecorderPack(GPluginInstance).EList.removeEvent(doStatusNONE, c_RCreateFrmInMainThread);
end;

procedure cTagPropNP.doCreateFrm(sender:tobject);
begin
  //if GetCurrentThreadId=MainThreadID then
  //SettingsFrm := TSettingsFrm.Create(nil);

  //SettingsFrm.GetRecorderTags;  // �������� ������ ����� ���������
  //ReadUserProperties(ini_path); // ������������� ��������� �������� ����� �� �����
end;

constructor cTagPropNP.create;
begin
  // �������� ���� � ����� �� ����������
  //ini_path := ExtractFileDrive(GetCurrentDir) + '\mera files\recorder\IVPDDI.ini';
  inherited;
end;

destructor cTagPropNP.destroy;
begin
  //WriteUserProperties(ini_path); // ���������� ��������� �������� ����� � ����

  // ����������� ������
  //SettingsFrm.destroy;
  //SettingsFrm := nil;

  inherited;
end;

//-- ��������� �� ��������� ����� ----------------------------------------------
procedure cTagPropNP.doUpdateTags;
begin
  //
end;

//-- ��������� �� ��������� ��������� ------------------------------------------
procedure cTagPropNP.doStatusNONE;
begin
  //
end;

//-- ������������ ������� �� ������ --------------------------------------------
function cTagPropNP.ProcessBtnClick(pMsgInfo:PCB_MESSAGE): boolean;
begin
  //
  result := true;
end;

//-- ������ ���� ������ ���� ---------------------------------------------------
function ReadBlockData(ind : integer; mode : integer) : boolean;
begin
  //
  result := true;
end;

//-- ����� ���� ������ ���� ----------------------------------------------------
function WriteBlockData(ind : integer) : boolean;
begin
  //
  result := true;
end;

//-- ������ �������� �� ����� --------------------------------------------------
procedure cTagPropNP.ReadUserProperties(FilePatch:string);
begin
  //
end;

//-- ��������� �������� � ���� -------------------------------------------------
procedure cTagPropNP.WriteUserProperties(FilePatch:string);
begin
  //
end;

// -------------------------------------------------------------------------
// ������� � ������� ����������� ������
initialization

finalization

end.
