#include <stdio.h>
#include <stddef.h>
#include "Types.h"
#include "Const.h"

int main() {
  printf("pointer=%u\n", (unsigned)sizeof(void*));
  printf("TBusType=%u TType=%u TLocation=%u TDeviceRoute=%u\n",
    (unsigned)sizeof(TBusType), (unsigned)sizeof(TType),
    (unsigned)sizeof(TLocation), (unsigned)sizeof(TDeviceRoute));
  printf("TDevice=%u DeviceType=%u Type=%u Route=%u DeviceName=%u RevString=%u Description=%u RevisionNo=%u SerialNo=%u DllName=%u Creator=%u pFinder=%u HWProtocol=%u wPriority=%u\n",
    (unsigned)sizeof(TDevice), (unsigned)offsetof(TDevice,DeviceType),
    (unsigned)offsetof(TDevice,Type), (unsigned)offsetof(TDevice,Route),
    (unsigned)offsetof(TDevice,DeviceName), (unsigned)offsetof(TDevice,RevString),
    (unsigned)offsetof(TDevice,Description), (unsigned)offsetof(TDevice,RevisionNo),
    (unsigned)offsetof(TDevice,SerialNo), (unsigned)offsetof(TDevice,DllName),
    (unsigned)offsetof(TDevice,Creator), (unsigned)offsetof(TDevice,pFinder),
    (unsigned)offsetof(TDevice,HWProtocol), (unsigned)offsetof(TDevice,wPriority));
  printf("TDeviceEnum=%u nFoundDevs=%u DevInfo=%u MAX_DEVICE=%u\n",
    (unsigned)sizeof(TDeviceEnum), (unsigned)offsetof(TDeviceEnum,nFoundDevs),
    (unsigned)offsetof(TDeviceEnum,DevInfo), (unsigned)MAX_DEVICE);
  printf("PROP_AMPLIFIER=0x%X\n", (unsigned)PROP_AMPLIFIER);
  return 0;
}
