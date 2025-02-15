
unit Types4bld;
{$OPTIMIZATION OFF}
interface
uses Windows,Classes,Series;



type

  //������������ �������
 TArrofSer=array of TLineSeries;
 //TArrofDbBuf=array of TCDBuff;
 TArrofboolean=array of boolean;
 TArrofInteger=array of Integer;

  TIndex=packed record
           Chan:Byte;  //��������� � ����
           Marker:Byte;
           Ticks:Cardinal;
  end;

  TVideo=packed record
           Chan1:byte;
           Sample1:Word;
           Chan2:Byte;
           Sample2:Word;
         end;

  TChangeStateType = (
    tcstEnterRise,   {������ ������}
    tcstLeaveRise,   {������ ����������}
    tcstEnterDrain,  {����� ������}
    tcstLeaveDrain); {����� �����������}

  type TTypeOfTime=(SEV,IRIG);

  TAngleGate=packed record //����������� ������� ���� � ������� ���������/���������
               Chan:Byte;  // ������ ��������, ����������� �� ������ Chan
               TachoChan:Byte; //��� ������������� �� ����� ������
               Blade:Byte;     //�������� ������� � ���� �������
               AdjChan:Byte;   //����� "���������" � ���� �������
               Marker3:Byte;
               Marker4:Byte;
               lpillar:Single;//����� ������ 0-1
               rpillar:Single;// ������ ������ 0-1
             end;


  TMyHead=packed record
           Ident: String[15];
           HeadLength:Word;//����� ����� ���������, ����������� ���������� � ����, ��� ������.
       end;


    TTypeSensor=(srRoot,srPeak,srInEdge,srOutEdge,srTaho,srRoot_cap,srPeak_cap,srUTS,srIRIG_B);

    TMode=(mdDynamic,mdStatic);

 TSensor=packed record     // ��������� ������
   NameSensor:String;       // ���(�����������) �������
   Chan:Word;               // ����� ������ � ���������� (������� � ����)
   TypeSensor:TTypeSensor;  // ��� ������� (���������,������������,��������)
  end;





  TArrIndex=array[0..$fffffff] of TIndex; //���
  PArrayIndex = ^TArrIndex;
  ArrLongWord=array[0..1000000] of LongWord;{Unsigned 32}
  PArrLongWord=^ArrLongWord;
  TState=(stStopped,stOscill,stProcessing);
  TStatus=(stOn,stOff);
  Tacquisition=(taPlate,taDisk,taNo);// ����� ������ � ����� ��� �� �����
  TArr_of_Indx = array[0..$fffffff] of TIndex;
  TpArr_of_Indx = ^TArr_of_Indx;
  PArrDouble=^TArrDouble;
  TArrDouble=array[0..1000000] of Double;
  TArrSmallInt=array[0..1024-1] of SmallInt;
    PArrSingle=^TArrSingle;
  TArrSingle=array[0..1000000] of Single;
  TMtxDouble=array[0..32-1,0..32-1] of Double;
  PMtxDbl=^TMtxDouble;
  TMArray=array of array[0..1] of Single;


  TFlags=packed record
        {}  Exit :Integer;    //����������� � flgExit:
        {}           (*���������� ������ �����: 2 - ������ �� ����������� ����� ;
        {}            ��� 1 -��������� ��������� ����� � ��������� 0. ���� 0 ������ �������� *)
        {}  flgRecord :Integer;//=0;
        {}     (*����������� � flgRecord: 7-�������� ��������� ����� ������� ������ ������ �����- ������ �� ������ ������ �����
        {}                     ���� =7 �� ��������� ������������� �����, �������� ��������� �����, ��������� 6
        {}                     ���� = 6 ���� � Processing - ������ ���������� ����� � ����,
        {}                     ���� =4 - ������ �� �������� �����, ������� ������� ���� � ��������� 2
        {}                     ���� 2 ���� ��� ������, �� ���������� ����������� ������� ����� ������  �� ������� ��� ������
        {}                      �� ����� (����� ����).� ��� ����� ����� �������� ����������� ����
        {}                     ���� =0 ������ �� ������������, ����� ������ �������� ������ ����� �������� ����� ������ *)
        {}  Contasq:Boolean;//=FAlse;//�������� �������� ��� ������ �� ������������ ����� ������
        {}  Auto:Boolean;//=False; //�������� �������� � ���������� ������ � Wat�hdog-�� � ��� ��������� ����
        {}                       // � ����� ������������� �������� ������
        {}  Server:Boolean;//=False;//�������� ���������������� ������
        {}  WDT:Boolean;//=False;//watchdog ��������������� ?
        {}  SEV:Boolean;//=False; //�������� �������� � �������� ���
        {}  Conjugatefile:Boolean;//���� ������ ����������� ����� ������� *.bld � "�����������" ����� *.bldc
        {}  FirstCycle:Boolean; // ���� ������� ����� ������������ ��� ������� �����
        {}  BurstFile:Boolean;  // ���� ������� � ����� ������� ����
        {}  autogain:Boolean;//=False;//�������� ������������ ���������� �������� ��� ������� ����
        {}  irror:Integer;  // ���-�� ������� �� ������� ������� ���������
        {}  Jrnl,JrnlFlash:Boolean;//�������� ����� ������
        {}  Loss:Boolean;//=False;
        {}  InRange:Boolean; //���� ��� ����������
        {}  View: Boolean; // ���������� ��� ��� 
        {}
        end;
   PFlags=^TFlags;

  TBuf=packed record
         Buf: PArrayIndex;  //����� ���� ����� ������� ����������� ���������
         BufEnd:Cardinal; // ������ ����� ������ � ��������.
         BuffSize:Cardinal; //������ �������������� ����� ������ � ������, ������� �� volatile
         BSIndx:Cardinal; //������ ������, ������������� �� API �����  - �� ��, ��� BuffSize, ������ � ��������
         AcqIndex:Cardinal; //������� �� volatile
         ProcIndex:Cardinal;//������� ������ Buf ��� ������� � ���������, ProcIndex "��������" AcqIndex.
         BaseTime:Double;//1/40 ��� 1/32 � ����������� �� �����
       end;
PBuf=^TBuf;       


TInternalPluginInfo = record
   Name: string; //������������ plug-in`�
   Dsc: string; //������ ��������
   Vendor: string; //������ ������������ �����
   Version: integer; //����� ������
   SubVersion: integer; //����� ���������
end;
   PluginInfo=^TInternalPluginInfo;

const

 maskBurst:Byte=$01;
 maskRotRise:Byte=$02;
 maskRotFall:Byte=$04;

 BsTimeM2081=1/40{ ��� };
 //BsTimeM2070=1/32{ ��� };
 BsTimeM2070=1/40{ ��� };
 cMera=$10B5;
 cM2081=$6081;
 cM2070=$6083;
 //��� ������������ ����� ������ ������ ����� � ������
 //      -������ ������, ������� ���� ������, � �������� FIFO ������ NFrame ����� �������
 NWord: array[0..6] of Word = ( 126, 255,510,1023,2046,4095, 6141 );
                //������ �� ������� ������������ ������������ ����� �����
 cIncrmdls: array[0..7] of Word=(0, 20, 40, 100, 200, 500, 1000,5000);
                //������� ��������� � ��������
 cStopTimes: array[0..9] of Word=(0,5,15,45,60,120,300,600,1800,3600);

                //������� ������ � ��������
 cStartTimes: array[0..9] of Word=(0,5,15,45,60,120,300,600,1800,3600);

 cPartFifo=8;//���������� ������� FIFO � ������ DMA API�����(���� �� �������� ���������)
 cSafetyfactor=10;//���������� ������� ������ BladeRecorder �� ������ ���� �� �������� ���������
 cFrame=10;//���-�� ������� �����, ����������� �������� FIFO
 //��� ��������� ����� (�������������������)
 cMode=$6;
 cBufSize=4096;
 cRate=10000;
 SynchChan=0;
// KfTaho=33.25/33;
 NumPort=2;

 cGateIdent='Mera DFM Gates ';
 //����� � ������������ ����������� � �����
 FileNameBios= 'BIOS\m2081lop.bio';  //����� �� 7.05.03
 FileNameFlex= 'BIOS\fl2081lpn.rbf';    //  v4_lpn.rbf ��� ������ 4 �2081, � ������ 374
                                     // fl2081lpn.rbf - ��� ������ ������
 //������� ������ ���������
 Vers=1000;
 // NumberFiles=99; //100 ��������� ����� ������ ���������� � ����


 TwoPi:Double=2*Pi;
 HistL=131072{65536}; //���������� ����������� ������������� ����������
 HistLDraft=16384{8192};//���������� �������� ����������

 cMaxChan = 32;
 cMaxBlade = 255;//���-�� ������������ ���� ����
 cSignatureMarker=cMaxBlade; // ������������� �������� ����������� ���� �� ���������
 cMaxTaho = 4;
 cMaxPairs = cMaxChan div 2;
 cMaxStages = 3{MaxPairs};
 cMaxSensors = cMaxChan;
 cMaxImpuls = cMaxBlade*2;
 cMaxHarm = 32;
 MaxResonance = 12;
 CfBadBlade = 0.2;



function Sngl2Dbl(sng:Single):Double;


 implementation

function Sngl2Dbl(sng:Single):Double;//
begin Result:=sng;                   //
end; ////----------------------------//



end.
