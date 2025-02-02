unit uSubRegsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN,
  uCommonTypes, uCommonMath,
  Winpos_ole_TLB, POSBase, uWPservices,
  uWPProc, uWPProcServices, ExtCtrls
  ;

type
  TSubRegsFrm = class(TForm)
    Label3: TLabel;
    Label14: TLabel;
    BandLengthFE: TFloatEdit;
    BandIntervalShiftFE: TFloatEdit;
    SubdivBtn: TButton;
    Timer1: TTimer;
    procedure SubdivBtnClickTimer(Sender: TObject);
    procedure SubdivBtnClick(Sender: TObject);
  public
  private
    m_continue:boolean;
    fm:IWPUSML;
  public
    procedure Stop;
    procedure ShowReg(m:IWPnode);
  end;

var
  SubRegsFrm: TSubRegsFrm;

implementation

{$R *.dfm}

{ TSubRegsFrm }

procedure TSubRegsFrm.ShowReg(m: iwpnode);
begin
  fm:=TypeCastToIWPUSML(m);
  if fm<>nil then
  begin
    caption:='������������� �����: '+extractfilename(fm.filename);
    inherited showmodal;
  end;
end;

procedure TSubRegsFrm.Stop;
begin
  m_continue:=false;
  //timer1.Enabled:=false;
end;

procedure TSubRegsFrm.SubdivBtnClick(Sender: TObject);
begin
  //timer1.Enabled:=true;
end;

procedure TSubRegsFrm.SubdivBtnClickTimer(Sender: TObject);
var
  p2, siginterval: point2d;
  str, path, savepath: string;
  i, j, start, endind: Integer;
  sig, parentsig: iwpsignal;
  d: IDispatch;
  // �������� ���� �� �������� saveusml
  dir, srcFile, dstFile, fname: string;
  b: boolean;
  n, src: iwpnode;
  datasize, readed: Integer;
  m:iwpusml;
  parentList: tstringlist;
begin
  siginterval:=GetStartStop(fm);
  p2.x:=siginterval.x;
  p2.y:=p2.x+bandLengthfe.FloatNum;
  src := GetCurSrcInMainWnd;
  m_continue:=true;
  while p2.x<siginterval.y do
  begin
    if not m_continue then
      break;
    if p2.y>siginterval.y then
      p2.y:=siginterval.y;
    if src <> nil then
    begin
      str := src.AbsolutePath;
      fname:=TrimExt(src.name);
      path := str + '/'+fname+'_sub_001';
      d := wp.GetNodeStr(path);
      while Supports(d, DIID_IWPNode) do
      begin
        path := modname(path, false);
        d := wp.GetNodeStr(path);
      end;
      for i := 0 to getChildCount(src) - 1 do
      begin
        sig:=GetChildSignal(src,i);
        if sig=nil then
          break;
        start := sig.IndexOf(p2.x);
        endind := sig.IndexOf(p2.y);
        sig := sig.Clone(start, endind - start) as iwpsignal;
        wp.Link(path, sig.sname, sig);
      end;
      wp.Refresh;

      sig := nil;
      if isusml(src) then
      begin
        m:=TypeCastToIWPUSML(src);
        dir := extractfiledir(m.FileName) + '\';
        savepath := dir;
        for j := length(path) downto 1 do
        begin
          if path[j] = '/' then
          begin
            str := Copy(path, j + 1, length(path) - j);
            savepath := savepath + str + '\' + str + '.mera';
            break;
          end;
        end;
        wp.SaveUSML(path, savepath);
      end;
      p2.x:=p2.y+BandIntervalShiftFE.FloatNum;
      p2.y:=p2.x+bandLengthfe.FloatNum;
    end;
  end;
end;

end.
