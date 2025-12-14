package notepad;

import java.nio.file.Path;

/**
 * 탭의 파일 상태를 저장하는 불변 레코드 (Java 16+). getter, toString, equals, hashCode가 자동 생성됨.
 */
public record EditorState(Path filePath, boolean isModified, boolean isDarkMode) {
	// Compact Constructor: 유효성 검증 로직 추가 가능
	public EditorState {
		if (filePath != null && !filePath.toFile().exists()) {
			// 신규 파일인 경우 로직 처리 등
		}
	}

	// 상태 변경을 위한 Wither 메서드 패턴 (불변 객체 수정 방식)
	public EditorState withModified(boolean newModified) {
		return new EditorState(filePath, newModified, isDarkMode);
	}

	public EditorState withPath(Path newPath) {
		return new EditorState(newPath, false, isDarkMode); // 저장 시 modified false
	}

	public EditorState withTheme(boolean newDarkMode) {
		return new EditorState(filePath, isModified, newDarkMode);
	}
}