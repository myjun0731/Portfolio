package notepad;

import javax.swing.*;
import java.awt.GridLayout;
import java.util.Locale;

public class SearchDialog extends JDialog {

	private final SmartEditor editor;
	private final JTextField searchField = new JTextField(15);
	private final JTextField replaceField = new JTextField(15);
	private final JCheckBox caseCheck = new JCheckBox("대소문자 구분");

	public SearchDialog(JFrame owner, SmartEditor editor) {
		super(owner, "찾기 및 바꾸기", false);
		this.editor = editor;
		initUi();
		pack();
		setLocationRelativeTo(owner);
	}

	private void initUi() {
		setLayout(new GridLayout(4, 2, 5, 5));

		add(new JLabel(" 찾을 내용:"));
		add(searchField);
		add(new JLabel(" 바꿀 내용:"));
		add(replaceField);
		add(caseCheck);
		add(new JLabel("")); // Placeholder

		var btnFind = new JButton("다음 찾기");
		var btnReplace = new JButton("바꾸기");

		btnFind.addActionListener(e -> performAction("FIND"));
		btnReplace.addActionListener(e -> performAction("REPLACE"));

		add(btnFind);
		add(btnReplace);
	}

	private void performAction(String actionType) {
		String keyword = searchField.getText();
		if (keyword.isEmpty())
			return;

		// Java 14 Switch Expression + Logic
		switch (actionType) {
		case "FIND" -> findNext(keyword);
		case "REPLACE" -> {
			replaceCurrent();
			findNext(keyword);
		}
		default -> throw new IllegalArgumentException("Unknown action: " + actionType);
		}
	}

	private void findNext(String keyword) {
		String content = editor.getText();
		boolean caseSensitive = caseCheck.isSelected();

		// 삼항 연산자 가독성 정리
		String target = caseSensitive ? content : content.toLowerCase(Locale.ROOT);
		String key = caseSensitive ? keyword : keyword.toLowerCase(Locale.ROOT);

		int startPos = editor.getCaretPosition();
		int idx = target.indexOf(key, startPos);

		if (idx == -1) {
			// 처음부터 다시 검색 (Wrap around)
			idx = target.indexOf(key);
		}

		if (idx != -1) {
			editor.setCaretPosition(idx + keyword.length());
			editor.select(idx, idx + keyword.length());
			editor.requestFocusInWindow();
		} else {
			JOptionPane.showMessageDialog(this, "찾을 수 없습니다: " + keyword);
		}
	}

	private void replaceCurrent() {
		String selection = editor.getSelectedText();
		if (selection != null) {
			editor.replaceSelection(replaceField.getText());
		}
	}
}