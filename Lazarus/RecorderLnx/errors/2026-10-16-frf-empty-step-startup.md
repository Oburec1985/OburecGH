# Startup rejects an FRF component after selecting an empty route step

Selecting an empty step deliberately writes PointNumber=0/PointLabel='' to
response geometry fields. The general model validator still demanded positive
PointNumber, so LoadFromStrings returned false and project loading raised
Invalid impact-hammer component. The route spinner regression reproduced a
failed save/load roundtrip before the fix.

Correction: zero means unassigned geometry, negative values remain invalid.
Loading zero preserves an empty label rather than inventing "0". Initial
step migration ignores responses with no target object instead of fabricating
a point mapping. No configuration error is swallowed and measurement/channel
validation remains enabled.

Verification: --route-spinner-only roundtrips the empty mapping, checks zero
and empty label and rejects -1. Forced main/UI/service builds and targeted
route navigation/UI tests passed. The user's actual configuration was not
modified; this is a reproduced configuration-state regression test.
