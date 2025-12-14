package notepad;

import javax.swing.*;
import java.awt.BorderLayout;
import java.awt.GridLayout;
import java.nio.file.Path;
import java.util.Optional;

// 탭 정보 관리
class EditorTab extends JPanel {
    private final SmartTextPane textPane;
    private final JScrollPane scrollPane;
    private Path filePath;
    private boolean isModified;

    public EditorTab() {
        setLayout(new BorderLayout());
        textPane = new SmartTextPane();
        scrollPane = new JScrollPane(textPane);
        
        // 행 번호 뷰 추가 (II. 기능)
        scrollPane.setRowHeaderView(new LineNumberPane(textPane));
        
        add(scrollPane, BorderLayout.CENTER);
        
        textPane.getDocument().addDocumentListener(new javax.swing.event.DocumentListener() {
            public void insertUpdate(javax.swing.event.DocumentEvent e) { isModified = true; }
            public void removeUpdate(javax.swing.event.DocumentEvent e) { isModified = true; }
            public void changedUpdate(javax.swing.event.DocumentEvent e) {}
        });
    }

    public SmartTextPane getTextPane() { return textPane; }
    public Optional<Path> getFilePath() { return Optional.ofNullable(filePath); }
    public void setFilePath(Path p) { this.filePath = p; this.isModified = false; }
    public boolean isModified() { return isModified; }
}

// 찾기/바꾸기 다이얼로그
class FindReplaceDialog extends JDialog {
    private final SmartTextPane editor;
    private final JTextField searchField = new JTextField();
    private final JTextField replaceField = new JTextField();

    public FindReplaceDialog(JFrame owner, SmartTextPane editor) {
        super(owner, "찾기 및 바꾸기", false); // Non-modal
        this.editor = editor;
        setSize(350, 150);
        setLocationRelativeTo(owner);
        setLayout(new GridLayout(3, 2));

        add(new JLabel(" 찾을 내용:")); add(searchField);
        add(new JLabel(" 바꿀 내용:")); add(replaceField);

        JButton findBtn = new JButton("찾기 (F3)");
        findBtn.addActionListener(e -> findNext());
        
        JButton replaceBtn = new JButton("바꾸기");
        replaceBtn.addActionListener(e -> replace());

        add(findBtn); add(replaceBtn);
    }

    public void findNext() {
        String key = searchField.getText();
        if (key.isEmpty()) return;
        String text = editor.getText();
        int idx = text.indexOf(key, editor.getCaretPosition());
        if (idx == -1) idx = text.indexOf(key); // Wrap around

        if (idx != -1) {
            editor.select(idx, idx + key.length());
            editor.requestFocus();
        } else {
            JOptionPane.showMessageDialog(this, "찾을 수 없습니다.");
        }
    }
    
    public void replace() {
        if (editor.getSelectedText() != null) {
            editor.replaceSelection(replaceField.getText());
            findNext();
        } else {
            findNext();
        }
    }
}