unit uRecorderEvents;

interface

const
  // событие обновления состояния рекордера
  //c_RC_ChangeState =         $00000001;
  // событие обновления тегов рекордера
  c_RUpdateData =            $00000002;
  // Создание форм в интерфейсном потоке
  c_RCreateFrmInMainThread = $00000004;
  // Показать форму (функции ShowModal) для редактирования свойств чего либо
  c_RShowModalSettingsFrm =  $00000008;
  // вызов настройки плагина
  c_RC_PlgEdit =             $00000010;
  c_RC_LoadCfg =             $00000020;
  c_RC_SynchroRead =         $00000040;
  c_RC_SaveCfg =             $00000080;
  // Выход из настройки
  c_RC_LeaveCfg =            $00000100;
  // событие в котором актуализирован rcStateChange
  c_RC_DoChangeRCState =       $00000200;
  // событие перерисовки формы (в потоке обновления экрана)
  c_RC_Redraw =       $00000400;
  E_MDBCreate =$00000800;
  E_RC_ChangeCfg =$00001000;
  E_RC_DestroyObject =$00002000;
  // рекордер загрузил плагины и конфиги
  E_RC_Init =         $00004000;

implementation

end.
