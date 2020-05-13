unit uAutoPage;

interface
uses
  uPage, uBasicTrend, uaxis;

type
  cAutoPage = class(cPage)
  public
    t1d,t2d:cBasictrend;
    // ������������� ��������/ ����������
    offsetLink:boolean;
    // ������������� ������� ������� ��������������
    id:integer;
    // ������ ������� ��������������
    src:tobject;
  public
    constructor Create;override;
  end;

implementation
uses
  uBuffTrend1d, uBuffTrend2d;

constructor cAutoPage.Create;
var
  ax:caxis;
begin
  inherited;
  offsetLink:=true;
  t1d:=cBuffTrend1d.create;
  t1d.visible:=false;
  t2d:=cBuffTrend2d.create;
  t2d.visible:=false;
  ax:=activeAxis;
  ax.AddChild(t1d);
  ax.AddChild(t2d);
end;

end.
