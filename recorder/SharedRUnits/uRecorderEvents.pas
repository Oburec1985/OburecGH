unit uRecorderEvents;

interface

const
  // ������� ���������� ��������� ���������
  //c_RC_ChangeState =         $00000001;
  // ������� ���������� ����� ���������
  c_RUpdateData =            $00000002;
  // �������� ���� � ������������ ������
  c_RCreateFrmInMainThread = $00000004;
  // �������� ����� (������� ShowModal) ��� �������������� ������� ���� ����
  c_RShowModalSettingsFrm =  $00000008;
  // ����� ��������� �������
  c_RC_PlgEdit =             $00000010;
  c_RC_LoadCfg =             $00000020;
  c_RC_SynchroRead =         $00000040;
  c_RC_SaveCfg =             $00000080;
  // ����� �� ���������
  c_RC_LeaveCfg =            $00000100;
  // ������� � ������� �������������� rcStateChange
  c_RC_DoChangeRCState =       $00000200;
  // ������� ����������� ����� (� ������ ���������� ������)
  c_RC_Redraw =       $00000400;
  E_MDBCreate =$00000800;
  E_RC_ChangeCfg =$00001000;
  E_RC_DestroyObject =$00002000;
  // �������� �������� ������� � �������
  E_RC_Init =         $00004000;

implementation

end.
