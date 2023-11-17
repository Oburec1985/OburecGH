unit SignalsGenerator;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, uBtnListView, DCL_MYOWN, uChart,
  ImgList, uSinFrame, umerasignal, upage, uDrawObj, utrend, uaxis, Menus, uEventList,
  ueventtypes, uLoadSignalForm, uFileMng, uShockFrame, uMeraFile, ubuffsignal,
  FreeFrmSignal,
  upoint, uCommonTypes,
  uSignalsUtils;

type
  TGeneratorForm = class(TForm)
    CommonGB: TGroupBox;
    Splitter1: TSplitter;
    NameEdit: TEdit;
    NameLabel: TLabel;
    FreqIE: TIntEdit;
    FreqLabel: TLabel;
    TypeLabel: TLabel;
    TypeCB: TComboBox;
    ImageList_16: TImageList;
    GenBtn: TButton;
    MainMenu1: TMainMenu;
    FileMenu: TMenuItem;
    LoadMenu: TMenuItem;
    SaveMenu: TMenuItem;
    RecentFiles: TMenuItem;
    AlgMenu: TMenuItem;
    SRSMenu: TMenuItem;
    SignalSpecOptsGB: TGroupBox;
    Splitter2: TSplitter;
    PreviewGB: TGroupBox;
    cChart1: cChart;
    SignalOptsGB: TGroupBox;
    SignalsLV: TBtnListView;
    Splitter3: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure GenBtnClick(Sender: TObject);
    procedure LoadMenuClick(Sender: TObject);
    procedure SignalsLVDblClickProcess(item: TListItem; lv: TListView);
    procedure SRSMenuClick(Sender: TObject);
    procedure RecentFilesClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SaveMenuClick(Sender: TObject);
    procedure TypeCBChange(Sender: TObject);
    procedure SignalsLVClick(Sender: TObject);
    procedure cChart1SelectPoint(Sender: TObject);
    procedure cChart1MovePoint(data, subdata: TObject);
  private
    FileMng:cFileMng;
    signals:cMeraFile;
    SinFrame:tsinframe;
    ShockFrame:tShockFrame;
    FreeFrmSignal:TFreeFrmSignalFrame;
    curSignal:csignal;
    events:cEventList;
  private
    function GetaActiveTrend:ctrend;
    procedure showSignalsInLV;
    procedure lincFrames;
    procedure CreateEvents;
    procedure OnChangeCfg(sender:tobject);
    function CreateSignal:csignal;
  public

  end;

var
  GeneratorForm: TGeneratorForm;

const
  c_sinType = 0;
  c_ShockType = 3;
  c_recentfiles = 'Недавние файлы';
  c_Helpfiles = 'Помощь';

implementation
uses
  //uSrs,
  uSaveSignalForm;
{$R *.dfm}

procedure TGeneratorForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fileMng.Destroy;
  signals.destroy;
  events.destroy;
end;

procedure TGeneratorForm.FormCreate(Sender: TObject);
begin
  events:=cEventList.create(self,true);
  lincFrames;
  typecb.ItemIndex:=c_sinType;
  FileMng:=cFileMng.Create(extractfiledir(Application.ExeName)+'\RecentFiles.ini',
                    MainMenu1,c_RecentFiles,nil);
  signals:=cmerafile.create;
  signals.signalclass:=cBuffSignal;
  CreateEvents;
  // отображаем форму во весь экран
  WindowState:=wsMaximized;
  RequestAlign;
end;

procedure TGeneratorForm.OnChangeCfg(sender:tobject);
begin
  showSignalsInLV;
end;

procedure TGeneratorForm.RecentFilesClick(Sender: TObject);
var
  fname:string;
  li:tlistitem;
begin
  if FileMng.bclick then
  begin
    FileMng.bClick:=false;
    fname:=FileMng.GetClickItem;
    if fileexists(fname) then
    begin
      LoadSignalForm.signals:=signals;
      signals.load(fname);
      showSignalsInLV;
      li:=SignalsLV.Items[0];
      li.Data:=signals.GetSignal(0);
      SignalsLVDblClickProcess(li,SignalsLV);
    end;
  end;
end;

procedure TGeneratorForm.SaveMenuClick(Sender: TObject);
begin
  SaveSignalForm.SaveMera(signals);
end;

procedure TGeneratorForm.LoadMenuClick(Sender: TObject);
var
  li:tlistItem;
begin
  if LoadSignalForm.LoadSignals(signals) then
  begin
    filemng.AddfilePath(LoadSignalForm.PathEdit.Text);
    li:=SignalsLV.Items[0];
    SignalsLVDblClickProcess(li,SignalsLV);
  end;
end;

procedure TGeneratorForm.cChart1MovePoint(data, subdata: TObject);
var
  index:integer;
  p1, p2:cbeziepoint;
  diff:point2;
begin
  ctrend(data).FindPoint(cbeziepoint(subdata).point.x,index);
  if index=0 then
  begin
    p1:=cbeziepoint(subdata);
    p2:=ctrend(data).getPoint(ctrend(data).count-1);
    p2.y:=p1.y;

    diff.x:=p1.right.x-p1.x;
    diff.y:=p1.right.y-p1.y;

    p2.left.x:=p2.x-diff.x;
    p2.left.y:=p2.y-diff.y;
  end;
end;

procedure TGeneratorForm.cChart1SelectPoint(Sender: TObject);
var
  p:cbeziepoint;
begin
  p:=cbeziepoint(sender);
  FreeFrmSignal.xfe.FloatNum:=p.point.x;
  FreeFrmSignal.yfe.FloatNum:=p.point.y;
end;

procedure TGeneratorForm.CreateEvents;
begin
  events.AddEvent('OnChangeSignalsList',
                          E_OnAddChild + E_OnRenameObj + E_OnAddObj +
                          E_OnDestroyObject, OnChangeCfg);
end;

procedure TGeneratorForm.lincFrames;
begin
  SinFrame:=tsinframe.create(self);
  SinFrame.Parent:=SignalOptSgb;
  SinFrame.Visible:=true;

  ShockFrame:=tShockFrame.create(self);
  ShockFrame.Parent:=SignalOptSgb;
  ShockFrame.Visible:=false;

  FreeFrmSignal:=tFreeFrmSignalFrame.create(self);
  FreeFrmSignal.Parent:=SignalOptSgb;
  FreeFrmSignal.Visible:=false;
end;


function TGeneratorForm.GetaActiveTrend:ctrend;
var
  page:cpage;
  ax:caxis;
  obj:ctrend;
begin
  // получаем активную страницу
  page:=cpage(cchart1.activeTab.activepage);
  obj:=ctrend(page.getChildrenByName('cTrend'));
  if obj=nil then
  begin
    ax:=page.activeAxis;
    obj:=ax.AddTrend;
    obj.drawpoint:=false;
  end;
  result:=obj;
end;

procedure TGeneratorForm.TypeCBChange(Sender: TObject);
var
  tr:ctrend;
  page:cpage;
  ax:caxis;
begin
  SinFrame.visible:=false;
  ShockFrame.visible:=false;
  FreeFrmSignal.visible:=false;
  case typecb.ItemIndex of
    c_sinType:SinFrame.visible:=true;
    c_ShockType:ShockFrame.visible:=true;
    4:
    begin
      FreeFrmSignal.visible:=true;
      tr:=cChart1.activetrend;
      if tr=nil then
      begin
        tr:=cTrend.create;
        tr.name:='FreeFrmLine';
        tr.color:=p3(0,0,1);
        page:=cpage(cchart1.activePage);

        ax:=page.activeAxis;
        ax.AddChild(tr);
        tr.AddPoint(0,0);
        tr.AddPoint(FreeFrmSignal.LengthFE.FloatNum,1);
        page.Normalise;
      end;
    end;
  end;
end;

function TGeneratorForm.CreateSignal:csignal;
var
  i:integer;
  obj:ctrend;
begin
  result:=cbuffsignal.create;
  result.freqX:=FreqIE.IntNum;
  case typecb.ItemIndex of
    c_sinType:
    begin
      NameEdit.Text:='sinus';
      result.freqX:=freqie.IntNum;
      SinFrame.CreateSignal(cbuffsignal(result));
    end;
    c_ShockType:
    begin
      NameEdit.Text:='shock';
      ShockFrame.CreateSignal(result);
    end;
  end;
  result.name:=NameEdit.Text;
  obj:=GetaActiveTrend;
  CopyToTrend(obj, result);
end;

procedure TGeneratorForm.showSignalsInLV;
var
  i:integer;
  s:csignal;
  li:tlistitem;
begin
  SignalsLV.Clear;
  for I := 0 to signals.Count - 1 do
  begin
    s:=signals.getsignal(i);
    li:=SignalsLV.Items.Add;
    li.data:=s;
    SignalsLV.SetSubItemByColumnName('№',inttostr(i),li);
    SignalsLV.SetSubItemByColumnName('Имя сигнала',s.name,li);
    SignalsLV.SetSubItemByColumnName('Число точек',inttostr(s.count),li);
    SignalsLV.SetSubItemByColumnName('Описание',s.dsc,li);
  end;
end;

procedure TGeneratorForm.SignalsLVClick(Sender: TObject);
begin
  curSignal:=csignal(SignalsLV.Selected.data);
end;

procedure TGeneratorForm.SignalsLVDblClickProcess(item: TListItem;
  lv: TListView);
var
  obj:ctrend;
begin
  obj:=GetaActiveTrend;
  obj.Clear;
  CopyToTrend(obj, csignal(item.data));
  curSignal:=csignal(item.data);
  cpage(cChart1.tabs.activepage).Normalise;
end;

procedure TGeneratorForm.SRSMenuClick(Sender: TObject);
var
  signal:csignal;
begin
  if cursignal<>nil then
  begin
    //signal:=EvalSrs(curSignal);
    signal.name:=curSignal.name+'_SRS';
    if signal<>nil then
    begin
      signals.add(signal);
      showSignalsInLV;
    end;
  end
  else
  begin
    showmessage('Необходимо выделить сигнал');
  end;
end;


procedure TGeneratorForm.GenBtnClick(Sender: TObject);
begin
  signals.Add(CreateSignal);
  showSignalsInLV;
end;



end.
