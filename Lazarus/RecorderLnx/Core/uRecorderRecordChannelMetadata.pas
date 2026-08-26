unit uRecorderRecordChannelMetadata;

{
  Neutral metadata contract used by record writers. Device-specific source and
  channel recognition belongs to implementations outside UI.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderTags;

type
  TRecorderRecordChannelMetadata = record
    IsUts: Boolean;
    UtsChannelName: string;
  end;

  IRecorderRecordChannelMetadataService = interface
    ['{5EAEFEE0-9375-4F49-A31A-0C34FCB5F31D}']
    function Resolve(ARegistry: TRecorderTagRegistry;
      ATag: TRecorderTag): TRecorderRecordChannelMetadata;
  end;

implementation

end.
