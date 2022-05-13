;******************************************************************
; 6502 BBC Micro Compressed VGM (VGC) Music Player
; By Simon Morris
; https://github.com/simondotm/vgm-player-bbc
; https://github.com/simondotm/vgm-packer
;******************************************************************


VGM_STREAM_CONTEXT_SIZE = 6 ; number of bytes total workspace for a stream
VGM_STREAMS = 8

;-------------------------------
; workspace/zeropage vars
;-------------------------------

; Declare where VGM player should locate its zero page vars
; VGX player uses:
;  8 zero page vars
.VGM_ZP SKIP 8 ; must be in zero page 

; declare zero page registers used for each compressed stream (they are context switched)
; none of the following have to be zp for indirect addressing reasons.
zp_literal_cnt  = VGM_ZP + 0    ; literal count LO/HI, 7 references
zp_match_cnt    = VGM_ZP + 2    ; match count LO/HI, 10 references
; temporary vars
zp_temp = VGM_ZP + 4 ; 2 bytes ; used only by lz_decode_byte and lz_fetch_count, does not need to be zp apart from memory/speed reasons

; Not context-switched per stream.
lz_zp = VGM_ZP + 6
zp_stream_src   = lz_zp + 0    ; stream data ptr LO/HI          *** ONLY USED 1-2 TIMES PER FRAME ***, not worth ZP?

; when mounting a VGM file we use these four variables as temporaries
; they are not speed or memory critical.
; they may need to be zero page due to indirect addressing
;zp_block_data = zp_stream_src ; re-uses zp_stream_src, must be zp ; zp_buffer+0 ; must be zp
;zp_block_size = zp_temp+0 ; does not need to be zp

VGM_MUSIC_BPM = 125
VGM_BEATS_PER_PATTERN = 8

VGM_FRAMES_PER_BEAT = 50 * (60.0 / VGM_MUSIC_BPM)
VGM_FRAMES_PER_PATTERN = VGM_FRAMES_PER_BEAT * VGM_BEATS_PER_PATTERN