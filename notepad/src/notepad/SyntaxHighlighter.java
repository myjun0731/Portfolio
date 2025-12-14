package notepad;

import javax.swing.SwingUtilities;
import javax.swing.text.StyledDocument;
import javax.swing.text.SimpleAttributeSet;
import javax.swing.text.StyleConstants;
import java.awt.Color;
import java.util.Set;
import java.util.concurrent.Executors;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Java 21 Virtual Threads를 활용한 비동기 구문 강조 처리기.
 */
public class SyntaxHighlighter {

	private static final Set<String> KEYWORDS = Set.of("public", "private", "protected", "class", "record", "interface",
			"enum", "var", "yield", "sealed", "permits", // Java 21 Keywords
			"int", "void", "if", "else", "return", "static", "final", "new");

	// 미리 컴파일된 패턴 (성능 최적화)
	private static final Pattern KEYWORD_PATTERN = Pattern.compile("\\b(" + String.join("|", KEYWORDS) + ")\\b");

	/**
	 * 가상 스레드를 사용하여 구문 강조를 수행합니다. UI 스레드(EDT)를 차단하지 않습니다.
	 */
	public static void applyAsync(StyledDocument doc, SimpleAttributeSet keywordStyle, SimpleAttributeSet normalStyle) {
		// 1. EDT에서 텍스트 추출 (Thread Safety)
		final String text;
		try {
			text = doc.getText(0, doc.getLength());
		} catch (Exception e) {
			return;
		}

		// 2. Java 21: Virtual Thread 생성 및 작업 위임
		Thread.ofVirtual().start(() -> {
			// CPU 집약적인 정규식 매칭 작업 (Background)
			Matcher matcher = KEYWORD_PATTERN.matcher(text);

			// 3. 결과 반영은 다시 EDT에서 수행
			SwingUtilities.invokeLater(() -> {
				// 기존 스타일 초기화
				doc.setCharacterAttributes(0, text.length(), normalStyle, true);

				while (matcher.find()) {
					doc.setCharacterAttributes(matcher.start(), matcher.end() - matcher.start(), keywordStyle, false);
				}
			});
		});
	}
}