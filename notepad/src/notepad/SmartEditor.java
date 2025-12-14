package notepad;

import javax.swing.JTextPane;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.text.SimpleAttributeSet;
import javax.swing.text.StyleConstants;
import javax.swing.undo.UndoManager;
import java.awt.Color;
import java.awt.Font;

public class SmartEditor extends JTextPane {

	private final UndoManager undoManager = new UndoManager();
	// Record로 상태 관리 (초기 상태: 경로 없음, 수정 안됨, 라이트 모드)
	private EditorState state = new EditorState(null, false, false);

	private final SimpleAttributeSet keywordStyle = new SimpleAttributeSet();
	private final SimpleAttributeSet normalStyle = new SimpleAttributeSet();

	public SmartEditor() {
		initializeStyles();
		initializeUi();
		setupListeners();
	}

	private void initializeStyles() {
		StyleConstants.setForeground(keywordStyle, new Color(0, 120, 215)); // Modern Blue
		StyleConstants.setBold(keywordStyle, true);
		StyleConstants.setForeground(normalStyle, Color.BLACK);
	}

	private void initializeUi() {
		setFont(new Font("Consolas", Font.PLAIN, 14));
		getDocument().addUndoableEditListener(undoManager);
	}

	private void setupListeners() {
		getDocument().addDocumentListener(new DocumentListener() {
			@Override
			public void insertUpdate(DocumentEvent e) {
				handleChange();
			}

			@Override
			public void removeUpdate(DocumentEvent e) {
				handleChange();
			}

			@Override
			public void changedUpdate(DocumentEvent e) {
			}
		});
	}

	private void handleChange() {
		if (!state.isModified()) {
			state = state.withModified(true);
		}
		// Java 21 Virtual Thread Highlighter 호출
		SyntaxHighlighter.applyAsync(getStyledDocument(), keywordStyle, normalStyle);
	}

	public void setTheme(boolean isDarkMode) {
		state = state.withTheme(isDarkMode);

		// Java 14 Switch Expression (향상된 스위치 문)
		var bgColor = isDarkMode ? new Color(30, 30, 30) : Color.WHITE;
		var fgColor = isDarkMode ? Color.WHITE : Color.BLACK;
		var caretColor = isDarkMode ? Color.WHITE : Color.BLACK;

		setBackground(bgColor);
		setCaretColor(caretColor);
		StyleConstants.setForeground(normalStyle, fgColor);

		// 강제 리프레시
		SyntaxHighlighter.applyAsync(getStyledDocument(), keywordStyle, normalStyle);
	}

	// --- Getters & Setters delegating to Record ---
	public EditorState getState() {
		return state;
	}

	public void setState(EditorState state) {
		this.state = state;
	}

	public UndoManager getUndoManager() {
		return undoManager;
	}
}