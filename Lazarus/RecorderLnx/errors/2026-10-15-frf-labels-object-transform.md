# FRF labels remain at old world positions

Moving a point cloud left FRF point labels at their sampled world coordinates.
The intensity adapter cached marker Position only during Configure/Update;
object manipulation did not sample FRF again.

Markers now expose TargetNodeId and PointNumber. The 3D host resolves the
logical vertex, current mesh position and current WorldTransform immediately
before projecting each marker. This applies to both FRF and demonstration
markers, independently of FRF playback or frequency changes.

Verification: forced RecorderLnx.lpi build completed with exit code 0 and linked
the main RecorderLnx.exe. Interactive visual verification remains pending.

## Scene ownership completed

Added scene-owned T3dSceneLabel objects, source-scoped EnsureLabel/RemoveLabels,
visibility and node/logical-vertex bindings. FRF publishes label definitions;
the scene resolves their live positions and the generic frame overlay renders
them. FRF marker rendering no longer draws text. Both FRF clients detach before
scene replacement. ThreeDMathTest passes translation without FRF update,
rotation, deformation, hide/show, missing target, identity and scoped removal.
Main forced build exit 0. Three read-only auditors accepted this scope; GUI
drag was not independently observed.
