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
*  ARE DISCLAIMED. IN NO EVENT SHALL NOAA/PMEL/TMAP BE LIABLE FOR ANY
*  SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
*  RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF
*  CONTRACT, NEGLIGENCE OR OTHER TORTUOUS ACTION, ARISING OUT OF OR IN
*  CONNECTION WITH THE ACCESS, USE OR PERFORMANCE OF THIS SOFTWARE.



*
* Create a Python static variable in Ferret.  This is accomplished by
* assigning the passed data to a slot in the XPYVAR_INFO common block.
*
* Input:
*
* Output:
*

      SUBROUTINE ADD_PYSTAT_VAR(ndarray_obj, codename, title, units,
     .                      bdfval, dset, axis_nums, axis_starts,
     .                      axis_ends, errmsg, lenerr)
      IMPLICIT NONE

      INCLUDE 'ferret.parm'
      INCLUDE 'errmsg.parm'
      INCLUDE 'tmap_dims.parm'
      INCLUDE 'tmap_errors.parm'
      INCLUDE 'xcontext.cmn'
      INCLUDE 'xprog_state.cmn'
      INCLUDE 'xtm_grid.cmn_text'
      INCLUDE 'xfr_grid.cmn'
      INCLUDE 'xpyvar_info.cmn'

*     Passed arguments
      INTEGER*8     ndarray_obj
      CHARACTER*(*) codename, title, units, dset, errmsg
      REAL*8        bdfval
      INTEGER       lenerr,
     .              axis_nums(nferdims),
     .              axis_starts(nferdims),
     .              axis_ends(nferdims)

*     Function declarations
      INTEGER       TM_LENSTR, STR_UPCASE, FIND_DSET_NUMBER
      LOGICAL       TM_LEGAL_NAME

*     Local variables
      INTEGER       k, ds_num, cx, vpos, category, ivar,
     .              ingrid, outgrid, sts
      CHARACTER*128 varname
      LOGICAL       its_dyn

*     Check the name for this pyvar
      IF ( LEN(codename) .GT. 128 ) THEN
          errmsg = 'variable name too long'
          lenerr = TM_LENSTR(errmsg)
          RETURN
      ENDIF
      IF ( .NOT. TM_LEGAL_NAME(codename) ) THEN
          errmsg = 'variable name contains invalid characters'
          lenerr = TM_LENSTR(errmsg)
          RETURN
      ENDIF
      IF ( mode_upcase_output ) THEN
          k = STR_UPCASE(varname, codename)
      ELSE
          varname = codename
      ENDIF

      IF ( dset .EQ. 'None' ) THEN
*         do not associate with a dataset
          ds_num = unspecified_int4
      ELSE IF ( dset .EQ. '' ) THEN
*         associate with the current dataset (if any)
          ds_num = cx_data_set(cx_last)
      ELSE
*         associate with the indicated dataset
          ds_num = FIND_DSET_NUMBER(dset)
          IF ( ds_num .EQ. unspecified_int4 ) THEN
              errmsg = 'Invalid dataset ' // dset
              lenerr = TM_LENSTR(errmsg)
              RETURN
          ENDIF
      ENDIF

*     Check if this variable will overwrite an existing variable
*     in the associated dataset (if any).
      CALL FIND_VAR_NAME(ds_num, varname, category, ivar)
      IF ( ivar .NE. munknown_var_name ) THEN
          IF ( category .EQ. cat_user_var ) THEN
              CALL DELETE_USER_VAR(ivar)
          ELSE IF ( category .EQ. cat_pystat_var ) THEN
              CALL PURGE_PYSTAT_VAR(ivar)
              CALL DELETE_PYSTAT_VAR(ivar, errmsg, lenerr)
              IF ( lenerr .GT. 0 ) RETURN
          ELSE
              errmsg = 'File variable with the same name exists'
              lenerr = TM_LENSTR(errmsg)
              RETURN
          ENDIF
          CALL PURGE_ALL_UVARS
      ENDIF

*     Find a slot for this pyvar
      DO 10 vpos = 1,maxpyvars
          IF ( pyvar_ndarray_obj(vpos) .EQ. 0 ) GOTO 20
  10  CONTINUE
      errmsg = 'No available slots for another Python-backed variable'
      lenerr = TM_LENSTR(errmsg)
      RETURN

  20  CONTINUE
*     Assign the code name into the array and hash table
      CALL STRING_ARRAY_MODIFY(pyvar_code_head, vpos,
     .                         varname, LEN(varname))
*     Assign the rest of the data
      pyvar_ndarray_obj(vpos) = ndarray_obj
      pyvar_title(vpos) = title
      pyvar_units(vpos) = units
      pyvar_missing_flag(vpos) = bdfval
      pyvar_dset_number(vpos) = ds_num
*     Only floats supported at this time
      pyvar_type(vpos) = ptype_float

*     Use axis_nums to find or create a grid
      CALL ALLO_GRID(ingrid, sts)
      IF ( sts .NE. ferr_ok ) THEN
          errmsg = 'Out of memory for a new temporary grid'
          lenerr = TM_LENSTR(errmsg)
          RETURN
      ENDIF
      CALL INIT_GRID(ingrid, '', mnormal)
      DO 30 k = 1,nferdims
          grid_line(k,ingrid) = axis_nums(k)
          CALL TM_USE_LINE(axis_nums(k))
   30 CONTINUE
      CALL TM_GET_LIKE_DYN_GRID(ingrid, its_dyn, outgrid,
     .                          grd_stk_ptr, sts)
      IF ( sts .NE. merr_ok ) THEN
          CALL DEALLO_GRID(sts)
          errmsg = 'Out of memory for a new dynamic grid'
          lenerr = TM_LENSTR(errmsg)
          RETURN
      ENDIF
      pyvar_grid_number(vpos) = outgrid
      CALL DEALLO_GRID(sts)

*     Assign the start and end indices of the axes in this grid
      DO 40 k = 1,nferdims
          pyvar_grid_start(k,vpos) = axis_starts(k)
          pyvar_grid_end(k,vpos) = axis_ends(k)
   40 CONTINUE

*     Success
      errmsg = ' '
      lenerr = 0
      RETURN

      END

