unit uNiiPM;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, ActiveX, Classes, ComObj, uNiiPMlib_TLB, StdVcl, uBaseObjService,
  Winpos_ole_TLB, POSBase, SysUtils, Forms, uNIIPMTenzopluginForm, uWPProcFrm,
  uWPProc, dialogs, variants, uCommonMath, uWPServices, uFindMax, libniipm_tlb;

type

  TNiiPM = class(TAutoObject, IWPPlugin)
  protected
    eoAmpFind: TExtOperAmpFind;
  protected
    function Connect(const app: IDispatch): Integer; safecall;
    function Disconnect: Integer; safecall;
    function NotifyPlugin(what: Integer; var param: OleVariant): Integer; safecall;
  end;

implementation

uses ComServ;

const
  vbEmpty=0;
  vbNull=1;
  vbInteger=2;
  vbLong=3;
  vbSingle=4;
  vbDouble=5;
  vbCurrency=6;
  vbDate=7;
  vbString=8;
  vbObject=9;
  vbError=10;
  vbBoolean=11;
  vbVariant=12;
  vbDataObject=13;
  vbDecimal=14;
  vbByte = 17;
  vbArray=8192;

var
  ID_RunNIIPM : Integer=0;
  ID_RunFx : Integer=0;
  // ���������� �� ������� ���������� ���������
  ID_NotifyEvent : cardinal;
// ��������� �� ������ �������

var
  bar_ID : Integer;
  mng:cWPObjMng;

function TNiiPM.Connect(const app: IDispatch): Integer;
var
  hbmp,hbmp2:THandle;
begin
  WINPOS:=app as IWinPOS;

  eoAmpFind:= TExtOperAmpFind.Create();
  WINPOS.RegisterExtOper( eoAmpFind, 1, 1, '����� �����������', 'AmpFind', FALSE );


  ID_NotifyEvent:=9 shl 16 +1;
  ID_RunNIIPM:= WINPOS.RegisterCommand();
  ID_RunFx:= WINPOS.RegisterCommand();

  bar_ID:=WINPOS.CreateToolbar();
  // hinstans - ���������� ���������� ������� �������� ��������������� ����������
  hbmp:= LoadBitmap(HInstance,'NIIPMBUTTON');
  hbmp2:= LoadBitmap(HInstance,'Fx');
  WINPOS.CreatetoolbarButton(bar_ID,ID_RunNIIPM,hbmp,
          '�����_�����������'#10'�����_�����������');

  WINPOS.CreatetoolbarButton(bar_ID,ID_RunFx,hbmp2,
         '�������� ���������'#10'�������� ���������');

  //hbmp:= LoadBitmap(HInstance,'RANDOM');
  //WINPOS.CreatetoolbarButton(bar_ID,ID_RunRnd,hbmp,'���� ���������� ����'#10'��������� ����');
  Result:=0;
  LoadStrings(extractfiledir(application.exename)+'\plugins\NIIPM\Services.Ini');

  mng:=cWPObjMng.create;

  // �������� ����
  NIIPMForm:=TNIIPMForm.Create(nil);
  FxForm:=TFxForm.Create(nil);
end;

function TNiiPM.Disconnect: Integer;
begin
  Result:=0;
end;

var InPlugunCode : Boolean = False;

function TNiiPM.NotifyPlugin(what: Integer;var param: OleVariant): Integer;
var
  alg, src:string;
  str1, str2:string;
  strList:tstringlist;
  o:coperobj;
  signalopts:csignalsopt;
  I: Integer;
  // � �������� ���������� ��������� ��������
  double:boolean;
begin
  Result:= 0;
  if not InPlugunCode then
  begin
  InPlugunCode:= true;
  try
    try
      // ����� �� ������� ������������ case, �.�. ID_Run1 - ����������, � �� ���������
      // ����� LoWord(what)=2 - "2" ������������� ������� ������ �������
      if HiWord(what)=ID_RunNIIPM
      then
      begin
        NIIPMForm.ShowModal;
      end;
      if HiWord(what)=ID_RunFx
      then
      begin
        FxForm.ShowModal(mng);
      end;
      if what=$000a0001
      then
      begin

      end
      else
      // ������ �������� ������ ��������� � ������ ��������
      if what=$000f0001
      then
      begin
        STR1:=param;
        // ������ ��� �� �������� ��� ������
        strList:=ParsStrParam(str1);
        o:=mng.AddOper(GetOperName(strlist),GetOperParams(strlist));
        signalopts:=GetSignalOpts(strlist,0);
        o.AddSrc(signalopts);
        if signalopts<>nil then
        begin
          for I := 1 to strlist.Count - 1 do
          begin
            signalopts:=GetSignalOpts(strlist,i);
            if signalopts<>nil then
            begin
              o.AddSrc(signalopts);
            end
            else
            begin
              break;
            end;
          end;
        end;
        // ������� ��������� ��������
        DeleteParsResult(strlist);
      end;
      // ������� ���������� ���������
      if what=ID_NotifyEvent
      then
      begin
        //str1:=VarArrayGet(param,[0]);
        //str2:=VarArrayGet(param,[1]);
        //mng.AddOper(str1,str2);
      end;
      Result:=0;
    finally
      begin
        InPlugunCode:= False;
      end;
    end
  except
  end;
  end;
end;

initialization

 TAutoObjectFactory.Create(ComServer, TNiiPM, CLASS_NIIPM,
   ciSingleInstance, tmApartment);

end.
