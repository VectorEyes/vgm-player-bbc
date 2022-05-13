;-------------------------------------------
; vgx_init
;-------------------------------------------
; Initialise playback routine
;  A points to HI byte of a page aligned 2Kb RAM buffer address
;  X/Y point to the VGX data stream to be played
;-------------------------------------------
.vgx_init
{
    ; stash the 2kb buffer address
    sta vgm_buffers
 
    ; For VGX we simply increment stream source by 4, skipping the 'VGX<0>' magic number header
    txa
    CLC
    ADC #4
    STA zp_stream_src+0
    BCC storeHighStreamSourceAddress
    INY
    .storeHighStreamSourceAddress
    STY zp_stream_src+1

    ldx #0
    ; clear vgm finished flag
    stx vgm_finished
.block_loop

    ; init the rest
IF MASTER
    stz vgm_streams + VGM_STREAMS*0, x  ; literal cnt 
    stz vgm_streams + VGM_STREAMS*1, x  ; literal cnt 
    stz vgm_streams + VGM_STREAMS*2, x  ; match cnt 
    stz vgm_streams + VGM_STREAMS*3, x  ; match cnt 
    stz vgm_streams + VGM_STREAMS*4, x  ; window src ptr 
    stz vgm_streams + VGM_STREAMS*5, x  ; window dst ptr 
ELSE
    lda #0
    sta vgm_streams + VGM_STREAMS*0, x  ; literal cnt 
    sta vgm_streams + VGM_STREAMS*1, x  ; literal cnt 
    sta vgm_streams + VGM_STREAMS*2, x  ; match cnt 
    sta vgm_streams + VGM_STREAMS*3, x  ; match cnt 
    sta vgm_streams + VGM_STREAMS*4, x  ; window src ptr 
    sta vgm_streams + VGM_STREAMS*5, x  ; window dst ptr 
ENDIF

    ; setup RLE tables
    lda #1
    sta vgm_register_counts, X

    ; for all 8 blocks / streams
    inx
    cpx #8
    bne block_loop

    rts
}
.vgx_init_end

PRINT "VGX init code size is ", (vgx_init_end - vgx_init), " bytes"
