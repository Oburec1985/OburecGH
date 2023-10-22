unit uCorrectUTS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, uSpin, DCL_MYOWN, uWPProc, posBase,
  inifiles, ComCtrls, uBtnListView, uComponentServises, uCommonMath, uCommonTypes;

type
  utsSignal = class
  public
    correct:boolean;
    s:cwpsignal;
  end;

  selectSrc = class
  public
    s:csrc;
    start:cwpsignal;
    utsSignals:tstringlist;
    slist:tstringlist;
    // ��������� �� ����������� �������
    resshift:double;
    // ����� �������� � tdatetime
    trigstart:tdatetime;

    NoShiftChan:boolean;
    // ������ � LBox
    itemindex:integer;
    // ������ ������� ������� �� ��������� �� UTS
    NoUTSChans:tstringlist;
  public
    function getUTS(name:string):cwpsignal;
    procedure cleardata;
    constructor create;
    destructor destroy;
  end;

  TCorrectUTSFrm = class(TForm)
    GroupBox1: TGroupBox;
    AddBtn: TButton;
    DelBtn: TButton;
    StartSignalCB: TComboBox;
    Label1: TLabel;
    Memo1: TMemo;
    ThresheldLabel: TLabel;
    RadioGroup1: TRadioGroup;
    GroupBox2: TGroupBox;
    SignalsLB: TListBox;
    Splitter1: TSplitter;
    Label2: TLabel;
    ThresheldSE: TFloatSpinEdit;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    Label3: TLabel;
    ResSE: TFloatSpinEdit;
    EvalBtn: TButton;
    UTSLV: TBtnListView;
    NotUTSShiftCB: TCheckBox;
    NamedShiftCB: TCheckBox;
    SICONCB: TCheckBox;
    NumFrontIE: TIntEdit;
    NumFrontLabel: TLabel;
    UseDateTimeCB: TCheckBox;
    TestTimeEdit: TEdit;
    TestTimeLabel: TLabel;
    TestTimeBtn: TButton;
    procedure SignalsLBClick(Sender: TObject);
    procedure DelBtnClick(Sender: TObject);
    procedure UTSLVClick(Sender: TObject);
    procedure UTSLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure EvalBtnClick(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure SignalsLBDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure SignalsLBMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TestTimeBtnClick(Sender: TObject);
  private
    m:cwpObjMng;
    // �������������� ���
    lastfile,
    start,
    // ��� ������ ��������� � �����
    siconName:string;
    // ������ �������������� ������
    correctlist:tstringlist;
  private
    procedure UpdateSICON(p_src:selectsrc; fname:string);
    procedure SaveCfg;
    procedure LoadCfg;
    procedure clearsignals;
    // sList - ������ ������� UTS ������
    // NoUTS - ������ ������� �� ������� �� ������� UTS � mera �����
    procedure findUts(slist:tstringlist; noUTS:tstringlist; src:csrc);
    procedure ShowUTS(s:selectSrc);
    // ��������� ��������� (������ ������� ������ ������)
    procedure FillCB;
    // �������������� ��� UTS �� ��������
    procedure CorrectUTS;
  public
    procedure Linc(mng:cWPObjMng);
    // ���������� �������� ������
    procedure ShowSignals;
    function ShowModal:integer;
  end;

var
  CorrectUTSFrm:TCorrectUTSFrm;

  function isUTS(s:cwpsignal):boolean;


implementation

uses
 uWpExtPack;

{$R *.dfm}

procedure TCorrectUTSFrm.Linc(mng:cWPObjMng);
begin
  m:=mng;
end;

procedure TCorrectUTSFrm.ShowSignals;
var
  s:csrc;
  // ������ ������ �������������� uts �������� � �������� ����������
  ls:selectsrc;
  i:integer;
begin
  clearsignals;
  for I := 0 to m.srcCount - 1 do
  begin
    s:=m.GetSrc(i);
    ls:=selectsrc.Create;
    ls.s:=s;
    ls.itemindex:=signalsLB.Count;
    findUts(ls.utsSignals, ls.NoUTSChans, ls.s);
    signalsLB.AddItem(s.name,ls);
  end;
  if m.srcCount > 0 then
  begin
    SignalsLB.selected[0]:=true;
    SignalsLBClick(nil);
  end;
end;

procedure TCorrectUTSFrm.SignalsLBClick(Sender: TObject);
var
  str: string;
  I, j, k: integer;
  s:selectSrc;
  f:tinifile;
  d:tdatetime;
  slist:tstringlist;
  ch:char;
begin
  if (SignalsLB.SelCount>0) or (SignalsLB.Count=1) then
  begin
    for I := 0 to SignalsLB.count - 1 do
    begin
      if SignalsLB.Selected[I] then
      begin
        s := selectSrc(SignalsLB.Items.Objects[I]);

        f:=tinifile.Create(s.s.merafile.FileName);
        slist:=tstringlist.Create;
        f.ReadSections(slist);
        for j := 0 to slist.Count - 1 do
        begin
          str :=f.ReadString(slist.Strings[j],'DateTime','');
          if str<>'' then
          begin
            if DecimalSeparator=',' then
            begin
              ch:='.';
            end
            else
            begin
              ch:=','
            end;
            k:=pos(ch,str);
            if k>0 then
            begin
              str[k]:=DecimalSeparator;
            end;

            TestTimeEdit.Text:= str;
            break;
          end;
        end;
        slist.Destroy;

        ShowUTS(s);
        fillCB;

        exit;
      end;
    end;
  end;
end;

procedure TCorrectUTSFrm.SignalsLBDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  s:selectSrc;
begin
  with SignalsLB.Canvas do
  begin
    s := selectSrc(SignalsLB.Items.Objects[Index]);
    if s.utsSignals.Count=0 then
    begin
      //���� ��������������� ������ ������.
      Brush.Color := clRed;
      FillRect(Rect);
      Font.Color := RGB(255, 255, 255);
      TextOut(Rect.Left, Rect.Top, SignalsLB.Items[Index]);
    end
    else
    begin
      FillRect(Rect);
      if Index >= 0 then
        TextOut(Rect.Left + 2, Rect.Top, SignalsLB.Items[Index]);
      // ��������� ���������
      {Brush.Color := clWhite;
      FillRect(Rect);
      Font.Color := font.Color;
      TextOut(Rect.Left, Rect.Top, SignalsLB.Items[Index]);}
    end;
  end;
end;

procedure TCorrectUTSFrm.SignalsLBMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  i:integer;
  obj:selectSrc;
  h:boolean;
begin
  i:=signalsLB.ItemAtPos(point(x,y),true);
  h:=false;
  if i>=0 then
  begin
    obj := selectSrc(SignalsLB.Items.Objects[i]);
    if obj.utsSignals.Count=0 then
    begin
      h:=true;
    end;
  end;
  SignalsLB.ShowHint:=h;
end;

procedure TCorrectUTSFrm.TestTimeBtnClick(Sender: TObject);
var
  I, j: Integer;
  s:selectsrc;
  t:tdatetime;
  f:tinifile;
  str, ident, fname:string;
  slist:tstringlist;
  b:boolean;
begin
  for I := 0 to SignalsLB.Count - 1 do
  begin
    s:=selectsrc(SignalsLB.Items.Objects[i]);
    if s=nil then break;

    str:=s.s.merafile.FileName;
    fname:=extractfilename(str);
    fname:=trimext(fname);
    str:=extractfiledir(s.s.merafile.FileName)+'\'+fname+'_Tcor';
    while fileexists(str+'.mera') do
    begin
      str:=modname(str, false);
    end;
    str:=str+'.mera';
    correctlist.Add(str);

    fname:=s.s.merafile.FileName;
    CopyFile(@fname[1], @str[1], b);
    // ������ ����� � ������������ �����
    f:=tinifile.Create(str);
    slist:=tstringlist.Create;
    f.ReadSections(slist);
    f.DeleteKey('MERA', 'Date');
    f.DeleteKey('MERA', 'Time');
    for j := 0 to slist.Count - 1 do
    begin
      f.DeleteKey(slist.Strings[j], 'DateTime');
    end;
    f.UpdateFile;
    ModalResult:=mrOk;
  end;
end;

procedure TCorrectUTSFrm.UTSLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if utssignal(item.data).correct<>item.Checked then
  begin
    utssignal(item.data).correct:=item.Checked;
  end;
end;

procedure TCorrectUTSFrm.UTSLVClick(Sender: TObject);
var
  li:tlistitem;
begin

end;

constructor selectSrc.create;
begin
  utsSignals:=tstringlist.create;
  utsSignals.Sorted:=true;
  NoUTSChans:=tstringlist.Create;
  NoUTSChans.Sorted:=true;
end;

destructor selectSrc.destroy;
begin
  cleardata;
  utsSignals.Destroy;
  NoUTSChans.Destroy;
end;

function selectSrc.getUTS(name: string): cwpsignal;
var
  I: Integer;
  s:utssignal;
begin
  result:=nil;
  for I := 0 to utsSignals.Count - 1 do
  begin
    s:=utssignal(utsSignals.Objects[i]);
    if s.s.name=name then
    begin
      result:=s.s;
    end;
  end;
end;

procedure TCorrectUTSFrm.DelBtnClick(Sender: TObject);
var
  i:integer;
  s:selectSrc;
begin
  while SignalsLB.SelCount <>0 do
  begin
    for I := 0 to SignalsLB.count - 1 do
    begin
      if SignalsLB.Selected[I] then
      begin
        s := selectSrc(SignalsLB.Items.Objects[I]);
        s.destroy;
        SignalsLB.Items.Delete(i);
        break;
      end;
    end;
  end;
end;

procedure TCorrectUTSFrm.EvalBtnClick(Sender: TObject);
var
  s, s2:cwpsignal;
  I: Integer;
  x,y,v:double;
  trig, success:boolean;
  src:selectsrc;
  p:point2d;
  f:tinifile;
begin
  if StartSignalCB.ItemIndex<0 then exit;
  s:=cwpsignal(StartSignalCB.Items.Objects[StartSignalCB.ItemIndex]);
  if NamedShiftCB.checked then
  begin
    for I := 0 to signalsLB.Count - 1 do
    begin
      src:=selectsrc(signalsLB.items.Objects[i]);
      s2:=src.s.getSignalObj(s.Name);

      f:=TIniFile.Create(src.s.merafile.FileName);
      src.trigstart:=f.ReadDateTime(s2.name,'DateTime',0);

      f.Destroy;
      if s2<>nil then
      begin
        p:=s.getMinMaxX;
        src.resshift:=EvalTrig(s2,p.x, p.y,ThresheldSE.Value, (RadioGroup1.ItemIndex=0), numfrontie.IntNum, '', nil, success);
        signalsLB.Items.Strings[i]:=src.s.name+' �����='+floattostr(src.resshift);
        resse.Value:=src.resshift;
      end
      else
      begin
        signalsLB.Items.Strings[i]:=src.s.name;
      end;
    end;
  end
  else
  begin
    p:=s.getMinMaxX;
    resse.Value:=EvalTrig(s,p.x, p.y,(ThresheldSE.Value), (RadioGroup1.ItemIndex=0), numfrontie.IntNum,'', nil, success);
  end;
end;

procedure CorrectXFile(fname:string; format:string; shift:double);
var
  f:file;
  fsize, readed:cardinal;
  r4_data:array of double;
  r8_data:array of double;
  I: Integer;
  changed:boolean;
begin
  AssignFile(f, fname);
  if Assigned(@f) then
  begin
    changed:=false;
    Reset(f, 1); // ����� ����� ������������ �������.
    fsize:=FileSize(f);
    if format='R4' then
    begin
      changed:=true;
      fsize:=round(fsize/4);
      setlength(r4_data, fsize);
      blockread(f, r4_data, fsize*4, readed);
      for I := 0 to fsize - 1 do
      begin
        r4_data[i]:=r4_data[i]+shift;
      end;
      CloseFile(f); // ������� ����

      AssignFile(f, fname);
      Rewrite(f,1);
      BlockWrite(f, r4_data, fsize*4);
      CloseFile(f); // ������� ����
    end;
    if format='R8' then
    begin
      changed:=true;
      fsize:=round(fsize/8);
      setlength(r8_data, fsize);
      blockread(f, r8_data[0], fsize*8, readed);
      for I := 0 to fsize - 1 do
      begin
        r8_data[i]:=r8_data[i]-shift;
      end;
      CloseFile(f); // ������� ����

      AssignFile(f, fname);
      Rewrite(f,1);
      BlockWrite(f, r8_data[0], fsize*8);
      CloseFile(f); // ������� ����
    end;
  end;
  if not changed then
  begin
    CloseFile(f); // ������� ����
  end;
end;

procedure UpdateFile(p_src:selectsrc; shift:double; corlist:tstringlist; noUTSShift:boolean; var lastfile:string);
var
  u:utsSignal;
  s:cwpSignal;
  str, src, dst, fname, prop, folder:string;
  f:tinifile;
  lstart:double;
  b:boolean;
  i,j,k, ind: Integer;
  tfile:tstringlist;
begin
  str:=p_src.s.merafile.FileName;
  fname:=extractfilename(str);
  fname:=trimext(fname);
  str:=extractfiledir(p_src.s.merafile.FileName)+'\'+fname+'_Tcor';
  while fileexists(str+'.mera') do
  begin
    str:=modname(str, false);
  end;
  str:=str+'.mera';
  lastfile:=str;
  corlist.Add(str);
  src:=p_src.s.merafile.FileName;
  CopyFile(@src[1], @str[1], b);
  // ������ ����� � ������������ �����
  f:=tinifile.Create(str);
  fname:=str;
  for j := 0 to p_src.utsSignals.Count - 1 do
  begin
    u:=utssignal(p_src.utsSignals.Objects[j]);
    str:=floattostr(u.s.Signal.k0+shift);
    ind:=pos(',',str);
    if ind>0 then
    begin
      str[ind]:='.';
    end;
    f.WriteString(u.s.Name,'k0',str);
  end;
  // �������� ������ ��� UTS. ����� ���������� ������ ��� ��� ��������, �������
  // ����� � �����
  if noUTSShift then
  begin
    for j := 0 to p_src.NoUTSChans.Count - 1 do
    begin
      if p_src.NoUTSChans.Strings[j]='MERA' then continue;
      str:=f.Readstring(p_src.NoUTSChans.Strings[j],'Start','');
      if str='' then
        str:='0';
      if str<>'' then
      begin
        lstart:=strtofloatext(str);
        lstart:=lstart-shift;
        str:=floattostr(lstart);
        ind:=pos(',',str);
        if ind>0 then
        begin
          str[ind]:='.';
        end;
        f.Writestring(p_src.NoUTSChans.Strings[j],'Start',str);
        //f.Writefloat(p_src.NoUTSChans.Strings[j],'Start',strtoFloatExt(str));
      end;
    end;
  end;

  // ��������� �������� � ������� ��� x y
  tfile:=TStringList.Create;
  tfile.LoadFromFile(fname);
  folder:=extractfiledir(fname);
  for I := 0 to p_src.s.ChildCount - 1 do
  begin
    s:=p_src.s.getSignalObj(i);
    if isUTS(s) then continue;
    prop:=f.ReadString(s.name,'XFormat','');
    b:=false;
    //s.Signal.GetProperty('XFormat');
    if prop<>'' then
    begin
      for j := 0 to tfile.Count - 1 do
      begin
        if b then
        begin
          b:=false;
          break;
        end;
        str:=tfile.Strings[j];
        if pos(s.name,str)>0 then
        begin
          for k:=length(str) downto 1 do
          begin
            if str[k]=']' then
            begin
              setlength(str,k-1);
              str:=str+'_Tcor'+']';
              tfile.Strings[j]:=str;

              src:=folder+'\'+s.name+'.dat';
              dst:=folder+'\'+s.name+'_Tcor.dat';
              CopyFile(@src[1], @dst[1], b);

              src:=folder+'\'+s.name+'.x';
              dst:=folder+'\'+s.name+'_Tcor.x';
              CopyFile(@src[1], @dst[1], b);


              CorrectXFile(dst, prop, shift);
              b:=true;
              break;
            end;
          end;
        end;
      end;
    end;
  end;
  tfile.SaveToFile(fname);
  tfile.Destroy;
  f.Destroy;
end;

procedure TCorrectUTSFrm.UpdateSICON(p_src:selectsrc; fname:string);
var
  u:utsSignal;
  str, src:string;
  f:tinifile;
  lstart:double;
  b, success:boolean;
  i,j, ind: Integer;
  sections:tstringlist;
  sig:cWPSignal;
  shift, start:double;
  p:point2d;
begin
  str:=fname;
  // ������ ����� � ������������ �����
  f:=tinifile.Create(str);

  sections:=TStringList.Create;
  sections.Sorted:=true;
  f.ReadSections(sections);


  sig:=p_src.s.getSignalObj(SiconName);
  if sig=nil then exit;
  // 50 = 5000 Hz / 100 Hz
  p:=sig.getMinMaxX;
  shift:=EvalTrig(sig, p.x, p.y, ThresheldSE.Value, (RadioGroup1.ItemIndex=0), 0,'', nil, success)*50;

  for I := 0 to sections.Count - 1 do
  begin
    str:=f.ReadString(sections.Strings[i],'UTS_Channel','');
    if str='UTS-{ 0-uts}' then
    begin
      f.WriteFloat(sections.Strings[i],'Freq',100);
      str:=f.ReadString(sections.Strings[i],'Start','');
      if str<>'' then
      begin
        str:=floattostr(strtofloatext(str)-shift);
        ind:=pos(',', str);
        if ind>0 then
        begin
          str[ind]:='.';
        end;
        f.WriteString(sections.Strings[i],'Start',str);
      end;
    end;
  end;
  f.Destroy;
end;

procedure TCorrectUTSFrm.ApplyBtnClick(Sender: TObject);
var
  I,j, ind: Integer;
  s:selectsrc;
  dtime, d, t:tdatetime;
  trig, uts:cwpsignal;
  rshift, trigstartdouble:double;
  f:tinifile;
  str:string;
  ch:char;
begin
  EvalBtnClick(nil);
  for I := 0 to SignalsLB.Count - 1 do
  begin
    s:=selectsrc(SignalsLB.Items.Objects[i]);
    dtime:=0;
    rshift:=0;
    if not UseDateTimeCB.Checked then
    begin
      f:=tinifile.Create(s.s.merafile.FileName);
      d:=f.ReadDate('MERA','Date',0);
      // �����
      str:=f.ReadString('MERA','Time','');
      ch:=DecimalSeparator;
      if ch=',' then
      begin
        if pos('.', str)>0 then
        begin
          str:=replaceChar(str,'.', ch);
        end;
      end
      else
      begin
        if pos(',', str)>0 then
        begin
          str:=replaceChar(str,',', ch);
        end;
      end;
      t:=StrToDateTime(str);

      trig:=cwpsignal(StartSignalCB.Items.Objects[StartSignalCB.ItemIndex]);
      str:=f.ReadString(trig.name,'UTS_Channel','');
      uts:=s.getUTS(str);
      trigstartdouble:=0;
      if uts=nil then
      begin
        str:=f.Readstring(trig.name,'DateTime','0');
        str:=replaceChar(str,'.',DecimalSeparator);
        trigstartdouble:=strtoFloatExt(str);
        f.Destroy;
      end
      else
      begin
        trigstartdouble:=trig.Signal.GetX(0);
        // 86400 - ������ � ������
        trigstartdouble:=uts.Signal.GetYX(trigstartdouble, 1)/86400;
      end;
      dtime:=(d+t-trigstartdouble);
      rshift:=dtime*86400;
    end;
    if NamedShiftCB.Checked then
    begin
      UpdateFile(s, s.resshift-rshift, correctlist, NotUTSShiftCB.checked, lastfile);
    end
    else
    begin
      UpdateFile(s, ResSE.Value-rshift, correctlist, NotUTSShiftCB.checked, lastfile);
    end;
    // ���������� �����
    if SICONCB.Checked then
    begin
      UpdateSICON(s, lastfile);
    end;
  end;
end;

procedure TCorrectUTSFrm.clearsignals;
var
  s:selectsrc;
  i:integer;
begin
  for I := 0 to signalsLB.Count - 1 do
  begin
    s:=selectsrc(signalsLB.Items.Objects[i]);
    s.destroy;
  end;
  SignalsLB.Clear;
  utslv.clear;
end;

procedure TCorrectUTSFrm.findUts(slist:tstringlist; noUTS:tstringlist;src:csrc);
var
  I, ind: Integer;
  s:cwpsignal;
  sig:utssignal;
  path, utsname:string;
  ifile:tinifile;
  // ������ ��������
  sections:tstringlist;
begin
  if src.merafile<>nil then
  begin
    path:=src.merafile.FileName;
    ifile:=TIniFile.Create(path);
    sections:=TStringList.Create;
    sections.Sorted:=true;
    ifile.ReadSections(sections);
    for I := 0 to sections.Count - 1 do
    begin
      utsname:=ifile.ReadString(sections.Strings[i],'UTS_Channel','');
      if not slist.Find(utsname,ind) then
      begin
        s:=src.getSignalObj(utsname);
        if s<>nil then
        begin
          sig:=utssignal.Create;
          sig.s:=s;
          sig.correct:=true;
          slist.AddObject(utsname,sig);
        end;
      end;
      // ���� ����� �� ����� UTS
      if utsname='' then
      begin
        NoUTS.Add(sections.Strings[i]);
      end;
    end;
    ifile.Destroy;
    sections.Destroy;
  end;
end;

procedure TCorrectUTSFrm.ShowUTS(s:selectSrc);
var
  i:integer;
  signal:utssignal;
  li:tlistitem;
begin
  utslv.Clear;
  for i:=0 to s.utsSignals.Count - 1 do
  begin
    signal:=utsSignal(s.utsSignals.Objects[i]);
    li:=utslv.Items.Add;
    li.Data:=signal;
    utslv.SetSubItemByColumnName('�', inttostr(i), li);
    utslv.SetSubItemByColumnName('���', signal.s.Name, li);
    li.Checked:=signal.correct;
  end;
  if s.utsSignals.Count>0 then
    LVChange(utslv);
end;

function TCorrectUTSFrm.ShowModal:integer;
var
  li:tlistitem;
  i:integer;
begin
  m.ReadSrc;
  correctlist:=tstringlist.Create;
  showsignals;
  LoadCfg;
  if inherited = mrok then
  begin

  end;
  SaveCfg;
  clearsignals;
  for I := 0 to correctlist.Count - 1 do
  begin
    winpos.LoadUSML(correctlist.Strings[i]);
  end;
  refresh;
  correctlist.Destroy;
end;

procedure TCorrectUTSFrm.CorrectUTS;
begin

end;



procedure TCorrectUTSFrm.FillCB;
var
  I: Integer;
  sel:selectsrc;
  s:cwpsignal;
begin
  startsignalcb.Clear;
  sel:=nil;
  for I := 0 to signalsLB.Items.Count - 1 do
  begin
    if signalsLB.Selected[i] then
    begin
      sel:=selectsrc(signalsLB.Items.Objects[i]);
      break;
    end;
  end;
  if sel<>nil then
  begin
    for I := 0 to sel.s.childCount - 1 do
    begin
      s:=sel.s.getSignalObj(i);
      startsignalcb.Items.AddObject(s.Name, s);
    end;
    startsignalcb.ItemIndex:=-1;
    for I := 0 to startsignalcb.Items.Count - 1 do
    begin
      if StartSignalCB.Items.Strings[i]=start then
      begin
        StartSignalCB.ItemIndex:=i;
        break;
      end;
    end;
  end;
end;

procedure selectSrc.cleardata;
var
  I: Integer;
  s:utssignal;
begin
  for I := 0 to utsSignals.Count - 1 do
  begin
    s:=utssignal(utsSignals.Objects[i]);
    s.Destroy;
  end;
  NoUTSChans.Clear;
  utsSignals.Clear;
end;


procedure TCorrectUTSFrm.SaveCfg;
var
  ifile:tinifile;
begin
  ifile:=tinifile.Create(startdir+'CorrectUTS.ini');
  ifile.writestring('main','start',StartSignalCB.Text);
  ifile.WriteFloat('main','Threshold',ThresheldSE.Value);
  ifile.WriteInteger('main','Front',RadioGroup1.ItemIndex);
  ifile.WriteBool('main','ShiftNoUts',NotUTSShiftCB.Checked);
  ifile.WriteBool('main','SICON',SICONCB.Checked);
  ifile.writestring('Main', 'SICONNAME', SiconName);
  ifile.Destroy;
end;

procedure TCorrectUTSFrm.LoadCfg;
var
  ifile:tinifile;
begin
  ifile:=tinifile.Create(startdir+'CorrectUTS.ini');
  start:=ifile.ReadString('Main','Start',StartSignalCB.Text);
  ThresheldSE.Value:=IniReadFloatEx(ifile,'Main','Threshold',0.5);
  RadioGroup1.ItemIndex:=ifile.ReadInteger('Main','Front',0);
  NotUTSShiftCB.Checked:=ifile.ReadBool('main','ShiftNoUts',false);

  SICONCB.Checked:=ifile.ReadBool('main','SICON', false);
  SICONCB.Visible:=SICONCB.Checked;
  SiconName:=ifile.ReadString('Main','SICONNAME','�����_��');

  ifile.Destroy;
end;

function isUTS(s:cwpsignal):boolean;
var
  I: Integer;
begin
  result:=false;
  for I := 0 to CorrectUTSFrm.UTSLV.Items.Count - 1 do
  begin
    if s.name=utssignal(CorrectUTSFrm.UTSLV.items[i].data).s.name then
    begin
      result:=true;
      exit;
    end;
  end;
end;


end.
