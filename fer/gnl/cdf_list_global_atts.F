	SUBROUTINE CDF_LIST_GLOBAL_ATTS ( dset, cdfid, status )

*  This software was developed by the Thermal Modeling and Analysis
*  Project(TMAP) of the National Oceanographic and Atmospheric
*  Administration's (NOAA) Pacific Marine Environmental Lab(PMEL),
*  hereafter referred to as NOAA/PMEL/TMAP.
*
*  Access and use of this software shall impose the following
*  obligations and understandings on the user. The user is granted the
*  right, without any fee or cost, to use, copy, modify, alter, enhance
*  and distribute this software, and any derivative works thereof, and
*  its supporting documentation for any purpose whatsoever, provided
*  that this entire notice appears in all copies of the software,
*  derivative works and supporting documentation.  Further, the user
*  agrees to credit NOAA/PMEL/TMAP in any publications that result from
*  the use of this software or in any product that includes this
*  software. The names TMAP, NOAA and/or PMEL, however, may not be used
*  in any advertising or publicity to endorse or promote any products
*  or commercial entity unless specific written permission is obtained
*  from NOAA/PMEL/TMAP. The user also understands that NOAA/PMEL/TMAP
*  is not obligated to provide the user with any support, consulting,
*  training or assistance of any kind with regard to the use, operation
*  and performance of this software nor to provide the user with any
*  updates, revisions, new versions or "bug fixes".
*
*  THIS SOFTWARE IS PROVIDED BY NOAA/PMEL/TMAP "AS IS" AND ANY EXPRESS
*  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
*  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
*  ARE DISCLAIMED. IN NO EVENT SHALL NOAA/PMEL/TMAP BE LIABLE FOR ANY SPECIAL,
*  INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
*  RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
*  CONTRACT, NEGLIGENCE OR OTHER TORTUOUS ACTION, ARISING OUT OF OR IN
*  CONNECTION WITH THE ACCESS, USE OR PERFORMANCE OF THIS SOFTWARE. 
*
*
* programmer - Ansley Manke
* NOAA/PMEL, Seattle, WA - TMAP
* Write global attributes to netcdf file

* V600  4/06 *acm* - additional declarations found by Solaris compiler
* V600  6/06 *acm* - additional declarations found by Solaris compiler
*       *acm* 3/12 cleanup ifdefs and unnecessary include files
* V720 *acm* 5/17 Implement specific calls in place of CD_GET_VAR_INFO

#include "netcdf.inc"
        include 'cd_lib.parm'
        include 'ferret.parm'


* calling argument declarations:
        INTEGER dset, cdfid, status
        
* internal variable declarations:
        LOGICAL MATCH_NAME, NC_GET_ATTRIB, do_warn, got_it
        INTEGER TM_LENSTR1, varid, nvatts, iatt, slen, attype, attlen, 
     .          attoutflag, bufflen
	REAL	vals(100)
        CHARACTER*128 varname, attname, aname
        CHARACTER*10240 buff

        bufflen = 10240
        varid = 0
        do_warn = .TRUE.

* Get global attributes from dset and if they have been marked for output,
* write to the file cdfid

        varname = '.'
        CALL CD_GET_VAR_NATTS (dset, varid, varname, nvatts, status) 

        DO 80 iatt = 1, nvatts
           CALL CD_GET_VAR_ATT_NAME( dset, varid, iatt, attname, status)
           slen = TM_LENSTR1(attname)

           IF ( MATCH_NAME (attname,  slen, 'HISTORY', 7 ) .OR. 
     .          MATCH_NAME (attname,  slen, 'TITLE', 5 ) .OR. 
     .          MATCH_NAME (attname,  slen, 'CONVENTIONS', 11 ) ) THEN
              slen = 0   ! done elsewhere
           ELSE
              CALL CD_GET_VAR_ATT_INFO (dset, varid, iatt, aname, 
     .                  attype, attlen, attoutflag, status )

              IF (attoutflag .EQ. 0) GOTO 80
              IF (attlen .GT. 100 .AND. attype .NE. NCCHAR) 
     .            attlen = 100
              got_it = NC_GET_ATTRIB ( dset, varid, aname, do_warn, 
     .           varname, bufflen, attlen, attoutflag, buff, vals)

              IF (attype .EQ. NCCHAR .AND. attoutflag.EQ.1) THEN
                 slen = TM_LENSTR1(buff)
                 CALL CD_WRITE_ATTRIB(cdfid, pcdf_global,
     .              aname, buff(:slen), .FALSE., status )
              ELSE IF (attoutflag.EQ.1) THEN
                 CALL CD_WRITE_ATTVAL(cdfid, pcdf_global,
     .              aname, vals, attlen, attype, status )

              ENDIF
           ENDIF

 80     CONTINUE

        RETURN
        END
