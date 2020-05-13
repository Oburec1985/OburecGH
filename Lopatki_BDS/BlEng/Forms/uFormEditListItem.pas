// ����� ������������ ��� ������  ListItem-�� ������� ������������� � �����
// uAddConstForm
unit uFormEditListItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN,
  ExtCtrls,
  ComCtrls,
  uBtnListView,
  ubldservice,
  ubldfile;

type
  TFormEditListItem = class(TForm)
    Bevel1: TBevel;
    NameEdit: TEdit;
    Label1: TLabel;
    Label6: TLabel;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    DeleteBtn: TButton;
    Label2: TLabel;
    ChanNumberIntEdit: TIntEdit;
    OffsetFloatEdit: TFloatEdit;
    Label3: TLabel;
    Label4: TLabel;
    SensorTypeComboBox: TComboBox;
    Label5: TLabel;
    StageComboBox: TComboBox;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    // ��������� ���������� TListItem ������� �����
    procedure FillListItem(var li:TListItem;var lv:TBtnListView);
    // ��������� ����� ������� ListItem-�
    procedure FillFormFromLI(const li:TListItem;var lv:TBtnListView);
    { Private declarations }
  public
    // ��������� ���������� ��� ������
    procedure UpdateComboBox(bldfile:cbldfilegen);
    // ��������� - ������� ����?
    function ShowModal(var li:TListItem;var lv:TBtnListView):integer;
    { Public declarations }
  end;

var
  FormEditListItem: TFormEditListItem;

implementation
  uses
    uAddConstForm;
{$R *.dfm}

// ��������� ���������� TListItem ������� �����
procedure TFormEditListItem.FillListItem(var li:TListItem;var lv:TBtnListView);
var str:string;
begin
    // ������� ��� �������
    lv.SetSubItemByColumnName(ColSensorName,NameEdit.Text,li);
    // ���������� ������ �������
    lv.SetSubItemByColumnName(ColChanNumber,ChanNumberIntEdit.Text,li);
    // �������� �������
    lv.SetSubItemByColumnName(ColSensorPos,OffsetFloatEdit.Text,li);
    // ��� �������
    lv.SetSubItemByColumnName(ColType,SensorTypeComboBox.Text,li);
end;

procedure TFormEditListItem.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    // �������� ���������� �� ������ ���������
    48:sendmessage(ApplyBtn.Handle,wm_lbuttondown,0,0);
  end;
end;

procedure TFormEditListItem.FillFormFromLI(const li:TListItem;var lv:TBtnListView);
var str:string;
begin
    // ������� ��� �������
    if lv.GetSubItemByColumnName(ColSensorName,li,str) then
      NameEdit.Text:=str
    else
      NameEdit.Text:='';
    // ����� ������
    if lv.GetSubItemByColumnName(ColChanNumber,li,str) then
      ChanNumberIntEdit.Text:=str
    else
      ChanNumberIntEdit.Text:='';
    // �������� �������
    if lv.GetSubItemByColumnName(ColSensorPos,li,str) then
      OffsetFloatEdit.Text:=str
    else
      OffsetFloatEdit.Text:='';
    // ��� �������
    if lv.GetSubItemByColumnName(ColType,li,str) then
      SensorTypeComboBox.Text:=str
    else
      SensorTypeComboBox.Text:='';
    if lv.GetSubItemByColumnName(ColStage,li,str) then
      StageComboBox.Text:=str
    else
      StageComboBox.Text:='';
end;

procedure TFormEditListItem.UpdateComboBox(bldfile:cbldfilegen);
var i,len:integer;
begin
  len:=bldfile.stages.Count;
  StageComboBox.clear;
  for I := 0 to len - 1 do
  begin
    StageComboBox.Items.Add(bldfile.stages.stages[i].name);
  end;
end;

function TFormEditListItem.ShowModal(var li:TListItem;var lv:TBtnListView):integer;
begin
  FillFormFromLI(li,lv);
  result:=inherited ShowModal;
  case result of
  1:FillListItem(li,lv);
  7:li.Delete;
  end;
end;



end.
