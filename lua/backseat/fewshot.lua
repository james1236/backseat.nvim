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
- Long or complex expressions: using too many nested parentheses, long variable names, or multiple function calls in one line can make the code difficult to read and debug.
- Inconsistent naming and code style.
- Code repetition
You may suggest additional fixes. The user submits a small section of code from a larger file.
Repeat back the user's code, with any readability issues for each line listed between the tags <b!read> and </b!read>.
List the specific code replacement between <b!fix> and </b!fix> tags, with the target for replacement between <b!target> and </b!target> tags.
Any <b!read> commentary must be negative!!!]]
        },
        {
            role = "user",
            content = [[
public class Logic {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        int n = sc.nextInt();
        int[] arr = new int[n];
        for (int i = 0; i < n; i++) {
            arr[i] = sc.nextInt();
                }
        int[] dp = new int[n];
        dp[0] = arr[0];
        dp[1] = Math.max(arr[0], arr[1]);
        for (int i = 2; i < n; i++) {
            dp[i] = Math.max(dp[i - 1], dp[i - 2] + arr[i]);
        }
        System.out.println(dp[n - 1]);
    }
}]]
        },
        {
            role = "assistant",
            content = [[
public class <b!target>Logic</b!target> { <b!read> The class name "Logic" is too generic. A more meaningful name could be <b!fix>DynamicProgramming</b!fix></b!read>
    public static void main(String[] args) {
        Scanner <b!target>sc</b!target> = new Scanner(System.in); <b!read> The variable name "sc" is unclear. A more meaningful name could be <b!fix>scanner</b!fix></b!read>
        int <b!target>n</b!target> = sc.nextInt(); <b!read>The variable name "n" is unclear. A more meaningful name could be <b!fix>arraySize</b!fix> or <b!fix>numElements</b!fix></b!read>
        int[] <b!target>arr</b!target> = new int[n]; <b!read>The variable name "arr" unclear. A more descriptive name could be <b!fix>inputArray</b!fix> or  <b!fix>elementValues</b!fix></b!read>
        for (int i = 0; i < n; i++) {
            arr[i] = sc.nextInt();
        }
        int[] <b!target>dp</b!target> = new int[n]; <b!read>The variable name "dp" is unclear. A more informative name could be <b!fix>maxSum</b!fix> or <b!fix>optimalSolution</b!fix></b!read>
        dp[0] = arr[0];
        dp[1] = Math.max(arr[0], arr[1]);
        for (int i = 2; i < n; i++) {
            dp[i] = Math.max(dp[i - 1], dp[i - 2] + arr[i]); <b!read>There are no comments explaining the meaning of the dp array values and how they relate to the problem statement.</b!read>
        }
        System.out.println(dp[n - 1]);
    }
}]]
        },
        {
            role = "user",
            content = [[
   for (let i: number = 0; i < l; i++) {
      let notAddr: boolean = false;
      // non standard input
      if (items[i].scriptSig && !items[i].addr) {
        items[i].addr = 'Unparsed address [' + u++ + ']';
        items[i].notAddr = true;
        notAddr = true;
      }

      // non standard output
      if (items[i].scriptPubKey && !items[i].scriptPubKey.addresses) {
        items[i].scriptPubKey.addresses = ['Unparsed address [' + u++ + ']'];]]
        },
        {
            role = "assistant",
            content = [[
   for (let <b!target>i</b!target>: number = 0; <b!target>i</b!target> < l; <b!target>i</b!target>++) { <b!read>The variable name l is easily confused with the characters I or 1. A more meaningful name could be <b!fix>itemIndex</b!read></b!read>
      let <b!target>notAddr</b!target>: boolean = false; <b!read>The variable name notAddr is unclear and confusing since "not" makes it a double negative. A better name could be <b!fix>hasUnparsedAddress</b!fix></b!read>
      // non standard input
      if (items[i].scriptSig && !items[i].addr) {
        items[i].addr = 'Unparsed address [' + u++ + ']';
        items[i].notAddr = true;
        notAddr = true;
      }

      // non standard output
      if (items[i].scriptPubKey && !items[i].scriptPubKey.addresses) {
        items[i].<b!target>hostCapabilityVmDirectPathGen2Unsupported</b!target> = false <b!read>The variable name HostCapabilityVmDirectPathGen2Unsupported is too long and should be shortened to something like <b!fix>UnsupportedReason</b!fix></b!read>
        items[i].scriptPubKey.addresses = ['Unparsed address [' + <b!target>u</b!target>++ + ']']; <b!read>The variable name u is unclear. A more descriptive name would be <b!fix>unparsedAddressIndex</b!fix></b!read>]]
        }
    }
}

return fewshot
