	INTEGER FUNCTION CD_ISIT_RECDIM( cdfid, dset, grid, idim,
     .     mode_upcase_output, keepax_flag, status )

*
*
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
* Is the indicated is the indicated axis of the grid the netCDF record axis?
* Or can it never become the record axis ?
* Or are both it and the record axis as-yet undefined?

* Programmer Steve Hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program

* revision 0.0 - 6/92
* V500 *kob* 3/99 - up lengths of CD_AXIS_NAME and name to correspond w/ 
*                   longer line_name
* V600 *acm* 6/05 - Attribute control. Get information from linked-list structure.
* V602 *acm*12/06 - Bug 1478: Correct the treatment of uppercasing names.
* V65  *acm* 1/10  Change all netcdf2-style calls and parameter names to 
*                  netcdf3-style calls, which are also consistent with netcdf4.
* V65  *acm* 1/10  Add #ifdef usingDODSf2cUnderscore, for 32-bit linux build
*                  linked with OPeNDAP library.
* V6.74 3/12 *acm* cleanup ifdefs and unnecessary include files
* V687 3/14 *acm* Fix ticket 1750. Write Ferret-internal axis names to cdf files, unless
*                 the user has said /KEEP_AXISNAMES
* V697 12/15 *acm* Fix ticket 2336: consistent application of CAN MODE UPCASE

* argument definitions:
*       dset    - dset (if netcdf file, for getting name and attribute 
*                 info from linked-list structure  
*       cdfid   - returned pointer to open CDF file
*       grid    - TMAP grid number
*       idim    - axis number (1-4)
*	status	- return status

* argument declarations:

	LOGICAL	mode_upcase_output
	INTEGER cdfid, dset, grid, idim, keepax_flag, status

* include files
        include 'netcdf.inc'
        include 'tmap_errors.parm'
        include 'cd_lib.parm'

! Declare netcdf function names. 
! The ones without trailing underscore are declared in netcdf.inc
#include "netcdf_declareUnderscore.inc"

* local variable declarations:
      LOGICAL this_ax_exists, recax_exists, coordvar
      INTEGER ndims, nvars, ngatts, recdim, cdfstat, nlen, dimid,
     .        varid, vartype, nvdims, vdims(8), nvatts, all_outflag
      CHARACTER CD_AXIS_OUTNAME*128, CD_AXIS_NAME*128, name*128, name_in*128

* get the axis name
         name = CD_AXIS_NAME( dset, grid, idim, nlen )
         IF (keepax_flag.EQ.1 .OR. .NOT.(mode_upcase_output)) 
     .       name = CD_AXIS_OUTNAME( dset, grid, idim, nlen )

* If mode upcase_output is set, then the axis name
* has been written to the file upcased.

         IF (mode_upcase_output) THEN
            name_in = name
            CALL STR_UPCASE( name, name_in)
         ENDIF

* is there a dimension by this name?
#ifdef usingDODSf2cUnderscore
        cdfstat = NF_INQ_DIMID_( cdfid, name(:nlen), dimid )
#else
        cdfstat = NF_INQ_DIMID ( cdfid, name(:nlen), dimid )
#endif

        this_ax_exists = cdfstat .EQ. NF_NOERR

* get vital statistics of file
#ifdef usingDODSf2cUnderscore
        cdfstat = NF_INQ_( cdfid, ndims, nvars, ngatts, recdim )
#else
        cdfstat = NF_INQ ( cdfid, ndims, nvars, ngatts, recdim )
#endif
!        IF ( cdfstat .NE. NF_NOERR ) GOTO 5100
        recax_exists = recdim .NE. -1

* so what's the answer?
        IF ( .NOT.(this_ax_exists .OR. recax_exists) ) THEN
           CD_ISIT_RECDIM = pcdf_undefined    ! both undefined as yet
        ELSEIF ( this_ax_exists
     .     .AND. recax_exists
     .     .AND. (dimid .EQ. recdim) ) THEN
           CD_ISIT_RECDIM = pcdf_yes          ! both defined and equal
        ELSE
           CD_ISIT_RECDIM = pcdf_no           ! at least one exists unequal
        ENDIF

* successful completion
 1000   status = merr_ok
        RETURN

* error exit
!5100   CALL TM_ERRMSG
!    .     ( cdfstat+pcdferr, status, 'CD_USE_RECDIM', cdfid,
!    .        no_varid, no_errstring, no_errstring, *5900 )
!5900   RETURN
	END
