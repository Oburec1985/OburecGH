unit u3dMotionContracts;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

type
  T3dMotionAxis = (maxisX, maxisY, maxisZ);
  T3dMotionSpace = (msHelperLocal, msParent, msWorld);

  T3dMotionCommand = record
    TargetNodeId: QWord;
    Axis: T3dMotionAxis;
    Space: T3dMotionSpace;
    Offset: Single;
  end;

  I3dMotionSink = interface
    ['{C03538F7-34ED-42E2-8544-A7CA94F08D31}']
    function Apply(const ACommands: array of T3dMotionCommand): Boolean;
    function Revision: QWord;
  end;

implementation

end.
