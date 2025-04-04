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
  mathfunction,
  u2dmath,
  uRCFunc,
  complex,
  uPathMng,
  uMyMath,
  uHardwareMath,
  variants;

type
  cFFTFltTag = class
  private // ����������� ���������
    foverflow: integer; // m_FFTCount-m_FFTShift;
    ffirstblock: boolean; // ��������� ������� ����� ������� ���� ��� ���������� �����������
  private
    finTag: cTag;
    m_freq, m_dx, m_dF: double;
    m_FFTCount: integer;
    // �������� ��� ���� ����� (����� ������� � �����������)
    m_FFTShift: integer;
    m_inData: TAlignDCmpx;
    // ��������������� ������� ������ ����� iFFT
    m_inData1: TAlignDCmpx;
    // ��������� �������
    m_FFTPlan: TFFTProp;
    // �������� FFT
    m_iFFTPlan: TFFTProp;
    // ����� ���������� ��� ���������� ������� (����� = FFTCount)
    m_func: TDoubleArray;
    // ������ ���������� ������������ ������� ����� ���������� EvalData
  public
    // ������ ���������� ������� � �������� ������
    m_lastindex,
    // ���������� ������� � ������ � ����� �����
    m_readyPoints: integer;
    // ������ �������� �������� ������� ����� �������� ��������� � �������� ���������� ���������� �����
    ///m_indInTag: integer;
    m_outData: TDoubleArray;
  protected
    procedure setintag(t: cTag);
  public
    procedure Start;
    // ������ �� �������� ������ �� ������� ������� ������ ������ � �������������� �� � �������� �����
    // ������ � ������ ���������� �������
    function EvalDataWithShift: integer;
    procedure resetData;overload;
    procedure resetData(lind:integer);overload;
    procedure setCorrFunc(func: TDoubleArray);
    procedure setFFTCount(fftCount, Shift: integer);
    property inTag: cTag read finTag write setintag;
  end;

  cFileTag = class
  public
  private
    m_threadID: cardinal;
    m_f: file;
    m_freq: double;
    m_filename: string;
    m_Datafilename: string;

    m_name: string;
    m_block: pointer;
    m_blSize: cardinal;
    m_start: double;
    m_record: boolean;
    m_time: double;
  protected
  public
    constructor create(p_name: string; p_freq: double);
    procedure saveBlock(time: double); overload;
    procedure saveBlock(time: double; count: integer); overload;
    procedure saveBlock(time: double; from: integer; count: integer); overload;
    procedure StopRecord;
    procedure StartRecord(merafile: string);
    function recordState: boolean;
    // size - ������ ����� ��������� ����; block - ������ �� m_TagData ��������� ����
    procedure setBlock(size: cardinal; var block: pointer);
    procedure setBlockSize(size: cardinal);
  public
    property name: string read m_name write m_name;
    property freq: double read m_freq write m_freq;
  end;

implementation
uses
  pluginclass;

{ cFileTag }

constructor cFileTag.create(p_name: string; p_freq: double);
begin
  m_time := -1;
  name := p_name;
  freq := p_freq;
end;

function cFileTag.recordState: boolean;
begin
  result := m_record;
end;

procedure cFileTag.saveBlock(time: double);
begin
  if m_time = -1 then
    m_start := time;
  m_time := time;

  Seek(m_f, FileSize(m_f));
  BlockWrite(m_f, TDoubleDynArray(m_block)[0], m_blSize * sizeof(double));
end;

procedure cFileTag.saveBlock(time: double; count: integer);
begin
  if m_time = -1 then
    m_start := time;
  m_time := time;

  Seek(m_f, FileSize(m_f));
  BlockWrite(m_f, TDoubleDynArray(m_block)[0], count * sizeof(double));
end;

procedure cFileTag.saveBlock(time: double; from: integer; count: integer);
begin
  if m_time = -1 then
    m_start := time;
  m_time := time;

  Seek(m_f, FileSize(m_f));
  BlockWrite(m_f, TDoubleDynArray(m_block)[from], count * sizeof(double));
end;

procedure cFileTag.setBlock(size: cardinal; var block: pointer);
begin
  m_blSize := size;
  // m_block:=Addr(block);
  m_block := block;
end;

procedure cFileTag.setBlockSize(size: cardinal);
begin
  m_blSize := size;
end;

procedure cFileTag.StartRecord(merafile: string);
var
  fname: string;
begin
  m_threadID := GetCurrentThreadId;
  m_record := false;
  if RStateRec then
  begin
    m_filename := merafile;
    fname := ExtractFileDir(m_filename) + '\' + name + '.dat';
    m_Datafilename := fname;
    if not fileexists(fname) then
    begin
      m_record := true;
      AssignFile(m_f, m_Datafilename);
      Rewrite(m_f, 1);
    end;
  end;
end;

procedure cFileTag.StopRecord;
var
  ifile: tinifile;
begin
  if m_threadID = GetCurrentThreadId then
  begin
    if recordState then
    begin
      closefile(m_f);
      ifile := tinifile.create(m_filename);
      ifile.WriteFloat(name, 'Freq', m_freq);
      ifile.WriteString(name, 'YFormat', 'R8');
      ifile.WriteFloat(name, 'Start', m_start);
      // k0
      ifile.WriteFloat(name, 'k0', 0);
      // k1
      ifile.WriteFloat(name, 'k1', 1);
      ifile.destroy;
      m_record := false;
    end;
  end;
end;

procedure multArrays(a1: TDoubleArray; var a2: TCmxArray_d);
var
  I, l: integer;
begin
  l := length(a1);
  for I := 0 to l - 1 do
  begin
    a2[I].re := a2[I].re * a1[I];
    a2[I].im := a2[I].im * a1[I];
  end;
end;

function cFFTFltTag.EvalDataWithShift: integer;
var
  b, newdata: boolean;
  i1, i2, len: integer;
  I, ind, blind: integer;
  k: double;

  logstr:string;
begin
  if m_lastindex > 0 then
  begin
    i1 := m_lastindex - foverflow;
    if i1<0 then
      i1:=0;
  end
  else
    i1 := m_lastindex;
  if finTag.lastindex > (i1 + m_FFTCount) then
    b := true
  else
    b := false;
  newdata:=false;
  while b do
  begin
    newdata:=true;
    m_FFTPlan.StartInd := i1;
    fft_al_d_sse(TDoubleArray(finTag.m_ReadData), TCmxArray_d(m_inData.p), m_FFTPlan);
    // ��������� ��������� �������
    multArrays(m_func, TCmxArray_d(m_inData.p));

    m_iFFTPlan.StartInd := 0;
    ifft_al_d_sse(TCmxArray_d(m_inData.p), TCmxArray_d(m_inData1.p), m_iFFTPlan);

    ind := i1;
    // ���� �� ������ ����
    for I := 0 to m_FFTCount - 1 do
    begin
      // ���������� ������
      if (I <= (foverflow - 1)) and (m_lastindex >0 ) then
      begin
        k := (I) / (foverflow - 1);
        //if abs(m_outData[ind] - finTag.m_ReadData[ind]) > 0.0001 then
        //begin
        //  showmessage('!');
        //end;
        m_outData[ind] := (1 - k) * m_outData[ind] + k * TCmxArray_d(m_inData1.p)[I].re;
      end
      // ������������ ������
      else
      begin
        m_outData[ind] := TCmxArray_d(m_inData1.p)[I].re;
      end;
      inc(ind);
    end;
    m_lastindex := i1 + m_FFTCount;
    if i1 + m_FFTShift + m_FFTCount > finTag.lastindex then
    begin
      b := false
    end
    else
    begin
      i1 := i1 + m_FFTShift;
    end;
  end;
  result:=0;
  if newdata then
  begin
    if m_lastindex-foverflow>0 then
    begin
      result:=m_lastindex - foverflow;
      len:=result-m_readyPoints;
      move(m_outData[m_readyPoints], fInTag.m_ReadData[m_readyPoints], len*sizeof(double));
      m_readyPoints:=m_readyPoints+len;
    end;
  end;
end;

procedure cFFTFltTag.resetData;
var
  endTimeInd, lastind, block: integer;
  DT: double;
begin
  if m_lastindex>m_fftcount then
  begin
    block:=m_lastindex div m_FFTCount;
    endTimeInd := block*m_FFTCount;
    // lastind:=m_fftshift*m_ReadyBlock+foverflow;
    lastind := m_lastindex;
    m_lastindex := lastind - endTimeInd;
    // lastind:=m_ReadyBlock*m_FFTCount;

    if finTag.m_ReadSize - m_lastindex <> 0 then
    begin
      move(m_outData[endTimeInd], m_outData[0], m_lastindex * sizeof(double));
      //ZeroMemory(@m_outData[m_lastindex], (finTag.m_ReadSize - m_lastindex)* sizeof(double));
    end;
    finTag.ResetTagDataTimeInd(endTimeInd);
    ///m_indInTag:=0;
  end;
end;

procedure cFFTFltTag.resetData(lind:integer);
var
  DT: double;
begin
  if lind>0 then
  begin
    m_lastindex := m_lastindex - lind;

    if m_lastindex <> 0 then
    begin
      move(m_outData[lind], m_outData[0], m_lastindex * sizeof(double));
      //ZeroMemory(@m_outData[m_lastindex], (finTag.m_ReadSize - m_lastindex)* sizeof(double));
    end;
    finTag.ResetTagDataTimeInd(lind);
    m_readyPoints:=m_readyPoints-lind;
  end;
end;

procedure cFFTFltTag.setCorrFunc(func: TDoubleArray);
begin
  m_func := func;
end;

procedure cFFTFltTag.setFFTCount(fftCount, Shift: integer);
var
  I: integer;
begin
  foverflow := fftCount - Shift;
  m_FFTPlan := GetFFTPlan(fftCount);
  m_iFFTPlan := GetInverseFFTPlan(fftCount);
  GetMemAlignedArray_cmpx_d(fftCount, m_inData);
  GetMemAlignedArray_cmpx_d(fftCount, m_inData1);
  m_FFTCount := fftCount;
  m_FFTShift := Shift;
  if finTag <> nil then
  begin
    m_freq := finTag.freq;
    m_dx := 1 / m_freq;
    m_dF := 0.5 * m_freq / fftCount;
    setlength(m_outData, finTag.m_ReadSize);
  end;
  // �������� �������
  setlength(m_func, fftCount);
  for I := 0 to m_FFTCount - 1 do
  begin
    m_func[I] := 1;
  end;
  m_func[0]:=0;
end;

procedure cFFTFltTag.setintag(t: cTag);
begin
  finTag := t;
end;

procedure cFFTFltTag.Start;
begin
  m_lastindex := 0;
  ///m_indInTag := 0;
end;

end.
