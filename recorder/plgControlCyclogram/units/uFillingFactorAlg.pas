unit uFillingFactorAlg;

interface

uses
  classes, windows, activex, ubasealg, uCommonMath, uRCFunc, tags, recorder,
  blaccess, nativexml,
  pluginclass, sysutils;

type
  cFillingFactorAlg = class(cbasealg)
  protected
    fLvl: double;
    fOutTag: cTag;
    fFillFct: double;
    fFs: double;
    // данные накопленные из входных данных. храним 2 периода = 1/fFs
    fOutBuff: array of double;
    // количество отсчетов в fOutBuff
    fReadyPoints: integer;
    // время начала блока fOutBuff
    fBlockTime: double;
    // выходной тег создан а не загружен
    fOutIsNew: boolean;
  protected
    InTag: cTag;
  protected
    procedure LoadTags(node: txmlNode); override;
    procedure SetProperties(str: string); override;
    function GetProperties: string; override;
    procedure doOnStart; override;
    procedure doEval(tag: cTag; time: double); override;
    procedure doGetData; override;
    // если поменялось имя входного канала то пересоздаем имя выходного канала, а может и тип
    // вызывается при загрузке или при установке входного тега
    procedure createOutChan;
    procedure updateOutChan;
    function getinptag: itag;
    procedure setinptag(t: itag); overload;
    procedure setinptag(t: cTag); overload;
    function genTagName: string; override;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlNode); override;
    function ready: boolean; override;
  public
    constructor create; override;
    destructor destroy; override;
    class function getdsc: string; override;
    // property inpTag:itag read getInptag write setInpTag;
    property FillFct: double read fFillFct write fFillFct;
  end;

const
  C_FillingFactorOpts = 'Lvl=0.5, Fs=1';

implementation

{ cFillingFactorAlg }

constructor cFillingFactorAlg.create;
begin
  inherited;
  Properties := C_FillingFactorOpts;
  fOutIsNew := false;
end;

destructor cFillingFactorAlg.destroy;
begin
  if fOutTag <> nil then
  begin
    fOutTag.destroy;
    fOutTag := nil;
  end;
  //if InTag<> nil then
  //begin
  //  InTag.destroy;
  //  InTag:= nil;
  //end;
  inherited;
end;

procedure cFillingFactorAlg.doEval(tag: cTag; time: double);
var
  I, j, len, copyLen, num, blocksize, blCount: integer;
  v, infs, prev, THiStart, TFall, THi, period, ldx: double;
  trig: boolean;
begin
  len := length(tag.m_TagData);
  period := 1 / fFs;
  infs := tag.tag.GetFreq;
  ldx := 1 / infs;
  if len > length(fOutBuff) then
  begin
    copyLen := length(fOutBuff);
  end
  else
  begin
    copyLen := len;
  end;
  move(tag.m_TagData[0], fOutBuff[fReadyPoints], copyLen * sizeof(double));
  if fBlockTime = 0 then
  begin
    fBlockTime := time;
  end;
  fReadyPoints := fReadyPoints + copyLen;
  blocksize := round(period / ldx);
  blCount := trunc(copyLen / blocksize);
  if blCount = 0 then
    inc(blCount);

  THiStart := 0;
  THi := 0;
  trig := false;
  num := 0;

  if fReadyPoints > blocksize then
  begin
    for I := 0 to blocksize * blCount - 1 do
    begin
      v := fOutBuff[I];
      if v > fLvl then
      begin
        if not trig then
        begin
          THiStart := time + ldx * I;
          trig := true;
        end;
      end
      else
      begin
        if trig then
        begin
          TFall := time + ldx * I;
          THi := THi + (TFall - THiStart);
          trig := false;
        end;
      end;
      if I >= (blocksize * (num + 1) - 1) then
      begin
        if fFillFct <> 0 then
          // fFillFct:=((THi/period)+fFillFct)/2
          fFillFct := THi / period
        else
        begin
          fFillFct := THi / period;
        end;
        THi := 0;
        fOutTag.m_TagData[num] := fFillFct;
        inc(num);
      end;
    end;
    // копируем кусок не использованных данных
    for j := 0 to (blocksize * (num) - 1) do
    begin
      fOutBuff[j] := 0;
    end;
    fReadyPoints := fReadyPoints - blocksize * (num);
    move(fOutBuff[blocksize * (num)], fOutBuff[0],
      fReadyPoints * sizeof(double));
    fBlockTime := 0;
  end;
  if num <> 0 then
  begin
    fOutTag.tag.PushDataEx(pointer(fOutTag.m_TagData)^, num, 0, time);
    num := 0;
  end;
end;

procedure cFillingFactorAlg.doGetData;
var
  I, BufCount, newBlockCount, blCount, readyBlockCount, blSize, blInd,
    writeBlockSize: integer;
  tare: boolean;
  timeinterval: double;
begin
  if InTag <> nil then
  begin
    InTag.block.LockVector;
    blCount := InTag.block.GetBlocksCount;
    blSize := InTag.block.GetBlocksSize;
    writeBlockSize := fOutTag.block.GetBlocksSize;
    if writeBlockSize > length(fOutTag.m_TagData) then
    begin
      setlength(fOutTag.m_TagData, writeBlockSize);
    end;
    readyBlockCount := 0;
    if blCount > 0 then
    begin
      // сколько всего
      readyBlockCount := InTag.block.GetReadyBlocksCount;
      // logMessage('ReadyBlock: ' + inttostr(readyBlockCount));
      // если количество блоков больше чем кол-во обработанных блоков (т.е. есть новые данные)
      if readyBlockCount > InTag.m_readyBlock then
      begin
        newBlockCount := readyBlockCount - InTag.m_readyBlock;
        // logMessage('newBlockCount: ' + inttostr(newBlockCount));
        BufCount := newBlockCount;
        // если готовых блоков больше чем размер буфера, то есть потери,
        // но с этим уже ничего не поделать
        if newBlockCount > blCount then
          BufCount := newBlockCount;
        for I := 0 to BufCount - 1 do
        begin
          InTag.m_readyBlock := readyBlockCount;
          tare := true;
          // например новых блоков 2. Последний блок в буфере всегда имеет последний тайм штамп.
          // Тогда, в цикле получаем блоки с последнего необработанного
          blInd := I + blCount - newBlockCount;
          // logMessage('blInd: ' + inttostr(newBlockCount));
          if SUCCEEDED(InTag.block.GetVectorR8(pointer(InTag.m_TagData)^,
              blInd, blSize, tare)) then
          begin
            timeinterval := InTag.block.GetBlockDeviceTime(blInd);
          end;
          // logMessage('BlInd:'+inttostr(blInd)+' Time:'+format('%.3g', [timeinterval]));
          // пишем блок данных
          doEval(InTag, timeinterval);
        end;
      end;
    end;
    InTag.block.unLockVector;
  end;
end;

procedure cFillingFactorAlg.doOnStart;
begin
  inherited;
  fFillFct := 0;
  fBlockTime := 0;
  fReadyPoints := 0;
end;

class function cFillingFactorAlg.getdsc: string;
begin
  result := 'Скважность';
end;

function cFillingFactorAlg.getinptag: itag;
begin

end;

procedure cFillingFactorAlg.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
var
  tnode, tagnode: txmlNode;
begin
  tnode := xmlNode.FindNode('OutputTag');
  if tnode <> nil then
  begin
    tagnode := tnode.FindNode('OutChan');
    if tagnode <> nil then
    begin
      fOutTag := LoadTag(tagnode,fOutTag);
    end;
  end;
  inherited;
  if m_inpTags.Count > 0 then
  begin
    InTag := InputTag[0];
  end;
end;

procedure cFillingFactorAlg.SaveObjAttributes(xmlNode: txmlNode);
var
  tnode, tagnode: txmlNode;
  I: integer;
begin
  inherited;
  tnode := xmlNode.NodeNew('OutputTag');
  tagnode := tnode.NodeNew('OutChan');
  saveTag(fOutTag, tagnode);
end;

procedure cFillingFactorAlg.LoadTags(node: txmlNode);
begin

end;

function cFillingFactorAlg.ready: boolean;
begin
  result := false;
  if InTag <> nil then
  begin
    if InTag.tag <> nil then
    begin
      if fOutTag.tag <> nil then
        result := true;
    end;
  end;
end;

procedure cFillingFactorAlg.setinptag(t: cTag);
var
  bl: IBlockAccess;
begin
  if t = nil then
    exit;
  if InTag <> nil then
  begin
    InTag.destroy;
    InTag := nil;
  end;
  InTag := t;
  setinptag(InTag.tag);
end;

procedure cFillingFactorAlg.setinptag(t: itag);
var
  bl: IBlockAccess;
begin
  if t = nil then
    exit;
  if InTag = nil then
  begin
    InTag := cTag.create;
  end;
  InTag.tag := t;
  InTag.tagname := t.GetName;
  t.GetTagId(InTag.ftagid);
  addInputTag(InTag);
  if not FAILED(t.QueryInterface(IBlockAccess, bl)) then
  begin
    InTag.block := bl;
    bl := nil;
  end;
  if fOutTag = nil then
  begin
    createOutChan
  end
  else
  begin
    if fouttag.tag=nil then
      createOutChan
    else
      updateOutChan;
  end;
end;

function cFillingFactorAlg.GetProperties: string;
begin
  if m_properties = '' then
    m_properties := C_FillingFactorOpts;
  result := m_properties;
end;

procedure cFillingFactorAlg.SetProperties(str: string);
var
  lstr: string;
  t: itag;
begin
  if str = '' then
    exit;
  inherited;
  lstr := GetParam(str, 'Lvl');
  if lstr <> '' then
  begin
    fLvl := strtoFloatExt(lstr);
  end;

  lstr := GetParam(str, 'Fs');
  if lstr <> '' then
  begin
    fFs := strtoFloatExt(lstr);
  end;

  lstr := GetParam(str, 'Channel');
  if lstr <> '' then
  begin
    if InTag = nil then
    begin
      InTag := cTag.create;
      t := getTagByName(lstr);
      setinptag(t);
    end;
    ChangeCTag(InTag, lstr);
  end;
end;

function createVectorTagR8(tagname: string; freq: double; CfgWritable: boolean;
  freqCorrection: boolean): itag;
var
  ir: irecorder;
  Name, errMes: string;
  err: cardinal;
  v: OleVariant;
begin
  ir := getIR;

  result := itag(ir.CreateTag(lpcstr(StrToAnsi(tagname)), LS_VIRTUAL, nil));
  if result = nil then // ошибка создания виртуального тега
  begin
    err := ir.GetLastError;
    errMes := ir.ConvertErrorCodeToString(err);
    // showmessage(errMes);
  end;
  // установка типа тега : вектор, прием и передача
  VariantInit(v);
  VariantClear(v);
  TPropVariant(v).vt := VT_UI4;
  v := TTAG_VECTOR or TTAG_INPUT;
  result.SetProperty(TAGPROP_TYPE, v);
  // частота опроса
  result.SetProperty(TAGPROP_ENABLEFREQCORRECTION, freqCorrection);
  VariantClear(v);
  // v := fintag.tag.GetFreq; // частота опроса датчика
  result.SetFreq(freq);
  // тип передаваемых данных
  VariantClear(v);
  TPropVariant(v).vt := VT_R8;
  // v := VarAsType(v, varDouble);
  result.SetProperty(TAGPROP_DATATYPE, v);
  result.CfgWritable(CfgWritable);
  // минимальное и максимальное значение диапазона
  // VariantClear(v);
  // m_TestWriteVTag.getProperty(TAGPROP_MINVALUE, v);
  // m_TestVTag.SetProperty(TAGPROP_MINVALUE, v);
  // VariantClear(v);
  // m_TestWriteVTag.getProperty(TAGPROP_MAXVALUE, v);
  // m_TestWriteVTag.SetProperty(TAGPROP_MAXVALUE, v);
end;

function cFillingFactorAlg.genTagName: string;
var
  tagname: string;
begin
  tagname := InTag.tagname;
  result := tagname + '_FillFct';
end;

procedure cFillingFactorAlg.createOutChan;
var
  tagname: string;
  bl: IBlockAccess;
begin
  if InTag <> nil then
  begin
    if InTag.tag <> nil then
    begin
      ecm;
      fOutTag := cTag.create;
      tagname := genTagName;
      fOutIsNew := true;
      if fOutTag.tag = nil then
      begin
        while getTagByName(tagname) <> nil do
        begin
          tagname := modname(tagname, false);
        end;
        fOutTag.tag := createVectorTagR8(tagname, fFs, true, false);
      end;
      if not FAILED(fOutTag.tag.QueryInterface(IBlockAccess, bl)) then
      begin
        fOutTag.block := bl;
        bl := nil;
      end;
      lcm;
    end;
  end;
end;

procedure cFillingFactorAlg.updateOutChan;
var
  v: OleVariant;
  t: itag;
  str: pansichar;
  bl: IBlockAccess;
  infreq, period, Rperiod: double;
begin
  str := lpcstr(StrToAnsi(genTagName));
  if fOutTag.tag <> nil then
  begin
    ecm;
    if fOutIsNew then
    begin
      fOutTag.tag.SetName(str);
    end;
    fOutTag.tag.SetFreq(fFs);
    fOutTag.block := nil;
    if not FAILED(fOutTag.tag.QueryInterface(IBlockAccess, bl)) then
    begin
      fOutTag.block := bl;
    end;
    setlength(fOutTag.m_TagData, fOutTag.block.GetBlocksSize);
    period := 1 / fFs;
    infreq := InTag.tag.GetFreq;
    Rperiod := InTag.block.GetBlocksSize / infreq;
    if 2 * period < Rperiod then
    begin
      period := Rperiod;
    end;
    setlength(fOutBuff, round(2 * period * infreq));
    lcm;
  end;
end;

end.
