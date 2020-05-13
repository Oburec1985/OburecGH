unit uCreateTrendForm;

interface

uses
  Windows, SysUtils, Classes, Forms,  StdCtrls, ComCtrls, ExtCtrls, uChart,
  Controls, uaxis, upage, uBuffTrend2d, uBaseObjService, ubaseobj, udrawobj,
  uBasicTrend;

type
  TSelGraphForm = class(TForm)
    CfgTV: TTreeView;
    CfgGB: TGroupBox;
    Splitter1: TSplitter;
    NewAxisCheckBox: TCheckBox;
    pageNameLabel: TLabel;
    PageNameEdit: TEdit;
    NameAxisLabel: TLabel;
    NameAxisEdit: TEdit;
    GraphNameEdit: TEdit;
    GraphNameLabel: TLabel;
    NewGraphCheckBox: TCheckBox;
    SelectActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    procedure NewAxisCheckBoxClick(Sender: TObject);
    procedure NewGraphCheckBoxClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    def:string;
  private
    procedure showInitChart(chart:cchart);
    procedure setNewAxis;
    procedure setNewTrend;
    function getselected:cbaseobj;
    function getAxis(chart:cchart):cAxis;
  public
    function ShowModal(chart:cchart; defname:string):cBasicTrend;
  end;

var
  SelGraphForm: TSelGraphForm;

implementation

{$R *.dfm}
procedure TSelGraphForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
    modalresult:=mrok;
  if key=27 then
    modalresult:=mrcancel;
end;

procedure TSelGraphForm.NewAxisCheckBoxClick(Sender: TObject);
begin
  if TCheckBox(sender).Checked then
  begin
    NameAxisEdit.Enabled:=true;
    NameAxisEdit.Text:='Axis_01';
  end;
end;

procedure TSelGraphForm.NewGraphCheckBoxClick(Sender: TObject);
begin
  if TCheckBox(sender).Checked then
  begin
    setNewTrend;
  end;
end;

procedure TSelGraphForm.setNewTrend;
begin
  GraphNameEdit.Enabled:=true;
  GraphNameEdit.Text:=def;
end;

procedure TSelGraphForm.setNewAxis;
begin
  if NewAxisCheckBox.Checked then
  begin
    setNewTrend;
  end;
end;

procedure TSelGraphForm.showInitChart(chart:cchart);
var
  p:cpage;
  axis:caxis;
  list:tstringlist;
begin
  // отображаем структуру компонента
  cfgtv.Items.Clear;
  showInTreeView(cfgtv, chart.activeTab);
  // отображаем имя страницы
  p:=cpage(chart.Activepage);
  PageNameEdit.Text:=p.name;
  // отображаем настройки оси по умолчанию
  axis:=p.activeAxis;
  NameAxisEdit.Text:=p.activeAxis.name;
  NameAxisEdit.Enabled:=false;
  NewAxisCheckBox.Checked:=false;
  list:=p.getChildrensByClassName('cBasicTrend');
  // отображаем настройки тренда по умолчанию
  if list.Count<>0 then
  begin
    GraphNameEdit.Enabled:=false;
    NewGraphCheckBox.Checked:=false;
    NewGraphCheckBox.Enabled:=true;
  end
  else
  begin
    GraphNameEdit.Enabled:=true;
    NewGraphCheckBox.Checked:=true;
    NewGraphCheckBox.Enabled:=false;
    GraphNameEdit.Text:=def;
  end;
  list.Destroy;
end;

function TSelGraphForm.ShowModal(chart:cchart; defname:string):cBasicTrend;
var
  a:caxis;
  t:cBasicTrend;
  obj:cdrawobj;
begin
  result:=nil;
  showInitChart(chart);
  def:=defname;
  GraphNameEdit.Text:=def;
  if inherited showmodal=mrok then
  begin
    if not NewGraphCheckBox.Checked then
    begin
      obj:=cdrawobj(getselected);
      if obj=nil then
      begin
        result:=nil;
      end
      else
      begin
        if obj is cBasicTrend then
        begin
          result:=cBasicTrend(obj);
        end;
      end;
    end
    else
    begin
      if NewAxisCheckBox.Checked then
      begin
        a:=cpage(chart.activepage).newaxis;
        a.name:=NameAxisEdit.Text;
        t:=cBuffTrend2d.Create;
        t.name:=GraphNameEdit.Text;
        t.color:=chart.getcolor(0);
        a.AddChild(t);
      end
      else
      begin
        a:=getAxis(chart);
        t:=cBuffTrend2d.Create;
        t.name:=GraphNameEdit.Text;
        t.color:=a.color;
        t.locked:=true;
        a.AddChild(t);
      end;
      result:=t;
    end;
  end
  else
    result:=nil;
end;

function TSelGraphForm.getselected:cbaseobj;
begin
  if CfgTV.Selected<>nil then
    result:=cbaseobj(CfgTV.Selected.Data)
  else
    result:=nil;
end;

function TSelGraphForm.getAxis(chart:cchart):cAxis;
var
  obj:cbaseobj;
begin
  obj:=getselected;
  result:=nil;
  if obj is caxis then
    result:=caxis(obj)
  else
  begin
    if obj is cBasicTrend then
    begin
      result:=caxis(obj.getparentByClassName('caxis'));
    end;
    if result=nil then
    begin
      result:=cpage(chart.activepage).activeAxis;
    end;
  end;
end;

end.
