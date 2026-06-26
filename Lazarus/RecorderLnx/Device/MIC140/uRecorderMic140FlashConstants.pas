unit uRecorderMic140FlashConstants;

{
  Константы flash MIC-140 (mi118tar, каталог тарировок в ПЗУ).
}

{$mode objfpc}{$H+}

interface

const
  CMic140Mi118TarFileName = 'mi118tar.bin';
  CMic140FlashDirOffset = 870;
  CMic140FlashDirSize = 400;
  CMic140FlashStorageBytes = 524288;
  CMic140FlashMaxDirEntries = 16;
  CMic140FlashNameLength = 13;
  CMic140TareTypeTable = 1;
  CMic140TareTableMaxPoints = 5;
  CMic140TareTable2MaxPoints = 153;

implementation

end.
