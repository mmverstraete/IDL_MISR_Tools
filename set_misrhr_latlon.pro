FUNCTION set_misrhr_latlon, misr_path, misr_block, latitudes, longitudes, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function calculates, returns and saves the
   ;  geographical location (latitude and longitude) of each pixel in a
   ;  MISR-HR product for the specified MISR PATH and BLOCK numbers. The
   ;  results are saved in a plain ASCII file as well as in a SAVE file,
   ;  and both are written in the appropriate standard output directory
   ;  under misr_roots[2] defined by the function set_misr_roots.pro.
   ;
   ;  ALGORITHM: This function relies on the MISR TOOLKIT function
   ;  MTK_BLS_TO_LATLON to compute the latitude and longitude of every
   ;  pixel in the specified PATH and BLOCK.
   ;
   ;  SYNTAX:
   ;  rc = set_misrhr_latlon(misr_path, misr_block, latitudes, longitudes, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   misr_path {INTEGER} [I]: The selected MISR PATH number.
   ;
   ;  *   misr_block {INTEGER} [I]: The selected MISR BLOCK number.
   ;
   ;  *   latitudes {DOUBLE array} [O]: The array of pixel latitudes,
   ;      dimensioned n_lines = 512 by n_samples = 2048.
   ;
   ;  *   longitudes {DOUBLE array} [O]: The array of pixel longitudes,
   ;      dimensioned n_lines = 512 by n_samples = 2048.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   EXCPT_COND = excpt_cond {STRING} [O] (Default value: ”):
   ;      Description of the exception condition if one has been
   ;      encountered, or a null string otherwise.
   ;
   ;  RETURNED VALUE TYPE: INTEGER.
   ;
   ;  OUTCOME:
   ;
   ;  *   If no exception condition has been detected, this function saves
   ;      the arrays of pixel latitudes and longitudes in a plain ASCII
   ;      text file as well as in an IDL SAVE file and returns 0; the
   ;      output keyword parameter excpt_cond is set to a null string.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code and the output keyword parameter
   ;      excpt_cond contains a message about the exception condition
   ;      encountered. The output files are not created.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: Positional parameter misr_path is invalid.
   ;
   ;  *   Error 120: Positional parameter misr_block is invalid.
   ;
   ;  *   Error 210: An exception condition occurred in function path2str.
   ;
   ;  *   Error 220: An exception condition occurred in function
   ;      block2str.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   MISR Toolkit
   ;
   ;  *   block2str.pro
   ;
   ;  *   chk_misr_block.pro
   ;
   ;  *   chk_misr_path.pro
   ;
   ;  *   is_dir.pro
   ;
   ;  *   is_writable.pro
   ;
   ;  *   path2str.pro
   ;
   ;  *   set_misr_roots.pro
   ;
   ;  *   strstr.pro
   ;
   ;  REMARKS: None.
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> rc = set_misrhr_latlon(168, 112, latitudes, longitudes, $
   ;         EXCPT_COND = excpt_cond)
   ;      IDL> SPAWN, 'ls ~/Documents/MISR_HR/Outcomes/P168_B112'
   ;      MISR-HR_LAT-LON_P168_B112.sav
   ;      MISR-HR_LAT-LON_P168_B112.txt
   ;      IDL> sf = '/Users/mmverstraete/Documents/MISR_HR/Outcomes/' + $
   ;         'P168_B112/MISR-HR_LAT-LON_P168_B112.sav'
   ;      IDL> sObj = OBJ_NEW('IDL_Savefile', sf)
   ;      IDL> sContents = sObj->Contents()
   ;      IDL> PRINT, sContents.N_VAR, '   ', sObj->Names()
   ;      4    LATITUDES LONGITUDES N_LINES N_SAMPLES
   ;
   ;  REFERENCES:
   ;
   ;  *   MISR TOOLKIT documentation.
   ;
   ;  VERSIONING:
   ;
   ;  *   2017–08–21: Version 0.9 — Initial release.
   ;
   ;  *   2017–11–30: Version 1.0 — Initial public release.
   ;
   ;
   ;Sec-Lic
   ;  INTELLECTUAL PROPERTY RIGHTS
   ;
   ;  *   Copyright (C) 2017 Michel M. Verstraete.
   ;
   ;      Permission is hereby granted, free of charge, to any person
   ;      obtaining a copy of this software and associated documentation
   ;      files (the “Software”), to deal in the Software without
   ;      restriction, including without limitation the rights to use,
   ;      copy, modify, merge, publish, distribute, sublicense, and/or
   ;      sell copies of the Software, and to permit persons to whom the
   ;      Software is furnished to do so, subject to the following
   ;      conditions:
   ;
   ;      The above copyright notice and this permission notice shall be
   ;      included in all copies or substantial portions of the Software.
   ;
   ;      THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
   ;      EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
   ;      OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
   ;      NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
   ;      HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
   ;      WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
   ;      FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
   ;      OTHER DEALINGS IN THE SOFTWARE.
   ;
   ;      See: https://opensource.org/licenses/MIT.
   ;
   ;  *   Feedback
   ;
   ;      Please send comments and suggestions to the author at
   ;      MMVerstraete@gmail.com.
   ;
   ;
   ;Sec-Cod
   ;  Initialize the default return code and error message of the function:
   return_code = 0
   excpt_cond = ''

   ;  Set the spatial resolution, number of lines and number of samples in
   ;  MISR-HR products:
   resolution = 275.0
   n_lines = 512
   n_samples = 2048

   ;  Define the output variables:
   latitudes = DBLARR(n_lines, n_samples)
   longitudes = DBLARR(n_lines, n_samples)

   ;  Return to the calling routine with an error message if this function is
   ;  called with the wrong number of required positional parameters:
   n_reqs = 4
   IF (N_PARAMS() NE n_reqs) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 100
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': Routine must be called with ' + strstr(n_reqs) + $
         ' positional parameters: misr_path, misr_block, latitudes, longitudes.'
      RETURN, error_code
   ENDIF

   ;  Return to the calling routine with an error message if this function is
   ;  called with an invalid MISR Path:
   rc = chk_misr_path(misr_path, EXCPT_COND = excpt_cond)
   IF (rc NE 0) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 110
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Return to the calling routine with an error message if this function is
   ;  called with an invalid MISR Block:
   rc = chk_misr_block(misr_block, EXCPT_COND = excpt_cond)
   IF (rc NE 0) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 120
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Set the string version of the MISR Path and Block numbers:
   rc = path2str(misr_path, misr_path_str, EXCPT_COND = excpt_cond)
   IF (rc NE 0) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 210
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF
   rc = block2str(misr_block, misr_block_str, EXCPT_COND = excpt_cond)
   IF (rc NE 0) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 220
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, error_code
   ENDIF

   ;  Get the standard locations of MISR and MISR-HR files on this computer:
   misr_roots = set_misr_roots()

   ;  Define the standard directory in which to save the file containing the
   ;  latitudes and longitudes of the MISR-HR pixels:
   pb = misr_path_str + '_' + misr_block_str
   latlon_path = misr_roots[2] + pb + PATH_SEP()

   ;  Create this output directory if it does not already exist:
   IF ((is_dir(latlon_path) NE 1) OR (is_writable(latlon_path) NE 1)) THEN BEGIN
      FILE_MKDIR, latlon_path
   ENDIF

   ;  Generate the specification of the lat-lon file:
   latlon_prefix = 'MISR-HR_LAT-LON_'
   latlon_fname = latlon_prefix + pb
   latlon_fspec = latlon_path + latlon_fname + '.txt'

   ;  Open this file:
   fmt1 = '(A6, 2X, A6, 2X, A15, 2X, A15)'
   fmt2 = '(I6, 2X, I6, 2X, D15.8, 2X, D15.8)'
   OPENW, latlon_unit, latlon_fspec, /GET_LUN
   PRINTF, latlon_unit, 'Latitudes and longitudes of the MISR-HR pixels ' + $
      'for Path ' + strstr(misr_path) + ' and Block ' + strstr(misr_block) + '.'
   PRINTF, latlon_unit
   PRINTF, latlon_unit, 'Line', 'Sample', 'Latitude', 'Longitude', FORMAT = fmt1

   ;  Loop over the lines:
   FOR i = 0, n_lines - 1 DO BEGIN

   ;  Loop over the samples:
      FOR j = 0, n_samples - 1 DO BEGIN
         res = MTK_BLS_TO_LATLON(misr_path, resolution, misr_block, $
            FLOAT(i), FLOAT(j), lat, lon)
         latitudes[i, j] = lat
         longitudes[i, j] = lon
         PRINTF, latlon_unit, i, j, lat, lon, FORMAT = fmt2
      ENDFOR
   ENDFOR

   FREE_LUN, latlon_unit
   CLOSE, latlon_unit

   ;  Save the latitudes and longitudes for easy subsequent retrieval:
   latlon_fspec = latlon_path + latlon_fname + '.sav'
   SAVE, n_lines, n_samples, latitudes, longitudes, FILENAME = latlon_fspec

   RETURN, return_code

END