unit uEditMenuChartForm;

interface

uses
  Windows, Classes, Controls, Forms, uchart, ComCtrls, uBtnListView,
  uChartCfgForm, uDescObj, utrend, udrawobj, uCommonMath, utrendform,
  ugistogram, uGistForm, uDrawObjEditForm, uPageForm, uPage, uCursorform,
  uChartCursor, uDoubleCursor, uDoublecursorform, uTextLabel, uTextLabelForm,
  uAxis, uCommonTypes, uBasicTrend, uRegClassesList, uAutoPage, uBasePage,
  uAxisForm;

type

  TEditMenuChartForm = class(TForm)
    MenuLV: TBtnListView;
    procedure MenuLVDblClickProcess(item: TListItem; lv: TListView);
  private
    m_chart:cchart;
    descList:cDescList;
  protected
    // добавляет пункты меню
    procedure PrepareAlgoritms;
    // показать пункты меню для выделенной группы
    procedure ShowItems(groupID:Cardinal);
    // определить какие алгоритмы нужно предложить выбрать
    function getGroupId:cardinal;
  public
    procedure linc(chart:cchart);
    function showmodal:integer;override;
    destructor destroy;override;
  end;

var
  EditMenuChartForm: TEditMenuChartForm;

const
  // группа алгоритмов для компонента
  c_ChartGroup = $000001;
  // группа алгоритмов для тренда
  c_TrendGroup = $000004;
  // группа алгоритмов для объекта отрисовки
  c_DrawObjGroup = $000002;
  // -----------------------------------
  // настроить объект
  c_EditObj = 1;
  // изменить стиль вершины
  c_ChangePointType = 2;
  // Сделать невидимым
  c_ChangeVisible = 3;
  // удалить
  c_Delete = 4;
  // настроить компонент
  c_EditComponent = 5;
  // добавить метку
  c_AddLabel = 6;
  // добавить страницу
  c_AddPage = 7;
  // добавить ось
  c_AddAxis = 8;

implementation

{$R *.dfm}

procedure TEditMenuChartForm.ShowItems(groupID:Cardinal);
var
  desc:cDescObj;
  I: Integer;
begin
  MenuLV.Clear;
  for I := 0 to desclist.count - 1 do
  begin
    desc:=cDescObj(desclist.getObj(i));
    if (desc.groupID and groupId)<>0 then
    begin
      menuLv.AddItem(desc.name,desc);
    end;
  end;
end;

procedure TEditMenuChartForm.PrepareAlgoritms;
var
  desc:cDescObj;
begin
  desc:=cDescObj.create(c_DrawObjGroup,c_EditObj,'Редактировать объект');
  DescList.additem(desc);
  desc:=cDescObj.create(c_ChartGroup,c_EditComponent,'Редактировать чарт');
  DescList.additem(desc);
  desc:=cDescObj.create(c_TrendGroup,c_ChangePointType,'Изменить тип вершины');
  DescList.additem(desc);
  desc:=cDescObj.create(c_DrawObjGroup+c_TrendGroup,c_ChangeVisible,'Видимость');
  DescList.additem(desc);
  desc:=cDescObj.create(c_DrawObjGroup+c_TrendGroup,c_Delete,'Удалить');
  DescList.additem(desc);
  desc:=cDescObj.create(c_TrendGroup, c_AddLabel,'Добавить метку');
  DescList.additem(desc);
  desc:=cDescObj.create(c_EditObj, c_AddPage,'Добавить страницу');
  DescList.additem(desc);
  desc:=cDescObj.create(c_EditObj, c_AddAxis,'Добавить ось');
  DescList.additem(desc);
end;

procedure TEditMenuChartForm.linc(chart:cchart);
begin
  m_chart:=chart;
  descList:=cDescList.create;
  PrepareAlgoritms;
end;

procedure TEditMenuChartForm.MenuLVDblClickProcess(item: TListItem;
  lv: TListView);
var
 ChartCfgForm: TChartCfgForm;
 form:tform;
 desc:tobject;
 obj:cdrawobj;
 textLabel:ctextLabel;
 trend:ctrend;
 ax:caxis;
 page:cpage;

 objcreator:cobjCreator;
 f:tform;
begin
  ModalResult:=mrok;
  obj:=cdrawobj(m_chart.selected);
  desc:=cDescObj(item.Data);
  if not (desc  is cDescObj) then
  begin
    if m_chart<>nil then
    begin
      if assigned(m_chart.onafteredit) then
      begin
        m_chart.onafteredit(item);
      end;
    end;
    exit;
  end;
  case cDescObj(desc).id of
    c_EditObj:
    begin
      objcreator:=cObjCreator(cRegClassesList(m_chart.OBJmNG.regclasses).GetObj(obj.ClassName));
      if objcreator<>nil then
      begin
        f:=tform(objcreator.GetObj('Form'));
        if f<>nil then
        begin
          if assigned(m_chart.OnEditObj) then
          begin
            m_chart.OnEditObj(obj);
            exit;
          end;
        end;
      end;
      if obj is cbasictrend then
      begin
        form:=TTrendForm.create(nil);
        ttrendform(form).ShowModal(ctrend(obj));
        form.Destroy;
        exit;
      end;
      if obj is cgistogram then
      begin
        form:=TGistForm.create(nil);
        TGistForm(form).ShowModal(cgistogram(obj));
        form.Destroy;
        exit;
      end;
      if obj is cPage then
      begin
        form:=TPageForm.create(nil);
        TPageForm(form).ShowModal(cpage(obj));
        form.Destroy;
        exit;
      end;
      if obj is cChartCursor then
      begin
        form:=TCursorForm.create(nil);
        TCursorForm(form).ShowModal(cChartcursor(obj));
        form.Destroy;
        exit;
      end;
      if obj is cdoublecursor then
      begin
        form:=TDoublecursorform.create(nil);
        TDoublecursorform(form).ShowModal(cDoubleCursor(obj));
        form.Destroy;
        exit;
      end;
      if obj is cTextLabel then
      begin
        form:=TTextLabelForm.create(nil);
        TTextLabelForm(form).ShowModal(cTextLabel(obj));
        form.Destroy;
        exit;
      end;
      if obj is cAxis then
      begin
        form:=taxisform.create(nil);
        taxisform(form).ShowModal(caxis(obj));
        form.Destroy;
        exit;
      end;
      if obj is cDrawObj then
      begin
        form:=TDrawObjEditForm.create(nil);
        TDrawObjEditForm(form).ShowModal(cDrawObj(obj));
        form.Destroy;
        exit;
      end;
    end;
    c_EditComponent:
    begin
      ChartCfgForm:=TChartCfgForm.Create(nil);
      ChartCfgForm.showmodal(m_chart);
      ChartCfgForm.Destroy;
    end;
    c_ChangePointType:
    begin
      trend:=ctrend(m_chart.selected);
      // изменение типа выделенных точек
      trend.changetype;
      cchart(m_chart).redraw;
    end;
    c_ChangeVisible:
    begin
      // изменение типа выделенных точек
      obj.visible:=not obj.visible;
     cchart(m_chart).redraw;
    end;
    c_Delete:
    begin
      obj.destroy;
      m_chart.selected:=nil;
      cchart(m_chart).redraw;
    end;
    c_AddLabel:
    begin
      ax:=caxis(obj.GetParentByClassName('cAxis'));
      if ax=nil then
      begin
        if obj is caxis then
          ax:=caxis(obj);
      end;
      textLabel:=ctextLabel.create;
      textLabel.name:=obj.name+'_Label';
      textLabel.events:=obj.events;
      textlabel.Position:=p2((ax.max.x+ax.min.x)/2, (ax.max.y+ax.min.y)/2);
      obj.AddChild(textLabel);
    end;
    c_AddPage:
    begin
      m_chart.addPage;
    end;
    c_AddAxis:
    begin
      if obj is cpage then
        page:=cpage(obj)
      else
      begin
        page:=cpage(obj.GetParentByClassName('cPage'));
        if page=nil then
        begin
          page:=cpage(m_chart.activepage);
        end;
      end;
      page.Newaxis;
    end;
  end;
end;

function TEditMenuChartForm.getGroupId;
var
  obj:cdrawobj;
begin
  result:=c_ChartGroup;
  obj:=m_chart.selected;
  if obj<>nil then
  begin
    if obj is cdrawobj then
    begin
      setflag(result,c_DrawObjGroup);
      if (obj Is ctrend) or (obj Is caxis) or (obj Is cGistogram) then
        setflag(result,c_TrendGroup);
    end;
  end;
end;

function TEditMenuChartForm.showmodal:integer;
begin
  ShowItems(getGroupId);
  MenuLV.Columns.Items[0].Width:=200;
  if assigned(m_chart.onbeforeedit) then
    m_chart.onbeforeedit(menulv);
  Result:= inherited showmodal;
end;

destructor TEditMenuChartForm.destroy;
begin
  descList.destroy;
  inherited;
end;

end.
