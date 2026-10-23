# MDB path and reversed object/test on MIC315

Confirmed through read-only UNC inspection of the active project on
192.168.15.84, local-pc-20261016:
- Object_0001.xml is MdbObject Name=Test_001.
- Its Test_0001.xml is MdbTest Name=Obj_001; Test_0002.xml is Obj_002.
- The displayed Object_0001/Test_0002 matches the selected XML IDs.
- Original Object_001/Test_001/Reg_001 also exists, using legacy root names
  and classes cObjFolder/cTestFolder/cRegFolder, without Id/Name/Path.
- Generic scanner previously ignored every root other than MeraDbNode.
- Runtime alTop groups were created with equal Top=0, placing Test above Object.

Fix: explicit Object-before-Test coordinates; preserve selected IDs on refresh;
accept legacy classes in the domain repository and derive path from descriptor
location. Legacy identity is deterministic (legacy:relative-path). Opening the
database does not rewrite descriptors or rename directories.

Verification: Mdb suite PASS, including direct read-only legacy hierarchy
assertions against the actual MIC315 project through UNC. Forced app build
exit 0 (229496 lines). Remote configuration and XML were not changed.

Prevention: folder location is authoritative for XML paths; names are display
values, selected IDs must survive refresh. Verify old and new descriptors in
the same database before shipping compatibility changes.
