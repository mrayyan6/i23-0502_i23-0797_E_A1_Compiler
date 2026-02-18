import java.io.IOException;
import java.io.StringReader;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;


/**
 * JFlexScanner.java  –  Driver for the JFlex-generated scanner (Yylex).
 * 
 * Usage:  java JFlexScanner <file.lang>
 * 
 * Produces the same output format as ManualScanner:
 *   - Token stream
 *   - Symbol table
 *   - Error report
 */
public class ScannerDriver 
{

    public static void main(String[] args) 
    {
        if (args.length < 1) 
        {
            System.err.println("Usage: java JFlexScanner <source-file>");
            System.exit(1);
        }

        String filePath = args[0];
        String source;
        try 
        {
            source = new String(Files.readAllBytes(Paths.get(filePath)));
        } 
        catch (IOException e) 
        {
            System.err.println("Error: Could not read file: " + filePath);
            System.err.println(e.getMessage());
            System.exit(1);
            return;
        }

        try 
        {
            Yylex scanner = new Yylex(new StringReader(source));
            List<Token> tokens = new ArrayList<>();

            Token t;
            do 
            {
                t = scanner.yylex();
                tokens.add(t);
            } while (t.type() != TokenType.EOF);

            // ----- Token Stream -----
            System.out.println("||============================================================|| ");
            System.out.println("||                        TOKEN STREAM                        || ");
            System.out.println("||============================================================|| ");

            for (Token tok : tokens) 
            {
                System.out.println("  " + tok);
            }

            System.out.println("||============================================================|| ");
            System.out.printf("||  Total tokens: %-45d \u2551%n", tokens.size());
            System.out.println("||============================================================|| ");

            // ----- Symbol Table -----
            scanner.syms().show();

            // ----- Errors -----
            scanner.errs().show();
        } 
        catch (IOException e) 
        {
            System.err.println("Scanner I/O error: " + e.getMessage());
            System.exit(1);
        }
    }
}