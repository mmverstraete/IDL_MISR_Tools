FUNCTION orbit2date, misr_orbit, EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function returns the date of acquisition of the
   ;  specified MISR ORBIT.
   ;
   ;  ALGORITHM: This function relies on MISR TOOLKIT routine
   ;  MTK_ORBIT_TO_TIMERANGE to determine and return the date on which the
   ;  specified MISR ORBIT was acquired.
   ;
   ;  SYNTAX: res = orbit2date(misr_orbit, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   misr_orbit {LONG} [I]: The selected MISR ORBIT number.
   ;
   ;  KEYWORD PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   EXCPT_COND = excpt_cond {STRING} [O] (Default value: ”):
   ;      Description of the exception condition if one has been
   ;      encountered, or a null string otherwise.
   ;
   ;  RETURNED VALUE TYPE: STRING.
   ;
   ;  OUTCOME:
   ;
   ;  *   If no exception condition has been detected, this function
   ;      returns to the calling routine a STRING containing the date when
   ;      the selected MISR ORBIT was acquired, formatted as YYYY-MM-DD,
   ;      and the output keyword parameter excpt_cond is set to a null
   ;      string.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a null string and the keyword parameter excpt_cond
   ;      contains a message about the exception condition encountered.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: Positional parameter misr_orbit is invalid.
   ;
   ;  *   Error 200: An exception condition was encountered in MTK routine
   ;      MTK_ORBIT_TO_TIMERANGE.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   MISR Toolkit
   ;
   ;  *   chk_misr_orbit.pro
   ;
   ;  *   strstr.pro
   ;
   ;  REMARKS:
   ;
   ;  *   NOTE 1: Argument misr_orbit cannot be smaller than 995L (the
   ;      first ORBIT for which MISR acquired data, on February 24, 2000)
   ;      or larger than 112000L (to be acquired on July 1, 2021).
   ;
   ;  EXAMPLES:
   ;
   ;      IDL> res = orbit2date(68050)
   ;      IDL> PRINT, res
   ;      2012-10-03
   ;
   ;      IDL> res = orbit2date(200000, EXCPT_COND = excpt_cond)
   ;      IDL> PRINT, excpt_cond
   ;      Error 110 in ORBIT2DATE: Error 220 in CHK_POB:
   ;      Incorrect misr_orbit number: must be within [995L, 112000L].
   ;
   ;  REFERENCES:
   ;
   ;  *   Web site: https://www-misr.jpl.nasa.gov/, select Gallery and
   ;      search for First Light, accessed on 5 Nov 2017.
   ;
   ;  *   MISR TOOLKIT documentation.
   ;
   ;  VERSIONING:
   ;
   ;  *   2009–11–11: Version 0.5 — Initial release by Linda Hunt (as
   ;      orbit_to_date).
   ;
   ;  *   2017–07–05: Version 0.9 — Changed function name to orbit2date,
   ;      updated the in-line documentation and added argument checking
   ;      logic.
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
   ;  Initialize the default error message and return code of the function:
   excpt_cond = ''
   return_code = ''

   ;  Return to the calling routine with an error message if this function is
   ;  called with the wrong number of required positional parameters:
   n_reqs = 1
   IF (N_PARAMS() NE n_reqs) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 100
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': Routine must be called with ' + strstr(n_reqs) + $
         ' positional parameters: misr_orbit.'
      RETURN, return_code
   ENDIF

   ;  Return to the calling routine with an error message if the argument
   ;  'misr_orbit' is invalid:
   rc = chk_misr_orbit(misr_orbit, EXCPT_COND = excpt_cond)
   IF (rc NE 0) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 110
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': ' + excpt_cond
      RETURN, return_code
   ENDIF

   ;  Get the date and time information using the MISR Toolkit:
   status = MTK_ORBIT_TO_TIMERANGE(misr_orbit, start_time, end_time)
   IF (status NE 0) THEN BEGIN
      error_code = 200
      excpt_cond = 'Error ' + strstr(error_code) + ' in MISR Toolkit ' + $
         'MTK_ORBIT_TO_TIMERANGE: status = ' + strstr(status)
   ENDIF

   ;  Extract the date of the Orbit:
   date = STRMID(start_time, 0, 10)

   RETURN, date

END