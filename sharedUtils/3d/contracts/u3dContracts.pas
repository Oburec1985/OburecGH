unit u3dContracts;

interface

uses
  u3dCoreTypes;

type
  I3dDisplacementSource = interface
    ['{8D45862D-7086-4D28-9479-F7DB97782F47}']
    function PointCount: Integer;
    function TryReadDisplacement(const APointIndex: Integer;
      const ATime: Double; out AValue: T3dVector3;
      out AVersion: Cardinal): Boolean;
  end;

  I3dTransformTarget = interface
    ['{3C0B1075-F6AD-45FA-A3CB-32675C1928AA}']
    function BindingId: Integer;
    procedure SetLocalDisplacement(const AValue: T3dVector3);
  end;

  I3dInvalidationSink = interface
    ['{03D11D5B-2F31-4F88-BA55-5F194E0DAF56}']
    procedure InvalidateGeometry;
  end;

  I3dRenderer = interface
    ['{6FF15724-6845-4A7B-B61E-B3207CB7596B}']
    procedure Attach(const AWindowHandle: NativeUInt;
      const AWidth, AHeight: Integer);
    procedure Resize(const AWidth, AHeight: Integer);
    procedure Render;
    procedure Detach;
  end;

  I3dScalarFieldSource = interface
    ['{D2103515-A3BE-4624-83BB-E17974BFEE09}']
    function ValueCount: Integer;
    function TryReadValues(const ADestination: PDouble;
      const ACapacity: Integer; out ACount: Integer;
      out AVersion: Cardinal): Boolean;
  end;

  I3dSceneLoader = interface
    ['{8A3E91CE-F84F-4DEB-A0D3-7D8A42FD3E4F}']
    function CanLoad(const AFileName: string): Boolean;
    procedure LoadScene(const AFileName: string);
  end;

implementation

end.
