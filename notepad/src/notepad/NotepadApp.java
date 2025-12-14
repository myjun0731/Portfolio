package notepad;

import javax.swing.SwingUtilities;
import javax.swing.UIManager;

public class NotepadApp {
    public static void main(String[] args) {
        // High DPI 지원 설정
        System.setProperty("sun.java2d.uiScale", "1.0");
        SwingUtilities.invokeLater(() -> {
            try {
                UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
            } catch (Exception ignored) {}
            new MainFrame().setVisible(true);
        });
    }
}