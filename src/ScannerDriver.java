import java.io.*;
import java.util.*;

/**
 * Test Driver for JFlex Scanner
 * CS4031 - Compiler Construction Assignment 01
 * 
 * This class demonstrates how to use the JFlex-generated scanner (Yylex)
 * and provides utilities for testing and displaying results.
 */
public class ScannerDriver {
    
    public static void main(String[] args) {
        if (args.length < 1) {
            System.out.println("Usage: java ScannerDriver <input_file>");
            System.out.println("Example: java ScannerDriver test1.lang");
            return;
        }
        
        String filename = args[0];
        
        try {
            // Create scanner with input file
            FileReader reader = new FileReader(filename);
            Yylex scanner = new Yylex(reader);
            
            System.out.println("||============================================================||");
            System.out.println("||              JFLEX LEXICAL ANALYZER OUTPUT                 ||");
            System.out.println("||============================================================||");
            System.out.println("File: " + filename);
            System.out.println("||============================================================||");
            
            // Scan all tokens
            Token token;
            List<Token> allTokens = new ArrayList<>();
            
            while (true) {
                token = scanner.yylex();
                if (token == null || token.type() == TokenType.EOF) {
                    break;
                }
                allTokens.add(token);
                System.out.println(token);
            }
            
            // Display statistics
            displayStatistics(scanner, allTokens);
            
            // Build and display symbol table
            buildSymbolTable(allTokens);
            
            reader.close();
            
        } catch (FileNotFoundException e) {
            System.err.println("Error: File '" + filename + "' not found.");
        } catch (IOException e) {
            System.err.println("Error reading file: " + e.getMessage());
        }
    }
    
    /**
     * Display scanning statistics
     */
    private static void displayStatistics(Yylex scanner, List<Token> tokens) {
        System.out.println("\n||============================================================||");
        System.out.println("||                      STATISTICS                            ||");
        System.out.println("||============================================================||");
        
        // Count tokens by type
        Map<TokenType, Integer> tokenTypeCounts = new HashMap<>();
        for (Token token : tokens) {
            tokenTypeCounts.put(token.type(), 
                tokenTypeCounts.getOrDefault(token.type(), 0) + 1);
        }
        
        System.out.println("Total Tokens: " + scanner.getTokenCount());
        System.out.println("Comments Removed: " + scanner.getCommentCount());
        System.out.println("\nToken Type Distribution:");
        System.out.println("------------------------");
        
        // Sort and display token type counts
        tokenTypeCounts.entrySet().stream()
            .sorted(Map.Entry.comparingByKey())
            .forEach(entry -> 
                System.out.printf("  %-20s : %d%n", entry.getKey(), entry.getValue())
            );
        
        System.out.println("||============================================================||");
    }
    
    /**
     * Build and display symbol table from tokens
     */
    private static void buildSymbolTable(List<Token> tokens) {
        SymbolTable symbolTable = new SymbolTable();
        
        // Add all identifiers to symbol table
        for (Token token : tokens) {
            if (token.type() == TokenType.IDENTIFIER) {
                // Add identifier (first occurrence wins)
                symbolTable.add(token.lex(), "UNKNOWN", "global", token.ln());
            }
        }
        
        // Display symbol table
        symbolTable.show();
    }
    
    /**
     * Compare two token lists (useful for Part 2 Task 2.3)
     */
    public static void compareTokens(List<Token> manual, List<Token> jflex) {
        System.out.println("\n||============================================================||");
        System.out.println("||                  SCANNER COMPARISON                        ||");
        System.out.println("||============================================================||");
        
        if (manual.size() != jflex.size()) {
            System.out.println("WARNING: Token count mismatch!");
            System.out.println("Manual Scanner: " + manual.size() + " tokens");
            System.out.println("JFlex Scanner: " + jflex.size() + " tokens");
        } else {
            System.out.println("✓ Token count matches: " + manual.size() + " tokens");
        }
        
        // Compare individual tokens
        int differences = 0;
        int compareLimit = Math.min(manual.size(), jflex.size());
        
        for (int i = 0; i < compareLimit; i++) {
            Token m = manual.get(i);
            Token j = jflex.get(i);
            
            if (!m.type().equals(j.type()) || !m.lex().equals(j.lex())) {
                differences++;
                System.out.println("\nDifference at token #" + (i + 1) + ":");
                System.out.println("  Manual: " + m);
                System.out.println("  JFlex:  " + j);
            }
        }
        
        if (differences == 0) {
            System.out.println("✓ All tokens match perfectly!");
        } else {
            System.out.println("\n⚠ Found " + differences + " differences");
        }
        
        System.out.println("||============================================================||");
    }
}
