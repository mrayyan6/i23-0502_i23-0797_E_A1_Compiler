
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.nio.charset.StandardCharsets;

public class TestRunner {

    private static final String[] FILES = {
        "tests/test1.lang",
        "tests/test2.lang",
        "tests/test3.lang",
        "tests/test4.lang",
        "tests/test5.lang"
    };

    public static void main(String[] args) {
        StringBuilder report = new StringBuilder();
        
        for (String path : FILES) {
            report.append("========== Running " + path + " ==========\n");
            
            String src;
            try {
                src = new String(Files.readAllBytes(Paths.get(path)));
            } catch (IOException e) {
                report.append("Error reading file: " + path + "\n");
                continue;
            }

            // Run ManualScanner (Original) - EXPECTED CORRECT
            ManualScanner s1 = new ManualScanner(src);
            List<Token> t1 = s1.all();

            // Run ManualScanner1 (New) - TO VERIFY
            ManualScanner1 s2 = new ManualScanner1(src);
            List<Token> t2 = s2.all();

            // Compare
            boolean match = true;
            if (t1.size() != t2.size()) {
                report.append("[FAIL] Token count mismatch!\n");
                report.append("Original: " + t1.size() + "\n");
                report.append("New     : " + t2.size() + "\n");
                match = false;
            }

            int min = Math.min(t1.size(), t2.size());
            for (int i = 0; i < min; i++) {
                Token tok1 = t1.get(i);
                Token tok2 = t2.get(i);

                if (tok1.type() != tok2.type() || !tok1.lex().equals(tok2.lex())) {
                    report.append("[FAIL] Mismatch at index " + i + "\n");
                    report.append("Original: " + tok1 + "\n");
                    report.append("New     : " + tok2 + "\n");
                    match = false;
                    // Print context
                    if (i > 0) report.append("   Prev: " + t1.get(i-1) + "\n");
                    
                    // Limit errors per file
                    if (i > 5) {
                        report.append("... too many errors ...\n");
                        break;
                    }
                }
            }

            if (match) {
                report.append("[PASS] Output matches perfectly.\n");
            } else {
                report.append("--------------------------------------------------\n");
                report.append("Original Tokens (Partial):\n");
                for(int i=0; i<Math.min(10, t1.size()); i++) report.append(t1.get(i) + "\n");
                report.append("...\n");
                report.append("New Tokens (Partial):\n");
                for(int i=0; i<Math.min(10, t2.size()); i++) report.append(t2.get(i) + "\n");
                report.append("--------------------------------------------------\n");
            }
            report.append("\n\n");
        }
        
        try {
            System.out.println(report.toString());
            Files.write(Paths.get("comparison_results.txt"), report.toString().getBytes(StandardCharsets.UTF_8));
            System.out.println("Comparison complete. Results written to comparison_results.txt");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
