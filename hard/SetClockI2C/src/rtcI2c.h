/* rtcI2C.h -- header for lowlevel RTC I/O */

int  open_RTC_libs(void);
void close_RTC_libs(void);

int  read_RTC(struct ClockData * CkData);
int  write_RTC(struct ClockData * CkData);

