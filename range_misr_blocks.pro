FUNCTION range_misr_blocks, l1b2_fspec, start_block, end_block, $
   EXCPT_COND = excpt_cond

   ;Sec-Doc
   ;  PURPOSE: This function reports on the range of MISR BLOCKS
   ;  containing actual data (instead of fill data) in a L1B2 Global or
   ;  Local Mode file.
   ;
   ;  ALGORITHM: This function checks the validity of the input arguments
   ;  and returns the first and last MISR BLOCKS containing usable data in
   ;  a L1B2 Global or Local Mode file.
   ;
   ;  SYNTAX:
   ;  rc = range_misr_blocks(l1b2_fspec, start_block, end_block, EXCPT_COND = excpt_cond)
   ;
   ;  POSITIONAL PARAMETERS [INPUT/OUTPUT]:
   ;
   ;  *   l1b2_fspec {STRING} [I]: The specification (path and name) of
   ;      the L1B2 Global or Local Mode file to inspect.
   ;
   ;  *   start_block {INT} [O]: The nothernmost BLOCK number containing
   ;      actual data.
   ;
   ;  *   end_block {INT} [O]: The southernmost BLOCK number containing
   ;      actual data.
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
   ;  *   If no exception condition has been detected, this function
   ;      returns 0, the values of the starting and ending BLOCK numbers
   ;      in output arguments, the output keyword parameter excpt_cond is
   ;      set to a null string.
   ;
   ;  *   If an exception condition has been detected, this function
   ;      returns a non-zero error code, the values of the starting and
   ;      ending BLOCK numbers may be undefined, and the output keyword
   ;      parameter excpt_cond contains a message about the exception
   ;      condition encountered.
   ;
   ;  EXCEPTION CONDITIONS:
   ;
   ;  *   Error 100: One or more positional parameter(s) are missing.
   ;
   ;  *   Error 110: Input positional parameter l1b2_fspec is not found or
   ;      not readable.
   ;
   ;  *   Error 200: An exception condition occurred in routine
   ;      MTK_FILEATTR_GET while recovering start_block.
   ;
   ;  *   Error 210: An exception condition occurred in routine
   ;      MTK_FILEATTR_GET while recovering end_block.
   ;
   ;  DEPENDENCIES:
   ;
   ;  *   MISR Toolkit
   ;
   ;  *   is_readable.pro
   ;
   ;  *   strstr.pro
   ;
   ;  REMARKS: None.
   ;
   ;  EXAMPLES:
   ;
   ;      [Insert the command and its outcome]
   ;
   ;  REFERENCES: None.
   ;
   ;  VERSIONING:
   ;
   ;  *   2017–12–13: Version 0.9 — Initial release.
   ;
   ;  *   2017–12–20: Version 1.0 — Initial public release.
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
   ;  Initialize the return code and the error message:
   ret_code = 0
   excpt_cond = ''

   ;  Return to the calling routine with an error message if this function is
   ;  called with the wrong number of required positional parameters:
   n_reqs = 3
   IF (N_PARAMS() NE n_reqs) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 100
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': Routine must be called with ' + strstr(n_reqs) + $
         ' positional parameter(s): l1b2_fspec, start_block, end_block.'
      RETURN, error_code
   ENDIF

   ;  Check that the input argument l1b2_fspec points to a readable L1B2 file:
   IF (is_readable(l1b2_fspec) NE 1) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 110
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': File specification ' + strstr(l1b2_fspec) + $
         ' not found or unreadable.'
      RETURN, error_code
   ENDIF

   ;  Use he MISR Toolkit routine to identify the first and last Blocks:
   status = MTK_FILEATTR_GET(l1b2_fspec, 'Start_block', start_block)
   IF (status NE 0) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 200
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': Error encountered in Mtk routine MTK_FILEATTR_GET while ' + $
         'recovering start_block in ' + l1b2_fspec
      RETURN, error_code
   ENDIF
   status = MTK_FILEATTR_GET(l1b2_fspec, 'End block', end_block)
   IF (status NE 0) THEN BEGIN
      info = SCOPE_TRACEBACK(/STRUCTURE)
      rout_name = info[N_ELEMENTS(info) - 1].ROUTINE
      error_code = 210
      excpt_cond = 'Error ' + strstr(error_code) + ' in ' + rout_name + $
         ': Error encountered in Mtk routine MTK_FILEATTR_GET while ' + $
         'recovering end_block in ' + l1b2_fspec
      RETURN, error_code
   ENDIF

   RETURN, ret_code

END