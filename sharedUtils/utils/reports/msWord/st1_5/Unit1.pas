unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OleServer, Excel97;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
   uses MyWord;



procedure TForm1.Button1Click(Sender: TObject);
 var BoxName_,LineName_:string;
begin
if CreateWord then begin
Messagebox(0,'Word �������.','',0);
VisibleWord(true);
Messagebox(0,'Word �����.','',0);
If AddDoc then begin
Messagebox(0,'�������� ������.','',0);
CreateTextBox(1,1,100,50,BoxName_);
Messagebox(0,'������� ����� - �������.','',0);
messagebox(0,pchar(GetNameIndexShape(1)),'������� ��� �����',0);
BoxName_:=SetNewNameShape(BoxName_,'����� ���');
messagebox(0,pchar(GetNameIndexShape(1)),'�������� ��� ����� � ��������� ��� �����',0);
TextToTextBox(BoxName_,'��������� ����� � TextBox');

messagebox(0,'������ �����','',0);
CreateLine(1,15,300,200,LineName_);
messagebox(0,'������� �����','',0);
DeleteShape(LineName_);
messagebox(0,'������� �������','',0);
DeleteShape(BoxName_);

SaveDocAs('c:\��������, ���������� �������');
Messagebox(0,'����� ��������','',0);
CloseDoc;
end;
Messagebox(0,' ����� ������','',0);
CloseWord;
end;


end;


end.
