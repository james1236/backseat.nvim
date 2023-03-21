Below is an instruction that describes a task. Write a response that appropriately completes the request.
### Instruction:
Readability issues to consider:
- Unclear naming
- Code with an unclear purpose
- Redundant or obvious comments
- Lack of comments
- Long or complex expressions: using too many nested parentheses, long variable names, or multiple function calls in one line can make the code difficult to read and debug.
- Inconsistent naming and code style.
- Code repetition
The user submits a small section of code from a larger file, if you find any readability issues in the code, list them with the corresponding line number in the format. Do not try and correct logical errors or whitespace, and ignore that some variables are likely undeclared as this is just a small section of code from a larger file. Do not be overly pedantic, it is ok to suggest no improvements.
Readability rating out of 5
Line #: <issue (must be negative)>

### Input:
04 public class Logic {
05     public static void main(String[] args) {
06         Scanner sc = new Scanner(System.in);
07         int n = sc.nextInt();
08         int[] arr = new int[n];
09         for (int i = 0; i < n; i++) {
10             arr[i] = sc.nextInt();
11         }
12         int[] dp = new int[n];
13         dp[0] = arr[0];
14         dp[1] = Math.max(arr[0], arr[1]);
15         for (int i = 2; i < n; i++) {
16             dp[i] = Math.max(dp[i - 1], dp[i - 2] + arr[i]);
17         }
18         System.out.println(dp[n - 1]);
19     }
20 }
### Response:
Readability rating: 1/5 - Awful (Issue report max length of 7) 7 issues found:
Line 4: The class name Logic is too generic
Line 6: The variable name sc is unclear. A more meaningful name could be scanner.
Line 7: The variable name n is unclear. A more meaningful name could be arraySize or numElements.
Line 8: The variable name arr unclear. A more descriptive name could be inputArray or elementValues.
Line 12: The variable name dp is unclear. A more informative name could be maxSum or optimalSolution.
Lines 9-11 and 15-17: There are no comments explaining the logic of the for loops and how they populate the arrays.
Lines 13-14 and 18: There are no comments explaining the meaning of the dp array values and how they relate to the problem statement.

### Input:
264                    else:
265                        #Play note
266                        if hasattr(pwm, 'duty_u16'):
267                            pwm.duty_u16(self.duty)
268                        else:
269                            pwm.duty(self.duty)
270                        pwm.freq(tones[self.playingNotes[i]])
271                    i = i + 1
272            
273
274            #Play arp of all playing notes
275            if (len(self.playingNotes) > len(self.pwms)):
276                p = self.pwms[len(self.pwms)-1];
277                if hasattr(p, 'duty_u16'):
278                    p.duty_u16(self.duty)
279                else:
280                    p.duty(self.duty)
281                
282                if (self.arpnote > len(self.playingNotes)-len(self.pwms)):
283                    self.arpnote = 0
284                self.pwms[len(self.pwms)-1].freq(tones[self.playingNotes[self.arpnote+(len(self.pwms)-1)]])
285                self.arpnote = self.arpnote + 1
### Response:
Readability rating: 4/5 - Good (Issue report max length of 3) 3 issues found:
Line 274: It is unclear what an "arp" is
Line 276: The variable name p is unclear. A better name would be currentPWM
Line 284: Too complicated for one line, separate the nested logic across multiple lines.

### Input:
313 //Section 5: Touchscreen configuration
314 
315 #ifdef CONFIG_ENABLE_TOUCH
316     #if CONFIG_TOUCH_CS == -1
317         #error "Invalid Touch Chip Select pin. Check TFT_eSPI configuration"
318     #else
319         #define TOUCH_CS            CONFIG_TOUCH_CS
320     #endif
321 
322     #define SPI_TOUCH_FREQUENCY CONFIG_SPI_TOUCH_FREQUENCY
### Response:
Readability rating: 5/5 - No Issues

### Input:
172         return cTile;
173     }
174 
175     public void setPos(Tile tile)
176     {
177         curTile = tile;
178         curTilePos = GridManager.instance.calcWorldCoord(new Vector2(tile.X, tile.Y));
179         gameObject.transform.position = curTilePos;
180         RemainingPath = new List<Tile>() { curTile };
181 
182         // remove fog of next tile and surrounding tiles, if any
183         if (GetComponent<IGameUnit>().OwnedBy == GameManager.instance.LocalPlayer)
184             GridManager.instance.UncoverTiles(GridManager.instance.GetHexArea(curTile, SightRadius));
185 
186         AdjustPlayerSight(curTile);
187     }
188 
189     public bool MoveTo(Vector2 dest)
190     {
191         if (!IsMoving)
192         {
193             var GM = GridManager.instance;
### Response:
Readability rating: 5/5 - No Issues

### Input:
348     char long_filename[20][13]; //Array of substrings that make up the long filename in reverse
349     int long_filename_pos = 0;
350 
351     while (1) {
352         //read_image(entry, sizeof(DirectoryEntry));
353         memcpy(entry, entries_buffer + entry_index, sizeof(DirectoryEntry));
354 
355         int cancel_long_filename_flag = 0;
356         
357         //Handle long filenames
358         if ((entry->DIR_Attr & 0b00111111) == 0b00001111) { //long filename entry
359             LongDirectoryEntry *long_entry = malloc(sizeof(LongDirectoryEntry));
360             memcpy(long_entry, entry, sizeof(DirectoryEntry));
361 
362             int char_pos = 0;
363             
364             for (int i = 0; i < 5; i++) {
365                 long_filename[long_filename_pos][char_pos++] = long_entry->LDIR_Name1[i * 2]; 
366             }
### Response:
Readability rating: 2/5 - Bad (Issue report max length of 6) 6 issues found:
Line 348: The variable name long_filename is unclear. A more descriptive name would be longFilenameParts.
Line 349: The variable name long_filename_pos is unclear. A more descriptive name would be longFilenamePartIndex.
Lines 352-353: The commented out line is confusing and should be removed.
Lines 355-357: The variable name cancel_long_filename_flag is unclear. A more descriptive name would be foundLongFilename.
Line 359: The variable name long_entry is unclear. A more descriptive name would be longFilenameEntry.
Lines 364-366: The for loop logic is complex, add a comment to explain what it does.

### Input:
285     fn next_block(&mut self, force_piece: Option<PieceType>) {
286         let piece = match force_piece {
287             None => self.bag.next_piece(),
288             Some(p) => Piece::with_piece_type(p),
289         };
290         self.piece = Some(build_piece_in_starting_pos(piece));
291         self.reset_drop();
292         self.frame_data.just_placed = true;
293 
294         if let Some(hold_piece) = self.hold_piece.as_mut() {
295             hold_piece.reset_hold();
296         }
297     }
298 
299     fn rot_pressed(&mut self, next: bool) {
300         let piece_with_pos = self.piece.as_mut().unwrap();
301         let piece_ref = piece_with_pos.tetris_piece_mut();
### Response:
Readability rating: 4/5 - Good (Issue report max length of 3) 3 issues found:
Line 286-289: The match statement is not commented, making it hard to understand at first glance.
Line 290: There are no comments explaining the logic taking place
Line 299: The function name rot_pressed is unclear. A more descriptive name would be handle_rotation_input.
