unit uAlgorithms;

interface
uses
  uBaseBldAlg, uPairShape, uDensityAlg, uTrendAlg, uRestoreVibrationAlg, udrawobj,
  uGistogram, uTrend, uEvalTahoAlg;

// создать алгоритм по идентификатору
function CreateAlgWithID(id:integer):cBaseBldAlg;
// создать отрисовываемый объект по идентификатору
function CreateAlgDrawObj(id:integer):cdrawobj;
function createDrawObjWithClassName(clName:string):cdrawobj;



implementation

function createDrawObjWithClassName(clName:string):cdrawobj;
begin
  result:=nil;
  if clName='cGistogram' then
  begin
    result:=cGistogram.create;
  end;
  if clName='cTrend' then
  begin
    result:=cTrend.create;
  end;
end;

function CreateAlgWithID(id:integer):cBaseBldAlg;
begin
  result:=nil;
  case id of
    c_PairShape:
    begin
      result:=cPairShape.create;
    end;
    c_BladeTrend:
    begin
      result:=cTrendAlg.create;
    end;
    c_TahoAlg:
    begin
      result:=cTahoAlg.create;
    end;
    c_RestoreSignal:
    begin
      result:=cRestoreAlg.create;
    end;
  end;
end;

function CreateAlgDrawObj(id:integer):cdrawobj;
begin
  result:=nil;
  case id of
    c_PairShape:
    begin
      result:=cGistogram.create;
    end;
    c_BladeTrend:
    begin
      result:=cTrend.create;
    end;
    c_TahoAlg:
    begin
      result:=cTrend.create;
    end;
    c_RestoreSignal:
    begin
      result:=cTrend.create;
    end;
  end;
end;

end.
