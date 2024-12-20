unit uMainFrmChart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, uChart, StdCtrls;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
  private
    procedure DoInit(sender:tobject);
  public
    chart:cChart;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


procedure TForm1.DoInit(sender: tobject);
begin
  chart.logstr('OnInitscene');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  chart:=cChart.Create(nil);
  chart.Parent:=self;
  chart.debugLB:=ListBox1;
  chart.OnInit:=DoInit;
end;

end.
