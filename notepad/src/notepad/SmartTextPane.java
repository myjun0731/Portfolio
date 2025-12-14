package notepad;

import javax.swing.JTextPane;
import javax.swing.SwingUtilities;
import javax.swing.text.*;
import javax.swing.undo.UndoManager;
import java.awt.Color;
import java.awt.Font;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class SmartTextPane extends JTextPane {
    
    private final UndoManager undoManager = new UndoManager();
    private final SimpleAttributeSet keywordStyle = new SimpleAttributeSet();
    private final SimpleAttributeSet normalStyle = new SimpleAttributeSet();
    private float zoomFactor = 1.0f;
    private int baseFontSize = 14;
    private boolean showInvisibles = false;

    // Java + Python Keywords
    private static final Set<String> KEYWORDS = Set.of(
        "public", "private", "class", "void", "int", "if", "else", "return", "import", // Java
        "def", "print", "elif", "None", "True", "False" // Python
    );
    private static final Pattern KEYWORD_PATTERN = 
        Pattern.compile("\\b(" + String.join("|", KEYWORDS) + ")\\b");

    public SmartTextPane() {
        initStyles();
        initBehavior();
    }

    private void initStyles() {
        setFont(new Font("Consolas", Font.PLAIN, baseFontSize));
        StyleConstants.setForeground(keywordStyle, Color.BLUE);
        StyleConstants.setBold(keywordStyle, true);
        StyleConstants.setForeground(normalStyle, Color.BLACK);
        
        getDocument().addUndoableEditListener(undoManager);
        
        // 내용 변경 시 구문 강조 (Virtual Thread 사용)
        getDocument().addDocumentListener(new javax.swing.event.DocumentListener() {
            public void insertUpdate(javax.swing.event.DocumentEvent e) { applySyntaxHighlighting(); }
            public void removeUpdate(javax.swing.event.DocumentEvent e) { applySyntaxHighlighting(); }
            public void changedUpdate(javax.swing.event.DocumentEvent e) {}
        });
    }

    private void initBehavior() {
        // 자동 들여쓰기 구현
        addKeyListener(new KeyAdapter() {
            @Override
            public void keyPressed(KeyEvent e) {
                if (e.getKeyCode() == KeyEvent.VK_ENTER) {
                    handleAutoIndent(e);
                }
            }
        });
    }

    private void handleAutoIndent(KeyEvent e) {
        try {
            int pos = getCaretPosition();
            int lineIndex = getDocument().getDefaultRootElement().getElementIndex(pos);
            Element lineElement = getDocument().getDefaultRootElement().getElement(lineIndex);
            int start = lineElement.getStartOffset();
            int end = lineElement.getEndOffset();
            
            String text = getDocument().getText(start, end - start);
            
            // 이전 줄의 공백(Tabs/Spaces) 계산
            StringBuilder indent = new StringBuilder();
            for (char c : text.toCharArray()) {
                if (c == ' ' || c == '\t') indent.append(c);
                else break;
            }
            
            // 엔터 처리 후 들여쓰기 삽입 (SwingUtilities.invokeLater로 순서 보장)
            if (indent.length() > 0) {
                // 기본 엔터 동작은 JTextPane이 처리하므로, 그 후에 들여쓰기 텍스트 삽입
                SwingUtilities.invokeLater(() -> {
                    try {
                        getDocument().insertString(getCaretPosition(), indent.toString(), null);
                    } catch (BadLocationException ignored) {}
                });
            }
        } catch (BadLocationException ex) {
            ex.printStackTrace();
        }
    }

    private void applySyntaxHighlighting() {
        Thread.ofVirtual().start(() -> {
            try {
                String text = getDocument().getText(0, getDocument().getLength());
                Matcher matcher = KEYWORD_PATTERN.matcher(text);
                
                SwingUtilities.invokeLater(() -> {
                    StyledDocument doc = getStyledDocument();
                    // 전체 초기화 (성능 최적화를 위해 변경된 부분만 해야 하지만, 데모는 전체)
                    doc.setCharacterAttributes(0, text.length(), normalStyle, true);
                    
                    while (matcher.find()) {
                        doc.setCharacterAttributes(
                            matcher.start(), 
                            matcher.end() - matcher.start(), 
                            keywordStyle, 
                            false
                        );
                    }
                });
            } catch (Exception ignored) {}
        });
    }

    // --- II. 기능 구현 메서드들 ---

    public void zoom(boolean in) {
        if (in) zoomFactor += 0.1f;
        else zoomFactor = Math.max(0.5f, zoomFactor - 0.1f);
        
        setFont(new Font("Consolas", Font.PLAIN, (int)(baseFontSize * zoomFactor)));
    }

    public void toggleComment() {
        // 선택된 영역 주석 처리 (간단 구현: 줄 앞에 // 추가/제거)
        try {
            int start = getSelectionStart();
            int end = getSelectionEnd();
            StyledDocument doc = getStyledDocument();
            Element root = doc.getDefaultRootElement();
            int startLine = root.getElementIndex(start);
            int endLine = root.getElementIndex(end);

            for (int i = startLine; i <= endLine; i++) {
                Element line = root.getElement(i);
                String lineText = doc.getText(line.getStartOffset(), 2);
                if ("//".equals(lineText)) {
                    doc.remove(line.getStartOffset(), 2); // 해제
                } else {
                    doc.insertString(line.getStartOffset(), "//", null); // 주석
                }
            }
        } catch (BadLocationException e) {
            e.printStackTrace();
        }
    }

    public void convertCase(boolean toUpper) {
        String sel = getSelectedText();
        if (sel == null) return;
        replaceSelection(toUpper ? sel.toUpperCase() : sel.toLowerCase());
    }
    
    public void setShowInvisibles(boolean show) {
        this.showInvisibles = show;
        // 실제 구현 시: Custom EditorKit이나 Painter를 사용해야 함.
        // 여기서는 개념적 구현으로 대체 (복잡도 제한)
        repaint(); 
    }

    public UndoManager getUndoManager() { return undoManager; }
}