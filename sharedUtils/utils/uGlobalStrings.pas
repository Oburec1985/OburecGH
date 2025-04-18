unit uGlobalStrings;

interface
uses
  uBaseObjService;

Var
  v_Num,
  v_Name,
  v_Type,
  v_Src,
  v_Dsc,
  v_DrawObj,
  v_ColTick,
  v_bldObj,
  v_UTS,
  v_Pair,
  v_Turbine,
  v_Sensor,
  v_Stage,
  v_Chan,
  v_Root,
  v_Edge,
  v_Rot,
  v_Plats,
  v_Channels,
  v_ColSensorPos,
  v_ColEdgeSensor,
  v_ColRootSensor,
  v_ColSkipBlades,
  v_ColFirstOffset,
  v_ColImpulsNum,
  v_UpdateTime,
  v_colProcTime,
  v_ColAlgName,
  v_BaseTAgDSC,
  v_ScalarTAgDSCf,
  v_2ScalarTAgDSCf,
  v_VectorTagDSCf,
  v_2VectorTAgDSC,
  v_sTrend,
  v_sStat,
  v_sPairShape,
  v_sRestore,
  v_sShape,
  v_sTaho,
  v_sStageShape,
  v_sSensorRep,
  v_sSkipSensorBlades,
  v_sPairTrend,
  v_sPairRestore,
  v_ShortDscMultiSensor,
  v_ShortDscPairTrend,
  v_ShortRestore,
  v_ShortDscPairRestore,
  v_ShortDscTrend,
  // �������� ���� �������� ����� M2-70, M2081
  v_OscTagDsc
  :string;



procedure InitGlobalStrings;

implementation

procedure InitGlobalStrings;
begin
  v_ColTick:= GetConstString('ColTick');
  v_bldObj:= GetConstString('bldObj');
  v_UTS:= GetConstString('UTS');
  v_Pair:= GetConstString('Pair');
  v_Turbine:= GetConstString('Turbine');
  v_Stage:= GetConstString('Stage');
  v_Sensor:= GetConstString('Sensor');
  v_Chan:= GetConstString('Chan');
  v_Root:= GetConstString('Root');
  v_Edge:= GetConstString('Edge');
  v_Rot:= GetConstString('Rot');
  v_Plats:=GetConstString('Plats');
  v_Channels:=GetConstString('Channels');
  v_ColSensorPos:=GetConstString('ColSensorPos');
  v_ColRootSensor:= GetConstString('ColRootSensor');
  v_ColEdgeSensor:=GetConstString('ColEdgeSensor');
  v_ColSkipBlades:=GetConstString('ColSkipBlades');
  v_ColFirstOffset:=GetConstString('ColFirstOffset');
  v_ColImpulsNum:=GetConstString('ColImpulsNum');
  v_UpdateTime:=GetConstString('ColUpdateTime');
  v_colProcTime:=GetConstString('ColProcTime');
  v_ColAlgName:=GetConstString('ColAlgName');
  v_BaseTAgDSC:=GetConstString('BaseTAgDSC');
  v_ScalarTAgDSCf:=GetConstString('ScalarTAgDSCf');
  v_2ScalarTAgDSCf:=GetConstString('2ScalarTAgDSCf');
  v_VectorTagDSCf:=GetConstString('VectorTagDSCf');
  v_2VectorTAgDSC:=GetConstString('2VectorTAgDSC');
  v_sTrend:=GetConstString('sTrend');
  v_sStat:=GetConstString('sStat');
  v_sPairShape:=GetConstString('sPairShape');
  v_sRestore:=GetConstString('sRestore');
  v_sShape:=GetConstString('sShape');
  v_sTaho:=GetConstString('sTaho');
  v_sStageShape:=GetConstString('sStageShape');
  v_sSensorRep:=GetConstString('sSensorRep');
  v_sSkipSensorBlades:=GetConstString('sSkipSensorBlades');
  v_sPairTrend:=GetConstString('sPairTrend');
  v_sPairRestore:=GetConstString('PairRestore');
  // ������� �������� ����������
  v_ShortDscPairTrend:=GetConstString('ShortDscPairTrend');
  v_ShortRestore:=GetConstString('ShortDscRestore');
  v_ShortDscPairRestore:=GetConstString('ShortDscPairTrend');
  v_ShortDscTrend:=GetConstString('ShortDscTrend');
  v_ShortDscMultiSensor:=GetConstString('ShortDscMultiSensor');
  v_OscTagDsc:=GetConstString('OscTagDsc');
  v_Num:=GetConstString('ColNum');
  v_Name:=GetConstString('ColName');
  v_Type:=GetConstString('ColType');
  v_Src:=GetConstString('ColSrc');
  v_Dsc:=GetConstString('ColDsc');
  v_DrawObj:=GetConstString('ColDrawObj');
end;

end.
