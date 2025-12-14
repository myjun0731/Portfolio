package notepad;

import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;
import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;
import java.awt.print.PrinterException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class MainFrame extends JFrame {
    
    private final JTabbedPane tabbedPane = new JTabbedPane();
    private final JLabel statusLabel = new JLabel(" Ready ");
    private FindReplaceDialog findDialog;

    public MainFrame() {
        setTitle("Java Swing Notepad");
        setSize(1000, 700);
        setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
        setLocationRelativeTo(null);
        
        initUi();
        addNewTab();
    }

    private void initUi() {
        setLayout(new BorderLayout());
        add(tabbedPane, BorderLayout.CENTER);
        
        // 상태 표시줄
        var statusPanel = new JPanel(new BorderLayout());
        statusPanel.setBorder(BorderFactory.createEtchedBorder());
        statusPanel.add(statusLabel, BorderLayout.WEST);
        add(statusPanel, BorderLayout.SOUTH);

        setJMenuBar(createMenuBar());
        
        // 종료 이벤트
        addWindowListener(new java.awt.event.WindowAdapter() {
            public void windowClosing(java.awt.event.WindowEvent e) { exit(); }
        });
    }

    private JMenuBar createMenuBar() {
        var mb = new JMenuBar();
        mb.add(createFileMenu());
        mb.add(createEditMenu());
        mb.add(createViewMenu()); // 서식/보기 메뉴
        return mb;
    }

    private JMenu createFileMenu() {
        var menu = new JMenu("파일(F)");
        menu.setMnemonic(KeyEvent.VK_F);
        
        addItem(menu, "새 파일 (Ctrl+N)", KeyEvent.VK_N, e -> addNewTab());
        addItem(menu, "열기 (Ctrl+O)", KeyEvent.VK_O, e -> openFile());
        addItem(menu, "저장 (Ctrl+S)", KeyEvent.VK_S, e -> saveFile(false));
        addItem(menu, "다른 이름으로 저장", -1, e -> saveFile(true));
        menu.addSeparator();
        addItem(menu, "인쇄 (Ctrl+P)", KeyEvent.VK_P, e -> printFile());
        menu.addSeparator();
        addItem(menu, "끝내기", KeyEvent.VK_F4, true, e -> exit()); // Alt+F4 handling
        
        return menu;
    }

 // [수정 1] 편집 메뉴 생성 로직 (매개변수 0 -> false 로 수정)
    private JMenu createEditMenu() {
        var menu = new JMenu("편집(E)");
        menu.setMnemonic(KeyEvent.VK_E);
        
        addItem(menu, "실행 취소 (Ctrl+Z)", KeyEvent.VK_Z, e -> {
            if (getCurrentPane() != null) getCurrentPane().getUndoManager().undo();
        });
        addItem(menu, "다시 실행 (Ctrl+Y)", KeyEvent.VK_Y, e -> {
            if (getCurrentPane() != null) getCurrentPane().getUndoManager().redo();
        });
        menu.addSeparator();
        
        addItem(menu, "찾기/바꾸기 (Ctrl+F)", KeyEvent.VK_F, e -> showFindDialog());
        
        // 오류 수정 부분: 4번째 인자를 0에서 false로 변경하고, 내부에서 마스크 처리
        addItem(menu, "다음 찾기 (F3)", KeyEvent.VK_F3, false, e -> { 
            if(findDialog != null) findDialog.findNext(); 
        });
        
        addItem(menu, "이동 (Ctrl+G)", KeyEvent.VK_G, e -> goToLine());
        menu.addSeparator();
        
        // 오류 수정 부분: 4번째 인자를 0에서 false로 변경
        addItem(menu, "날짜/시간 (F5)", KeyEvent.VK_F5, false, e -> insertDate());
        
        menu.addSeparator();
        
        // 고급 편집 기능
        var advMenu = new JMenu("고급 기능");
        addItem(advMenu, "대문자로 변환", -1, e -> {
            if (getCurrentPane() != null) getCurrentPane().convertCase(true);
        });
        addItem(advMenu, "소문자로 변환", -1, e -> {
            if (getCurrentPane() != null) getCurrentPane().convertCase(false);
        });
        addItem(advMenu, "주석 처리/해제", -1, e -> {
            if (getCurrentPane() != null) getCurrentPane().toggleComment();
        });
        menu.add(advMenu);
        
        return menu;
    }


    private JMenu createViewMenu() {
        var menu = new JMenu("보기/서식(V)");
        menu.setMnemonic(KeyEvent.VK_V);
        
        addItem(menu, "글꼴 설정...", -1, e -> changeFont());
        var wrapItem = new JCheckBoxMenuItem("자동 줄 바꿈");
        wrapItem.addActionListener(e -> JOptionPane.showMessageDialog(this, "JTextPane Wrap 구현 필요"));
        menu.add(wrapItem);
        
        menu.addSeparator();
        // II. 줌 기능
        addItem(menu, "확대 (Ctrl+Plus)", KeyEvent.VK_EQUALS, e -> getCurrentPane().zoom(true));
        addItem(menu, "축소 (Ctrl+Minus)", KeyEvent.VK_MINUS, e -> getCurrentPane().zoom(false));
        
        return menu;
    }
    
    // --- Helper Methods ---

    private void addItem(JMenu m, String title, int key, java.awt.event.ActionListener al) {
        addItem(m, title, key, false, al);
    }
    
    // [수정 2] 헬퍼 메서드 로직 개선 (Function Key 예외 처리 추가)
    private void addItem(JMenu m, String title, int key, boolean isAlt, java.awt.event.ActionListener al) {
        var item = new JMenuItem(title);
        
        if (key != -1) {
            int mask;
            // F3, F5 같은 Function Key는 Ctrl/Alt 조합 없이 단독으로 사용
            if (key == KeyEvent.VK_F3 || key == KeyEvent.VK_F5) {
                mask = 0; 
            } else {
                // 그 외에는 Alt 여부에 따라 마스크 설정 (기본은 Ctrl)
                mask = isAlt ? ActionEvent.ALT_MASK : ActionEvent.CTRL_MASK;
            }
            item.setAccelerator(KeyStroke.getKeyStroke(key, mask));
        }
        
        item.addActionListener(al);
        m.add(item);
    }

    private SmartTextPane getCurrentPane() {
        if (tabbedPane.getSelectedComponent() instanceof EditorTab tab) {
            return tab.getTextPane();
        }
        return null;
    }

    // --- Actions ---

    private void addNewTab() {
        var tab = new EditorTab();
        tabbedPane.addTab("제목 없음", tab);
        tabbedPane.setSelectedComponent(tab);
        updateStatus("새 파일 생성됨");
    }

    private void openFile() {
        var chooser = new JFileChooser();
        if (chooser.showOpenDialog(this) == JFileChooser.APPROVE_OPTION) {
            Path p = chooser.getSelectedFile().toPath();
            try {
                String content = Files.readString(p);
                addNewTab();
                EditorTab tab = (EditorTab) tabbedPane.getSelectedComponent();
                tab.getTextPane().setText(content);
                tab.getTextPane().setCaretPosition(0); // 맨 위로
                tab.setFilePath(p);
                tabbedPane.setTitleAt(tabbedPane.getSelectedIndex(), p.getFileName().toString());
                updateStatus("파일 열림: " + p);
            } catch (Exception e) {
                JOptionPane.showMessageDialog(this, "열기 실패: " + e.getMessage());
            }
        }
    }

    private void saveFile(boolean saveAs) {
        EditorTab tab = (EditorTab) tabbedPane.getSelectedComponent();
        if (tab == null) return;
        
        Path p = tab.getFilePath().orElse(null);
        if (p == null || saveAs) {
            var chooser = new JFileChooser();
            if (chooser.showSaveDialog(this) == JFileChooser.APPROVE_OPTION) {
                p = chooser.getSelectedFile().toPath();
            } else return;
        }
        
        try {
            Files.writeString(p, tab.getTextPane().getText());
            tab.setFilePath(p);
            tabbedPane.setTitleAt(tabbedPane.getSelectedIndex(), p.getFileName().toString());
            updateStatus("저장됨: " + p);
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "저장 실패");
        }
    }
    
    private void printFile() {
        try {
            SmartTextPane p = getCurrentPane();
            if (p != null) p.print();
        } catch (PrinterException e) {
            e.printStackTrace();
        }
    }
    
    private void showFindDialog() {
        if (findDialog == null) {
            findDialog = new FindReplaceDialog(this, getCurrentPane());
        }
        findDialog.setVisible(true);
    }
    
    private void goToLine() {
        String input = JOptionPane.showInputDialog(this, "이동할 줄 번호:");
        try {
            int line = Integer.parseInt(input);
            SmartTextPane p = getCurrentPane();
            var root = p.getDocument().getDefaultRootElement();
            if (line > 0 && line <= root.getElementCount()) {
                p.setCaretPosition(root.getElement(line - 1).getStartOffset());
                p.requestFocus();
            }
        } catch (Exception ignored) {}
    }
    
    private void insertDate() {
        try {
            getCurrentPane().getDocument().insertString(
                getCurrentPane().getCaretPosition(),
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")),
                null
            );
        } catch (Exception ignored) {}
    }
    
    private void changeFont() {
        // 간단한 폰트 사이즈 변경 (정식 구현은 다이얼로그 필요)
        String size = JOptionPane.showInputDialog("폰트 크기 입력 (예: 16):");
        try {
            int s = Integer.parseInt(size);
            getCurrentPane().setFont(new java.awt.Font("Consolas", java.awt.Font.PLAIN, s));
        } catch (Exception ignored) {}
    }

    private void updateStatus(String msg) {
        statusLabel.setText(" " + msg);
    }

    private void exit() {
        // 종료 전 확인 (간략화)
        if (JOptionPane.showConfirmDialog(this, "종료하시겠습니까?", "종료", JOptionPane.YES_NO_OPTION) == JOptionPane.YES_OPTION) {
            System.exit(0);
        }
    }
}