local fewshot = {
    messages = {
        {
            role = "system",
            content = [[
You must identify any readability issues in the code snippet.
Some readability issues to consider:
- Unclear naming
- Unclear purpose
- Redundant or obvious comments
- Lack of comments
- Long or complex one liners
- Too much nesting
- Long variable names
- Inconsistent naming and code style.
- Code repetition
You may identify additional problems. The user submits a small section of code from a larger file.
Only list lines with readability issues, in the format line=<num>: <issue and proposed solution>
Your commentary must fit on a single line]]
        },
        {
            role = "user",
            content = [[
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
20 }]]
        },
        {
            role = "assistant",
            content = [[
line=4: The class name Logic is too generic. A more meaningful name could be DynamicProgramming
line=6: The variable name sc is unclear. A more meaningful name could be scanner.
line=7: The variable name n is unclear. A more meaningful name could be arraySize or numElements.
line=8: The variable name arr unclear. A more descriptive name could be inputArray or elementValues.
line=12: The variable name dp is unclear. A more informative name could be maxSum or optimalSolution.
line=13: There are no comments explaining the meaning of the dp array values and how they relate to the problem statement.
line=15: There are no comments explaining the logic and purpose of the for loop]]
        },
        {
            role = "user",
            content = [[
673    for (let i: number = 0; i < l; i++) {
674       let notAddr: boolean = false;
675       // non standard input
676       if (items[i].scriptSig && !items[i].addr) {
677         items[i].addr = 'Unparsed address [' + u++ + ']';
678         items[i].notAddr = true;
679         notAddr = true;
680       }
681
682       // non standard output
683       if (items[i].scriptPubKey && !items[i].scriptPubKey.addresses) {
684         items[i].scriptPubKey.addresses = ['Unparsed address [' + u++ + ']'];]]
        },
        {
            role = "assistant",
            content = [[
line=673: The variable name i and l are unclear and easily confused with other characters like 1. A more meaningful name could be index and length respectively.
line=674: The variable name notAddr is unclear and a double negative. An alternative could be hasUnparsedAddress.
line=676: The comment "non standard input" is not very informative. It could be more descriptive, e.g., "Check for non standard input address"
line=682: The comment "non standard output" is not very informative. It could be more descriptive, e.g., "Check for non standard output address"
line=683: The variable name items might be more informative if changed to transactions or txItems.
line=684: The array element 'Unparsed address [' + u++ + ']' could use a more descriptive comment, e.g., "Assign a unique identifier to non standard output addresses"
line=684: The variable name u is unclear. A more meaningful name could be unparsedAddressCount or unparsedAddressId.]]
        }
    }
}

return fewshot
