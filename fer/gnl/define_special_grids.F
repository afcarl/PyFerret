	SUBROUTINE DEFINE_SPECIAL_GRIDS

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
* define "pre_defined" grids not set up by TMAP_FORMAT COMMON

* programmer - steve hankin
* NOAA/PMEL, Seattle, WA - Tropical Modeling and Analysis Program

*
* V200:  6/22/89
*	10/23/89 - added ez_dflt
* V300: 6/93 - lengthened axis EZ x10 so that accidental truncations were rarer
* V500: 12/98 - added XABSTRACT, YABSTRACT, ZABSTRACT, and TABSTRACT
* V581*acm*  6/05 - For fix to bug 1271, add flag line_shift_origin
* V62 *acm*  2/09 - Save original upper/lowercase spelling of axis names 
*                   in line_name_orig for CANCEL MODE UPCASE
*       *acm* 3/12 cleanup ifdefs and unnecessary include files
* V685 *acm*  6/13 Increase nominal length of abstract axis
* V698 *sh* 12/15 set up dummy (missing placeholder) dataset 
* v74   *acm* 3/18 Introduce parameter abstractax_len replacing 99999999

	include	'tmap_dims.parm'
	include	'tmap_errors.parm'
	include 'xunits.cmn_text'
	external xunits_data
	include 'xtm_grid.cmn_text'
	external xgt_grid_data
	include 'xdset_info.cmn_text'
	include	'ferret.parm'
	include	'xfr_grid.cmn'

* local variable declarations:
	INTEGER	TM_FIND_LINE_SLOT, TM_FIND_GRID_SLOT,
     .		iline, igrid, idim, iline_abstract, status

* "ABSTRACT" axis
* find a space to catalog it
	status = TM_FIND_LINE_SLOT( iline )
	IF ( status .NE. merr_ok ) GOTO 5000

* save the line in memory - but don't catalog its name
	line_name     ( iline ) = 'ABSTRACT'
	line_name_orig( iline ) = 'ABSTRACT'
	line_start    ( iline ) = 1.0D0
	line_delta    ( iline ) = 1.0D0
	line_dim      ( iline ) = abstractax_len
	line_regular  ( iline ) = .TRUE.
	line_modulo   ( iline ) = .FALSE.
	line_units    ( iline ) = ' '
	line_unit_code( iline ) = 0	! unknown units
	line_t0       ( iline ) = ' '
	line_shift_origin( iline ) = .FALSE.
	line_direction( iline ) = 'NA'
	iline_abstract = iline

* "ABSTRACT" grid
* find a space to catalog it
	status = TM_FIND_GRID_SLOT( igrid )
	IF ( status .NE. merr_ok ) GOTO 5000

* make grid with nferdims abstract axes
	DO 100 idim = 1, nferdims
	   grid_line    (idim, igrid) = iline_abstract
           grid_out_prod(idim, igrid) = .TRUE.
 100	CONTINUE	
	grid_rotation( igrid ) = 0.0
	grid_name    ( igrid ) = 'ABSTRACT'

* save pointer to grid
	mgrid_abstract = igrid


* "EZ" axis
* find a space to catalog it
	status = TM_FIND_LINE_SLOT( iline )
	IF ( status .NE. merr_ok ) GOTO 5000

* save the line in memory - but don't catalog its name
	line_name     ( iline ) = 'EZ'
	line_name_orig( iline ) = 'EZ'
	line_start    ( iline ) = 1.0D0
	line_delta    ( iline ) = 1.0D0
	line_dim      ( iline ) = 20480
	line_regular  ( iline ) = .TRUE.
	line_modulo   ( iline ) = .FALSE.
	line_units    ( iline ) = ' '
	line_unit_code( iline ) = 0	! unknown units
	line_t0       ( iline ) = ' '
	line_shift_origin( iline ) = .FALSE.
	line_direction( iline ) = 'NA'

* "EZ" grid
* find a space to catalog it
	status = TM_FIND_GRID_SLOT( igrid )
	IF ( status .NE. merr_ok ) GOTO 5000

* make grid with 1 axis, only
	DO 200 idim = 1, nferdims
	   grid_line    (idim, igrid) = mnormal
           grid_out_prod(idim, igrid) = .TRUE.
 200	CONTINUE	
	grid_line    (1, igrid) = iline    
	grid_rotation( igrid ) = 0.0
	grid_name    ( igrid ) = 'EZ'

* save pointer to grid
	mgrid_ez_dflt = igrid


* "XABSTRACT" grid
* find a space to catalog it
	status = TM_FIND_GRID_SLOT( igrid )
	IF ( status .NE. merr_ok ) GOTO 5000

* make grid with 1 abstract axis
	DO 300 idim = 1, nferdims
	   grid_line    (idim, igrid) = mnormal
           grid_out_prod(idim, igrid) = .TRUE.
 300	CONTINUE
	grid_line(x_dim, igrid) = iline_abstract
	grid_rotation( igrid ) = 0.0
	grid_name    ( igrid ) = 'XABSTRACT'

* save pointer to grid
	mgrid_xabstract = igrid

* "YABSTRACT" grid
* find a space to catalog it
	status = TM_FIND_GRID_SLOT( igrid )
	IF ( status .NE. merr_ok ) GOTO 5000

* make grid with 1 abstract axis
	DO 400 idim = 1, nferdims
	   grid_line    (idim, igrid) = mnormal
           grid_out_prod(idim, igrid) = .TRUE.
 400	CONTINUE
	grid_line(y_dim, igrid) = iline_abstract
	grid_rotation( igrid ) = 0.0
	grid_name    ( igrid ) = 'YABSTRACT'

* save pointer to grid
	mgrid_yabstract = igrid


* "ZABSTRACT" grid
* find a space to catalog it
	status = TM_FIND_GRID_SLOT( igrid )
	IF ( status .NE. merr_ok ) GOTO 5000

* make grid with 1 abstract axis
	DO 500 idim = 1, nferdims
	   grid_line    (idim, igrid) = mnormal
           grid_out_prod(idim, igrid) = .TRUE.
 500	CONTINUE
	grid_line(z_dim, igrid) = iline_abstract
	grid_rotation( igrid ) = 0.0
	grid_name    ( igrid ) = 'ZABSTRACT'

* save pointer to grid
	mgrid_zabstract = igrid

* "TABSTRACT" grid
* find a space to catalog it
	status = TM_FIND_GRID_SLOT( igrid )
	IF ( status .NE. merr_ok ) GOTO 5000

* make grid with 1 abstract axis
	DO 600 idim = 1, nferdims
	   grid_line    (idim, igrid) = mnormal
           grid_out_prod(idim, igrid) = .TRUE.
 600	CONTINUE
	grid_line(t_dim, igrid) = iline_abstract
	grid_rotation( igrid ) = 0.0
	grid_name    ( igrid ) = 'TABSTRACT'

* save pointer to grid
	mgrid_tabstract = igrid



* "EABSTRACT" grid
* find a space to catalog it
	status = TM_FIND_GRID_SLOT( igrid )
	IF ( status .NE. merr_ok ) GOTO 5000

* make grid with 1 abstract axis
	DO 700 idim = 1, nferdims
	   grid_line    (idim, igrid) = mnormal
           grid_out_prod(idim, igrid) = .TRUE.
 700	CONTINUE
	grid_line(e_dim, igrid) = iline_abstract
	grid_rotation( igrid ) = 0.0
	grid_name    ( igrid ) = 'EABSTRACT'

* save pointer to grid
	mgrid_eabstract = igrid



* "FABSTRACT" grid
* find a space to catalog it
	status = TM_FIND_GRID_SLOT( igrid )
	IF ( status .NE. merr_ok ) GOTO 5000

* make grid with 1 abstract axis
	DO 800 idim = 1, nferdims
	   grid_line    (idim, igrid) = mnormal
           grid_out_prod(idim, igrid) = .TRUE.
 800	CONTINUE
	grid_line(f_dim, igrid) = iline_abstract
	grid_rotation( igrid ) = 0.0
	grid_name    ( igrid ) = 'FABSTRACT'

* save pointer to grid
	mgrid_fabstract = igrid

* dummy dataset
	ds_name(pdset_dummy) = "(dummy)"
	ds_des_name(pdset_dummy) = "(dummy)"

	RETURN

 5000	STOP 'DFN_SPC_GRD'
	END
