program FactoryAliasSmoke;
{$mode objfpc}{$H+}
uses SysUtils, uRecorderFormModel;
var gStarts, gDestroyed: Integer;
type
  TCountingFactory = class(TRecorderComponentFactoryBase)
    procedure DoStart; override;
    destructor Destroy; override;
  end;
procedure TCountingFactory.DoStart;
begin Inc(gStarts); inherited DoStart; end;
destructor TCountingFactory.Destroy;
begin Inc(gDestroyed); inherited Destroy; end;
procedure Check(ACondition: Boolean; const AMessage: string);
begin if not ACondition then raise Exception.Create(AMessage); end;
var lRegistry: TRecorderComponentFactory; lFactory, lRejected: TCountingFactory;
  lComponent: TRecorderVisualComponent;
begin
  lRegistry := TRecorderComponentFactory.Create;
  try
    lFactory := TCountingFactory.Create('Canonical', 'Factory', TRecorderVisualComponent, 1, 1, False);
    lRegistry.RegisterFactory(lFactory);
    lRegistry.RegisterAlias('OldType', 'canonical');
    lRegistry.RegisterAlias('OtherOldType', 'Canonical');
    Check((lRegistry.FactoryCount = 1) and (lRegistry.Factories[0] = lFactory), 'Canonical owns once');
    Check(lRegistry.FindFactory('OLDTYPE') = lFactory, 'Case-insensitive alias');
    lComponent := lRegistry.CreateComponent('oldtype');
    try Check(lComponent.Factory = lFactory, 'Alias creates canonical component');
    finally lComponent.Free; end;
    lRegistry.DoStart;
    Check(gStarts = 1, 'Alias must not duplicate lifecycle');
    try lRegistry.RegisterAlias('OLDTYPE', 'Canonical'); Check(False, 'Duplicate alias accepted');
    except on E: ERecorderFormError do ; end;
    try lRegistry.RegisterAlias('canonical', 'Canonical'); Check(False, 'Canonical collision accepted');
    except on E: ERecorderFormError do ; end;
    try lRegistry.RegisterAlias('chain', 'OldType'); Check(False, 'Alias chain accepted');
    except on E: ERecorderFormError do ; end;
    try lRegistry.RegisterAlias('missing', 'Absent'); Check(False, 'Missing target accepted');
    except on E: ERecorderFormError do ; end;
    try lRegistry.RegisterAlias('', 'Canonical'); Check(False, 'Empty alias accepted');
    except on E: ERecorderFormError do ; end;
    lRejected := TCountingFactory.Create('oldTYPE', 'Rejected', TRecorderVisualComponent, 1, 1, False);
    try
      try lRegistry.RegisterFactory(lRejected); Check(False, 'Alias canonical collision accepted');
      except on E: ERecorderFormError do ; end;
    finally lRejected.Free; end;
    Check((lRegistry.FactoryCount = 1) and (lRegistry.FindFactory('OldType') = lFactory) and
      (lRegistry.FindFactory('chain') = nil), 'Failed registrations must not mutate map');
    Check(not lRegistry.UnregisterFactory('OldType'), 'Unregister requires canonical ID');
    Check(lRegistry.UnregisterFactory('CANONICAL'), 'Canonical unregister');
    Check((lRegistry.FactoryCount = 0) and (lRegistry.FindFactory('OldType') = nil) and
      (lRegistry.FindFactory('OtherOldType') = nil) and (gDestroyed = 2), 'Aliases removed before single destroy');
    lFactory := TCountingFactory.Create('OldType', 'Reuse', TRecorderVisualComponent, 1, 1, False);
    lRegistry.RegisterFactory(lFactory);
    Check(lRegistry.FindFactory('oldtype') = lFactory, 'Freed alias name may be canonical');
  finally lRegistry.Free; end;
  Check(gDestroyed = 3, 'Registry teardown frees each owned factory once');
  WriteLn('RESULT FactoryAliasSmoke lookup/collisions/lifecycle/unregister passed');
end.
