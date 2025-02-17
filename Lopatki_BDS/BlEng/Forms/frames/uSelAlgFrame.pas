unit uSelAlgFrame;

interface

uses
  Windows, Forms,  StdCtrls, uBtnListView, Controls, ComCtrls, Classes,
  ubldobj, utrend, uBldMath, usensor, uPair, uchart, ToolWin, ImgList, uBaseBldAlg,
  sysutils, udrawobj, uGistogram, uCommonTypes, ustage, utrendalg, uSensorRep,
  uBldObjList, uDensityForm, uSensorList, uCreateTrendForm, uGetSkipBladesAlg,
  uPairTrend, uBldGlobalStrings, uPairRestore, uBasicTrend, uPage, uaxis, uBuffTrend2d;

type
  TSelectAlgFrame = class(TFrame)
    SelAlgFrame: TGroupBox;
    SelAlgLV: TBtnListView;
    SelectActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
  private
    curObjList:cBldObjList;
    curchart:cchart;
  private
    procedure ShowAlgorithms;
  public
    procedure getObj(obj:cBldObjList);
    procedure getChart(chart:cchart);
    function apply:integer;
  end;

implementation
uses
  ubldeng, uRestoreVibrationAlg, uMultiSensor, uPairShape;

{$R *.dfm}

procedure TSelectAlgFrame.getChart(chart:cchart);
begin
  curchart:=chart;
end;

procedure TSelectAlgFrame.getObj(obj:cBldObjList);
begin
  curobjList:=obj;
  ShowAlgorithms;
end;

procedure TSelectAlgFrame.ShowAlgorithms;
var li:tlistitem;
begin
  SelAlgLV.Clear;
  if curobjList.Count=0 then exit;
  case curobjList.GetObjectsType of
    c_Sensor:
    begin
      if curobjList.Count>1 then
      begin
        // ��������� �������� "���������� ���������"
        li:=SelAlgLV.items.Add;
        SelAlgLV.SetSubItemByColumnName('�', inttostr(li.Index), li);
        SelAlgLV.SetSubItemByColumnName('��������', v_sPairShape, li);
        SelAlgLV.SetSubItemByColumnName('��� �������', v_Sensor, li);
      end;
      // ��������� �������� "���������� ���������"
      li:=SelAlgLV.items.Add;
      SelAlgLV.SetSubItemByColumnName('�', inttostr(li.Index), li);
      SelAlgLV.SetSubItemByColumnName('��������', v_sStat, li);
      SelAlgLV.SetSubItemByColumnName('��� �������', v_Sensor, li);
      // ��������� �������� "��������� ����"
      li:=SelAlgLV.items.Add;
      SelAlgLV.SetSubItemByColumnName('�', inttostr(li.Index), li);
      SelAlgLV.SetSubItemByColumnName('��������', v_sTaho, li);
      SelAlgLV.SetSubItemByColumnName('��� �������', v_Sensor, li);
      // ��������� �������� "������������ ������"
      li:=SelAlgLV.items.Add;
      SelAlgLV.SetSubItemByColumnName('�', inttostr(li.Index), li);
      SelAlgLV.SetSubItemByColumnName('��������', v_sRestore, li );
      SelAlgLV.SetSubItemByColumnName('��� �������', v_Sensor, li);
      // ��������� �������� "������������ ������"
      li:=SelAlgLV.items.Add;
      SelAlgLV.SetSubItemByColumnName('�', inttostr(li.Index), li);
      SelAlgLV.SetSubItemByColumnName('��������', v_sTrend, li );
      SelAlgLV.SetSubItemByColumnName('��� �������', v_Sensor, li);
      // ��������� �������� ����� �� �������
      li:=SelAlgLV.items.Add;
      SelAlgLV.SetSubItemByColumnName('�', inttostr(li.Index), li);
      SelAlgLV.SetSubItemByColumnName('��������', v_sSensorRep, li );
      SelAlgLV.SetSubItemByColumnName('��� �������', v_Sensor, li);
      // ��������� �������� ������ �������� �������
      li:=SelAlgLV.items.Add;
      SelAlgLV.SetSubItemByColumnName('�', inttostr(li.Index), li);
      SelAlgLV.SetSubItemByColumnName('��������', v_sSkipSensorBlades, li );
      SelAlgLV.SetSubItemByColumnName('��� �������', v_Sensor, li);
    end;
    c_Pair:
    begin
      // ��������� �������� "����� �����"
      li:=SelAlgLV.items.Add;
      SelAlgLV.SetSubItemByColumnName('�', inttostr(li.Index), li);
      SelAlgLV.SetSubItemByColumnName('��������', v_sShape, li);
      SelAlgLV.SetSubItemByColumnName('��� �������', v_Pair, li);
      // ��������� �������� "����� �����"
      li:=SelAlgLV.items.Add;
      SelAlgLV.SetSubItemByColumnName('�', inttostr(li.Index), li);
      SelAlgLV.SetSubItemByColumnName('��������', v_sPairTrend, li);
      SelAlgLV.SetSubItemByColumnName('��� �������', v_Pair, li);
      // 3d �����
      li:=SelAlgLV.items.Add;
      SelAlgLV.SetSubItemByColumnName('�', inttostr(li.Index), li);
      SelAlgLV.SetSubItemByColumnName('��������', v_sPairRestore, li);
      SelAlgLV.SetSubItemByColumnName('��� �������', v_Pair, li);
    end;
    c_stage:
    begin
      // ��������� �������� "���������� ����� ������"
      li:=SelAlgLV.items.Add;
      SelAlgLV.SetSubItemByColumnName('�', inttostr(li.Index), li);
      SelAlgLV.SetSubItemByColumnName('��������', v_sStageShape, li);
      SelAlgLV.SetSubItemByColumnName('��� �������', v_Stage, li);
    end;
  end;
  SelAlgLV.Selected:=SelAlgLV.Items[0];
end;

function TSelectAlgFrame.apply;
var
  i:integer;
  li:tlistitem;
  algname:string;
  trend:cbasictrend;
  eng:cbldeng;
  taho, sensor:csensor;
  stage:cstage;
  obj:cdrawobj;
  ax:caxis;
  rect:frect;
  alg:cRestoreAlg;
  opts:cBaseOpts;
  f:tform;
begin
  eng:=curobjlist.GetObj(0).eng;
  li:=SelAlgLV.Selected;
  SelAlgLV.GetSubItemByColumnName('��������', li, algname);
  taho:=csensor(eng.GetTaho(curobjlist.GetObj(0), false));
  if algname=v_sTaho then
  begin
    trend:=SelGraphForm.ShowModal(curchart,csensor(curobjlist.GetObj(0)).name+'_Taho');
    if trend=nil then
      exit;
    ax:=caxis(trend.parent);
    for i:=0 to curobjlist.Count-1 do
    begin
      if i>0 then
      begin
        trend:=cBuffTrend2d.Create;
        trend.name:=csensor(curobjlist.GetObj(i)).name+'_Taho';
        trend.color:=curchart.getcolor(i);
        trend.locked:=true;
        ax.AddChild(trend);
      end;
      trend.xunits:='date';
      trend.yunits:='rpm';
      trend.drawpoint:=false;
      // ��������� ����
      EvalTaxo(csensor(curobjlist.GetObj(i)), trend, eng.uts);
    end;
    cpage(curchart.activepage).Normalise;
  end;
  if algname=v_sPairShape then
  begin
    trend:=SelGraphForm.ShowModal(curchart,csensor(curobjlist.GetObj(0)).name+'_PairShape');
    BuildMultiSensor(taho,cAlgSensorList(curobjlist),trend);
  end;
  if algname=v_sPairTrend then
  begin
    BuildPairTrends(taho,cAlgSensorList(curobjlist),curchart);
  end;
  if algname=v_sPairRestore then
  begin
    BuildPairRestore(taho,cAlgSensorList(curobjlist),curchart);
  end;
  if algname=v_sStat then
  begin
    DensityForm.ShowModal(taho,cAlgSensorList(curobjlist),curchart);
    for I := 0 to cpage(curchart.activepage).activeAxis.ChildCount - 1 do
    begin
      obj:=cdrawobj(cpage(curchart.activepage).activeAxis.getChild(i));
      if obj is ctrend then
        obj.visible:=false;
      if obj is cgistogram then
      begin
        rect.BottomLeft:=p2(0,0);
        rect.TopRight:=p2(360,obj.GetBound.TopRight.y*1.05);
        cpage(curchart.activepage).ZoomfRect(rect);
      end;
    end;
  end;
  if algname=v_sRestore then
  begin
    trend:=SelGraphForm.ShowModal(curchart,csensor(curobjlist.GetObj(0)).name+'_Restore');
    if trend<>nil then
      RestoreSignal(taho,cAlgSensorList(curobjlist),trend)
    else
      RestoreSignal(taho,cAlgSensorList(curobjlist),ctrend(curchart));
  end;
  if algname=v_sShape then
  begin
    BuildPairShape(taho,cAlgSensorList(curobjlist),curchart);
  end;
  if algname=v_sTrend then
  begin
    trend:=SelGraphForm.ShowModal(curchart,csensor(curobjlist.GetObj(0)).name+'_BladeTrend');
    generateTrend(taho,cAlgSensorList(curobjlist),curchart)
  end;
  if algname=v_sStageShape then
  begin
    sensor:=csensor(eng.GetObjDlg(curobjlist.GetObj(0),c_RootSensor));
    // ���������� ������ ���������� ����� ���������
    cstage(curobjlist.GetObj(0)).Shape.Eval(taho, sensor, curobjlist.GetObj(0),true, -1, -1);
  end;
  if algname=v_sSensorRep then
  begin
    // ���������� ������ ���������� ����� ���������
    GenerateReport(taho,cAlgSensorList(curobjlist),curchart);
  end;
  if algname=v_sSkipSensorBlades then
  begin
    // ���������� ������ ���������� ����� ���������
    GetSkipBlades(taho,cAlgSensorList(curobjlist), curchart);
  end;
end;

end.
