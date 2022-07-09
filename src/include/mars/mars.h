#ifndef __MARS_H__
#define __MARS_H__

#define MARS_CRAM           (*(volatile unsigned short *) 0x20004200 )
#define MARS_FRAMEBUFFER    (*(volatile unsigned short *) 0x24000000 )
#define MARS_OVERWRITE_IMG  (*(volatile unsigned short *) 0x24020000 )
#define MARS_SDRAM          (*(volatile unsigned short *) 0x26000000 )

#define MARS_SYS_INTMSK     (*(volatile unsigned short *) 0x20004000 )
#define MARS_SYS_INTMSK_FM  0x8000

#define MARS_COMM0          (*(volatile unsigned short *) 0x20004020 )
#define MARS_COMM1          (*(volatile unsigned short *) 0x20004022 )
#define MARS_COMM2          (*(volatile unsigned short *) 0x20004024 )
#define MARS_COMM3          (*(volatile unsigned short *) 0x20004026 )
#define MARS_COMM4          (*(volatile unsigned short *) 0x20004028 )
#define MARS_COMM5          (*(volatile unsigned short *) 0x2000402A )
#define MARS_COMM6          (*(volatile unsigned short *) 0x2000402C )
#define MARS_COMM7          (*(volatile unsigned short *) 0x2000402E )

#define MARS_COMM0L         (*(volatile unsigned int *) &MARS_COMM0 )
#define MARS_COMM2L         (*(volatile unsigned int *) &MARS_COMM2 )
#define MARS_COMM4L         (*(volatile unsigned int *) &MARS_COMM4 )
#define MARS_COMM6L         (*(volatile unsigned int *) &MARS_COMM6 )

#define MARS_VDP_DISPMODE   (*(volatile unsigned short *) 0x20004100 )
#define MARS_VDP_SHIFTREG   (*(volatile unsigned short *) 0x20004102 )
#define MARS_VDP_FILLLEN    (*(volatile unsigned short *) 0x20004104 )
#define MARS_VDP_FILLADR    (*(volatile unsigned short *) 0x20004106 )
#define MARS_VDP_FILLDAT    (*(volatile unsigned short *) 0x20004108 )
#define MARS_VDP_FBCTL      (*(volatile unsigned short *) 0x2000410A )


#endif