unit uTurbineFrame;

interface

uses
  Windows, Classes, Forms,  StdCtrls, Controls, uBldObj, ImgList, ToolWin,
  ComCtrls, uBldEng, ExtCtrls, DCL_MYOWN, uBaseObjPropertyFrame,
  uTurbina, uStageFrame, uBaseObjService, uEventList, uframeevents;

type
  TTurbineFrame = class(TFrame)
    TurbinePropGB: TGroupBox;
    StageCountLabel: TLabel;
    CfgLabel: TLabel;
    StageCountIE: TIntEdit;
    CfgTV: TTreeView;
    RecentFileEdit: TEdit;
    RecentFileLabel: TLabel;
    procedure CfgTVChange(Sender: TObject; Node: TTreeNode);
  public
    events:ceventlist;
  private
    eng:cBldEng;
  protected
    procedure showcfg(obj:cbldobj);
  public
    procedure LincToEng(p_eng:cBldEng);
    //  ���������� �������� ������� � �����
    procedure GetObj(obj:cbldobj);
    //  ��������� �������� ������� �� ������ � ������
    procedure SetObj(obj:cbldobj);
  end;



implementation

{$R *.dfm}

procedure TTurbineFrame.LincToEng(p_eng:cBldEng);
begin
  eng:=p_eng;
end;

//  ���������� �������� ������� � �����
procedure TTurbineFrame.CfgTVChange(Sender: TObject; Node: TTreeNode);
begin
  if events<>nil then
  begin
    // ���������� ��� ������ ������ ����
    events.CallAllEventsWithSender(SelectStageEvent,node.data);
  end;
end;

procedure TTurbineFrame.GetObj(obj:cbldobj);
begin
  if eng=nil then
    eng:=obj.eng;
  if obj<>nil then
  begin
    RecentFileEdit.Text:=eng.lastfile;
    StageCountIE.IntNum:=cturbine(obj).StageCount;
  end
  else
  begin
    RecentFileEdit.Text:='';
    StageCountIE.IntNum:=0;
  end;
  showcfg(obj);
end;

//  ��������� �������� ������� �� ������ � ������
procedure TTurbineFrame.SetObj(obj:cbldobj);
begin
  eng.lastfile:=RecentFileEdit.Text;
end;

procedure TTurbineFrame.showcfg(obj:cbldobj);
begin
  CfgTV.Items.Clear;
  if obj<>nil then
  begin
    cfgTV.Images:=obj.images;
    showInTreeView(CfgTV, obj);
  end;
end;



end.
