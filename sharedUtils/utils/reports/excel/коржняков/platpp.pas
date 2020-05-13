unit platpp;

interface
{$I-}

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
     Buttons, ExtCtrls, Menus, Dialogs, Mask, ShellApi;

type
  Tplatpp_ = class(TForm)
    OKBtn: TButton;
    Button1: TButton;
    GroupBox1: TGroupBox;
    plINN: TEdit;
    plNAME: TEdit;
    plRS: TEdit;
    GroupBox2: TGroupBox;
    bplNAME: TEdit;
    bplBIK: TEdit;
    bplKS: TEdit;
    GroupBox3: TGroupBox;
    polINN: TEdit;
    polNAME: TEdit;
    polRS: TEdit;
    GroupBox4: TGroupBox;
    bpolNAME: TEdit;
    bpolBIK: TEdit;
    bpolKS: TEdit;
    GroupBox5: TGroupBox;
    Label4: TLabel;
    Label1: TLabel;
    npp: TEdit;
    summp: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    cvidpl: TComboBox;
    GroupBox6: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    vidop: TEdit;
    srokop: TEdit;
    nazpl: TEdit;
    ocherpl: TEdit;
    rezpole: TEdit;
    kod: TEdit;
    mnazpl: TMemo;
    Label11: TLabel;
    SaveDialog1: TSaveDialog;
    SpeedButton1: TSpeedButton;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    OpenDialog1: TOpenDialog;
    Label12: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label22: TLabel;
    datepp: TMaskEdit;
    Button2: TButton;
    Button3: TButton;
    SaveDialog2: TSaveDialog;
    OpenDialog2: TOpenDialog;
    summpp: TMemo;
    Timer1: TTimer;
    SpeedButton2: TSpeedButton;
    PopupMenu2: TPopupMenu;
    N3: TMenuItem;
    N4: TMenuItem;
    SaveDialog3: TSaveDialog;
    OpenDialog3: TOpenDialog;
    N5: TMenuItem;
    OpenDialog4: TOpenDialog;
    SaveDialog4: TSaveDialog;
    OpenDialog5: TOpenDialog;
    PopupMenu3: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    OpenDialog6: TOpenDialog;
    SaveDialog5: TSaveDialog;
    PopupMenu4: TPopupMenu;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    OpenDialog7: TOpenDialog;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure dbfIII1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  platpp_: Tplatpp_;

implementation

{$R *.DFM}

   uses myWord,platunit;

Procedure load_from_pp;
begin
with platpp_ do begin
npp.Text:=pp.npp;
datepp.Text:=pp.datepp;
cvidpl.Text:=pp.cvidpl;
summp.Text:=pp.summp;
summpp.Text:=pp.summpp;

plName.Text:=pp.plName;
plINN.Text:=pp.plINN;
plRS.Text:=pp.plRS;
bplName.Text:=pp.bplName;
bplBik.Text:=pp.bplBik;
bplKs.Text:=pp.bplKs;

polName.Text:=pp.polName;
polINN.Text:=pp.polINN;
polRS.Text:=pp.polRS;
bpolName.Text:=pp.bpolName;
bpolBik.Text:=pp.bpolBik;
bpolKs.Text:=pp.bpolKs;

vidop.Text:=pp.vidop;
srokop.Text:=pp.srokop;
nazpl.Text:=pp.nazpl;
ocherpl.Text:=pp.ocherpl;
kod.Text:=pp.kod;
rezpole.Text:=pp.rezpole;

mnazpl.Text:=pp.mnazpl;
end;
End;


Procedure load_mass_pp;
begin
with platpp_ do begin
pp.npp:=npp.Text;
pp.datepp:=datepp.Text;
pp.cvidpl:=cvidpl.Text;
pp.summp:=summp.Text;
pp.summpp:=summpp.Text;

pp.plName:=plName.Text;
pp.plINN:=plINN.Text;
pp.plRS:=plRS.Text;
pp.bplName:=bplName.Text;
pp.bplBik:=bplBik.Text;
pp.bplKs:=bplKs.Text;

pp.polName:=polName.Text;
pp.polINN:=polINN.Text;
pp.polRS:=polRS.Text;
pp.bpolName:=bpolName.Text;
pp.bpolBik:=bpolBik.Text;
pp.bpolKs:=bpolKs.Text;

pp.vidop:=vidop.Text;
pp.srokop:=srokop.Text;
pp.nazpl:=nazpl.Text;
pp.ocherpl:=ocherpl.Text;
pp.kod:=kod.Text;
pp.rezpole:=rezpole.Text;

pp.mnazpl:=mnazpl.Text;
end;
End;


procedure Tplatpp_.FormClose(Sender: TObject; var Action: TCloseAction);
 var f_:file;
begin
load_mass_pp;
assignfile(f_,'plat.bin'); rewrite(f_,sizeof(pp));
blockwrite(f_,pp,1); closefile(f_);
{close_shell_word;}
end;

procedure Tplatpp_.Button1Click(Sender: TObject);
begin
   CreateWord;
   OpenDoc(ExtractFileDir(application.ExeName)+'\pp.rtf');

   StartOfDoc; FindAndPasteTextDoc('###№ П.П.&',npp.text);
   StartOfDoc; FindAndPasteTextDoc('###Дата&',datepp.text);
   StartOfDoc; FindAndPasteTextDoc('###Вид платежа&',cvidpl.text);
   StartOfDoc; FindAndPasteTextDoc('###Сумма прописью&',summpp.text);
   StartOfDoc; FindAndPasteTextDoc('###Сумма&',summp.text);

   StartOfDoc; FindAndPasteTextDoc('###ИНН плательщика&',plINN.text);
   StartOfDoc; FindAndPasteTextDoc('###Плательщик&',plNAME.text);
   StartOfDoc; FindAndPasteTextDoc('###Р/С плательщика&',plRS.text);
   StartOfDoc; FindAndPasteTextDoc('###Банк плательщика&',bplNAME.text);
   StartOfDoc; FindAndPasteTextDoc('###БИК плательщика&',bplBIK.text);
   StartOfDoc; FindAndPasteTextDoc('###К/С плательщика&',bplKS.text);

   StartOfDoc; FindAndPasteTextDoc('###ИНН получателя&',polINN.text);
   StartOfDoc; FindAndPasteTextDoc('###Получатель&',polNAME.text);
   StartOfDoc; FindAndPasteTextDoc('###Р/С получателя&',polRS.text);
   StartOfDoc; FindAndPasteTextDoc('###Банк получателя&',bpolNAME.text);
   StartOfDoc; FindAndPasteTextDoc('###БИК получателя&',bpolBIK.text);
   StartOfDoc; FindAndPasteTextDoc('###К/С получателя&',bpolKS.text);

   StartOfDoc; FindAndPasteTextDoc('###В.О.&',vidop.text);
   StartOfDoc; FindAndPasteTextDoc('###С.П.&',srokop.text);
   StartOfDoc; FindAndPasteTextDoc('###Н.П.&',nazpl.text);
   StartOfDoc; FindAndPasteTextDoc('###О.П.&',ocherpl.text);
   StartOfDoc; FindAndPasteTextDoc('###Код&',kod.text);
   StartOfDoc; FindAndPasteTextDoc('###Р.П.&',rezpole.text);
   StartOfDoc; FindAndPasteTextDoc('###Назначение платежа&',mnazpl.text);
   SaveDocAs(ExtractFileDir(application.ExeName)+'\Платежное поручение.rtf');
   CloseDoc;

   messagebox(Handle,'Нажмите кн. для продолжения!','Формирование документа окончено!',0);
   shellexecute(handle,'open',pchar(ExtractFileDir(application.ExeName)+'\Платежное поручение.rtf'),'','',1);
end;




procedure Tplatpp_.SpeedButton1Click(Sender: TObject);
begin
PopupMenu1.Popup(left+GroupBox3.Left+SpeedButton1.Left+10,top+GroupBox3.top+SpeedButton1.Top+10);
end;

procedure Tplatpp_.N1Click(Sender: TObject);
 var f_:file;
   dir_:string;
   eee_:string;
   a_:word;
begin
getdir(0,dir_);
eee_:=polNAME.Text;
for a_:=1 to length(eee_) do
    if ((ord(eee_[a_])>=48)and(ord(eee_[a_])<=57))or
       ((ord(eee_[a_])>=65)and(ord(eee_[a_])<=90))or
       ((ord(eee_[a_])>=97)and(ord(eee_[a_])<=122))or
       ((ord(eee_[a_])>=128)) then else eee_[a_]:=' ';
SaveDialog1.FileName:=eee_;
if not SaveDialog1.Execute then begin Chdir(dir_); exit; end;
Chdir(dir_);
polut.Name:=polName.Text;
polut.INN:=polINN.Text;
polut.RS:=polRS.Text;
polut.bank.Name:=bpolName.Text;
polut.bank.Bik:=bpolBIK.Text;
polut.bank.Ks:=bpolKS.Text;
assignfile(f_,SaveDialog1.FileName);
rewrite(f_,sizeof(polut));
blockwrite(f_,polut,1);
closefile(f_);
end;

procedure Tplatpp_.N2Click(Sender: TObject);
 var f_:file;
   dir_:string;
begin
getdir(0,dir_);
if  not OpenDialog1.Execute then begin chdir(dir_); exit; end;
chdir(dir_);
assignfile(f_,OpenDialog1.FileName);
reset(f_,sizeof(polut));
blockread(f_,polut,1);
polName.Text:=polut.Name;
polINN.Text:=polut.INN;
polRS.Text:=polut.RS;
bpolName.Text:=polut.bank.Name;
bpolBIK.Text:=polut.bank.Bik;
bpolKS.Text:=polut.bank.Ks;
closefile(f_);
end;










procedure Tplatpp_.FormShow(Sender: TObject);
 var f_:file;
    Fs_:TSearchRec;
begin
if FindFirst('plat.bin',faArchive,fs_)>0 then exit;
assignfile(f_,'plat.bin'); reset(f_,sizeof(pp));
blockread(f_,pp,1); closefile(f_);
load_from_pp;
end;

procedure Tplatpp_.Button2Click(Sender: TObject);
 var f_:file;
   dir_:string;
   eee_:string;
   a_:word;
begin
getdir(0,dir_);
{if cvid.ItemIndex=0 then eee_:='Платежное поручение № '+npp.text+' от '+datepp.Text;
if cvid.ItemIndex=1 then eee_:='Инкассовое поручение № '+npp.text+' от '+datepp.Text;}
eee_:='Платежное поручение № '+npp.text+' от '+datepp.Text;
for a_:=1 to length(eee_) do
    if ((ord(eee_[a_])>=48)and(ord(eee_[a_])<=57))or
       ((ord(eee_[a_])>=65)and(ord(eee_[a_])<=90))or
       ((ord(eee_[a_])>=97)and(ord(eee_[a_])<=122))or
       ((ord(eee_[a_])>=128)) then else eee_[a_]:=' ';
SaveDialog2.FileName:=eee_;
if not SaveDialog2.Execute then begin Chdir(dir_); exit; end;
Chdir(dir_);
load_mass_pp;
assignfile(f_,SaveDialog2.FileName);
rewrite(f_,sizeof(pp));
blockwrite(f_,pp,1);
closefile(f_);
end;


procedure Tplatpp_.Button3Click(Sender: TObject);
 var f_:file;
   dir_:string;
begin
getdir(0,dir_);
if  not OpenDialog2.Execute then begin chdir(dir_); exit; end;
chdir(dir_);
assignfile(f_,OpenDialog2.FileName);
reset(f_,sizeof(pp));
blockread(f_,pp,1);
closefile(f_);
load_from_pp;
end;

procedure Tplatpp_.SpeedButton2Click(Sender: TObject);
begin
PopupMenu2.Popup(left+GroupBox3.Left+GroupBox4.Left+SpeedButton2.Left+10,top+GroupBox3.top+GroupBox4.top+SpeedButton2.Top+10);
end;

procedure Tplatpp_.N3Click(Sender: TObject);
 var f_:file;
   dir_:string;
   eee_:string;
   a_:word;
begin
getdir(0,dir_);
eee_:=bpolNAME.Text;
for a_:=1 to length(eee_) do
    if ((ord(eee_[a_])>=48)and(ord(eee_[a_])<=57))or
       ((ord(eee_[a_])>=65)and(ord(eee_[a_])<=90))or
       ((ord(eee_[a_])>=97)and(ord(eee_[a_])<=122))or
       ((ord(eee_[a_])>=128)) then else eee_[a_]:=' ';
SaveDialog3.FileName:=eee_;
if not SaveDialog3.Execute then begin Chdir(dir_); exit; end;
Chdir(dir_);
bank.Name:=bpolName.Text;
bank.Bik:=bpolBIK.Text;
bank.Ks:=bpolKS.Text;
assignfile(f_,SaveDialog3.FileName);
rewrite(f_,sizeof(bank));
blockwrite(f_,bank,1);
closefile(f_);
end;


procedure Tplatpp_.N5Click(Sender: TObject);
 var f_:file;
   dir_:string;
begin
getdir(0,dir_);
if  not OpenDialog3.Execute then begin chdir(dir_); exit; end;
chdir(dir_);
assignfile(f_,OpenDialog3.FileName);
reset(f_,sizeof(bank));
blockread(f_,bank,1);
bpolName.Text:=bank.Name;
bpolBIK.Text:=bank.Bik;
bpolKS.Text:=bank.Ks;
closefile(f_);
end;


procedure Tplatpp_.dbfIII1Click(Sender: TObject);
 label 0,1,2;
 var Fs_:TSearchRec;
    dir_:string;
    eee_:string;
begin
if FindFirst('temp',faDirectory, Fs_)>0 then mkdir('temp');
if FindFirst('dbf',faDirectory, Fs_)>0 then mkdir('dbf');

getdir(0,dir_);
if  not OpenDialog4.Execute then begin chdir(dir_); exit; end;
chdir(dir_);
eee_:=OpenDialog4.FileName+chr(0);
copyfile(@eee_[1],'temp\temp.dbf',false);

errorBDE:=0;
end;


procedure Tplatpp_.SpeedButton3Click(Sender: TObject);
begin
PopupMenu3.Popup(left+GroupBox1.Left+SpeedButton3.Left+10,top+GroupBox1.top+SpeedButton3.Top+10);
end;

procedure Tplatpp_.MenuItem1Click(Sender: TObject);
 var f_:file;
   dir_:string;
   eee_:string;
   a_:word;
begin
getdir(0,dir_);
eee_:=plNAME.Text;
for a_:=1 to length(eee_) do
    if ((ord(eee_[a_])>=48)and(ord(eee_[a_])<=57))or
       ((ord(eee_[a_])>=65)and(ord(eee_[a_])<=90))or
       ((ord(eee_[a_])>=97)and(ord(eee_[a_])<=122))or
       ((ord(eee_[a_])>=128)) then else eee_[a_]:=' ';
SaveDialog4.FileName:=eee_;
if not SaveDialog4.Execute then begin Chdir(dir_); exit; end;
Chdir(dir_);
platel.Name:=plName.Text;
platel.INN:=plINN.Text;
platel.RS:=plRS.Text;
platel.bank.Name:=bplName.Text;
platel.bank.Bik:=bplBIK.Text;
platel.bank.Ks:=bplKS.Text;
assignfile(f_,SaveDialog4.FileName);
rewrite(f_,sizeof(platel));
blockwrite(f_,platel,1);
closefile(f_);
end;

procedure Tplatpp_.MenuItem2Click(Sender: TObject);
 var f_:file;
   dir_:string;
begin
getdir(0,dir_);
if  not OpenDialog5.Execute then begin chdir(dir_); exit; end;
chdir(dir_);
assignfile(f_,OpenDialog5.FileName);
reset(f_,sizeof(platel));
blockread(f_,platel,1);
plName.Text:=platel.Name;
plINN.Text:=platel.INN;
plRS.Text:=platel.RS;
bplName.Text:=platel.bank.Name;
bplBIK.Text:=platel.bank.Bik;
bplKS.Text:=platel.bank.Ks;
closefile(f_);
end;

procedure Tplatpp_.SpeedButton4Click(Sender: TObject);
begin
PopupMenu4.Popup(left+GroupBox1.Left+GroupBox2.Left+SpeedButton4.Left+10,top+GroupBox1.top+GroupBox2.top+SpeedButton4.Top+10);
end;

procedure Tplatpp_.MenuItem4Click(Sender: TObject);
 var f_:file;
   dir_:string;
   eee_:string;
   a_:word;
begin
getdir(0,dir_);
eee_:=bplNAME.Text;
for a_:=1 to length(eee_) do
    if ((ord(eee_[a_])>=48)and(ord(eee_[a_])<=57))or
       ((ord(eee_[a_])>=65)and(ord(eee_[a_])<=90))or
       ((ord(eee_[a_])>=97)and(ord(eee_[a_])<=122))or
       ((ord(eee_[a_])>=128)) then else eee_[a_]:=' ';
SaveDialog5.FileName:=eee_;
if not SaveDialog5.Execute then begin Chdir(dir_); exit; end;
Chdir(dir_);
bank.Name:=bplName.Text;
bank.Bik:=bplBIK.Text;
bank.Ks:=bplKS.Text;
assignfile(f_,SaveDialog5.FileName);
rewrite(f_,sizeof(bank));
blockwrite(f_,bank,1);
closefile(f_);
end;

procedure Tplatpp_.MenuItem6Click(Sender: TObject);
 var f_:file;
   dir_:string;
begin
getdir(0,dir_);
if  not OpenDialog6.Execute then begin chdir(dir_); exit; end;
chdir(dir_);
assignfile(f_,OpenDialog6.FileName);
reset(f_,sizeof(bank));
blockread(f_,bank,1);
bplName.Text:=bank.Name;
bplBIK.Text:=bank.Bik;
bplKS.Text:=bank.Ks;
closefile(f_);
end;

procedure Tplatpp_.MenuItem8Click(Sender: TObject);
 label 0,1,2;
 var Fs_:TSearchRec;
    dir_:string;
    eee_:string;
begin
if FindFirst('temp',faDirectory, Fs_)>0 then mkdir('temp');
if FindFirst('dbf',faDirectory, Fs_)>0 then mkdir('dbf');

getdir(0,dir_);
if  not OpenDialog7.Execute then begin chdir(dir_); exit; end;
chdir(dir_);
eee_:=OpenDialog7.FileName+chr(0);
copyfile(@eee_[1],'temp\temp.dbf',false);

errorBDE:=0;

end;

end.
