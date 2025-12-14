package notepad;

import javax.swing.JPanel;
import javax.swing.JTextPane;
import javax.swing.border.EmptyBorder;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.text.Element;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics;
import java.awt.Point;

/**
 * 텍스트 에디터 좌측에 행 번호를 표시하는 컴포넌트.
 */
public class LineNumberPane extends JPanel {
    private final JTextPane textPane;
    private static final int MARGIN = 5;

    public LineNumberPane(JTextPane textPane) {
        this.textPane = textPane;
        setBackground(new Color(240, 240, 240));
        setBorder(new EmptyBorder(0, 0, 0, MARGIN));
        
        // 폰트 동기화 및 리페인팅 트리거
        textPane.getDocument().addDocumentListener(new DocumentListener() {
            @Override public void insertUpdate(DocumentEvent e) { repaint(); }
            @Override public void removeUpdate(DocumentEvent e) { repaint(); }
            @Override public void changedUpdate(DocumentEvent e) { repaint(); }
        });
    }

    @Override
    public Dimension getPreferredSize() {
        // 줄 수에 따른 동적 너비 계산
        int lines = textPane.getDocument().getDefaultRootElement().getElementCount();
        int digits = Math.max(String.valueOf(lines).length(), 3);
        int width = getFontMetrics(getFont()).charWidth('0') * digits + (MARGIN * 2);
        return new Dimension(width, textPane.getHeight());
    }

    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        g.setFont(textPane.getFont());
        FontMetrics fm = g.getFontMetrics();
        
        Element root = textPane.getDocument().getDefaultRootElement();
        int lineCount = root.getElementCount();
        int startOffset = textPane.viewToModel2D(new Point(0, 0));
        int endOffset = textPane.viewToModel2D(new Point(0, textPane.getParent().getHeight()));
        
        // 보이는 영역만 그리기 (최적화)
        int startLine = root.getElementIndex(startOffset);
        int endLine = root.getElementIndex(endOffset);

        for (int i = startLine; i <= endLine; i++) {
            Element line = root.getElement(i);
            try {
                int y = (int) textPane.modelToView2D(line.getStartOffset()).getY();
                String lineNum = String.valueOf(i + 1);
                int stringWidth = fm.stringWidth(lineNum);
                g.drawString(lineNum, getWidth() - stringWidth - MARGIN, y + fm.getAscent());
            } catch (Exception e) {
                break;
            }
        }
    }
}