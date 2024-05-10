.exportzp sp, tmp1, ptr1, ptr4, tmp2, sreg, tmp4;
.exportzp _zpb1;
.exportzp _zpb2;
.exportzp _zpb3;
.exportzp _zpb4;
.exportzp _zpw1;
.exportzp _zpw2;
.exportzp _zpw3;
.exportzp _zpw4;

.segment "ZEROPAGE"
sp: .res 2
sreg:           .res    2       ; Secondary register/high 16 bit for longs
regsave:        .res    4       ; Slot to save/restore (E)AX into
ptr1:           .res    2
ptr2:           .res    2
ptr3:           .res    2
ptr4:           .res    2
tmp1:           .res    1
tmp2:           .res    1
tmp3:           .res    1
tmp4:           .res    1
_zpb1:          .res    1
_zpb2:          .res    1
_zpb3:          .res    1
_zpb4:          .res    1
_zpw1:          .res    2
_zpw2:          .res    2
_zpw3:          .res    2
_zpw4:          .res    2