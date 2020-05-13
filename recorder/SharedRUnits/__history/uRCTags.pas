unit uRCTags;

interface
uses
  Windows,
  recorder,
  tags,
  types,
  plugin,
  iplgmngr,
  ActiveX,
  SysUtils,
  SyncObjs,
  Classes,
  ExtCtrls,
  blaccess,
  uEventList,
  uRecorderEvents,
  dialogs,
  nativexml,
  inifiles,
  uCommonTypes,
  ucommonmath,
  u2dmath,
  uRCFunc,
  complex,
  uPathMng,
  uMyMath,
  uHardwareMath,
  variants;

type
  cFFTFltTag = class
  private // вычисляемые параметры
    foverflow:integer; // m_FFTCount-m_FFTShift;
    ffirstblock:boolean; // обработка первого блока который идет без перекрытия предыдущего
  private
    finTag:cTag;
    m_freq,m_dx, m_dF:double;
    m_FFTCount:integer;
    // смещение для след блока (можно считать с перекрытием)
    m_FFTShift:integer;
    m_inData:TAlignDCmpx;
    m_inData1:TAlignDCmpx;
    // настройки спектра
    m_FFTPlan:TFFTProp;
    // обратный FFT
    m_iFFTPlan:TFFTProp;
    // набор множителей для фильтрации спектра (длина = FFTCount)
    m_func:TDoubleArray;
    // индекс последнего заполненного отсчета после выполнения EvalData
    flastindex:integer;
  public
    m_outData:TDoubleArray;
  protected
    procedure setintag(t:cTag);
  public
    procedure Start;
    // шуршит по входному буферу на предмет наличия свежих данных и перемолачивает их в выходной буфер
    function EvalData:integer;
    procedure setCorrFunc(func:TDoubleArray);
    procedure setFFTCount(fftCount, Shift:integer);
    property inTag:ctag read fInTag write setInTag;
  end;

  cFileTag = class
  public
  private
    m_threadID:cardinal;
    m_f:file;
    m_freq:double;
    m_filename:string;
    m_Datafilename:string;

    m_name:string;
    m_block:pointer;
    m_blSize:cardinal;
    m_start:double;
    m_record:boolean;
    m_time:double;
  protected
  public
    constructor create(p_name:string; p_freq:double);
    procedure saveBlock(time:double);overload;
    procedure saveBlock(time:double; count:integer);overload;
    procedure StopRecord;
    procedure StartRecord(merafile:string);
    function recordState:boolean;
    // size - размер блока исходного тега; block - ссылка на m_TagData исходного тега
    procedure setBlock(size:cardinal;var block:pointer);
    procedure setBlockSize(size: cardinal);
  public
    property name:string read m_name write m_name;
    property freq:double read m_freq write m_freq;
  end;


implementation

{ cFileTag }

constructor cFileTag.create(p_name: string; p_freq: double);
begin
  m_time:=-1;
  name:=p_name;
  freq:=p_freq;
end;

function cFileTag.recordState: boolean;
begin
  result:=m_record;
end;

procedure cFileTag.saveBlock(time:double);
begin
  if m_time=-1 then
    m_start:=time;
  m_time:=time;

  Seek(m_f,FileSize(m_f));
  BlockWrite(m_f, TDoubleDynArray(m_block)[0] , m_blSize*sizeof(double));
end;

procedure cFileTag.saveBlock(time:double; count:integer);
begin
  if m_time=-1 then
    m_start:=time;
  m_time:=time;

  Seek(m_f,FileSize(m_f));
  BlockWrite(m_f, TDoubleDynArray(m_block)[0] , count*sizeof(double));
end;

procedure cFileTag.setBlock(size: cardinal; var block: pointer);
begin
  m_blSize:=size;
  //m_block:=Addr(block);
  m_block:=block;
end;

procedure cFileTag.setBlockSize(size: cardinal);
begin
  m_blSize:=size;
end;

procedure cFileTag.StartRecord(merafile:string);
var
  fname:string;
begin
  m_threadID:=GetCurrentThreadId;
  m_record:=false;
  if RStateRec then
  begin
    m_filename:=merafile;
    fname:=ExtractFileDir(m_filename)+'\'+name+'.dat';
    m_Datafilename:=fname;
    if not fileexists(fname) then
    begin
      m_record:=true;
      AssignFile(m_f,m_Datafilename);
      Rewrite(m_f,1);
    end;
  end;
end;

procedure cFileTag.StopRecord;
var
  ifile:tinifile;
begin
  if m_threadID=GetCurrentThreadId then
  begin
    if recordstate then
    begin
      closefile(m_f);
      ifile:=TIniFile.Create(m_filename);
      ifile.WriteFloat(name, 'Freq', m_freq);
      ifile.WriteString(name, 'YFormat', 'R8');
      ifile.WriteFloat(name, 'Start', m_start);
      // k0
      ifile.WriteFloat(name,'k0',0);
      // k1
      ifile.WriteFloat(name,'k1',1);
      ifile.destroy;
      m_record:=false;
    end;
  end;
end;

procedure multArrays(a1:TDoubleArray;var a2:TCmxArray_d);
var
  I, l: Integer;
begin
  l:=length(a1);
  for I := 0 to l - 1 do
  begin
    a2[i].re:=a2[i].Re*a1[i];
    a2[i].im:=a2[i].im*a1[i];
  end;
end;

function cFFTFltTag.EvalData:integer;
var
  b,
  // перекрытие блоков
  offset:boolean;
  blInd, i1, i2, len:integer;
  I, ind, ind1: Integer;
  k:double;
begin
  i1:=0;
  i2:=m_FFTCount;
  blInd:=0;
  offset:=m_FFTShift<m_FFTCount;
  i:=0;
  if fintag.lastindex>m_fftcount then
    b:=true
  else
    b:=false;
  while b do
  begin
    m_FFTPlan.StartInd:=i1;
    fft_al_d_sse(tdoublearray(finTag.m_ReadData),TCmxArray_d(m_inData.p), m_FFTPlan);
    // частотная коррекция спектра
    multArrays(m_func,TCmxArray_d(m_inData.p));

    m_iFFTPlan.StartInd:=0;
    ifft_al_d_sse(TCmxArray_d(m_inData.p), TCmxArray_d(m_inData1.p), m_iFFTPlan);
    ind:=blind*m_FFTCount;
    // если не первый блок
    if not ffirstblock then
    begin
      for I := 0 to m_FFTShift-1 do
      begin
        m_outData[ind]:=TCmxArray_d(m_inData1.p)[i].re;
        inc(ind);
      end;
      for I := (m_FFTShift) to (m_FFTCount-1) do
      begin
        k:=(m_FFTCount-1-i)/(overflow-1);
        m_outData[ind]:=k*m_outData[ind]+(1-k)*TCmxArray_d(m_inData1.p)[i-m_FFTShift].re;
        inc(ind);
      end;
    end
    else
    begin
      for I := 0 to m_FFTCount-1 do
      begin
        m_outData[ind]:=TCmxArray_d(m_inData1.p)[i].re;
          inc(ind);
      end;
    end;
    if blind>0 then
    begin
      // расчет с перекрытием
      if offset then
      begin
        i1:=i1+m_FFTShift;
      end
      // расчет без перекрытия
      else
      begin
        i1:=i1+m_FFTCount;
      end;
    end;
    inc(blInd);
    i1:=i1+m_FFTShift;
    if (i1+m_fftcount)>fintag.lastindex then
    begin
      b:=false
    end
    else
    begin
      i2:=i1+m_fftcount;
    end;
  end;
  flastindex:=i1;
  if flastindex>finTag.lastindex then
  begin
    showmessage('if flastindex>finTag.lastindex then');
  end;
  result:=flastindex;
end;

procedure cFFTFltTag.setCorrFunc(func: TDoubleArray);
begin
  m_func:=func;
end;

procedure cFFTFltTag.setFFTCount(fftCount, Shift:integer);
var
  I: Integer;
begin
  foverflow:=fftCount - Shift;
  m_FFTPlan:=GetFFTPlan(fftCount);
  m_iFFTPlan:=GetInverseFFTPlan(fftCount);
  GetMemAlignedArray_cmpx_d(fftCount, m_inData);
  GetMemAlignedArray_cmpx_d(fftCount, m_inData1);
  m_FFTCount:=fftCount;
  m_FFTShift:=shift;
  if fInTag<>nil then
  begin
    m_freq:=fInTag.freq;
    m_dx:=1/m_freq;
    m_dF:=0.5*m_freq/fftcount;
    setlength(m_outData,fintag.m_ReadSize);
  end;
  // тестовая функция
  setlength(m_func, fftcount);
  for I := 0 to m_FFTCount - 1 do
  begin
    m_func[i]:=1;
  end;
  //m_func[0]:=0;
end;

procedure cFFTFltTag.setintag(t: cTag);
begin
  finTag:=t;
end;

procedure cFFTFltTag.Start;
begin
  ffirstblock:=true;
end;

end.
