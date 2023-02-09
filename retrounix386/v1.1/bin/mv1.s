; ****************************************************************************
; mv386.s (mv1.s) - by Erdogan Tan - 22/05/2022
; ----------------------------------------------------------------------------
; Retro UNIX 386 v1 - mv -- move (or rename) file (or directory)
;
; [ Last Modification: 27/05/2022 ]
;
; Derived from (original) UNIX v7 'mv.c' source Code
; Ref:
; www.tuhs.org (https://minnie.tuhs.org)
; ****************************************************************************
; [ v7.tar.gz - usr/src/cmd/mv.c (archive date: 10-01-1979) ]
;
; Assembler: NASM v2.15
; ((nasm mv1.s -l mv1.txt -o mv1 -Z error.txt))

; mv2.s - 27/05/2022 - Retro UNIX 386 v1.2 & v2
; mv1.s - 27/05/2022 - Retro UNIX 386 v1 & v1.1
; mv0.s - 27/05/2022 - Retro UNIX 8086 v1 (16 bit 'mv1.s')

; 12/01/2022 (Retro UNIX 386 v1.2)
; 13/10/2015

; UNIX v1 system calls
_rele 	equ 0
_exit 	equ 1
_fork 	equ 2
_read 	equ 3
_write	equ 4
_open	equ 5
_close 	equ 6
_wait 	equ 7
_creat 	equ 8
_link 	equ 9
_unlink	equ 10
_exec	equ 11
_chdir	equ 12
_time 	equ 13
_mkdir 	equ 14
_chmod	equ 15
_chown	equ 16
_break	equ 17
_stat	equ 18
_seek	equ 19
_tell 	equ 20
_mount	equ 21
_umount	equ 22
_setuid	equ 23
_getuid	equ 24
_stime	equ 25
_quit	equ 26	
_intr	equ 27
_fstat	equ 28
_emt 	equ 29
_mdate 	equ 30
_stty 	equ 31
_gtty	equ 32
_ilgins	equ 33
_sleep	equ 34 ; Retro UNIX 8086 v1 feature only !
_msg    equ 35 ; Retro UNIX 386 v1 feature only !
_geterr	equ 36 ; Retro UNIX 386 v1 feature only !
; 12/01/2022 - Retro UNIX 386 v1.2
; Retro UNIX 386 v2 system calls
_setgid	equ 37
_getgid	equ 38
_sysver	equ 39 ; (get) Retro Unix 386 version

;;;
ESCKey equ 1Bh
EnterKey equ 0Dh

%macro sys 1-4
    ; 03/09/2015	
    ; 13/04/2015
    ; Retro UNIX 386 v1 system call.		
    %if %0 >= 2   
        mov ebx, %2
        %if %0 >= 3    
            mov ecx, %3
            ;%if %0 = 4
            %if	%0 >= 4 ; 11/03/2022
		mov edx, %4   
            %endif
        %endif
    %endif
    mov eax, %1
    int 30h	   
%endmacro

; Retro UNIX 386 v1 system call format:
; sys systemcall (eax) <arg1 (ebx)>, <arg2 (ecx)>, <arg3 (edx)>

; 11/03/2022
; Note: Above 'sys' macro has limitation about register positions;
;	ebx, ecx, edx registers must not be used after their
;	positions in sys macro.
; for example:
;	'sys _write, 1, msg, ecx' is defective, because
;	 ecx will be used/assigned before edx in 'sys' macro.
; correct order may be:
;	'sys _write, 1, msg, eax ; (eax = byte count)

struc stat
	; Note: This is for Retro UNIX v1 'sysstat' output !!!
	; (34 bytes)
	.inode:  resw 1	
	.mode:	 resw 1
	.nlinks: resb 1
	.uid:	 resb 1
	.size:	 resw 1
	.dskptr: resw 8
	.ctime:	 resd 1
	.mtime:	 resd 1
	.rsvd:   resw 1
	.strucsize:
endstruc 

;struc stat
;	; Note: This is for Retro UNIX v1.2 'sysstat' output !!!
;	; (66 bytes)
;	.inode:  resw 1	
;	.mode:	 resw 1
;	.nlinks: resw 1 
;	.uid:	 resw 1
;	.gid:	 resb 1
;	.size_h: resb 1
;	.size:	 resd 1
;	.dskptr: resd 10
;	.atime:	 resd 1
;	.mtime:	 resd 1
;	.ctime:  resd 1
;	.strucsize:
;endstruc   

;;struc stat
;;	; Note: Retro UNIX v2 'sysstat' output DRAFT !!!
;;	; (72 bytes)
;;	.idev:	 resb 1
;;	.rsvd:	 resb 3
;;	.inum:   resd 1	
;;	.mode:	 resw 1
;;	.nlinks: resw 1 
;;	.uid:	 resw 1
;;	.gid:	 resb 1
;;	.size_h: resb 1
;;	.size:	 resd 1
;;	.dskptr: resd 10
;;	.atime:	 resd 1
;;	.mtime:	 resd 1
;;	.ctime:  resd 1
;;	.strucsize:
;;endstruc 

;S_IFMT   equ 0F000h ; /* type of file */
;S_IFDIR  equ 04000h ; /* directory */
;S_IFCHR  equ 02000h ; /* character special */
;S_IFBLK  equ 06000h ; /* block special */
;S_IFREG  equ 08000h ; /* regular */
;S_ISUID  equ 00800h ; /* set user id on execution */
;S_ISGID  equ 00400h ; /* set group id on execution */
;S_IREAD  equ 00100h ; /* read permission, owner */
;S_IWRITE equ 00080h ; /* write permission, owner */
;S_IEXEC  equ 00040h ; /* execute/search permission, owner */

S_IFMT   equ 0F0h ; /* type of file */
S_IFDIR  equ 040h ; /* directory */
S_IFCHR  equ 020h ; /* character special */
S_IFBLK  equ 060h ; /* block special */
S_IFREG  equ 080h ; /* regular */
S_ISUID  equ 008h ; /* set user id on execution */
S_ISGID  equ 004h ; /* set group id on execution */
S_IREAD  equ 001h ; /* read permission, owner */
S_IWRITE equ 080h ; /* write permission, owner */
S_IEXEC  equ 040h ; /* execute/search permission, owner */

;; UNIX v1 inode
;; byte 1
;S_ALLOC  equ 080h ; Allocated flag
;S_IFDIR  equ 040h ; Directory flag
;S_IFMDF  equ 020h ; File modified flag (always on)
;S_IFLRG  equ 010h ; Large File flag
;; byte 0
;S_ISUID  equ 020h ; Set User ID On Execution flag
;S_IEXEC  equ 010h ; Executable File flag
;S_IREAD  equ 008h ; Owner's Read Permission flag
;S_IWRITE equ 004h ; Owner's Write Permission flag

;%define DOT "."
;%define DOTDOT ".."
%define DELIM '/'
;%define SDELIM "/"
MODEBITS equ 11111b ; Retro UNIX v1
;MODEBITS equ 111111111b ; Retro UNIX v1.2 (v2)
ROOTINO equ 41 ; Retro UNIX v1
;ROOTINO equ 1 ; Retro UNIX v1.2 (v2)

STDIN equ 0
; 23/05/2022
MAXN equ 112

;-----------------------------------------------------------------
;  text - code
;-----------------------------------------------------------------

[BITS 32] ; 32-bit intructions (for 80386 protected mode)

[ORG 0] 

START_CODE:
	; 27/05/2022
	; 26/05/2022
	; 24/05/2022
	; 23/05/2022
	; 22/05/2022
	pop	eax ; number of arguments
	pop	edx ; argv[0]	
	;mov	[argc], eax
	mov	[argc], al

	;cmp	eax, 3
	cmp	al, 3
	jnb	short mv_0
	dec	al
	jnz	short mv_usage
	sys	_msg, program_msg, 255, 0Fh
	;mov	eax, program_msg
	;call	print_msg
mv_usage:
	;sys	_msg, usage_msg, 255, 07h
	mov	eax, usage_msg
	;call	print_msg
	jmp	print_exit ; 24/05/2022
;mv_exit:
;	sys	_exit	; sys exit
;;hlt:
;;	nop
;;	nop
;;	jmp	short hlt

mv_0:
	pop	edi ; argv[1]

	; 26/05/2022
	sys	_stat, edi, st1buf
	jnc	short mv_1

	mov	eax, msg_cant_access
	; 24/05/2022
	call	print_msg
	mov	eax, edi  ; argv[1]
	call	print_msg
	mov	eax, nextline
print_exit:
	call	print_msg
_exit_:
	sys	_exit

hang_em_high:
	nop
	jmp	short hang_em_high

mv_61:
	mov	eax, msg_ok
	jmp	short print_exit

mv_1:
	; Retro UNIX 386 v1.2
	;mov	[st1dev], eax
	;mov	al, byte [st1buf+stat.mode+1]
	;and	al, S_IFREG|S_IFDIR
	;cmp	al, S_IFREG|S_IFDIR
	;jne	short mv_2
	
	; Retro UNIX 386 v1
	;mov	[st1dev], ax ; device number
			     ; (0 = root fs)
			     ; (1 = mounted fs)
	test	byte [st1buf+stat.mode+1], S_IFDIR
	jz	short mv_2

	cmp	byte [argc], 3
	jne	short mv_usage

	pop	ebp ; argv[2]

	call	mvdir
	jnc	short mv_61 ; "OK."
	jmp	short _exit_

mv_2:
	;setuid(getuid());
	sys	_getuid
	sys	_setuid, eax
	jnc	short mv_3

	; error (permission denied)
	mov	eax, err_msg
	jmp	short print_exit
mv_3:
	; (here [esp] = argv[2]) 
	mov	al, [argc]
	dec	al  ; (if [argc] = 3 then al = 2)
	mov	cl, 2 
	sub	al, cl  ; argv[0], argv[1]
	shl	eax, cl ; * 4
	mov	ebp, esp
	add	ebp, eax
	; ebp = argv[argc-1]
	;mov	[target], ebp

	; 26/05/2022
	mov	ebp, [ebp]

	; 24/05/2022
	;cmp	byte [argc], 3
	sub	byte [argc], 2
	cmp	byte [argc], 1
	jna	short mv_6

	; (target must a -valid- directory)

	sys	_stat, ebp, st2buf
	jnc	short mv_5
mv_4:
	jmp	mv_usage
mv_5:	
	; Retro UNIX 386 v1.2
	;mov	[st2dev], eax
	;mov	al, byte [st2buf+stat.mode+1]
	;and	al, S_IFREG|S_IFDIR
	;cmp	al, S_IFREG|S_IFDIR
	;jne	short mv_4
	
	; Retro UNIX 386 v1
	;mov	[st2dev], ax ; device number
			     ; (0 = root fs)
			     ; (1 = mounted fs)
	test	byte [st2buf+stat.mode+1], S_IFDIR
	jz	short mv_4

	; 26/05/2022
	;sub	byte [argc], 2 ; [argc] >= 1
	;	; i = 1
mv_6:	
	; edi = argv[i] 
	; ebp = argv[argc-1]
	call	move
	jnc	short mv_7
	inc	byte [errors]
mv_7:
	dec	byte [argc] ; i++
	jz	short mv_8
		    ; i < argc-1
	pop	edi ; argv[i]
	jmp	short mv_6
mv_8:
	cmp	byte [errors], 0
	ja	short mv_9

	mov	eax, msg_ok
	;jmp	print_exit
	call	print_msg
mv_9:
	jmp	_exit_

;-----------------------------------------------------------------

move:
	; 27/05/2022
	; 26/05/2022
	; 24/05/2022
	; 22/05/2022

	; move(source, target)

	; INPUT:
	;	edi = source
	;	ebp = target
	; OUTPUT:
	;	cf = 0 -> ok
	;	cf = 1 -> error

	; if (stat(source, &s1) < 0)
	sys	_stat, edi, st1buf
	jnc	short mv_10

	mov	eax, msg_cant_access
	; 24/05/2022
	call	print_msg
	mov	eax, edi ; source
	call	print_msg
	mov	eax, nextline
move_err:
	call	print_msg
	stc
	retn
mv_10:
	; Retro UNIX 386 v1.2
	;mov	[st1dev], eax
	;mov	al, byte [st1buf+stat.mode+1]
	;and	al, S_IFREG|S_IFDIR
	;cmp	al, S_IFREG|S_IFDIR
	;jne	short mv_11

	; Retro UNIX 386 v1 (& v1.1)
	mov	[st1dev], ax ; device number
			     ; (0 = root fs)
			     ; (1 = mounted fs)

	; if ((s1.st_mode & S_IFMT) == S_IFDIR)
	test	byte [st1buf+stat.mode+1], S_IFDIR
	jz	short mv_11

	mov	eax, msg_rename_only
	jmp	short move_err
mv_11:
	; 26/05/2022
	mov	[target], ebp

	; if (stat(target, &s2) >= 0)
	sys	_stat, ebp, st2buf
	;jc	short mv_19
	; 23/05/2022
	jnc	short mv_12
	jmp	mv_19
mv_12:
	; Retro UNIX 386 v1.2
	;mov	[st2dev], eax
	;mov	al, byte [st2buf+stat.mode+1]
	;and	al, S_IFREG|S_IFDIR
	;cmp	al, S_IFREG|S_IFDIR
	;jne	short mv_14

	; Retro UNIX 386 v1 (& v1.1)
	mov	[st2dev], ax ; device number
			     ; (0 = root fs)
			     ; (1 = mounted fs)

	; if ((s2.st_mode & S_IFMT) == S_IFDIR)
	test	byte [st2buf+stat.mode+1], S_IFDIR
	jz	short mv_14

	; sprintf(buf, "%s/%s", target, dname(source));

;	mov	esi, ebp ; target
;	mov	ebx, edi ; source
;	mov	edx, ebx ; source 
;	mov	edi, buf ; pathname buffer (100 bytes)
;	mov	[target], edi
;mv_12:
;	lodsb
;	or	al, al
;	jz	short mv_13
;	stosb
;	jmp	short mv_12
;		
;mv_13:
;	mov	al, DELIM ; '/'
;	stosb
;	
;	; edx = source (pathname)
;	; edi = buffer (offset) position
;	call	dname
;	mov	edi, ebx ; source
;			 ; target = buf;
	; 22/05/2022
	call	strcpy ; 27/05/2022

	;if (stat(target, &s2) >= 0)

	sys	_stat, buf, st2buf
	;jc	short mv_20 ; 26/05/2022
	; 26/05/2022
	jnc	short mv_13
	jmp	mv_20
mv_13:
	; Retro UNIX 386 v1.2
	;mov	[st2dev], eax
	;mov	al, byte [st2buf+stat.mode+1]
	;and	al, S_IFREG|S_IFDIR
	;cmp	al, S_IFREG|S_IFDIR
	;jne	short mv_14

	; Retro UNIX 386 v1 (& v1.1)
	mov	[st2dev], ax ; device number
			     ; (0 = root fs)
			     ; (1 = mounted fs)

	; if ((s2.st_mode & S_IFMT) == S_IFDIR)
	test	byte [st2buf+stat.mode+1], S_IFDIR
	jz	short mv_14

	;fprintf(stderr, "mv: %s is a directory\n", target);
	mov	eax, mv_header
	call	print_msg
	mov	eax, buf  ; target
	call	print_msg
	mov	eax, msg_is_a_dir
	jmp	move_err

mv_14:
	; if (s1.st_dev==s2.st_dev && s1.st_ino==s2.st_ino)
	mov	ax, [st1buf+stat.inode]
	cmp	ax, [st2buf+stat.inode]
	jne	short mv_15
	; 26/05/2022
	mov	ax, [st1dev]
	cmp	ax, [st2dev]
	jne	short mv_15

	;fprintf(stderr, "mv: %s and %s are identical\n",
	;		source, target);

	; edi = source
	; (buf = target or) [target] = target

	mov	eax, mv_header
	call	print_msg
	mov	eax, edi ; source
	call	print_msg
	mov	eax, msg_and
	call	print_msg
	mov	eax, [target] ; target ; 26/05/2022
	call	print_msg
	mov	eax, msg_identical
	jmp	move_err

mv_15:
	; if (access(target, 2) < 0 && isatty(fileno(stdin)))
	mov	esi, st2buf
	call	access
	jnz	short mv_18
	; not permitted

	call	isatty
	jc	short mv_18 ; not a tty
	
	;fprintf(stderr, "mv: %s: %o mode ", target,
	;			s2.st_mode & MODEBITS);

	mov	eax, mv_header
	call	print_msg
	mov	eax, [target] ; target ; 26/05/2022
	call	print_msg
	mov	ebx, [st2buf+stat.mode]
	and	ebx, MODEBITS
	mov	esi, octm 
	call	octalnumber
	; 27/05/2022
	;mov	eax, octm
	mov	byte [octms], 20h
	mov	eax, octms
	call	print_msg
	mov	eax, msg_mode
	call	print_msg

	; i = c = getchar();
	call	getchar
	
	cmp	al, 'y'
	je	short mv_17

	mov	eax, msg_no
mv_16:
	call	print_msg
	stc
	retn
mv_17:
	mov	eax, msg_yes
	call	print_msg
mv_18:
	; if (unlink(target) < 0)	
	sys	_unlink, [target] ; 26/05/2022
	jnc	short mv_20

	; fprintf(stderr, "mv: cannot unlink %s\n", target);
	mov	eax, msg_cant_unlink
	call	print_msg
	mov	eax, [target] ; 26/05/2022
	call	print_msg
	mov	eax, nextline 
	jmp	short mv_16	
mv_19:
	; 26/05/2022
	;mov	[target], ebp ; target
mv_20:
	; if (link(source, target) < 0)

	sys	_link, edi, [target]
	jnc	short mv_25

	mov	ebx, mv_21  ; child process jump address	
	sys	_fork
	jnc	short mv_22 ; parent return and jump

	mov	eax, msg_try_again
	jmp	short mv_16
mv_21:
	; child process will continue from here
	
	mov	eax, [target]
	mov	[cp_target], eax
	mov	[cp_source], edi

	sys	_exec, cp_cmd, cp_args
	
	; fprintf(stderr, "mv: cannot exec cp\n");
	mov	eax, msg_cant_exec_cp
	;call	print_msg
	;jmp	_exit_
	; 23/05/2022
	jmp	print_exit

mv_22:
	mov	edx, eax ; child process id
mv_23:
	; while ((c = wait(&status)) != i && c != -1)
	;if (status != 0)
	;	return(1);
	; utime(target, &s1.st_atime);

	sys	_wait
	jc	short mv_24

	cmp	eax, edx
 	jne	short mv_23

	; 26/05/2022 (check if /bin/cp has been failed) 
	sys	_stat, [target], fstbuf
	jc	short mv_24
	mov	ax, [fstbuf+stat.size]
	cmp	ax, [st1buf+stat.size]
	je	short mv_25
	stc
mv_24:
	retn

	; utime(target, &s1.st_atime);

	;;;
mv_25:
	;if (unlink(source) < 0) {
	;	fprintf(stderr, "mv: cannot unlink %s\n", source);
	;	return(1);
	;}

	sys	_unlink, edi
	jnc	short mv_24

	mov	eax, msg_cant_unlink
	call	print_msg
	mov	eax, edi ; source
	call	print_msg
	mov	eax, nextline	
	;if (status != 0)
	;	return(1);
	jmp	mv_16

;-----------------------------------------------------------------

mvdir:
	; 27/05/2022
	; 26/05/2022
	; 23/05/2022
	; 22/05/2022
	
	; mvdir(source, target)

	; INPUT:
	;	edi = source
	;	ebp = target
	; OUTPUT:
	;	cf = 0 -> ok
	;	cf = 1 -> error

	; st1buf = source (inode) stat(us) buffer

	;if (stat(target, &s2) >= 0) 
	sys	_stat, ebp, st2buf
	jc	short mv_29

	;if ((s2.st_mode&S_IFMT) != S_IFDIR)
	
	; Retro UNIX 386 v1.2
	;mov	[st2dev], eax
	;mov	al, byte [st2buf+stat.mode+1]
	;and	al, S_IFREG|S_IFDIR
	;cmp	al, S_IFREG|S_IFDIR
	;je	short mv_28

	; Retro UNIX 386 v1 (& v1.1)
	;mov	[st2dev], ax ; device number
			     ; (0 = root fs)
			     ; (1 = mounted fs)

	;if ((s2.st_mode & S_IFMT) == S_IFDIR)
	test	byte [st2buf+stat.mode+1], S_IFDIR
	jnz	short mv_28

	;fprintf(stderr, "mv: %s exists\n", target);

	push	ebp ; target
mv_27:
	mov	eax, mv_header
	call	print_msg	
	pop	eax  ; target
	call	print_msg 
	mov	eax, msg_exists
	call	print_msg
	stc
	retn

mv_28:
	;if (strlen(target) > MAXN-DIRSIZ-2) {
	;	fprintf(stderr, "mv: target name too long\n");
	;	return(1);
	;}

	;strcpy(buf, target);

;	mov	esi, ebp ; target
;	mov	edx, edi ; source
;	mov	edi, buf ; pathname buffer (100 bytes)
;	mov	[target], edi 
;mv_29:
;	lodsb
;	stosb
;	and	al, al
;	jnz	short mv_29
	
	;strcat(buf, SDELIM);
	;strcat(buf, dname(source));

	call	strcpy ; 27/05/2022

	sys	_stat, buf, st2buf
	jc	short mv_30

	push	ebx ; buf ; [target]
	jmp	short mv_27

mv_29:
	mov	[target], ebp
mv_30:
	; if (strcmp(source, target) == 0) {
	
	push	edi
	mov	esi, edi
	mov	edi, [target]
	call	strcmp
	pop	edi
	jne	short mv_32

	mov	eax, msg_src_target
mv_31:
	call	print_msg
	stc
	retn

mv_32:
	mov	edx, edi
	mov	edi, fstbuf ; (66 bytes buffer)
	;mov	ebx, edi
	push	edx ; *
	call	dname
	; edx = fstbuf = file name

	;!strcmp(p, "")
	cmp	byte [edx], 0
	je	short mv_33 ; null
	;!strcmp(p, DOT)
	mov	esi, edx		
	cmp	byte [esi], '.'
	jne	short mv_34
	mov	edi, DOT
	call	strcmp
	je	short mv_33 ; '.'
	;!strcmp(p, DOTDOT)
	mov	esi, edx
	mov	edi, DOTDOT
	call	strcmp
	jne	short mv_34
	; '..'
mv_33:
	pop	edi ; *
	
	;fprintf(stderr, "mv: cannot rename %s\n", p);
	mov	eax, msg_cant_rename
	call	print_msg
	mov	eax, fstbuf
	jmp	short mv_31

mv_34:
	pop	edi ; *
	mov	ebx, sbuf
	; edi = source
	; ebx = buffer
	call	pname
	; esi = parent directory name address
	;
	;if (stat(pname(source), &s1) < 0 ||
	sys	_stat, esi, pst1buf
	jnc	short mv_36
mv_35:
	mov	eax, msg_cant_locate
 	jmp	short mv_31
mv_36:
	mov	[st1dev], ax
	mov	edx, [target]
	xchg	edx, edi
	;stat(pname(target), &s2) < 0)
	; edi = source
	mov	ebx, tbuf ; buffer
	call	pname
	; esi = parent directory name address
	mov	edi, edx
	sys	_stat, esi, pst2buf
	jc	short mv_35
	mov	[st2dev], ax
	;if (access(pname(target), 2) < 0)		
	mov	esi, pst2buf
	call	access
	jnz	short mv_39
	; permission denied !
	mov	edx, tbuf ; pname(target)
mv_37:
	push	edx ; pname(target) or pname(source)
	mov	eax, msg_no_w_access
	call	print_msg
	pop	eax ; pname(target) or pname(source)
	call	print_msg
	mov	eax, nextline
mv_38:
	call	print_msg
	stc
	retn
mv_39:
	;if (access(pname(source), 2) < 0)
	mov	esi, pst1buf
	call	access
	jnz	short mv_40
	; permission denied !
	mov	edx, sbuf ; pname(source)
	jmp	short mv_37
mv_40:
	;if (access(source, 2) < 0)
 	; edi = source
	mov	esi, st1buf 
		; source (inode) stat(us) buffer
	call	access
	jnz	short mv_41
	mov	edx, edi ; source
	jmp	short mv_37
mv_41:
	;if (s1.st_dev != s2.st_dev)
	mov	ax, [st1dev]
	cmp	ax, [st2dev]
	je	short mv_42
	;fprintf(stderr, "mv: cannot move directories
	;			 across devices\n");
	mov	eax, msg_accross_devices
	jmp	short mv_38
mv_42:
	;if (s1.st_ino != s2.st_ino)	
	mov	ax, [pst1buf+stat.inode]
	cmp	ax, [pst2buf+stat.inode]
	jne	short mv_43
	jmp	mv_57
mv_43:
	; (move dir from parent dir to another dir)

	;if (chkdot(source) || chkdot(target))
	mov	ebx, edi ; source
	call	chkdot
	jnc	short mv_45
mv_44:
	;fprintf(stderr, "mv: Sorry, path names
	;	 including %s aren't allowed\n", DOTDOT);
	mov	eax, msg_pathname_dotdot
	jmp	short mv_38
mv_45:
	mov	ebx, [target] ; target
	call	chkdot
	jc	short mv_44
mv_46:
	;stat(source, &s1);
	;if (check(pname(target), s1.st_ino))
	mov	ebx, tbuf
	call	check
	jc	short mv_49 ; return(1);
mv_47:		
	;for (i = 1; i <= NSIG; i++)
	;	signal(i, SIG_IGN);
	;   if (link(source, target) < 0) {
	
	sys	_link, edi, [target]
	jnc	short mv_50
	
	; fprintf(stderr, "mv: cannot link %s to %s\n",
	;		 target, source);
mv_48:
	mov	eax, msg_cant_link
	call	print_msg
	mov	eax, [target] ; target
	call	print_msg
	mov	eax, msg_to
	call	print_msg
	mov	eax, edi ; source
	call	print_msg
	mov	eax, nextline
	call	print_msg
	stc
mv_49:
	retn
mv_50:
 	;if (unlink(source) < 0) {
	sys	_unlink, edi	
	jnc	short mv_51

	;fprintf(stderr, "mv: %s: cannot unlink\n", source);
	mov	eax, msg_cant_unlink
	call	print_msg
	mov	eax, edi ; source
	call	print_msg
	mov	eax, nextline
	call	print_msg
	;unlink(target);
	sys	_unlink, [target]
	;return(1);
	stc
	retn
mv_51:
	;strcat(dst, target);
	;strcat(dst, "/");
	;strcat(dst, DOTDOT);

	mov	esi, [target]
	push	edi ; *
	mov	edi, nspth 
mv_52:
	lodsb
	stosb
	and	al, al
	jnz	short mv_52
	dec	edi
	mov	eax, 002E2E2Fh ; db '/..', 0  
	stosd
	pop	edi ; *

	;if (unlink(dst) < 0)
	sys	_unlink, nspth
	jnc	short mv_56

	; fprintf(stderr, "mv: %s: cannot unlink\n", dst);
	mov	eax, msg_cant_unlink
	call	print_msg
	mov	eax, nspth ; dst
	call	print_msg
	mov	eax, nextline
	call	print_msg
mv_53:
	;if (link(target, source) >= 0)
	;	unlink(target);
	sys	_link, edi, [target]
	jc	short mv_55
mv_54:
	;unlink(target);
	sys	_unlink, [target]
	;return(1);
	stc
mv_55:
	retn
mv_56:
	;if (link(pname(target), dst) < 0)
	sys	_link, tbuf, nspth
	jnc	short mv_55 ;return(0)

	;fprintf(stderr, "mv: cannot link %s to %s\n",
	;		dst, pname(target));
	mov	eax, msg_cant_link
	call	print_msg
	mov	eax, nspth ; dst
	call	print_msg
	mov	eax, msg_to
	call	print_msg
	mov	eax, tbuf ; pname(taget)
	call	print_msg
	mov	eax, nextline
	call	print_msg
	;if (link(pname(source), dst) >= 0)
	sys	_link, sbuf, nspth
	jc	short mv_55
	;if (link(target, source) >= 0)
	;	unlink(target);
	jmp	short mv_53

mv_57:
	; (move dir in same parent directory)
 
	;if (link(source, target) < 0)
	sys	_link, edi, [target]
	jnc	short mv_60
	;fprintf(stderr, "mv: cannot link %s and %s\n",
	;		source, target);
	mov	eax, msg_cant_link
	call	print_msg
	mov	eax, edi ; source
	call	print_msg
	mov	eax, msg_and
	call	print_msg
	mov	eax, [target] ; target
mv_58:
	call	print_msg
	mov	eax, nextline
	call	print_msg
	;return(1);
	stc
mv_59:
	retn	
mv_60:
	;if (unlink(source) < 0) {
	sys	_unlink, edi
	jnc	short mv_59 ;return(0)
	
	;fprintf(stderr, "mv: ?? cannot unlink
	;		 %s\n", source);
	
	mov	eax, msg_cant_unlink
	call	print_msg
	mov	eax, edi ; source
	jmp	short mv_58

;-----------------------------------------------------------------

strcpy:
	mov	esi, ebp ; target
	mov	ebx, edi ; source
	mov	edx, ebx
	mov	edi, buf ; pathname buffer (100 bytes)
	mov	[target], edi
strcp_1:
	lodsb
	or	al, al
	jz	short strcp_2
	stosb
	jmp	short strcp_1
strcp_2:
	; 27/05/2022
	mov	al, DELIM ; '/'
	cmp	edi, buf
	jna	short strcp_3
	;cmp	byte [edi-1], DELIM  ; '/'
	cmp	byte [edi-1], al ; '/'
	je	short strcp_4
strcp_3:
	;mov	al, DELIM ; '/'
	stosb
strcp_4:	
	; edx = source (pathname)
	; edi = buffer (offset) position
	call	dname
	mov	edi, ebx ; source
			 ; target = buf;
	retn

;-----------------------------------------------------------------

strcmp:
	; esi = source
	; edi = target
strcmp_1:
	lodsb
	or	al, al
	jz	short strcmp_2
	scasb
	je	short strcmp_1
	retn
strcmp_2:
	;cmp	[edi], al ; 0
	scasb
strcmp_3:
	; zf = 1 -> same
	retn
	
;-----------------------------------------------------------------

dname:	; dname(name)
	; edx = source (pathname)
	; edi = buffer (offset) position
dname_0:
	mov	esi, edx  ; name
	;p = name;
	;while (*p)
dname_1:
	lodsb
	and	al, al
	jz	short dname_2
	cmp	al, DELIM  ; cmp al, '/'
	jne	short dname_1
	;if (*p++ == DELIM && *p)
	cmp	byte [esi], 0
	;je	short dname_1
	je	short dname_2 
	mov	edx, esi
	jmp	short dname_1	
dname_2:
	; edx = file name
	mov	esi, edx
dname_3:
	lodsb
	stosb
	or	al, al	
	jnz	short dname_3
	retn

;-----------------------------------------------------------------

pname:	; pname(name)
	; 23/05/2022

	; INPUT:
	;	edi = source (pathname)
	;	ebx = buffer address
	; OUTPUT:
	;	esi = parent dir name address
pname_0:
	mov	esi, edi ; source
	push	edi ; *
	;p = q = buf;
	mov	edi, ebx
	mov	ecx, ebx
	; while (c = *p++ = *name++)
pname_1:
	lodsb
	stosb
	and	al, al
	jz	short pname_2
	;if (c == DELIM)
	;	q = p-1;
	cmp	al, DELIM  ; cmp al, '/'
	jne	short pname_1
	mov	ebx, edi
	dec	ebx
	jmp	short pname_1
pname_2:
	;if (q == buf && *q == DELIM)
	;    q++;
	cmp	ebx, ecx
	jne	short pname_3
	cmp	byte [ebx], DELIM ; '/'
	jne	short pname_3
	inc	ebx	
pname_3:
	;*q = 0;
	mov	byte [ebx], 0
	mov	esi, ecx
	pop	edi ; *
	; return buf[0]? buf : DOT;
	cmp	byte [esi], 0
	ja	short pname_4
	mov	eax, [DOT] ; db '.', 0
	mov	[esi], eax
pname_4:
	retn

;-----------------------------------------------------------------

check:	; check(spth, dinode)
	; 23/05/2022

	; INPUT:
	;	ebx = name buffer address
	;	[st1buf+stat.inode] = inode num to be compared
	; OUTPUT:
	;	cf = 1 -> error
	;	cf = 0 -> no problem

	;strcpy(nspth, spth);

	mov	esi, ebx
	push	edi ; *
	mov	edi, nspth 
check_1:
	lodsb
	stosb
	and	al, al
	jnz	short check_1
	sub	esi, ebx 
	dec	esi ; esi = strlen(nspth)
	pop	edi ; *
check_2:
	;if (stat(nspth, &sbuf) < 0)
	sys	_stat, nspth, fstbuf
	jnc	short check_5
	;fprintf(stderr, "mv: cannot access %s\n", nspth);
	mov	eax, msg_cant_access
	call	print_msg
	mov	eax, nspth
	call	print_msg
	mov	eax, nextline
check_3:
	call	print_msg
	stc
check_4:
	retn
check_5:
	;if (sbuf.st_ino == dinode)
	mov	ax, [fstbuf+stat.inode]
	cmp	ax, [st1buf+stat.inode]
	jne	short check_6
	; fprintf(stderr, "mv: cannot move a directory
	;			 into itself\n");
	mov	eax, msg_cant_mv_itself
	jmp	short check_3
check_6:
	;while (sbuf.st_ino != ROOTINO)
	cmp	ax, ROOTINO
	je	short check_4

	;if (strlen(nspth) > MAXN-2-sizeof(DOTDOT))
	cmp	esi, MAXN-4
	jna	short check_7

	;fprintf(stderr, "mv: name too long\n");
	mov	eax, msg_too_long
	jmp	short check_3
check_7:
	;strcat(nspth, SDELIM);
	;strcat(nspth, DOTDOT);
	mov	eax, 002E2E2Fh ; db '/..', 0  
	mov	[esi+nspth], eax
	add	esi, 3
	jmp	short check_2

;-----------------------------------------------------------------

chkdot:	; chkdot(s)
	; 23/05/2022

	;do {
	;    if (strcmp(dname(s), DOTDOT) == 0)
	;	return(1);
	;    s = pname(s);
	;} while (strcmp(s, DOT) != 0 && strcmp(s, SDELIM) != 0);
	;return(0);

	; INPUT:
	;	ebx = name buffer address
	; OUTPUT:
	;	cf = 1 -> DOTDOT (return 0)
	;	cf = 0 -> not DOTDOT (return 1)

	; get last '/'
	mov	esi, ebx
chkdot_0:
	mov	ecx, ebx
chkdot_1:
	lodsb
	and	al, al
	jz	short chkdot_2
	cmp	al, DELIM ; '/'
 	jne	short chkdot_1
	cmp	byte [esi], 0
	jna	short chkdot_2	
	mov	ecx, esi
	dec	ecx
	jmp	short chkdot_1 
chkdot_2:
	push	edi ; *
	mov	esi, ecx
	mov	edi, DOTDOT
	call	strcmp
	jz	short chkdot_4 ; DOTDOT
	mov	edi, ebx
	mov	ebx, fstbuf
	call	pname
	pop	edi ; *
	mov	ebx, esi  ; parent dir's pathname buf
	mov	ax, [esi]
	or	ah, ah ; 0 ?
	jnz	short chkdot_0
	; (single character parent directory name)
	; (it's name may be '.' or '/' or another char)
	; pathname does not contain a DOTDOT
	retn
chkdot_4:
	; pathname contains DOTDOT
	stc
	retn
	 
;-----------------------------------------------------------------

access:
	; 22/05/2022
	; Retro UNIX 386 v1 & v1.1 & v1.2

	; INPUT:
	;	esi = stat(us) buffer 
	; OUTPUT:
	;	zf = 1 -> no write permission
	;	zf = 0 -> permitted to write
		
	sys	_getuid
	;mov	[uid], ax

	; Retro UNIX 386 v1.2 (v2 fs)
	;mov	dl, 80h  ; write permission flag, owner

	; Retro UNIX 386 v1
	mov	dl, 4  ; write permission flag, owner

	;or	ax, ax
	or	al, al
	jz	short access_1 ; root

	;cmp	ax, [esi+stat.uid]	
	cmp	al, [esi+stat.uid]
	je	short access_1

	; Retro UNIX 386 v1.2 (v2 fs inode)
	;sys	_getgid
	;;mov	[gid], al

	;mov	dl, 10h
	;cmp	al, [esi+stat.gid]
	;je	short access_1
	;
	;mov	dl, 02h

	; Retro UNIX 386 v1	
	mov	dl, 1
access_1:
	test	dl, [esi+stat.mode]
	retn

;-----------------------------------------------------------------

isatty:
	; 22/05/2022
	; Retro UNIX 386 v1 & v1.1 & v1.2

	; Input: stdin (= 0)
	; output:
	;	cf = 1 -> not a tty

	sys	_fstat, STDIN, fstbuf

	mov	ax, [fstbuf+stat.inode]

	; Retro UNIX 386 v1.2
	;cmp	ax, 8 ; /dev/tty
	;je	short isatty_2
	;cmp	ax, 26 ; /dev/tty8
	;ja	short isatty_1
	;cmp	ax, 17 ; /dev/tty0
	;retn

	; Retro UNIX 386 v1 (& v1.1)
	cmp	ax, 1 ; /dev/tty
	je	short isatty_2
	cmp	ax, 19 ; /dev/tty8
	ja	short isatty_1
	cmp	ax, 10 ; /dev/tty0
	retn
isatty_1:
	stc
isatty_2:   
	retn

;-----------------------------------------------------------------
	
octalnumber:
	; 27/05/2022

	; Input:
	;   ebx = binary number (max. 9 bit)
	;   esi = string buffer (4 byte)

	mov	eax, ebx
	mov	cl, 3
	shr	ebx, cl ; 3
	and	al, 7
	push	eax
	mov	eax, ebx
	shr	ebx, cl ; 3 
	and	al, 7	
	push	eax
	mov	eax, ebx
	and	al, 7
octn_0:
	; 27/05/2022
	;mov	byte [esi], 20h
	;inc	esi
	mov	ebx, esi
	;or	al, al
	;jz	short octn_1
	call	octn_3
octn_1:
	pop	eax
	; 27/05/2022
	call	octn_3
octn_2:
	pop	eax
	;call	octn_3
	call	octn_4 ; 27/05/2022
	xor	al, al
	jmp	short octn_5

octn_3:
	; 27/05/2022
	and	al, al
	jnz	short octn_4
	cmp	esi, ebx
	je	short octn_6
octn_4:
	add	al, '0'
octn_5:
	mov	[esi], al
	inc	esi
octn_6:
	retn

;-----------------------------------------------------------------

getchar:
	; i = c = getchar();
	; while (c != '\n' && c != EOF)
	;		c = getchar();
getc_0:	
	sys	_read, STDIN, char, 1
	mov	al, [char]
	cmp	al, 'y'
	je	short getc_2
	cmp	al, 'n'
	je	short getc_2	
	cmp	al, ESCKey
	je	short getc_2
	cmp	al, EnterKey
	je	short getc_2
	cmp	al, 'Y'	
	jne	short getc_1
	mov	al, 'y'
	retn
getc_1:
	cmp	al, 'N'
	jne	short getc_0
getc_2:
	retn	

;-----------------------------------------------------------------

print_msg:
	; eax = asciiz string address
	mov	esi, eax
	dec	esi
nextchr:
	inc	esi
	cmp	byte [esi], 0
	ja	short nextchr
	;cmp	[esi], 0Dh
	;ja	short nextchr
	sub	esi, eax
	; esi = asciiz string length
	;
	sys	_write, 1, eax, esi
	;
	retn

;-----------------------------------------------------------------
;  data - initialized data
;-----------------------------------------------------------------

;argc:	dd 0
argc:	db 0
errors:	db 0

cp_cmd:
	db '/bin/cp', 0

cp_args:
	dd cp_cmd
cp_source:
	dd 0		
cp_target:
	dd 0
	dd 0

DOTDOT:	db '.'
DOT:	db '.', 0
	;db 0, 0

; ----------------------------------------------------------------

program_msg:
	db  0Dh, 0Ah
	db  'Retro UNIX 386 v1 MOVE by Erdogan TAN - 27/05/2022'
	db  0Dh, 0Ah, 0

usage_msg:
	db  0Dh, 0Ah
	db  'usage: mv f1 f2; or mv d1 d2; or mv f1 ... fn d1'
nextline:
	db  0Dh, 0Ah, 0

mv_header:
	db 0Dh, 0Ah
	db 'mv: '
	db 0
msg_not_exists:
	;db 0Dh, 0Ah
	db ' does not exist '
	db 0Dh, 0Ah, 0

msg_is_a_dir:
	db ' is a directory '
	db 0Dh, 0Ah, 0

msg_cant_access:
	db 0Dh, 0Ah
	db 'mv: cannot access '
	db 0

msg_rename_only:
	db 0Dh, 0Ah
	db 'mv: directory rename only'
	db 0Dh, 0Ah, 0

msg_cant_unlink:
	db 0Dh, 0Ah
	db 'mv: cannot unlink '
	db 0

msg_try_again:
	db 0Dh, 0Ah
	db 'mv: try again'
	db 0Dh, 0Ah, 0

msg_cant_exec_cp:
	db 0Dh, 0Ah
	db 'mv: cannot exec cp'
	db 0Dh, 0Ah, 0

msg_exists:
	db ' exists '
	db 0Dh, 0Ah, 0

;msg_long_target:
;	db 0Dh, 0Ah
;	db 'mv: target name too long'
;	db 0Dh, 0Ah, 0

msg_src_target:
	db 0Dh, 0Ah
	db 'mv: ?? source == target, source exists and target doesnt'
	db 0Dh, 0Ah, 0

msg_cant_locate:
	db 0Dh, 0Ah
	db 'mv: cannot locate parent'
	db 0Dh, 0Ah, 0

msg_no_w_access:
	db 0Dh, 0Ah
	db 'mv: no write access to '
	db 0

msg_accross_devices:
	db 0Dh, 0Ah
	db 'mv: cannot move directories across devices'
	db 0Dh, 0Ah, 0

msg_pathname_dotdot:
	db 0Dh, 0Ah
	db "mv: Sorry, path names including '..' aren't allowed"
	db 0Dh, 0Ah, 0

msg_cant_rename:
	db 0Dh, 0Ah
	db 'mv: cannot rename '
	db 0

msg_cant_link:
	db 0Dh, 0Ah
	db 'mv: cannot link '
	db 0
msg_to:
	db ' to '
	db 0
msg_and:
	db ' and '
	db 0

msg_identical:
	db ' are identical'
	db 0Dh, 0Ah, 0	 

msg_cant_mv_itself:
	db 0Dh, 0Ah
	db 'mv: cannot move a directory into itself'
	db 0Dh, 0Ah, 0

msg_too_long:
	db 0Dh, 0Ah
	db 'mv: name too long'
	db 0Dh, 0Ah, 0

msg_mode:
	db ' mode ? (y/n) '
	db 0

msg_yes:
	db ' YES '
	db 0Dh, 0Ah, 0

msg_no:
	db ' NO '
	db 0Dh, 0Ah, 0

err_msg:
	db 0Dh, 0Ah
	db 'Error! '
	db 0Dh, 0Ah, 0

msg_ok:
	db  0Dh, 0Ah
	db  'OK.'
	db  0Dh, 0Ah, 0

;-----------------------------------------------------------------
;  bss - uninitialized data
;-----------------------------------------------------------------

align 4

bss_start:

ABSOLUTE bss_start

;uid:	resw 1
;;gid:	resw 1  ; Retro UNIX 386 v1.2

target:	resd 1	; destination/target pathname pointer

st1dev: resw 1
st1buf: resb 34 ; for Retro UNIX 386 v1 & v1.1
st2dev: resw 1
st2buf: resb 34 ; 
;st1dev: resd 1
;st1buf: resb 66 ; for Retro UNIX 386 v1.2
;st2dev: resd 1
;st2buf: resb 66 ;

buf:	resb 100 ; pathname buffer
sbuf:	resb 92 ; source, parent name buffer ; 23/05/2022
tbuf:	resb 92 ; target, parent name buffer ; 23/05/2022			
fstbuf:	resb 66	; fstat buffer
; 23/05/2022
;pst1buf: resb 66
;pst2buf: resb 66
pst1buf: resb 34
pst2buf: resb 34
octms:	resb 1	; 27/05/2022
octm:	resb 4	; octal mode number
char:	resb 1	; getchar buffer	
nspth:	resb MAXN ; 112 ; buffer for 'check' procedure

; 22/05/2022
;-----------------------------------------------------------------
; Original UNIX v7 - mv (utility) c source code (mv.c)
;-----------------------------------------------------------------
;/* UNIX V7 source code: see www.tuhs.org for details. */;
;
;/*
; * mv file1 file2
; */
;
;#include <stdio.h>
;#include <sys/types.h>
;#include <sys/stat.h>
;#include <sys/dir.h>
;#include <signal.h>
;
;#define DOT	"."
;#define DOTDOT	".."
;#define DELIM	'/'
;#define SDELIM "/"
;#define MAXN	100
;#define MODEBITS 07777
;#define ROOTINO 2
;
;char	*pname();
;char	*sprintf();
;char	*dname();
;struct	stat s1, s2;
;
;main(argc, argv)
;register char *argv[];
;{
;	register i, r;
;
;	if (argc < 3)
;		goto usage;
;	if (stat(argv[1], &s1) < 0) {
;		fprintf(stderr, "mv: cannot access %s\n", argv[1]);
;		return(1);
;	}
;	if ((s1.st_mode & S_IFMT) == S_IFDIR) {
;		if (argc != 3)
;			goto usage;
;		return mvdir(argv[1], argv[2]);
;	}
;	setuid(getuid());
;	if (argc > 3)
;		if (stat(argv[argc-1], &s2) < 0 || (s2.st_mode & S_IFMT) != S_IFDIR)
;			goto usage;
;	r = 0;
;	for (i=1; i<argc-1; i++)
;		r |= move(argv[i], argv[argc-1]);
;	return(r);
;usage:
;	fprintf(stderr, "usage: mv f1 f2; or mv d1 d2; or mv f1 ... fn d1\n");
;	return(1);
;}
;
;move(source, target)
;char *source, *target;
;{
;	register c, i;
;	int	status;
;	char	buf[MAXN];
;
;	if (stat(source, &s1) < 0) {
;		fprintf(stderr, "mv: cannot access %s\n", source);
;		return(1);
;	}
;	if ((s1.st_mode & S_IFMT) == S_IFDIR) {
;		fprintf(stderr, "mv: directory rename only\n");
;		return(1);
;	}
;	if (stat(target, &s2) >= 0) {
;		if ((s2.st_mode & S_IFMT) == S_IFDIR) {
;			sprintf(buf, "%s/%s", target, dname(source));
;			target = buf;
;		}
;		if (stat(target, &s2) >= 0) {
;			if ((s2.st_mode & S_IFMT) == S_IFDIR) {
;				fprintf(stderr, "mv: %s is a directory\n", target);
;				return(1);
;			}
;			if (s1.st_dev==s2.st_dev && s1.st_ino==s2.st_ino) {
;				fprintf(stderr, "mv: %s and %s are identical\n",
;						source, target);
;				return(1);
;			}
;			if (access(target, 2) < 0 && isatty(fileno(stdin))) {
;				fprintf(stderr, "mv: %s: %o mode ", target,
;					s2.st_mode & MODEBITS);
;				i = c = getchar();
;				while (c != '\n' && c != EOF)
;					c = getchar();
;				if (i != 'y')
;					return(1);
;			}
;			if (unlink(target) < 0) {
;				fprintf(stderr, "mv: cannot unlink %s\n", target);
;				return(1);
;			}
;		}
;	}
;	if (link(source, target) < 0) {
;		i = fork();
;		if (i == -1) {
;			fprintf(stderr, "mv: try again\n");
;			return(1);
;		}
;		if (i == 0) {
;			execl("/bin/cp", "cp", source, target, 0);
;			fprintf(stderr, "mv: cannot exec cp\n");
;			exit(1);
;		}
;		while ((c = wait(&status)) != i && c != -1)
;			;
;		if (status != 0)
;			return(1);
;		utime(target, &s1.st_atime);
;	}
;	if (unlink(source) < 0) {
;		fprintf(stderr, "mv: cannot unlink %s\n", source);
;		return(1);
;	}
;	return(0);
;}
;
;mvdir(source, target)
;char *source, *target;
;{
;	register char *p;
;	register i;
;	char buf[MAXN];
;
;	if (stat(target, &s2) >= 0) {
;		if ((s2.st_mode&S_IFMT) != S_IFDIR) {
;			fprintf(stderr, "mv: %s exists\n", target);
;			return(1);
;		}
;		if (strlen(target) > MAXN-DIRSIZ-2) {
;			fprintf(stderr, "mv :target name too long\n");
;			return(1);
;		}
;		strcpy(buf, target);
;		target = buf;
;		strcat(buf, SDELIM);
;		strcat(buf, dname(source));
;		if (stat(target, &s2) >= 0) {
;			fprintf(stderr, "mv: %s exists\n", buf);
;			return(1);
;		}
;	}
;	if (strcmp(source, target) == 0) {
;		fprintf(stderr, "mv: ?? source == target, source exists and target doesnt\n");
;		return(1);
;	}
;	p = dname(source);
;	if (!strcmp(p, DOT) || !strcmp(p, DOTDOT) || !strcmp(p, "") || p[strlen(p)-1]=='/') {
;		fprintf(stderr, "mv: cannot rename %s\n", p);
;		return(1);
;	}
;	if (stat(pname(source), &s1) < 0 || stat(pname(target), &s2) < 0) {
;		fprintf(stderr, "mv: cannot locate parent\n");
;		return(1);
;	}
;	if (access(pname(target), 2) < 0) {
;		fprintf(stderr, "mv: no write access to %s\n", pname(target));
;		return(1);
;	}
;	if (access(pname(source), 2) < 0) {
;		fprintf(stderr, "mv: no write access to %s\n", pname(source));
;		return(1);
;	}
;	if (access(source, 2) < 0) {
;		fprintf(stderr, "mv: no write access to %s\n", source);
;		return(1);
;	}
;	if (s1.st_dev != s2.st_dev) {
;		fprintf(stderr, "mv: cannot move directories across devices\n");
;		return(1);
;	}
;	if (s1.st_ino != s2.st_ino) {
;		char dst[MAXN+5];
;
;		if (chkdot(source) || chkdot(target)) {
;			fprintf(stderr, "mv: Sorry, path names including %s aren't allowed\n", DOTDOT);
;			return(1);
;		}
;		stat(source, &s1);
;		if (check(pname(target), s1.st_ino))
;			return(1);
;		for (i = 1; i <= NSIG; i++)
;			signal(i, SIG_IGN);
;		if (link(source, target) < 0) {
;			fprintf(stderr, "mv: cannot link %s to %s\n", target, source);
;			return(1);
;		}
;		if (unlink(source) < 0) {
;			fprintf(stderr, "mv: %s: cannot unlink\n", source);
;			unlink(target);
;			return(1);
;		}
;		strcat(dst, target);
;		strcat(dst, "/");
;		strcat(dst, DOTDOT);
;		if (unlink(dst) < 0) {
;			fprintf(stderr, "mv: %s: cannot unlink\n", dst);
;			if (link(target, source) >= 0)
;				unlink(target);
;			return(1);
;		}
;		if (link(pname(target), dst) < 0) {
;			fprintf(stderr, "mv: cannot link %s to %s\n",
;				dst, pname(target));
;			if (link(pname(source), dst) >= 0)
;				if (link(target, source) >= 0)
;					unlink(target);
;			return(1);
;		}
;		return(0);
;	}
;	if (link(source, target) < 0) {
;		fprintf(stderr, "mv: cannot link %s and %s\n",
;			source, target);
;		return(1);
;	}
;	if (unlink(source) < 0) {
;		fprintf(stderr, "mv: ?? cannot unlink %s\n", source);
;		return(1);
;	}
;	return(0);
;}
;
;char *
;pname(name)
;register char *name;
;{
;	register c;
;	register char *p, *q;
;	static	char buf[MAXN];
;
;	p = q = buf;
;	while (c = *p++ = *name++)
;		if (c == DELIM)
;			q = p-1;
;	if (q == buf && *q == DELIM)
;		q++;
;	*q = 0;
;	return buf[0]? buf : DOT;
;}
;
;char *
;dname(name)
;register char *name;
;{
;	register char *p;
;
;	p = name;
;	while (*p)
;		if (*p++ == DELIM && *p)
;			name = p;
;	return name;
;}
;
;check(spth, dinode)
;char *spth;
;ino_t dinode;
;{
;	char nspth[MAXN];
;	struct stat sbuf;
;
;	sbuf.st_ino = 0;
;
;	strcpy(nspth, spth);
;	while (sbuf.st_ino != ROOTINO) {
;		if (stat(nspth, &sbuf) < 0) {
;			fprintf(stderr, "mv: cannot access %s\n", nspth);
;			return(1);
;		}
;		if (sbuf.st_ino == dinode) {
;			fprintf(stderr, "mv: cannot move a directory into itself\n");
;			return(1);
;		}
;		if (strlen(nspth) > MAXN-2-sizeof(DOTDOT)) {
;			fprintf(stderr, "mv: name too long\n");
;			return(1);
;		}
;		strcat(nspth, SDELIM);
;		strcat(nspth, DOTDOT);
;	}
;	return(0);
;}
;
;chkdot(s)
;register char *s;
;{
;	do {
;		if (strcmp(dname(s), DOTDOT) == 0)
;			return(1);
;		s = pname(s);
;	} while (strcmp(s, DOT) != 0 && strcmp(s, SDELIM) != 0);
;	return(0);
;}
;